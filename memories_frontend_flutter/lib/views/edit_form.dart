import 'package:memories_frontend_flutter/helpers/colors.dart';
import 'package:memories_frontend_flutter/helpers/config.dart';
import 'package:memories_frontend_flutter/models/api_response.dart';
import 'package:memories_frontend_flutter/models/post.dart';
import 'package:memories_frontend_flutter/services/post_services.dart';
import 'package:memories_frontend_flutter/services/user_services.dart';
import 'package:memories_frontend_flutter/views/login_screen.dart';
import 'package:flutter/material.dart';

class EditForm extends StatefulWidget {
    final Post? post;
    final String? title;
    final String? description;

    const EditForm({super.key, 
        this.post,
        this.title,
        this.description
    });

    @override
    State<EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
    
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _txtControllerTitle = TextEditingController();
    final TextEditingController _txtControllerDescription = TextEditingController();
    bool _loading = false;
    List selectedImagesInitial = [];

    void editOnPost(String title, String description) async {
        ApiResponse response = await editPost(
            postId: widget.post!.id!,
            title: title,
            description: description,
            images: selectedImagesInitial,
        );
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

    @override
    void initState() {
        if(widget.post != null){
            _txtControllerTitle.text = widget.post!.title!;
            _txtControllerDescription.text = widget.post!.description!;
            selectedImagesInitial = widget.post!.imagePosts!
                .map((imagePost) => imagePost.path!)
                .toList();
        }
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        var size = MediaQuery.of(context).size;
        return Scaffold(
            body: _loading ? Center(child: CircularProgressIndicator(color: primary),) :  
                Container(
                    height: size.height * 1,
                    decoration: BoxDecoration(
                        color: white
                    ),
                    child: ListView(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                            selectedImagesInitial.length > 0 ?
                                Container(
                                    height: 200,
                                    child: GridView.count(
                                        crossAxisCount: 3,
                                        children: List.generate(selectedImagesInitial.length, (index) {
                                            return Stack(
                                                children: [
                                                    Container(
                                                        margin: EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                                image: NetworkImage("$storage${selectedImagesInitial[index]}"),
                                                                fit: BoxFit.cover
                                                            ),
                                                            borderRadius: BorderRadius.circular(10),
                                                        ),
                                                    ),
                                                ],
                                            );
                                        }),
                                    ),
                                )
                            : Container(),
                                    
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
                                child: kTextButton("Update", (){
                                    if (_formKey.currentState!.validate()){
                                        setState(() {
                                            _loading = !_loading;
                                        });
                                        editOnPost(_txtControllerTitle.text, _txtControllerDescription.text);
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
}