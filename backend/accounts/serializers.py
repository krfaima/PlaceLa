from rest_framework import serializers
from django.contrib.auth.models import User
# from django.contrib.auth.models import AbstractUser
from .models import CustomUser, Carpark, Reservation, Payment, UserProfile, Vehicle, GPSCoordinate

class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'email', 'username', 'password']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = CustomUser.objects.create_user(**validated_data)
        return user

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

class CarparkSerializer(serializers.ModelSerializer):
    distance_from_user = serializers.FloatField(required=False, read_only=True)
    
    class Meta:
        model = Carpark
        fields = [
            'id', 'name', 'address', 'city', 'latitude', 'longitude',
            'total_spots', 'available_spots', 'price_per_hour',
            'is_active', 'distance_from_user'
        ]

class ReservationSerializer(serializers.ModelSerializer):
    carpark_name = serializers.ReadOnlyField(source='carpark.name')
    
    class Meta:
        model = Reservation
        fields = [
            'id', 'carpark', 'carpark_name', 'plate_number', 'duration',
            'color', 'price', 'created_at', 'is_active'
        ]

class PaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Payment
        fields = [
            'id', 'reservation', 'transaction_id', 'amount', 'status', 'card_last4'
        ]
class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = '__all__'

class VehicleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vehicle
        fields = '__all__'

class GPSCoordinateSerializer(serializers.ModelSerializer):
    class Meta:
        model = GPSCoordinate
        fields = '__all__'
# class FullUserProfileSerializer(serializers.ModelSerializer):
#     profile = UserProfileSerializer(source='userprofile')
#     vehicles = VehicleSerializer(many=True)
#     gps_coordinates = GPSCoordinateSerializer(many=True)
#     reservations = ReservationSerializer(many=True)
#     payments = PaymentSerializer(many=True)

#     class Meta:
#         model = User
#         fields = ['id', 'username', 'email', 'profile', 'vehicles', 'gps_coordinates', 'reservations', 'payments']
# 1. First, fix the FullUserProfileSerializer:
class FullUserProfileSerializer(serializers.ModelSerializer):
    # Use required=False to handle cases where a user might not have a profile yet
    profile = UserProfileSerializer(source='userprofile', required=False)
    
    # CustomUser has a related_name="reservations" for Reservation model
    reservations = ReservationSerializer(many=True, read_only=True)
    
    # These fields need related_name attributes in their models
    # vehicles is OneToOneField so shouldn't use many=True
    vehicle = VehicleSerializer(source='vehicle', required=False, read_only=True)
    gps_coordinate = GPSCoordinateSerializer(source='gpscoordinate', required=False, read_only=True)
    
    # Get payments through reservations
    class Meta:
        model = CustomUser  # Use CustomUser instead of User
        fields = ['id', 'username', 'email', 'profile', 'vehicle', 'gps_coordinate', 'reservations']