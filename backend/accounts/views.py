from rest_framework.response import Response
from rest_framework import status, generics
from rest_framework.decorators import api_view
from rest_framework.views import APIView
from django.contrib.auth import get_user_model, authenticate
from django.utils import timezone
from rest_framework_simplejwt.tokens import RefreshToken
from django.conf import settings
from postmarker.core import PostmarkClient 
import random
import uuid
import string
from datetime import timedelta
from .models import Carpark, Reservation, Payment
from .serializers import ReservationSerializer, PaymentSerializer
from .serializers import RegisterSerializer, LoginSerializer
# Remove this circular import:
# from .views import verifier_matricule
from django.http import JsonResponse
# from .models import Parking
from django.views.decorators.csrf import csrf_exempt
import json
# from .models import Parking, Reservation

import math
import requests
from rest_framework import status

from .serializers import CarparkSerializer

User = get_user_model()

# ✅ Vue pour l'inscription
class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer

    def perform_create(self, serializer):
        user = serializer.save()
        user.verification_code = self.generate_verification_code()
        user.code_expires_at = timezone.now() + timedelta(minutes=10)
        user.verification_attempts = 0
        user.save()
        self.send_verification_email(user)

    def generate_verification_code(self):
        return ''.join(random.choices(string.digits, k=6))

    def send_verification_email(self, user):
        postmark = PostmarkClient(server_token=settings.POSTMARK_SERVER_TOKEN)
        postmark.emails.send(
            From="selma.abdeslem.0802@univ-sba.dz",
            To=user.email,
            Subject="Verify your email",
            HtmlBody=f"""
                <p>Your verification code is: <strong>{user.verification_code}</strong></p>
                <p>This code expires in 10 minutes. Enter it in the app to verify your email.</p>
            """,
        )

# ✅ Vue pour la vérification de l'email
class VerifyEmailView(APIView):
    def post(self, request):
        email = request.data.get("email")
        code = request.data.get("code")

        try:
            user = User.objects.get(email=email)

            if user.verification_attempts >= 5:
                return Response({"error": "Too many failed attempts. Please request a new code."}, status=status.HTTP_403_FORBIDDEN)
            
            if timezone.now() > user.code_expires_at:
                return Response({"error": "Verification code expired. Please request a new one."}, status=status.HTTP_400_BAD_REQUEST)
            
            if str(user.verification_code).strip() == str(code).strip():
                user.is_verified = True
                user.verification_code = None
                user.code_expires_at = None
                user.verification_attempts = 0
                user.save()
                return Response({"message": "Email verified successfully", "username": user.username}, status=status.HTTP_200_OK)
            else:
                user.verification_attempts += 1
                user.save()
                return Response({"error": "Invalid verification code"}, status=status.HTTP_400_BAD_REQUEST)

        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

# ✅ Vue pour le login
# ✅ Vue pour le login avec JWT
class LoginView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data["email"]
            password = serializer.validated_data["password"]

            try:
                user = User.objects.get(email=email)
            except User.DoesNotExist:
                return Response({"error": "Invalid email or password"}, status=status.HTTP_400_BAD_REQUEST)

            if not user.check_password(password):
                return Response({"error": "Invalid email or password"}, status=status.HTTP_400_BAD_REQUEST)

            if not user.is_verified:
                return Response({"error": "Email not verified. Please check your inbox."}, status=status.HTTP_403_FORBIDDEN)

            # ✅ Générer un token JWT
            refresh = RefreshToken.for_user(user)
            access_token = str(refresh.access_token)

            # ✅ Retourne les infos de l'utilisateur + le token JWT
            return Response({
                "message": "Login successful",
                "user": {
                    "id": user.id,
                    "email": user.email,
                    "username": user.username
                },
                "token": access_token,  # 🔹 Ajout du token JWT
            }, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# filepath: c:\src\flutter_app\appone\backend\accounts\views.py
# Vue pour récupérer tous les parkings
@api_view(['GET'])
def carparks(request):
    carparks = Carpark.objects.filter(is_active=True)
    serializer = CarparkSerializer(carparks, many=True)
    return Response(serializer.data)

# Vue pour récupérer les parkings à proximité
@api_view(['GET'])
def nearby_carparks(request):
    try:
        lat = float(request.query_params.get('lat', 0))
        lng = float(request.query_params.get('lng', 0))
    except (TypeError, ValueError):
        return Response({'error': 'Invalid or missing latitude/longitude'}, status=400)

    # Récupérer tous les parkings actifs
    carparks = Carpark.objects.filter(is_active=True)
    
    # Calculer la distance pour chaque parking
    parking_data = []
    for parking in carparks:
        distance = calculate_distance(lat, lng, parking.latitude, parking.longitude)
        
        # Ajouter les données du parking avec la distance
        parking_dict = CarparkSerializer(parking).data
        parking_dict['distance_from_user'] = distance
        parking_data.append(parking_dict)
    
    # Trier par distance
    parking_data.sort(key=lambda x: x['distance_from_user'])
    
    return Response(parking_data)

def calculate_distance(lat1, lon1, lat2, lon2):
    # Earth's radius in km
    R = 6371.0
    
    # Convert to radians
    lat1_rad = math.radians(lat1)
    lon1_rad = math.radians(lon1)
    lat2_rad = math.radians(lat2)
    lon2_rad = math.radians(lon2)
    
    # Differences
    dlon = lon2_rad - lon1_rad
    dlat = lat2_rad - lat1_rad
    
    # Haversine formula
    a = math.sin(dlat / 2)**2 + math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    distance = R * c
    
    return distance

# Mise à jour de la vue de réservation pour inclure le parking
class ReservationView(APIView):
    def post(self, request, *args, **kwargs):
        # Récupérer les données de la requête
        carpark_id = request.data.get('carpark_id')
        plate_number = request.data.get('plate_number')
        duration = request.data.get('duration')  # Durée en heures directement
        color = request.data.get('color')

        # Vérifier que le parking existe
        try:
            carpark = Carpark.objects.get(id=carpark_id, is_active=True)
        except Carpark.DoesNotExist:
            return Response({"error": "Parking non trouvé ou inactif"}, status=status.HTTP_404_NOT_FOUND)

        # Vérifier la disponibilité des places
        if carpark.available_spots <= 0:
            return Response({"error": "Aucune place disponible dans ce parking"}, status=status.HTTP_400_BAD_REQUEST)

        # Calculer le prix en fonction de la durée et du tarif du parking
        price = float(carpark.price_per_hour) * float(duration)

        # Créer une nouvelle réservation
        reservation = Reservation.objects.create(
            carpark=carpark,
            plate_number=plate_number,
            duration=duration,
            color=color,
            price=price
        )

        # Mettre à jour le nombre de places disponibles
        carpark.available_spots -= 1
        carpark.save()

        # Sérialiser la réservation
        serializer = ReservationSerializer(reservation)

        # Retourner la réponse avec les données de la réservation
        return Response(serializer.data, status=status.HTTP_201_CREATED)

# Mise à jour de la vue de paiement pour inclure le parking
class ProcessPaymentView(APIView):
    def post(self, request, *args, **kwargs):
        # Récupérer les données de la réservation
        carpark_id = request.data.get('carpark_id')
        plate_number = request.data.get('plate_number')
        color = request.data.get('color')
        duration = request.data.get('duration')
        price = request.data.get('price')
        
        # Données de la carte
        card_number = request.data.get('card_number')
        card_expiry = request.data.get('card_expiry')
        card_cvv = request.data.get('card_cvv')
        card_name = request.data.get('card_name')
        
        # Validation de base
        if not all([carpark_id, plate_number, color, duration, price, card_number, card_expiry, card_cvv, card_name]):
            return Response(
                {"error": "Toutes les informations sont nécessaires pour le paiement"}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Vérifier que le parking existe
            try:
                carpark = Carpark.objects.get(id=carpark_id, is_active=True)
            except Carpark.DoesNotExist:
                return Response({"error": "Parking non trouvé ou inactif"}, status=status.HTTP_404_NOT_FOUND)

            # Vérifier la disponibilité des places
            if carpark.available_spots <= 0:
                return Response({"error": "Aucune place disponible dans ce parking"}, status=status.HTTP_400_BAD_REQUEST)
                
            # 1. Créer la réservation
            reservation = Reservation.objects.create(
                carpark=carpark,
                plate_number=plate_number,
                color=color,
                duration=duration,
                price=price
            )
            
            # 2. Simuler le traitement du paiement
            payment_success = self.process_card_payment(card_number, card_expiry, card_cvv, card_name, price)
            
            if payment_success:
                # 3. Enregistrer le paiement réussi
                transaction_id = f"TX-{uuid.uuid4().hex[:8].upper()}"
                payment = Payment.objects.create(
                    reservation=reservation,
                    transaction_id=transaction_id,
                    amount=price,
                    status='completed',
                    card_last4=card_number[-4:]
                )
                
                # 4. Mettre à jour le nombre de places disponibles
                carpark.available_spots -= 1
                carpark.save()
                
                # Préparer la réponse
                reservation_data = ReservationSerializer(reservation).data
                payment_data = PaymentSerializer(payment).data
                
                return Response({
                    "success": True,
                    "message": "Paiement traité avec succès",
                    "transaction_id": transaction_id,
                    "reservation": reservation_data,
                    "payment": payment_data
                }, status=status.HTTP_200_OK)
            else:
                # Le paiement a échoué, supprimer la réservation
                reservation.delete()
                return Response({
                    "success": False,
                    "message": "Le paiement a échoué. Veuillez vérifier vos informations et réessayer."
                }, status=status.HTTP_400_BAD_REQUEST)
                
        except Exception as e:
            return Response({
                "success": False,
                "message": f"Une erreur est survenue: {str(e)}"
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    def process_card_payment(self, card_number, card_expiry, card_cvv, card_name, amount):
        """
        Simuler le traitement d'un paiement par carte
        En production, utilisez un processeur de paiement comme Stripe
        """
        # Validation simplifiée
        if len(card_number) < 13 or not card_number.isdigit():
            return False
            
        if not card_expiry or '/' not in card_expiry:
            return False
            
        if not card_cvv or len(card_cvv) < 3:
            return False
            
        # En environnement réel, intégrez ici la logique du processeur de paiement
        # Ici, simulons un paiement qui réussit toujours
        return True
##verificatioon 
@api_view(['GET'])
def verifier_matricule(request):
    if request.method == "GET":
        matricule = request.GET.get("matricule")
        if not matricule:
            return JsonResponse({"success": False, "error": "Matricule non fourni"})

        # Rechercher une réservation active
        # Fix the field name here - it's plate_number not matricule
        existe = Reservation.objects.filter(plate_number__iexact=matricule).exists()

        return JsonResponse({"success": True, "existe": existe})