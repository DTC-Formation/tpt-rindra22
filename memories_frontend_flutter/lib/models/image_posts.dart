class ImagePosts {
    int? id;
    int? postId;
    String? path;

    ImagePosts({this.id, this.postId, this.path});

    ImagePosts.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        postId = json['post_id'];
        path = json['path'];
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['id'] = this.id;
        data['post_id'] = this.postId;
        data['path'] = this.path;
        return data;
    }
}