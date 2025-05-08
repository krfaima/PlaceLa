// ✅ main.dart (modifié avec style violet et jaune)
import 'package:flutter/material.dart';
import 'dart:async';
import 'register_page.dart';
import 'pages/find_parking_page.dart';
import 'profile_page.dart';      // à créer si pas encore

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF6A5AE0),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF6A5AE0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF6A5AE0),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF6A5AE0), width: 2),
          ),
          labelStyle: TextStyle(color: Color(0xFF6A5AE0)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/register': (context) => RegisterPage(),
        '/find_parking': (context) => const FindParkingPage(),
         '/user_profile': (context) {
          final token = ModalRoute.of(context)!.settings.arguments as String;
          return ProfilePage(token: token);
        },
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo1.png', width: 180),
          ],
        ),
      ),
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/image1.png',
      'text': 'Trouvez un parking facilement autour de vous.'
    },
    {
      'image': 'assets/image2.png',
      'text': 'Réservez et payez rapidement en toute sécurité.'
    },
    {
      'image': 'assets/image3.png',
      'text': 'Prolongez le temps de stationnement à distance.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (value) {
                setState(() => _page = value);
              },
              itemCount: onboardingData.length,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(onboardingData[index]['image']!, width: double.infinity),
                    SizedBox(height: 40),
                    Text(
                      onboardingData[index]['text']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(onboardingData.length, (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              width: _page == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _page == index ? Color(0xFF6A5AE0) : Colors.grey,
                shape: BoxShape.circle,
              ),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_page == onboardingData.length - 1) {
                  Navigator.of(context).pushReplacementNamed('/register');
                } else {
                  _controller.nextPage(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.ease,
                  );
                }
              },
              child: Text(_page == onboardingData.length - 1 ? 'Commencer' : 'Suivant'),
            ),
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/register');
            },
            child: Text("Passer l'introduction"),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
