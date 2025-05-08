from rest_framework import serializers
from .models import CustomUser, Carpark, Reservation, Payment

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
