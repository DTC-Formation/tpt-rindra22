import 'package:memories_frontend_flutter/views/home_page_screen.dart';
import 'package:memories_frontend_flutter/views/login_screen.dart';
import 'package:memories_frontend_flutter/views/post_form.dart';
import 'package:memories_frontend_flutter/views/sign_up_screen.dart';
import 'package:memories_frontend_flutter/views/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Memories',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: false,
            ),
            home: const SplashScreen(),
            routes: {
                '/splashscreen': (context) => const SplashScreen(),
                '/login': (context) => const Login(),
                '/register': (context) => const SignUp(),
                '/home': (context) => const HomePageScreen(),
                '/add-memo': (context) => const PostForm(),
            }
        );
    }
}


