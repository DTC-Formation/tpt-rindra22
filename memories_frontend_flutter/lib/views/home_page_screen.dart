import 'package:memories_frontend_flutter/helpers/colors.dart';
import 'package:memories_frontend_flutter/helpers/config.dart';
import 'package:memories_frontend_flutter/models/api_response.dart';
import 'package:memories_frontend_flutter/models/user.dart';
import 'package:memories_frontend_flutter/services/user_services.dart';
import 'package:memories_frontend_flutter/views/login_screen.dart';
import 'package:memories_frontend_flutter/views/post_form.dart';
import 'package:memories_frontend_flutter/views/post_screen.dart';
import 'package:memories_frontend_flutter/views/profil_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memories_frontend_flutter/views/widgets/text_field.dart';

String currentSelectedPage = 'Memories';
class HomePageScreen extends StatefulWidget {
    const HomePageScreen({super.key});

    @override
    State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> with TickerProviderStateMixin{
   
    late TabController? tabController;

    final PageController _pageController = PageController();

    List pages = [
        const PostScreen(),
        const PostForm(),
        const ProfilScreen(),
    ];

     int currentIndex = 0;

    List<Tab> myTabs = [
        const Tab(
            icon: Icon(Icons.home_outlined),
            text: "Home",
        ),
        const Tab(
            icon: Icon(Icons.add_circle_outline),
            text: "Add Memories",
        ),
        const Tab(
            icon: Icon(Icons.person_outline),
            text: "Profil",
        ),
    ];

    void _getUserDetail() async{
        ApiResponse response = await getUserDetail();
        if(response.error == null){
            User user = response.data as User;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${user.name}')
            ));
        }
        else if(response.error == unauthorized){
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login()), (route) => false);
        }
        else{
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${response.error}')
            ));
        }
    }

    @override
      initState(){
        _getUserDetail();
        tabController = TabController(length: myTabs.length, vsync: this, initialIndex: currentIndex);
        super.initState();
    }

    @override
    void dispose() {
        tabController!.dispose();
        super.dispose();
    }

    void onTap(int selectedIndex) {
        setState(() {
            currentIndex = selectedIndex;
        });
        tabController!.animateTo(currentIndex);
        currentSelectedPage = currentIndex == 0
            ? 'Memories'
            : currentIndex == 1
                ? 'Add Memories'
                : 'Profile';
        _pageController.jumpToPage(currentIndex);
    }
    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Stack(
                        children: [
                            PositionedDirectional(
                                top: 0,
                                start: 0,
                                end: 0,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                        InkWell(
                                            child: Row(
                                                children: [
                                                    Container(
                                                        padding: const EdgeInsetsDirectional.all(3),
                                                        height: 60,
                                                        width: 60,
                                                        child: SvgPicture.asset("${imageLogoPath}logo.svg",width:10,color: primary,)
                                                    ),
                                                    const SizedBox(width: 15),
                                                    Text(
                                                        currentSelectedPage,
                                                        style: const TextStyle(
                                                            color: primary,
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.w600,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                            onTap: () {
                                                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                                            },
                                        ),
                                        Row(
                                            children: [
                                                IconButton(
                                                    splashRadius: 1,
                                                    onPressed: () {
                                                    
                                                    },
                                                    icon: const Icon(
                                                        Icons.notifications_none,
                                                        color: primary,
                                                    )
                                                ),
                                                // logout
                                                IconButton(
                                                    splashRadius: 1,
                                                    onPressed: () {
                                                        logout().then((value) => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Login()), (route) => false));
                                                    },
                                                    icon: const Icon(
                                                        Icons.logout,
                                                        color: primary,
                                                    )
                                                ),
                                            ],
                                        )
                                    ],
                                ),
                            ),
                            PositionedDirectional(
                                top: 105,
                                bottom: 5,
                                start: 5,
                                end: 5,
                                child: PageView(
                                    allowImplicitScrolling: true,
                                    controller: _pageController,
                                    onPageChanged: (int index) {
                                        onTap(index);
                                    },
                                    children: const <Widget>[
                                        PostScreen(),
                                        PostForm(),
                                        ProfilScreen(),
                                    ],
                                ),
                            ),
                            PositionedDirectional(
                                bottom: 5,
                                start: 5,
                                end: 5,
                                child: Container(
                                    decoration: BoxDecoration(
                                        boxShadow: const [
                                            BoxShadow(
                                            offset: Offset(2, 2),
                                            blurRadius: 10,
                                            color: Color.fromRGBO(0, 0, 0, 0.16),
                                            ),
                                        ],
                                        borderRadius: BorderRadius.circular(17),
                                        color: white,
                                    ),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: TabBar(
                                                onTap: onTap,
                                                labelColor: white,
                                                unselectedLabelColor: primary,
                                                controller: tabController,
                                                indicatorSize: TabBarIndicatorSize.tab,
                                                indicator: const BoxDecoration(
                                                    color: primary,
                                                ),
                                            tabs: myTabs,
                                        ),
                                    ),
                                ),
                            )
                        ],
                    )
                ),
            ),
        );
    }
}