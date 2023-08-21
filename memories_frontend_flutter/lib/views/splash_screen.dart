import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memories_frontend_flutter/helpers/config.dart';
import 'package:memories_frontend_flutter/models/api_response.dart';
import 'package:memories_frontend_flutter/models/user.dart';
import 'package:memories_frontend_flutter/services/user_services.dart';
import 'package:memories_frontend_flutter/views/login_screen.dart';

class SplashScreen extends StatefulWidget {
    const SplashScreen({super.key});

    @override
    State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin{

    late AnimationController _controller;
    late Animation<Offset> imageanimation;

    void _getUserDetail() async{
        ApiResponse response = await getUserDetail();
        if(response.error == null){
            User user = response.data as User;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${user.name}')
            ));
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
        else if(response.error == unauthorized){
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login()), (route) => false);
        }
        else{
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${response.error}')
            ));
        }
    }

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
        /* Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }); */
        Future.delayed(const Duration(seconds: 2), _getUserDetail);
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