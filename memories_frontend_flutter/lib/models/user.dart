class User {
    int? id;
    String? name;
    String? phone;
    String? image;
    String? email;
    String? token;

    User({
        this.id,
        this.name,
        this.phone,
        this.image,
        this.email,
        this.token
    });


    // function to convert json data to user model
    factory User.fromJson(Map<String, dynamic> json){
        return User(
            id: json['user']['id'],
            name: json['user']['name'],
            phone: json['user']['phone'],
            image: json['user']['image'],
            email: json['user']['email'],
            token: json['token']
        );
    }
}