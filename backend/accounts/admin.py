from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser
from .models import Reservation, Payment, Carpark


class CustomUserAdmin(UserAdmin):
    model = CustomUser
    list_display = ('email', 'username', 'is_staff', 'is_active', 'is_verified')
    list_filter = ('is_staff', 'is_active', 'is_verified')
    fieldsets = (
        (None, {'fields': ('email', 'password', 'username')}),
        ('Permissions', {'fields': ('is_staff', 'is_active', 'is_verified', 'groups', 'user_permissions')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'username', 'password1', 'password2', 'is_staff', 'is_active')}
        ),
    )
    search_fields = ('email', 'username')
    ordering = ('email',)
@admin.register(Carpark)
class CarparkAdmin(admin.ModelAdmin):
    list_display = ('name', 'address', 'city', 'total_spots', 'available_spots', 'price_per_hour', 'is_active')
    list_filter = ('city', 'is_active')
    search_fields = ('name', 'address', 'city')
    ordering = ('name',)

@admin.register(Reservation)
class ReservationAdmin(admin.ModelAdmin):
    list_display = ('plate_number', 'carpark', 'duration', 'price', 'created_at', 'is_active')
    list_filter = ('is_active', 'created_at')
    search_fields = ('plate_number', 'carpark__name')
    ordering = ('-created_at',)

@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ('transaction_id', 'reservation', 'amount', 'status', 'card_last4')
    list_filter = ('status',)
    search_fields = ('transaction_id', 'reservation__plate_number')

admin.site.register(CustomUser, CustomUserAdmin)
