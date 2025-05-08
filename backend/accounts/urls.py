# urls.py
from django.urls import path
from . import views
from .views import UserProfileDetailView

urlpatterns = [
    # URLs existantes
    path('register/', views.RegisterView.as_view(), name='register'),
    path('verify-email/', views.VerifyEmailView.as_view(), name='verify-email'),
    path('login/', views.LoginView.as_view(), name='login'),
    
    # URLs pour les parkings
    path('carparks/', views.carparks, name='carparks'),
    path('nearby-carparks/', views.nearby_carparks, name='nearby-carparks'),
    # path('get-route/', views.get_route, name='get-route'),
    
    # URLs pour les réservations
    path('reserve/', views.ReservationView.as_view(), name='reservation'),
    path('process-payment/', views.ProcessPaymentView.as_view(), name='process-payment'),
    path('verifier-matricule/', views.verifier_matricule, name='verifier-matricule'),
    
    path('profile/', UserProfileDetailView.as_view(), name='user-profile'),

]