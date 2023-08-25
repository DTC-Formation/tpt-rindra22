import 'dart:io';

import 'package:memories_frontend_flutter/helpers/colors.dart';
import 'package:memories_frontend_flutter/helpers/config.dart';
import 'package:memories_frontend_flutter/models/api_response.dart';
import 'package:memories_frontend_flutter/models/user.dart';
import 'package:memories_frontend_flutter/services/user_services.dart';
import 'package:memories_frontend_flutter/views/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilScreen extends StatefulWidget {
    const ProfilScreen({super.key});

    @override
    State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {

    User? user;
    bool loading = true;
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    File? _imageFile;
    final _picker = ImagePicker();
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController emailController = TextEditingController();


    Future getImage() async {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null){
            setState(() {
                _imageFile = File(pickedFile.path);
            });
        }
    }

    // get user detail
    void getUser() async {
        ApiResponse response = await getUserDetail();
        if(response.error == null) {
            setState(() {
                user = response.data as User;
                loading = false;
                nameController.text = user!.name ?? '';
                phoneController.text = user!.phone ?? '';
                emailController.text = user!.email ?? '';
            });
        }
        else if(response.error == unauthorized){
            logout().then((value) => {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Login()), (route) => false)
            });
        }
        else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${response.error}')
            ));
        }
    }

    //update profile
    void updateProfile() async {
        String? image = _imageFile ==  null ? null : getStringImage(_imageFile);
        ApiResponse response = await updateUser(name: nameController.text, phone: phoneController.text, email: emailController.text, image: image);
        setState(() {
            loading = false;
        });
        if(response.error == null){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${response.data}')
            ));
        }
        else if(response.error == unauthorized){
            logout().then((value) => {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Login()), (route) => false)
            });
        }
        else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${response.error}')
            ));
        }
    }

    @override
    void initState() {
        getUser();
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return loading ? Center(child: CircularProgressIndicator(color: primary),) :
            Padding(
                padding: EdgeInsets.only(top: 40, left: 40, right: 40),
                child: ListView(
                    children: [
                        Center(
                            child:GestureDetector(
                                child: Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60),
                                    image: _imageFile == null ? user!.image != null ? DecorationImage(
                                            image: CachedNetworkImageProvider( storage + user!.image!),
                                            fit: BoxFit.cover
                                        ) : DecorationImage(image: NetworkImage("https://blurha.sh/12c2aca29ea896a628be.jpg"), fit: BoxFit.cover)
                                        : DecorationImage(
                                            image: FileImage(_imageFile ?? File('')),
                                            fit: BoxFit.cover
                                        ),
                                        color: primary
                                    ),
                                ),
                                onTap: (){
                                    getImage();
                                },
                            )
                        ),
                        SizedBox(height: 20,),
                        Form(
                            key: formKey,
                            child: Column(
                                children: [
                                    getUserNameField(),
                                    getPhoneNumberField(),
                                    getEmailField(),
                                ],
                            )
                        ),
                        SizedBox(height: 20,),
                        kTextButton('Update', (){
                            if(formKey.currentState!.validate()){
                                setState(() {
                                    loading = true;
                                });
                                updateProfile();
                            }
                        }
                    )
                ],
            ),
        );
    }

    TextButton kTextButton(String label, Function onPressed){
        return TextButton(
            child: Text(label, style: TextStyle(color: Colors.white),),
            style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith((states) => primary),
                padding: MaterialStateProperty.resolveWith((states) => EdgeInsets.symmetric(vertical: 10)),
            ),
            onPressed: () => onPressed(),
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
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    controller: phoneController,
                    cursorColor: primary,
                    validator: (val) => val!.isEmpty ? 'Invalid phone number' : null,
                    style: const TextStyle(color: black, fontWeight: FontWeight.normal),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone_outlined,color: primary,),
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

}