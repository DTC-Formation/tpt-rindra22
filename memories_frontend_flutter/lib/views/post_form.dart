import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:memories_frontend_flutter/helpers/colors.dart';
import 'package:memories_frontend_flutter/helpers/config.dart';
import 'package:memories_frontend_flutter/models/api_response.dart';
import 'package:memories_frontend_flutter/models/post.dart';
import 'package:memories_frontend_flutter/services/post_services.dart';
import 'package:memories_frontend_flutter/services/user_services.dart';
import 'package:memories_frontend_flutter/views/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class PostForm extends StatefulWidget {
    final Post? post;
    final String? title;
    final String? description;


    const PostForm({super.key, 
        this.post,
        this.title,
        this.description
    });

    @override
    State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
    
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _txtControllerTitle = TextEditingController();
    final TextEditingController _txtControllerDescription = TextEditingController();
    bool _loading = false;
    File? _imageFile;
    String _imagePath = '';
    final _picker = ImagePicker();
    List<File> selectedImages = [];
    List<XFile>? pickedFiles = [];

    Future _getFromCamera() async {
        final pickedFile = await _picker.pickImage(source: ImageSource.camera);
        if (pickedFile != null){
            setState(() {
                _imageFile = File(pickedFile.path);
                selectedImages.add(_imageFile!);
                
            });
        }
    }

  /*   Future _getFromGallery() async {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null){
            setState(() {
                _imageFile = File(pickedFile.path);
            });
        }
    } */

    Future<void> addPost(List pickedFiles, String title, String description) async {
        List imagePaths = pickedFiles.map((pickedFile) => pickedFile.path).toList();
        List<File> imageFiles = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();

        List<String> existingImagePaths = [];
        List<File> existingImageFiles = [];

        for (var i = 0; i < imageFiles.length; i++) {
            if (imageFiles[i].existsSync()) {
            existingImagePaths.add(imagePaths[i]);
            existingImageFiles.add(imageFiles[i]);
            } else {
            print('Image file not found: ${imageFiles[i].path}');
            }
        }

        if (existingImagePaths.isNotEmpty) {

            ApiResponse response = await createPost(
                title: title,
                description: description,
                images: existingImagePaths,
            );
           // print('Server Response: ${response.data}');
           // print('Server Error: ${response.error}');

            if(response.error ==  null || response.data == null) {
                Navigator.pushNamed(context, '/home');
            }
            else if (response.error == unauthorized){
                logout().then((value) => {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Login()), (route) => false)
                });
            }
            else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${response.error}')
                ));
                setState(() {
                    _loading = !_loading;
                });
            }
        }
    }

    Future<void> getImages() async {
        try {
            pickedFiles = await _picker.pickMultiImage(
                imageQuality: 100,
                maxHeight: 1000,
                maxWidth: 1000,
            );
        } catch (e) {
            print("Image selection error: $e");
            return;
        }

        if(pickedFiles != null && pickedFiles!.isNotEmpty){
            for (var i = 0; i < pickedFiles!.length; i++) {
                selectedImages.add(File(pickedFiles![i].path));
            }
            setState(
                () { 
                    print("Longuer: ${selectedImages.length}");
                },
            );
        }else{
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No images selected')));
        }

    }

    @override
    void initState() {
        if(widget.post != null){
            _txtControllerTitle.text = widget.post!.title!;
            _txtControllerDescription.text = widget.post!.description!;
            _imagePath = widget.post!.image ?? '';
        }
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        var size = MediaQuery.of(context).size;
        return Scaffold(
            body: _loading ? Center(child: CircularProgressIndicator(color: primary),) :  
                Container(
                    height: size.height * 0.7,
                    decoration: BoxDecoration(
                        color: white
                    ),
                    child: ListView(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                            selectedImages.length > 0 ?
                                Container(
                                    height: 200,
                                    child: GridView.count(
                                        crossAxisCount: 3,
                                        children: List.generate(selectedImages.length, (index) {
                                            return Stack(
                                                children: [
                                                    Container(
                                                        margin: EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                                image: FileImage(selectedImages[index]),
                                                                fit: BoxFit.cover
                                                            ),
                                                            borderRadius: BorderRadius.circular(10),
                                                        ),
                                                    ),
                                                    Positioned(
                                                        top: 0,
                                                        right: 0,
                                                        child: IconButton(
                                                            onPressed: (){
                                                                setState(() {
                                                                    selectedImages.removeAt(index);
                                                                });
                                                            },
                                                            icon: Icon(Icons.close, color: redCustomText, size: 20,),
                                                        ),
                                                    )
                                                ],
                                            );
                                        }),
                                    ),
                                )
                            : Container(),
                                Container(
                                    height: size.height * .2,
                                    padding: const EdgeInsets.all(15),
                                    margin: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: white,
                                        borderRadius: BorderRadius.circular(10),
                                        border:
                                        Border.all(color: Colors.black12, width: 1),
                                        boxShadow: const [
                                            BoxShadow(
                                                color: Color(0x0f000000),
                                                blurRadius: 10.0,
                                            ),
                                        ],
                                    ),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                            GestureDetector(
                                                onTap: () {
                                                    _showPicker();
                                                },
                                                child: Container(
                                                    width: size.width * .135,
                                                    padding: const EdgeInsets.all(15),
                                                    decoration: const BoxDecoration(
                                                        color: Color(0xffe9f0ff),
                                                        shape: BoxShape.circle,
                                                    ),
                                                    child: SvgPicture.asset(
                                                        "assets/images/upload.svg"
                                                    ),
                                                ),
                                            ),
                                            SizedBox(
                                                height: size.height * .01,
                                            ),
                                            const Text(
                                                "Upload Photo",
                                                style: TextStyle(color: primary,fontSize: 16 ),
                                            )
                                        ],
                                    )
                                ),
                                /* Container(
                                    width: size.width * .135,
                                    height: size.height * .24,
                                    padding: const EdgeInsets.all(15),
                                    margin: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: FileImage(_imageFile ?? File('')),
                                            fit: BoxFit.cover
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                            TextButton(
                                                onPressed: (){
                                                    _showPicker();
                                                    setState(() {
                                                        _imageFile = null;
                                                    });
                                                },
                                                child: Row(children: [
                                                    Icon(Icons.edit, size: 20, color: white,),
                                                    SizedBox(width: 10,),
                                                    Text('Edit', style: TextStyle(color: white),)
                                                ],),
                                                style: TextButton.styleFrom(
                                                    backgroundColor: redCustomButton,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10)
                                                    )
                                                ),
                                            )
                                        ],
                                    ),
                                ), */
                                
                                Form(
                                    key: _formKey,
                                    child: Column(
                                        children: [
                                            Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: TextFormField(
                                                        controller: _txtControllerTitle,
                                                        keyboardType: TextInputType.multiline,
                                                        maxLines: 3,
                                                        validator: (val) => val!.isEmpty ? 'Title is required' : null,
                                                        decoration: const InputDecoration(
                                                            hintText: 'Title',
                                                            border: OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black38))
                                                        ),
                                                    ),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: TextFormField(
                                                        controller: _txtControllerDescription,
                                                        keyboardType: TextInputType.multiline,
                                                        maxLines: 9,
                                                        validator: (val) => val!.isEmpty ? 'Description is required' : null,
                                                        decoration: const InputDecoration(
                                                        hintText: 'Description',
                                                        border: OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black38))
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                                Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8),
                                    child: kTextButton('Create', (){
                                        if (_formKey.currentState!.validate()){
                                            setState(() {
                                                _loading = !_loading;
                                            });
                                            addPost(selectedImages, _txtControllerTitle.text, _txtControllerDescription.text);
                                        }
                                    }),
                                )
                        ],
                    ),
                ),
        );
    }
    TextButton kTextButton(String label, Function onPressed){
        return TextButton(
            style: ButtonStyle(
            backgroundColor: MaterialStateColor.resolveWith((states) => primary),
            padding: MaterialStateProperty.resolveWith((states) => const EdgeInsets.symmetric(vertical: 10)),
            ),
            onPressed: () => onPressed(),
            child: Text(label, style: const TextStyle(color: Colors.white),),
        );
    }

    void _showPicker() {
        showDialog(
            context: context,
            builder: (BuildContext context) {
                return Dialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)), //this right here
                    child: SizedBox(
                        height: 150,
                        width: 100,
                        child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                    TextButton.icon(
                                        icon: const Icon(
                                            Icons.photo_library,
                                            color: primary,
                                        ),
                                        label: const Text(
                                            'Gallery',
                                            style: TextStyle(
                                                color: primary,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: () {
                                            getImages();
                                            Navigator.of(context).pop();
                                        }
                                    ),
                                    TextButton.icon(
                                        icon: const Icon(
                                            Icons.photo_camera,
                                            color: primary,
                                        ),
                                        label: const Text(
                                            'Camera',
                                            style: TextStyle(
                                                color: primary,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold
                                            ),
                                        ),
                                        onPressed: () {
                                            _getFromCamera();
                                            Navigator.of(context).pop();
                                        },
                                    )
                                ]
                            ),
                        )
                    )
                );
            },
        );
    }
}