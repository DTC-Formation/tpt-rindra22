import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:like_button/like_button.dart';
import 'package:memories_frontend_flutter/helpers/colors.dart';
import 'package:memories_frontend_flutter/helpers/config.dart';
import 'package:memories_frontend_flutter/models/api_response.dart';
import 'package:memories_frontend_flutter/models/post.dart';
import 'package:memories_frontend_flutter/services/post_services.dart';
import 'package:memories_frontend_flutter/services/user_services.dart';
import 'package:memories_frontend_flutter/views/comment_screen.dart';
import 'package:memories_frontend_flutter/views/edit_form.dart';
import 'package:memories_frontend_flutter/views/login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memories_frontend_flutter/views/widgets/text_field.dart';
import 'package:octo_image/octo_image.dart';
import 'package:readmore/readmore.dart';

class PostScreen extends StatefulWidget {
    const PostScreen({super.key});

    @override
    State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

    final TextEditingController _searchController = TextEditingController();
    List<dynamic> _postList = [];
    int userId = 0;
    bool _loading = true, _searching = false;
    int _current = 0;

    // get all posts
    Future<void> retrievePosts() async {
        userId = await getUserId();
        ApiResponse response = await getPosts();

        if(response.error == null){
            setState(() {
                _postList = response.data as List<dynamic>;
                // print(_postList);
                _loading = _loading ? !_loading : _loading;
            });
        }
        else if (response.error == unauthorized){
            logout().then((value) => {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Login()), (route) => false)
            });
        }
        else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${response.error}'),
            ));
        }
    }


    void _handleDeletePost(int postId) async {
        ApiResponse response = await deletePost(postId);
        if (response.error == null){
            retrievePosts();
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

    void _handleSearchPost(String query) async {
        ApiResponse response = await searchPost(query);
        if (response.error == null){
            setState(() {
                if(response.data != null){
                    _postList = response.data as List<dynamic>;
                    // print("Search result: ${_postList}");
                }
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

    // post like dislik
    Future<bool> _handlePostLikeDislike(bool isLiked,int postId,) async {
        ApiResponse response = await likeUnlikePost(postId);

        if(response.error == null){
            retrievePosts();
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

        return !isLiked;
    }

    @override
    void initState() {
        retrievePosts();
        super.initState();
    }


    @override
    Widget build(BuildContext context) {
        return _loading ? const Center(child:CircularProgressIndicator(color: primary)) :
            SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        AppTextField(
                            controller: _searchController,
                            prefixIcon: Icons.search_outlined,
                            suffixIcon: _searching ? Icons.close : null,
                            suffixIconCallBack: () {
                                setState(() {
                                    _searching = false;
                                });
                                retrievePosts();
                                _searchController.clear();
                            },
                            focusNode: FocusNode(),
                            hintText: 'Search Memories (title or description)',
                            isEnabled: true,
                            onChanged: (value) {
                                if(value.isEmpty){
                                    retrievePosts();
                                    _searching = false;
                                }
                                else {
                                    _handleSearchPost(value);
                                    _searching = true;
                                }
                            }
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.65,
                            child: RefreshIndicator(
                                color: primary,
                                onRefresh: () {
                                    return retrievePosts();
                                },
                                child : ListView.builder(
                                    itemCount: _postList.length,
                                    itemBuilder: (BuildContext context, int index){
                                        Post post = _postList[index];
                                        print(post.user!.email);
                                        return Card(
                                            child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                        Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                                Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                                                    child: Row(
                                                                        children: [
                                                                            CircleAvatar(
                                                                                backgroundImage: post.user!.image != null ?
                                                                                    CachedNetworkImageProvider('$storage${post.user!.image}') :
                                                                                    const CachedNetworkImageProvider('https://blurha.sh/12c2aca29ea896a628be.jpg'),
                                                                                radius: 20,
                                                                            ),
                                                                            const SizedBox(width: 10,),
                                                                            Text(
                                                                                '${post.user!.name}',
                                                                                style: const TextStyle(
                                                                                    fontWeight: FontWeight.w600,
                                                                                    fontSize: 16
                                                                                ),
                                                                            )
                                                                        ],
                                                                    ),
                                                                ),
                                                                post.user!.id == userId ?
                                                                PopupMenuButton(
                                                                    child: const Padding(
                                                                        padding: EdgeInsets.only(right:10),
                                                                        child: Icon(Icons.more_vert, color: Colors.black,)
                                                                    ),
                                                                    itemBuilder: (context) => [
                                                                        const PopupMenuItem(
                                                                            value: 'edit',
                                                                            child: Text('Edit')
                                                                        ),
                                                                        const PopupMenuItem(
                                                                            value: 'delete',
                                                                            child: Text('Delete')
                                                                        )
                                                                    ],
                                                                    onSelected: (val){
                                                                        if(val == 'edit'){
                                                                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EditForm(
                                                                                title: 'Edit Memories',
                                                                                post: post,
                                                                            )));
                                                                        } else {
                                                                            _handleDeletePost(post.id ?? 0);
                                                                        }
                                                                    },
                                                                ) : const SizedBox()
                                                            ],
                                                        ),
                                                        const SizedBox(height: 12,),
                                                        AutoSizeText(
                                                            '${post.title}',
                                                            style: const TextStyle(
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 18
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                        ),
                                        
                                                        SizedBox(height: 10,),
                                        
                                                        // add description with view more
                                                        /* AutoSizeText(
                                                            '${post.description}',
                                                            style: const TextStyle(
                                                                fontSize: 16
                                                            ),
                                                            maxLines: 3,
                                                            overflow: TextOverflow.ellipsis,
                                                        ), */
                                                        ReadMoreText(
                                                            '${post.description}',
                                                            trimLines: 3,
                                                            colorClickableText: Colors.pink,
                                                            trimMode: TrimMode.Line,
                                                            trimCollapsedText: 'Show more',
                                                            trimExpandedText: ' Show less',
                                                            moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                                            lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
                                                        ),
                            
                                                        SizedBox(height: 10,),
                                        
                                                        post.image != null ?
                                                            OctoImage(
                                                                image: CachedNetworkImageProvider("$baseURL${post.image}"),
                                                                placeholderBuilder: OctoPlaceholder.blurHash(
                                                                    'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                                                                ),
                                                                errorBuilder: OctoError.icon(color: redCustomButton),
                                                                fit: BoxFit.cover,
                                                                width: MediaQuery.of(context).size.width,
                                                                height: 180
                                                            )
                                                        : SizedBox(height: post.image != null ? 0 : 10,),
                                                            post.imagePosts?.length != 0 ?
                                                                Column(
                                                                    children: [
                                                                        CarouselSlider(
                                                                            options: CarouselOptions(
                                                                                height: 180,
                                                                                viewportFraction: 1,
                                                                                autoPlay: true,
                                                                                autoPlayInterval: const Duration(seconds: 5),
                                                                                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                                                                autoPlayCurve: Curves.fastOutSlowIn,
                                                                                pauseAutoPlayOnTouch: true,
                                                                                aspectRatio: 2.0,
                                                                                enableInfiniteScroll: false,
                                                                                onPageChanged: (index, reason) {
                                                                                    setState(() {
                                                                                        _current = index;
                                                                                    });
                                                                                },
                                                                            ),
                                                                            items: post.imagePosts!.map((i) {
                                                                                return Builder(
                                                                                    builder: (BuildContext context) {
                                                                                        return Container(
                                                                                            width: MediaQuery.of(context).size.width,
                                                                                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                                                                            decoration: BoxDecoration(
                                                                                                color: greenCustomButton,
                                                                                                borderRadius: BorderRadius.circular(10)
                                                                                            ),
                                                                                            child: ClipRRect(
                                                                                                borderRadius: BorderRadius.circular(10),
                                                                                                child: CachedNetworkImage(
                                                                                                    imageUrl: "$storage${i.path}",
                                                                                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: primary)),
                                                                                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                                                                                    fit: BoxFit.cover,
                                                                                                ),
                                                                                            ),
                                                                                        );
                                                                                    },
                                                                                );
                                                                            }).toList(),
                                                                        ),
                                                                        post.imagePosts!.length > 1
                                                                        ? Row(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: post.imagePosts!.asMap().entries.map((entry) {
                                                                            final itemIndex = entry.key;
                                                                            return Container(
                                                                                width: _current == itemIndex ? 20.0 : 10.0,
                                                                                height: 8.0,
                                                                                margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                                                                                decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(20),
                                                                                color: _current == itemIndex
                                                                                    ? primary
                                                                                    : const Color.fromRGBO(0, 0, 0, 0.1),
                                                                                ),
                                                                            );
                                                                            }).toList(),
                                                                        )
                                                                        : const SizedBox(),
                                                                    ],
                                                                ) : SizedBox(height: 10,),
                                                        Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                                Padding(
                                                                    padding: const EdgeInsets.only(top: 10,bottom: 5),
                                                                    child: Container(
                                                                        padding: const EdgeInsets.symmetric(vertical:12,horizontal: 25),
                                                                        decoration: BoxDecoration(
                                                                            border: Border.all(color: Colors.grey.withOpacity(0.03)),
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            color: Colors.grey.withOpacity(0.03)
                                                                        ),
                                                                        child: Row(
                                                                            children: [
                                                                                LikeButton(
                                                                                    size: 25,
                                                                                    isLiked: post.selfLiked ?? false,
                                                                                    circleColor: const CircleColor(
                                                                                        start: primary,
                                                                                        end: primary,
                                                                                    ),
                                                                                    bubblesColor: const BubblesColor(
                                                                                        dotPrimaryColor: redCustomButton,
                                                                                        dotSecondaryColor: redCustomText
                                                                                    ),
                                                                                    likeBuilder: (bool isLiked) {
                                                                                        return Icon(
                                                                                            isLiked ? Icons.favorite : Icons.favorite_border,
                                                                                            color: isLiked ? Colors.red : Colors.black54,
                                                                                            size: 25,
                                                                                        );
                                                                                    },
                                                                                    likeCountPadding: const EdgeInsets.only(left: 5),
                                                                                    likeCount: post.likesCount ?? 0,
                                                                                    countBuilder: (int? count, bool isLiked, String text) {
                                                                                        var color = isLiked ? Colors.red : Colors.black54;
                                                                                        Widget result;
                                                                                        if (count == 0) {
                                                                                            result = Text(
                                                                                                "J'aime",
                                                                                                style: TextStyle(color: color),
                                                                                            );
                                                                                        } else {
                                                                                            result = Text(
                                                                                                    text,
                                                                                                style: TextStyle(color: color),
                                                                                            );
                                                                                        }
                                                                                        return result;
                                                                                    },
                                                                                    onTap: (isLiked) {
                                                                                        return _handlePostLikeDislike(isLiked, post.id ?? 0);
                                                                                    },
                                                                                ),
                                                                            ],
                                                                        ),
                            
                                                                    )
                                                                ),
                                                                Padding(padding:
                                                                    const EdgeInsets.only(top: 5,bottom: 5,left: 110),
                                                                    child: Container(
                                                                        padding: const EdgeInsets.symmetric(vertical:12,horizontal: 25),
                                                                        margin: const EdgeInsets.only(right: 10),
                                                                        decoration: BoxDecoration(
                                                                            border: Border.all(color: Colors.grey.withOpacity(0.03)),
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            color: Colors.grey.withOpacity(0.03)
                                                                        ),
                                                                        child: InkWell(
                                                                            onTap: (){
                                                                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CommentScreen(
                                                                                    postId: post.id,
                                                                                )));
                                                                            },
                                                                            child: Row(
                                                                                children: [
                                                                                    const Icon(Icons.sms_outlined, size: 25, color: Colors.black54,),
                                                                                    const SizedBox(width:4),
                                                                                    Text('${post.commentsCount ?? 0}')
                                                                                ],
                                                                            ),
                                                                        ),
                                                                    ),
                                                                ),
                                                            ],
                                                        ),
                                                    ],
                                                ),
                                            ),
                                        );
                                    }
                                ),
                            )
                        )
                    ],
                ),
            );
    }

    // likes and comment btn
    Expanded kLikeAndComment (int value, IconData icon, Color color, Function onTap) {
        return Expanded(
            child: Material(
                color: Colors.white,
                child: InkWell(
                    onTap: () => onTap(),
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical:10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Icon(icon, size: 22, color: color,),
                                SizedBox(width:4),
                                Text('$value')
                            ],
                        ),
                    ),
                ),
            ),
        );
    }
}