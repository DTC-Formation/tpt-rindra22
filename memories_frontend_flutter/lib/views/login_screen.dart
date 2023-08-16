import 'package:memories_frontend_flutter/helpers/colors.dart';
import 'package:memories_frontend_flutter/helpers/config.dart';
import 'package:memories_frontend_flutter/models/api_response.dart';
import 'package:memories_frontend_flutter/models/user.dart';
import 'package:memories_frontend_flutter/services/user_services.dart';
import 'package:memories_frontend_flutter/views/widgets/simple_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
    const Login({super.key});

    @override
    State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool loading = false;
    TextEditingController? emailController;
    TextEditingController? passwordController;

    void _loginUser() async {
        ApiResponse response = await login(emailController!.text, passwordController!.text);
        if (response.error == null){
            _saveAndRedirectToHome(response.data as User);
        }
        else {
            setState(() {
                loading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${response.error}')
            ));
        }
    }

    void _saveAndRedirectToHome(User user) async {
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString('token', user.token ?? '');
        await pref.setInt('userId', user.id ?? 0);
        Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
    }

    @override
    void initState() {
        emailController = TextEditingController();
        passwordController = TextEditingController();
        super.initState();
    }

    @override
    void dispose() {
        emailController!.dispose();
        passwordController!.dispose();
        super.dispose();
    }
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            SvgPicture.asset("${imageLogoPath}logo.svg",width: 150, height: 150),
                            const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                    Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 50),
                                        child: Text("Login",
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: black)
                                        ),
                                    ),
                                ],
                            ),
                            getEmailTextFormField(),
                            getPasswordTextFormField(),
                            loading ? const CircularProgressIndicator(color: primary) : SimpleButton(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.width * 0.13,
                                borderRadius: 10,
                                backgroundColor: primary,
                                buttonText: "Login",
                                borderColor: backgroundColor,
                                textColor: white,
                                textFontSize: 16,
                                onButtonPressed: () {
                                    setState(() {
                                        loading = true;
                                    });
                                    _loginUser();
                                },
                            ),
                            const Row(
                                children: [
                                    Expanded(
                                        child: Padding(
                                            padding: EdgeInsetsDirectional.only(start: 15.0),
                                            child: Divider(
                                                indent: 20.0,
                                                endIndent: 5.0,
                                                thickness: 1,
                                                color: Colors.black45),
                                        ),
                                    ),
                                    Text(
                                        "Or",
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            fontSize: 12,
                                            color: black
                                        )
                                    ),
                                    Expanded(
                                    child: Padding(
                                        padding: EdgeInsetsDirectional.only(end: 15.0),
                                        child: Divider(
                                            indent: 5.0,
                                            endIndent: 20.0,
                                            thickness: 1,
                                            color: Colors.black45),
                                    ),
                                    ),
                                ],
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                        SimpleImageButton(
                                            image: "${imageLogoPath}facebook_logo.png",
                                            width: MediaQuery.of(context).size.width / 3,
                                            height: MediaQuery.of(context).size.width * 0.13,
                                            borderRadius: 10,
                                            backgroundColor: backgroundColor,
                                            buttonText: "Facebook",
                                            textColor: black,
                                            textFontSize: 16,
                                            borderColor: primary,
                                            borderWidth: 1,
                                            onButtonPressed: () {},
                                        ),
                                        SimpleImageButton(
                                            image: "${imageLogoPath}google_logo.png",
                                            width: MediaQuery.of(context).size.width / 3,
                                            height: MediaQuery.of(context).size.width * 0.13,
                                            borderRadius: 10,
                                            backgroundColor: backgroundColor,
                                            buttonText: "Google",
                                            textColor: black,
                                            textFontSize: 16,
                                            borderWidth: 1,
                                            borderColor: primary,
                                            onButtonPressed: () {},
                                        ),
                                    ],
                                )
                            ),
                            Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                        const Text("Don't have an account?",
                                            style: TextStyle(
                                                decoration: TextDecoration.none,
                                                fontSize: 15,
                                                color: black)),
                                        TextButton(
                                            onPressed: () {
                                                Navigator.pushNamed(context, '/register');
                                            },
                                            child: const Text("Register",
                                                style: TextStyle(
                                                    decoration: TextDecoration.none,
                                                    fontSize: 15,
                                                    color: primary)),
                                        ),
                                    ],
                                ),
                            ),
                        ],
                    ),
                ),
            )
        );
    }

    getEmailTextFormField() {
        return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.13,
                child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    controller: emailController,
                    cursorColor: primary,
                    validator: (val) => val!.isEmpty ? "Enter an email" : null,
                    style: const TextStyle(color: black, fontWeight: FontWeight.normal),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined,color: primary,),
                        hintText: "Enter your email",
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: black),
                            borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10.0),
                        ),
                    ),
                ),
            ),
        );
    }

    getPasswordTextFormField() {
        return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.13,
                child: TextFormField(
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    controller: passwordController,
                    style: const TextStyle(color: black, fontWeight: FontWeight.normal),
                    obscureText: true,
                    validator: (val) => val!.isEmpty ? "Enter a password" : null,
                    cursorColor: primary,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline,color: primary),
                        hintText: "Enter your password",
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: black),
                            borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10.0),
                        ),
                    ),
                ),
            ),
        );
    }
}