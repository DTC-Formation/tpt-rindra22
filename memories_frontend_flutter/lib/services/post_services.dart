
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:memories_frontend_flutter/helpers/config.dart';
import 'package:memories_frontend_flutter/models/api_response.dart';
import 'package:memories_frontend_flutter/models/post.dart';
import 'package:memories_frontend_flutter/services/user_services.dart';
import 'package:http/http.dart' as http;

// get all posts
Future<ApiResponse> getPosts() async {
    ApiResponse apiResponse = ApiResponse();
    try {
        String token = await getToken();
        final response = await http.get(Uri.parse(postsURL),
        headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
        });

        switch(response.statusCode){
            case 200:
                final responseData = jsonDecode(response.body);
              //  print('Response Data: $responseData');

                if (responseData.containsKey('posts')) {
                    final postsData = responseData['posts'] as List;
                    final postsList = postsData.map((p) => Post.fromJson(p)).toList();
                    apiResponse.data = postsList;
                } else {
                    apiResponse.error = 'No posts found in response.';
                }
                break;
            case 401:
                apiResponse.error = unauthorized;
                break;
            default:
                apiResponse.error = somethingWentWrong;
                break;
        }
    }
    catch (e){
        apiResponse.error = serverError;
    }
    return apiResponse;
}
Future<ApiResponse> createPost({required String title, String? description, List? images}) async {
    ApiResponse apiResponse = ApiResponse();
    try {
        String token = await getToken();
        var uri = Uri.parse(postsURL);
        http.MultipartRequest request = new http.MultipartRequest('POST', uri);
        request.headers['Accept'] = 'application/json';
        request.headers['Authorization'] = 'Bearer $token';
        request.fields['title'] = title;
        request.fields['description'] = description ?? "";

        List<http.MultipartFile> multipartImages = [];

        if (images != null) {
            for (int i = 0; i < images.length; i++) {
                File imageFile = File(images[i].toString());

                if (imageFile.existsSync()) {
                    var stream = http.ByteStream(imageFile.openRead());
                    var length = await imageFile.length();
                    var multipartFile = http.MultipartFile(
                        'images[]', // Change 'path[]' to 'images[]' or an appropriate field name
                        stream,
                        length,
                        filename: imageFile.path,
                    );
                    multipartImages.add(multipartFile);
                } else {
                    print('Image file not found: ${imageFile.path}');
                }
            }
        }

        request.files.addAll(multipartImages);

        http.StreamedResponse response = await request.send();

        switch (response.statusCode) {
        case 200:
            apiResponse.data = jsonDecode(await response.stream.bytesToString())['message'];
            break;
        case 422:
            final errors = jsonDecode(await response.stream.bytesToString())['errors'];
            apiResponse.error = errors[errors.keys.elementAt(0)][0];
            break;
        case 401:
            apiResponse.error = unauthorized;
            break;
        default:
            print(await response.stream.bytesToString());
            apiResponse.error = somethingWentWrong;
            break;
        }
    } catch (e) {
        apiResponse.error = serverError;
    }
    return apiResponse;
}

Future<ApiResponse> editPost({required int postId, required String title, String? description, List? images}) async{
    ApiResponse apiResponse = ApiResponse();
    try {
        String token = await getToken();
        final response = await http.put(Uri.parse('$postsURL/$postId'),
        headers: {
            'Accept': 'application/json',
            'Connection': 'Keep-Alive',
            'Authorization': 'Bearer $token'
        }, body: {
            'title': title,
            'description': description ?? ""
        });

    // print(response);

        switch(response.statusCode){
            case 200:
                apiResponse.data = jsonDecode(response.body)['message'];
                break;
            case 403:
                apiResponse.error = jsonDecode(response.body)['message'];
                break;
            case 401:
                apiResponse.error = unauthorized;
                break;
            default:
                apiResponse.error = somethingWentWrong;
                break;
        }
    }
    catch (e){
        apiResponse.error = serverError;
    }
    return apiResponse;
}

// Delete post
Future<ApiResponse> deletePost(int postId) async {
    ApiResponse apiResponse = ApiResponse();
    try {
        String token = await getToken();
        final response = await http.delete(Uri.parse('$postsURL/$postId'),
        headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
        });

        switch(response.statusCode){
            case 200:
                apiResponse.data = jsonDecode(response.body)['message'];
                break;
            case 403:
                apiResponse.error = jsonDecode(response.body)['message'];
                break;
            case 401:
                apiResponse.error = unauthorized;
                break;
            default:
                apiResponse.error = somethingWentWrong;
                break;
        }
    }
    catch (e){
        apiResponse.error = serverError;
    }
    return apiResponse;
}


// Like or unlike post
Future<ApiResponse> likeUnlikePost(int postId) async {
    ApiResponse apiResponse = ApiResponse();
    try {
        String token = await getToken();
        final response = await http.post(Uri.parse('$postsURL/$postId/likes'),
        headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
        });

        switch(response.statusCode){
            case 200:
                apiResponse.data = jsonDecode(response.body)['message'];
                break;
            case 401:
                apiResponse.error = unauthorized;
                break;
            default:
                apiResponse.error = somethingWentWrong;
                break;
        }
    }
    catch (e){
        apiResponse.error = serverError;
    }
    return apiResponse;
}

// Search posts
Future<ApiResponse> searchPost(String? query) async{
    ApiResponse apiResponse = ApiResponse();
    try {
        String token = await getToken();
        final response = await http.get(Uri.parse('$searchURL/?query=$query'),
        headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
        });

        switch(response.statusCode){
            case 200:
                final responseData = jsonDecode(response.body);
                if (responseData.containsKey('results')) {
                    final results = responseData['results'];
                    final postsList = results.map((post) => Post.fromJson(post)).toList();
                    apiResponse.data = postsList;
                } else {
                    apiResponse.error = 'No posts found in response.';
                }
                break;
            case 401:
                apiResponse.error = unauthorized;
                break;
            default:
                apiResponse.error = somethingWentWrong;
                break;
        }
    }
    catch (e){
        apiResponse.error = serverError;
    }

    return apiResponse;
}