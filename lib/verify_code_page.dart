import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'welcome_page.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;
  VerifyCodePage({required this.email});

  @override
  _VerifyCodePageState createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final TextEditingController codeController = TextEditingController();
  final AuthService authService = AuthService();

  void verifyCode() async {
    print(
        "🟡 Tentative de vérification - Email: ${widget.email}, Code: ${codeController.text}");

    String? errorMessage =
        await authService.verifyCode(widget.email, codeController.text);

    if (errorMessage == null) {
      print(" Vérification réussie !");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vérification réussie !")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WelcomePage(username: widget.email)),
      );
    } else {
      print(" Code invalide !");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vérifier le code")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: codeController,
                decoration: InputDecoration(
                    labelText: "Entrez le code de vérification")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: verifyCode, child: Text("Vérifier")),
          ],
        ),
      ),
    );
  }
}
