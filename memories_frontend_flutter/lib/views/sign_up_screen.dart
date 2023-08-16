// ignore_for_file: deprecated_member_use

import 'package:memories_frontend_flutter/helpers/colors.dart';
import 'package:memories_frontend_flutter/helpers/config.dart';
import 'package:memories_frontend_flutter/models/api_response.dart';
import 'package:memories_frontend_flutter/models/user.dart';
import 'package:memories_frontend_flutter/services/user_services.dart';
import 'package:memories_frontend_flutter/views/widgets/simple_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
    const SignUp({Key? key}) : super(key: key);

    @override
    State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool loading = false;
    TextEditingController
        nameController = TextEditingController(), 
        phoneController = TextEditingController(), 
        emailController = TextEditingController(),
        passwordController = TextEditingController(),
        passwordConfirmController = TextEditingController();
    void _registerUser () async {
        ApiResponse response = await register(name: nameController.text, email: emailController.text, phone: phoneController.text, password: passwordController.text);
        if(response.error == null) {
            _saveAndRedirectToHome(response.data as User);
        } 
        else {
            setState(() {
                loading = !loading;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${response.error}')
            ));
        }
    }

    // Save and redirect to home
    void _saveAndRedirectToHome(User user) async {
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString('token', user.token ?? '');
        await pref.setInt('userId', user.id ?? 0);
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: backgroundColor,
            body: Form(
                key: formKey,
                child: Center(
                  child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                              getLogo(),
                              getText(),
                              getUserNameField(),
                              getPhoneNumberField(),
                              getEmailField(),
                              getPasswordField(),
                              getPasswordConfirmField(),
                              loading ? 
                                Center(child: CircularProgressIndicator(color: primary))
                                : registerButton(),
                              Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                          const Text("Already have an account? ",
                                              style: TextStyle(
                                                  decoration: TextDecoration.none,
                                                  fontSize: 15,
                                                  color: black)),
                                          TextButton(
                                              onPressed: () {
                                                  Navigator.pushNamed(context, '/login');
                                              },
                                              child: const Text("Login",
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
              ),
            ),
        );
    }

    getLogo() {
        return SvgPicture.asset("${imageLogoPath}logo.svg",width: 150, height: 150);
    }

    getText() {
        return const  Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 50),
                    child: Text("Create Account",
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: black)
                    ),
                ),
            ],
        );
    }

    registerButton() {
        return Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: SimpleButton(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.13,
                borderRadius: 10,
                backgroundColor: primary,
                buttonText: "Register",
                textColor: white,
                borderColor: backgroundColor,
                textFontSize: 16,
                onButtonPressed: () {
                    if (formKey.currentState!.validate()) {
                        // formKey.currentState!.save();
                        setState(() {
                            loading = !loading;
                            _registerUser();
                        });
                    }
                },
            ),
        );
    }

    getEmailField() {
        return Padding(
            padding: const EdgeInsetsDirectional.only(top: 15),
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.13,
                child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: primary,
                    controller: emailController,
                    validator: (val) => val!.isEmpty ? 'Invalid email address' : null,
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

    getUserNameField() {
        return Padding(
            padding: const EdgeInsetsDirectional.only(top: 15.0),
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.13,
                child: TextFormField(
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    controller: nameController,
                    cursorColor: primary,
                    validator: (val) => val!.isEmpty ? 'Invalid name' : null,
                    style: const TextStyle(color: black, fontWeight: FontWeight.normal),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outlined,color: primary,),
                        hintText: "Enter your name",
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

    getPhoneNumberField() {
        return Padding(
            padding: const EdgeInsetsDirectional.only(top: 15.0),
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.13,
                child: TextFormField(
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    controller: phoneController,
                    cursorColor: primary,
                    validator: (val) => val!.isEmpty ? 'Invalid phone number' : null,
                    style: const TextStyle(color: black, fontWeight: FontWeight.normal),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone_android_sharp,color: primary,),
                        hintText: "Enter your phone number",
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

    getPasswordField() {
        return Padding(
            padding: const EdgeInsetsDirectional.only(top: 15.0),
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.13,
                child: TextFormField(
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    cursorColor: primary,
                    validator: (val) => val!.length < 6 ? 'Password too short' : null,
                    style: const TextStyle(color: black, fontWeight: FontWeight.normal),
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline,color: primary,),
                        hintText: "Enter your password",
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

    getPasswordConfirmField() {
        return Padding(
            padding: const EdgeInsetsDirectional.only(top: 15.0),
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.13,
                child: TextFormField(
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(color: black, fontWeight: FontWeight.normal),
                    obscureText: true,
                    controller: passwordConfirmController,
                    cursorColor: primary,
                    validator: (val) => val != passwordController.text ? 'Passwords do not match' : null,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline,color: primary,),
                        hintText: "Confirm your password",
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
