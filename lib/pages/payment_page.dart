import 'package:flutter/material.dart';
import '../services/carpark_service.dart';

class PaymentPage extends StatefulWidget {
  final String carparkId; // ✅ Ajouté
  final String plateNumber;
  final String color;
  final int duration;
  final int price;

  const PaymentPage({
    Key? key,
    required this.carparkId, // ✅ Ajouté
    required this.plateNumber,
    required this.color,
    required this.duration,
    required this.price,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final CarparkService service = CarparkService();
        bool success = await service.processPayment(
          carparkId: widget.carparkId,
          plateNumber: widget.plateNumber,
          color: widget.color,
          duration: widget.duration,
          price: widget.price,
          cardNumber: _cardNumberController.text,
          cardExpiry: _cardExpiryController.text,
          cardCvv: _cardCvvController.text,
          cardName: _cardNameController.text,
        );

        if (success) {
          _showSuccessDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Échec du paiement. Veuillez réessayer.')),
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Paiement réussi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Votre réservation a été confirmée et payée avec succès.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Numéro d\'immatriculation: ${widget.plateNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Durée: ${widget.duration} heure(s)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Montant: ${widget.price} DA',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Résumé
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Résumé de la réservation',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text('Plaque d\'immatriculation: ${widget.plateNumber}'),
                      Text('Couleur du véhicule: ${widget.color}'),
                      Text('Durée: ${widget.duration} heure(s)'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Montant total:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${widget.price} DA',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Informations de paiement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de carte',
                  hintText: 'XXXX XXXX XXXX XXXX',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Veuillez entrer le numéro de carte';
                  String cleaned = value.replaceAll(' ', '');
                  if (cleaned.length < 13 || cleaned.length > 19) return 'Numéro de carte invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cardExpiryController,
                      decoration: const InputDecoration(
                        labelText: 'Date d\'expiration',
                        hintText: 'MM/YY',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requis';
                        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) return 'Format MM/YY';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cardCvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: 'XXX',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requis';
                        if (value.length != 3) return 'CVV invalide';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom sur la carte',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom figurant sur la carte';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processPayment,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Payer maintenant', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.security, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vos informations de paiement sont sécurisées et cryptées.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
