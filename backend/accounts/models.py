from django.contrib.auth.models import AbstractUser
from django.db import models
from datetime import datetime, timedelta

class CustomUser(AbstractUser):
    email = models.EmailField(unique=True)
    is_verified = models.BooleanField(default=False)
    verification_code = models.CharField(max_length=6, null=True, blank=True)
    code_expires_at = models.DateTimeField(null=True, blank=True)
    verification_attempts = models.IntegerField(default=0)  # Limite d'essais

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    def generate_verification_code(self):
        """Génère un code de vérification à 6 chiffres"""
        import random
        self.verification_code = f"{random.randint(100000, 999999)}"
        self.code_expires_at = datetime.now() + timedelta(minutes=10)  # Expire dans 10 minutes
        self.verification_attempts = 0  # Réinitialise les tentatives
        self.save()

class Carpark(models.Model):
    name = models.CharField(max_length=100)
    address = models.CharField(max_length=255, null=True, blank=True)
    city = models.CharField(max_length=100, null=True, blank=True)
    latitude = models.FloatField()
    longitude = models.FloatField()
    total_spots = models.IntegerField(default=0)
    available_spots = models.IntegerField(default=0)
    price_per_hour = models.DecimalField(max_digits=8, decimal_places=2, default=150.00)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.name

class Reservation(models.Model):
    carpark = models.ForeignKey(Carpark, on_delete=models.CASCADE, null=True, related_name='reservations')
    plate_number = models.CharField(max_length=20)
    duration = models.IntegerField()  # En heures
    color = models.CharField(max_length=50)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.plate_number} - {self.duration}h"

class Payment(models.Model):
    reservation = models.ForeignKey(Reservation, on_delete=models.CASCADE, related_name='payment')
    transaction_id = models.CharField(max_length=50, unique=True)
    amount = models.IntegerField()
    status = models.CharField(
        max_length=20,
        choices=[
            ('pending', 'En attente'),
            ('completed', 'Complété'),
            ('failed', 'Échoué'),
        ],
        default='pending'
    )
    payment_method = models.CharField(max_length=20, default='card')
    created_at = models.DateTimeField(auto_now_add=True)
    card_last4 = models.CharField(max_length=4, null=True)

    def __str__(self):
        return f"Payment {self.transaction_id} - {self.status}"
