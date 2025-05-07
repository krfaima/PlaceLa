// pages/reservation_page.dart
import 'package:flutter/material.dart';
import '../models/carpark.dart';
import '../services/carpark_service.dart';
import 'payment_page.dart';
class ReservationPage extends StatefulWidget {
  final Carpark carpark;

  const ReservationPage({Key? key, required this.carpark}) : super(key: key);

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  String _selectedColor = 'Blanc';
  final List<String> _carColors = ['Blanc', 'Noir', 'Rouge', 'Bleu', 'Gris', 'Vert', 'Jaune', 'Orange', 'Marron', 'Autre'];

  bool _isLoading = false;

  @override
  void dispose() {
    _plateNumberController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  double _calculatePrice() {
    int duration = int.tryParse(_durationController.text) ?? 0;
    return duration * widget.carpark.pricePerHour;
  }

  Future<void> _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final CarparkService service = CarparkService();
        bool success = await service.sendReservation(
          carparkId: widget.carpark.id,
          duration: _durationController.text,
          color: _selectedColor,
          plateNumber: _plateNumberController.text,
        );

        if (success) {
          _navigateToPayment();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Échec de la réservation. Veuillez réessayer.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          carparkId: widget.carpark.id,
          plateNumber: _plateNumberController.text,
          color: _selectedColor,
          duration: int.parse(_durationController.text),
          price: _calculatePrice().toInt(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver une place'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.carpark.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (widget.carpark.address != null)
                        Text('Adresse: ${widget.carpark.address}'),
                      const SizedBox(height: 4),
                      Text('Places disponibles: ${widget.carpark.availableSpots}'),
                      const SizedBox(height: 4),
                      Text('Tarif: ${widget.carpark.pricePerHour.toStringAsFixed(2)} DA/heure'),
                      const SizedBox(height: 4),
                      Text('Distance: ${widget.carpark.distanceFromUser.toStringAsFixed(1)} km'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _plateNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro d\'immatriculation',
                  hintText: 'Ex: 123456-111-16',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le numéro d\'immatriculation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Durée (heures)',
                  hintText: 'Ex: 2',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la durée';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'La durée doit être un nombre positif';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Couleur du véhicule',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.color_lens),
                ),
                value: _selectedColor,
                items: _carColors.map((color) {
                  return DropdownMenuItem<String>(
                    value: color,
                    child: Text(color),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedColor = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              Card(
                color: isDarkMode ? Colors.blueGrey[700] : Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Prix total:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_calculatePrice().toStringAsFixed(2)} DA',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Passer à la caisse',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// // ------------------- PAGE DE PAIEMENT ------------------

// class PaymentPage extends StatefulWidget {
//   final String carparkId;
//   final String plateNumber;
//   final String color;
//   final int duration;
//   final int price;

//   const PaymentPage({
//     Key? key,
//     required this.carparkId,
//     required this.plateNumber,
//     required this.color,
//     required this.duration,
//     required this.price,
//   }) : super(key: key);

//   @override
//   State<PaymentPage> createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Paiement"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Immatriculation: ${widget.plateNumber}'),
//             Text('Couleur: ${widget.color}'),
//             Text('Durée: ${widget.duration} heure(s)'),
//             Text('Montant à payer: ${widget.price} DA'),
//             const SizedBox(height: 24),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Paiement simulé effectué avec succès !')),
//                   );
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Payer maintenant'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
