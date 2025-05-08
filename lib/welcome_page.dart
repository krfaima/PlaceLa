// import 'package:flutter/material.dart';
// import 'auth_service.dart';
// import 'login_page.dart';

// class WelcomePage extends StatefulWidget {
//   final String username;

//   WelcomePage({required this.username});

//   @override
//   _WelcomePageState createState() => _WelcomePageState();
// }

// class _WelcomePageState extends State<WelcomePage> {
//   final AuthService authService = AuthService();

//   void logout(BuildContext context) {
//     authService.logout();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => LoginPage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//   //  return Scaffold(
//   //     appBar: AppBar(title: const Text('Réserver une place')),
//   //     body: Padding(
//   //       padding: const EdgeInsets.all(16.0),
//   //       child: Form(
//   //         key: _formKey,
//   //         child: ListView(
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Bienvenue"),
//         backgroundColor: const Color.fromARGB(255, 230, 230, 231),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () => logout(context),
//           ),
//         ],
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image.asset('assets/logo1.png', width: 180, height: 180),
//               SizedBox(height: 30),
//               Text(
//                 "Bienvenue ${widget.username.split('@').first},",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[800],
//                 ),
//               ),
//               SizedBox(height: 10),
//               // Text(
//               //   "Heureux de vous revoir dans l'application",
//               //   textAlign: TextAlign.center,
//               //   style: TextStyle(fontSize: 16, color: Colors.grey[800]),
//               // ),
//               SizedBox(height: 40),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/find_parking');
//                   },
//                   icon: Icon(Icons.local_parking),
//                   label: Text("Trouver un parking"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.deepPurple,
//                     foregroundColor: Colors.white,
//                     padding: EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_page.dart';
import 'profile_page.dart'; // Assure-toi d'importer la page de profil

class WelcomePage extends StatefulWidget {
  final String username;

  WelcomePage({required this.username});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final AuthService authService = AuthService();

  void logout(BuildContext context) {
    authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Bienvenue"),
        backgroundColor: const Color.fromARGB(255, 230, 230, 231),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo1.png', width: 180, height: 180),
              SizedBox(height: 30),
              Text(
                "Bienvenue ${widget.username.split('@').first},",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 10),
              SizedBox(height: 40),
              
              // Bouton pour aller à la page de profil
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Assure-toi d'avoir configuré la route '/profile' dans ton app
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(token: 'ton_token_ici'),
                      ),
                    );
                  },
                  icon: Icon(Icons.account_circle),
                  label: Text("Voir mon profil"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Bouton pour trouver un parking
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/find_parking');
                  },
                  icon: Icon(Icons.local_parking),
                  label: Text("Trouver un parking"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
