import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
    const SplashScreen({super.key});

    @override
    State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin{

    late AnimationController _controller;
    late Animation<Offset> imageanimation;

    @override
    void initState() {
        _controller = AnimationController(
            vsync: this,
            duration: const Duration(seconds: 2),
        );
        imageanimation = Tween<Offset>(
            begin: const Offset(0.0, 0.1),
            end: const Offset(0.0, 0.0))
            .animate(
                CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.1, 0.4, curve: Curves.easeIn)
                )
            );
        _controller.forward();
        Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        });
        super.initState();
    }

    @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Colors.white,
                body: Stack(
                    children: [
                        _buildlogo(),
                    ],
                )
        );
    }

    Widget _buildlogo() {
        return SlideTransition(
            position: imageanimation,
            child: Center(
                child: SvgPicture.asset(
                    'assets/images/logo/logo.svg',
                    height: 200,
                    width: 150,
                ),
            ),
        );
    }
}