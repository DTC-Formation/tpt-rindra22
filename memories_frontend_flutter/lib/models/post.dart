import 'package:memories_frontend_flutter/models/image_posts.dart';

import 'user.dart';

class Post {
    int? id;
    String? title;
    String? description;
    String? image;
    int? likesCount;
    int? commentsCount;
    User? user;
    bool? selfLiked;
    List<ImagePosts>? imagePosts;

    Post({
        this.id,
        this.title,
        this.description,
        this.image,
        this.likesCount,
        this.commentsCount,
        this.user,
        this.selfLiked,
        this.imagePosts
    });

    // Map json to post model
    factory Post.fromJson(Map<String, dynamic> json) {
        return Post(
            id: json['id'],
            title: json['title'],
            description: json['description'],
            image: json['image'],
            likesCount: json['likes_count'],
            commentsCount: json['comments_count'],
            selfLiked: json['likes'].length > 0,
            user: User(
                id: json['user']['id'],
                name: json['user']['name'],
                image: json['user']['image']
            ),
            imagePosts: json['image_posts'].map<ImagePosts>((imagePost) => ImagePosts.fromJson(imagePost)).toList()
        );
    }

}