import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../assets/ColorCodes.dart';
import '../../assets/images.dart';
import '../../constants/IConstants.dart';
import '../../constants/features.dart';
import '../../controller/mutations/address_mutation.dart';
import '../../controller/mutations/cart_mutation.dart';
import '../../controller/mutations/home_screen_mutation.dart';
import '../../controller/mutations/home_store_mutation.dart';
import '../../data/calculations.dart';
import '../../generated/l10n.dart';
import '../../models/VxModels/VxStore.dart';
import '../../models/newmodle/home_page_modle.dart';
import '../../models/newmodle/home_store_modle.dart';
import '../../models/newmodle/user.dart';
import '../../providers/advertise1items.dart';
import '../../providers/sellingitems.dart';
import '../../repository/authenticate/AuthRepo.dart';
import '../../repository/fetchdata/view_all_product.dart';
import '../../rought_genrator.dart';
import '../../screens/customer_support_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/profile_screen.dart';
import '../../utils/ResponsiveLayout.dart';
import '../../utils/prefUtils.dart';
import '../../widgets/CarouselSliderimageWidget.dart';
import '../../widgets/MultivendorOffersWidget.dart';
import '../../widgets/advertisemultivendor_items.dart';
import '../../widgets/StoreBottomNavigationWidget.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/carousel_slider_store.dart';
import '../../widgets/categoryOne.dart';
import '../../widgets/categoryOnemultivendor.dart';
import '../../widgets/floatbuttonbadge.dart';
import '../../widgets/footer.dart';
import '../../widgets/header.dart';
import '../../widgets/nearby_shop.dart';
import '../../widgets/simmers/ItemWeb_shimmer.dart';
import '../../widgets/simmers/home_screen_shimmer.dart';
import '../../widgets/simmers/item_list_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

import '../providers/branditems.dart';

class StoreScreen extends StatefulWidget {
  static const routeName = '/store-screen';
  const StoreScreen({Key? key}) : super(key: key);
  static  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with Navigations {
  bool _isDelivering = true;
  bool iphonex = false;
  bool _isinternet = true;
  Future<OfferByCart>?  futureproducts ;
  var name = "",
      email = "",
      photourl = "",
      phone = "";
  int count =0;
  var _isLoading = true;
  String? title;
  bool _isWeb =false;
  final storedata = (VxState.store as GroceStore).homestore;
  DateTime? currentBackPressTime;
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero, () async {
      //prefs = await SharedPreferences.getInstance();
      final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      //debugPrint("routeArgs..."+widget.params['seeallpress'].toString());
      final seeallpress = "featured";

      auth.getuserProfile(onsucsess: (value){
        debugPrint("getuserprofile.....onsucsess");
        HomeStoreScreenController(user: PrefUtils.prefs!.getString("apikey") ?? PrefUtils.prefs!.getString("ftokenid"),  lat: (VxState.store as GroceStore).userData.latitude??PrefUtils.prefs!.getString("latitude"),
            long: (VxState.store as GroceStore).userData.longitude??PrefUtils.prefs!.getString("longitude"));
      }, onerror: (){
        debugPrint("getuserprofile.....onerror");
        HomeStoreScreenController(user: PrefUtils.prefs!.getString("apikey") ?? PrefUtils.prefs!.getString("ftokenid"),  lat: (VxState.store as GroceStore).userData.latitude??PrefUtils.prefs!.getString("latitude"),
            long: (VxState.store as GroceStore).userData.longitude??PrefUtils.prefs!.getString("longitude"));
      });
      try {
        if (Platform.isIOS) {
          setState(() {
            _isWeb = false;
            iphonex = MediaQuery
                .of(context)
                .size
                .height >= 812.0;
          });
        } else {
          setState(() {
            _isWeb = false;
          });
        }
      } catch (e) {
        setState(() {
          _isWeb = true;
        });
      }
      int _nestedIndex = 0;
    });
  }
  Future<void> _refreshProducts(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      setState(() {_isinternet = true;});
    } else if (connectivityResult == ConnectivityResult.wifi) {
      setState(() {_isinternet = true;});
    } else {
      Fluttertoast.showToast(
        msg: "No internet connection!!!", fontSize: MediaQuery
          .of(context)
          .textScaleFactor * 13,);
      setState(() {
        _isinternet = false;
      });
    }

    auth.getuserProfile(onsucsess: (value){
      debugPrint("getuserprofile.....onsucsess");
      HomeStoreScreenController(user: PrefUtils.prefs!.getString("apikey") ?? PrefUtils.prefs!.getString("ftokenid"),  lat: (VxState.store as GroceStore).userData.latitude??PrefUtils.prefs!.getString("latitude"),
          long: (VxState.store as GroceStore).userData.longitude??PrefUtils.prefs!.getString("longitude"));
    }, onerror: (){
    });
  }
  void launchWhatsApp() async {
    String phone = /*"+918618320591"*/IConstants.secondaryMobile;
    debugPrint("Whatsapp . .. . . .. . .");
    String url() {
      if (Platform.isIOS) {
        debugPrint("Whatsapp1 . .. . . .. . .");
        return "whatsapp://wa.me/$phone/?text=${Uri.parse('I want to order Grocery')}";
      } else {
        return "whatsapp://send?phone=$phone&text=${Uri.parse('I want to order Grocery')}";
        const url = "https://wa.me/?text=YourTextHere";

      }
    }
    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }

  Widget Carousel(Home_Store storedata){
    return Container(
      padding: EdgeInsets.only(left: 15, right: 10),
      child: CarouselSliderStoreimage(fromScreen: "StoreScreen",homedata: storedata,),
      //CarouselSliderStoreimage("StoreScreen",storedata),
    );
  }
  Widget Category(Home_Store storedata){
    return
      Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: [
          (storedata.data!.featuredCategoryTags!.length>0)?
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storedata.data!.categoryTagsLabel!,//"Categories",
                    style: TextStyle(
                        fontSize: ResponsiveLayout.isSmallScreen(context)
                            ? 20.0
                            : 24.0,
                        color: ColorCodes.blackColor,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5,),
                  Text(
                    storedata.data!.categoryTagsLabelsub!,//"Eat what makes you happy",
                    style: TextStyle(
                        fontSize: ResponsiveLayout.isSmallScreen(context)
                            ? 15.0
                            : 16.0,
                        color: ColorCodes.grey,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Spacer(),
              if(Features.view_all)
                Text(
                  S.of(context).view_all, //'View All',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: ColorCodes.discount),
                ),
            ],
          ):SizedBox.shrink(),
          SizedBox(height: 10,),
          (storedata.data!.featuredTagsBanner!.length>0)?
          MouseRegion(
            cursor: MouseCursor.uncontrolled,
            child: SizedBox(
              height: 105,
              child: ListView.builder(
                  shrinkWrap: true,
                  controller: new ScrollController(keepScrollOffset: false),
                  itemCount: storedata.data!.featuredTagsBanner!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) =>
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if (storedata.data!.featuredTagsBanner![i].bannerFor ==
                                "8") {
                              String prevbranch = PrefUtils.prefs!.getString("branch")!;
                              PrefUtils.prefs!.setString("prevbranch", prevbranch);
                              print("store tap..."+prevbranch.toString()+"....."+PrefUtils.prefs!.getString("prevbranch")!);
                              PrefUtils.prefs!.setString("branch",storedata.data!.featuredTagsBanner![i].stores!.toString());
                              print("store tap...branch"+storedata.data!.featuredTagsBanner![i].stores!.toString()+"....."+PrefUtils.prefs!.getString("branch")!);
                              GroceStore store = VxState.store;
                              store.homescreen.data = null;
                              IConstants.storename = storedata.data!.featuredTagsBanner![i].title.toString();
                              Navigation(context,name: Routename.Home,navigatore: NavigatoreTyp.Push,
                              );
                              BrandItemsList().GetRestaurantNew(PrefUtils.prefs!.getString("branch")!,()async {
                              });
                            }

                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 5),
                            child:  Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  //padding: const EdgeInsets.only(left:20.0,right: 5.0,top: 5.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: storedata.data!.featuredTagsBanner![i].bannerImage,
                                      placeholder: (context, url) =>    Shimmer.fromColors(
                                          baseColor: /*Color(0xffd3d3d3)*/Colors.grey[200]!,
                                          highlightColor: /*Color(0xffeeeeee)*/Colors.grey[200]!,
                                          child: Image.asset(Images.defaultCategoryImg))/*_horizontalshimmerslider()*/,
                                      errorWidget: (context, url, error) => Image.asset(Images.defaultCategoryImg),
                                      height: ResponsiveLayout.isSmallScreen(context)?105:120,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ],
                            ) ,
                            // )
                          ),
                        ),
                      )
              ),
            ),
          ): SizedBox.shrink(),
          (storedata.data!.featuredCategoryTags!.length>0)?
          CategoryOneMultiVendor(
              storedata):  SizedBox.shrink(),

        ],
      ),
    );
  }



  Widget loadhomeScreen() {
      double deviceWidth = MediaQuery.of(context).size.width;
      int widgetsInRow = 1;
      MediaQueryData queryData;
      queryData = MediaQuery.of(context);
      double wid= queryData.size.width;
      double maxwid=wid*0.90;
      if (deviceWidth > 1200) {
        widgetsInRow = 5;
      } else if (deviceWidth > 768) {
        widgetsInRow = 3;
      }
      // double aspectRatio = (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160;
      double aspectRatio =   (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
      (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 372:
      (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 115;
    final storedata = (VxState.store as GroceStore).homestore;

    if (storedata.data != null)
      return SingleChildScrollView(
          child: _isinternet
              ?
          VxBuilder(
              mutations: {SetPrimeryLocation},
              builder: (context,  value, widget) {
               /* print("store data...length.."+storedata.data!.nearestStores!.length.toString()+"...."+_isDelivering.toString()+"....//"+value.userData.delevrystatus!.toString());
                print("store length...."+PrefUtils.prefs!.getBool("deliverystatus").toString());*/
                bool? deliverystatus = PrefUtils.prefs!.getBool("deliverystatus"); /*value.userData.delevrystatus??*/
                print("store length....delivery stattus"+value.userData.delevrystatus.toString()+deliverystatus.toString());
                return !deliverystatus!?
                SingleChildScrollView(
                  child: Center(
                    child: Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  left: 80.0, right: 80.0),
                              width:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .width,
                              height: 200.0,
                              child: new Image.asset(
                                  Images.notDeliveringImg)),
                          SizedBox(
                            height: 10.0,
                          ),
                          if(value.userData.area!=null)
                            Text(
                                S.of(context)
                                    .sorry_wedidnt_deliever +
                                    // "Sorry, we don't deliver in " +
                                    value.userData.area.toString()),
                          GestureDetector(
                            onTap: () {
                              PrefUtils.prefs!.setString(
                                  "formapscreen", "homescreen");
                              /*Navigator.of(context)
                                  .pushNamed(MapScreen.routeName);*/
                              Navigation(context, name:Routename.MapScreen,navigatore: NavigatoreTyp.Push);
                            },
                            child: Container(
                              width: 100.0,
                              height: 40.0,
                              margin: EdgeInsets.only(top: 20.0),
                              decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .accentColor,
                                borderRadius:
                                BorderRadius.circular(3.0),
                              ),
                              child: Center(
                                  child: Text(
                                    S
                                        .of(context)
                                        .change_location,
                                    //'Change Location',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white),
                                  )),
                            ),
                          ),
                          if (Vx.isWeb)Footer(
                            address: PrefUtils.prefs!.getString("restaurant_address")!,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    :
                _isDelivering
                    ? storedata != null ?
                Column(
                    children: <Widget>[
                       Carousel(storedata),
                      SizedBox(height: 15,),
                      Category(storedata),
                      SizedBox(height: 20,),
                      _featuredItemMobile(storedata),
                      SizedBox(height: 15,),
                      advertisemultivendor(storedata),
                      SizedBox(height: 15,),
                      _allShopsNearBy(storedata)
                      // Align(
                      //   alignment: Alignment.center,
                      //   child: Container(
                      //     child:
                      //     FutureBuilder<OfferByCart> (
                      //       future: futureproducts,
                      //       builder: (BuildContext context, AsyncSnapshot<OfferByCart> snapshot){
                      //         final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
                      //         final seeallpress = "featured";
                      //         switch(snapshot.connectionState){
                      //
                      //           case ConnectionState.none:
                      //             return SizedBox.shrink();
                      //             // TODO: Handle this case.
                      //             break;
                      //           case ConnectionState.waiting:
                      //             return (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))
                      //                 ? ItemListShimmerWeb()
                      //                 : ItemListShimmer();
                      //         // TODO: Handle this case.
                      //           default:
                      //           //print("selling.."+snapshot.data!.data!.length.toString());
                      //             if(snapshot.data!=null)
                      //               return
                      //                 Column(
                      //                     children:[
                      //                       Row(
                      //                         children: <Widget>[
                      //                           SizedBox(
                      //                             width: 10.0,
                      //                           ),
                      //                           Text(
                      //                             S.of(context).all_shop_nearby,
                      //                             style: TextStyle(
                      //                                 fontSize: ResponsiveLayout.isSmallScreen(context)
                      //                                     ? 20.0
                      //                                     : 23.0,
                      //                                 color: ColorCodes.blackColor,
                      //                                 fontWeight: FontWeight.bold),
                      //                           ),
                      //                           /*Spacer(),
                      //                      MouseRegion(
                      //                        cursor: SystemMouseCursors.click,
                      //                        child: GestureDetector(
                      //                          onTap: () {
                      //                            *//*    Navigator.of(context)
                      //               .pushNamed(SellingitemScreen.routeName, arguments: {
                      //             'seeallpress': "featured",
                      //             'title': storedata.data!.featuredByCart!.label,
                      //           });*//*
                      //                            Navigation(context, name: Routename.SellingItem, navigatore: NavigatoreTyp.Push,
                      //                                parms: {"seeallpress": "featured",});
                      //                          },
                      //                          child: Text(
                      //                            S
                      //                                .of(context)
                      //                                .view_all, //'View All',
                      //                            textAlign: TextAlign.center,
                      //                            style: TextStyle(
                      //                                fontWeight: FontWeight.bold,
                      //                                fontSize: 14,
                      //                                color: Theme
                      //                                    .of(context)
                      //                                    .primaryColor),
                      //                          ),
                      //                        ),
                      //                      ),
                      //                      SizedBox(
                      //                        width: 10,
                      //                      ),*/
                      //                         ],
                      //                       ),
                      //                       SizedBox(height: 8.0),
                      //                       GridView.builder(
                      //                           shrinkWrap: true,
                      //                           itemCount:snapshot.data!.data!.length,
                      //                           controller: new ScrollController(keepScrollOffset: false),
                      //                           gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      //                             /*crossAxisCount: 2,
                      //                       childAspectRatio: 0.55,
                      //                       crossAxisSpacing: 3,
                      //                       mainAxisSpacing: 3,*/
                      //                             crossAxisCount: widgetsInRow,
                      //                             crossAxisSpacing: 3,
                      //                             childAspectRatio: aspectRatio,
                      //                             mainAxisSpacing: 3,
                      //                           ),
                      //                           itemBuilder: (BuildContext context, int index) {
                      //                             return NearShop("sellingitem_screen","featured".toString(), snapshot.data!.data![index],"");
                      //                             /* return SellingItems(
                      //                      "sellingitem_screen",
                      //                      snapshot.data.data[index].id,
                      //                      snapshot.data.data[index].title,
                      //                      snapshot.data.data[index].imageUrl,
                      //                      snapshot.data.data[index].brand,
                      //                      "",
                      //                      snapshot.data.data[index].veg_type,
                      //                      snapshot.data.data[index].type,
                      //                      snapshot.data.data[index].eligible_for_express,
                      //                      snapshot.data.data[index].delivery,
                      //                      snapshot.data.data[index].duration,
                      //                      snapshot.data.data[index].durationType,
                      //                      snapshot.data.data[index].note,
                      //                      snapshot.data.data[index].subscribe,
                      //                      snapshot.data.data[index].paymentmode,
                      //                      snapshot.data.data[index].cronTime,
                      //                      snapshot.data.data[index].name,
                      //
                      //                    );*/
                      //                           }),
                      //                     ]
                      //
                      //                 );
                      //             else
                      //               return SizedBox.shrink();
                      //         }
                      //
                      //       },
                      //     ),
                      //   ),
                      //
                      // ),

                    ]
                )
                    : SizedBox.shrink() :
                SingleChildScrollView(
                  child: Center(
                    child: Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  left: 80.0, right: 80.0),
                              width:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .width,
                              height: 200.0,
                              child: new Image.asset(
                                  Images.notDeliveringImg)),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                              S
                                  .of(context)
                                  .sorry_wedidnt_deliever +
                                  // "Sorry, we don't deliver in " +
                                  PrefUtils.prefs!.getString(
                                      "deliverylocation")!),
                          GestureDetector(
                            onTap: () {
                              PrefUtils.prefs!.setString(
                                  "formapscreen", "homescreen");
                              /* Navigator.of(context)
                                  .pushNamed(MapScreen.routeName);*/
                              Navigation(context, name:Routename.MapScreen,navigatore: NavigatoreTyp.Push);
                            },
                            child: Container(
                              width: 100.0,
                              height: 40.0,
                              margin: EdgeInsets.only(top: 20.0),
                              decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .accentColor,
                                borderRadius:
                                BorderRadius.circular(3.0),
                              ),
                              child: Center(
                                  child: Text(
                                    S
                                        .of(context)
                                        .change_location,
                                    //'Change Location',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white),
                                  )),
                            ),
                          ),
                          if (Vx.isWeb)Footer(
                            address: PrefUtils.prefs!.getString(
                                "restaurant_address")!,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }) :
          SingleChildScrollView(
            child: Center(
              child: Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            left: 80.0, right: 80.0),
                        width:
                        MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: 200.0,
                        child: new Image.asset(
                            Images.notDeliveringImg)),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                        S.of(context)
                            .sorry_wedidnt_deliever +
                            // "Sorry, we don't deliver in " +
                            PrefUtils.prefs!.getString(
                                "deliverylocation")!),
                    GestureDetector(
                      onTap: () {
                        PrefUtils.prefs!.setString(
                            "formapscreen", "homescreen");
                        /*Navigator.of(context)
                            .pushNamed(MapScreen.routeName);*/
                        Navigation(context, name:Routename.MapScreen,navigatore: NavigatoreTyp.Push);
                      },
                      child: Container(
                        width: 100.0,
                        height: 40.0,
                        margin: EdgeInsets.only(top: 20.0),
                        decoration: BoxDecoration(
                          color: Theme
                              .of(context)
                              .accentColor,
                          borderRadius:
                          BorderRadius.circular(3.0),
                        ),
                        child: Center(
                            child: Text(
                              S
                                  .of(context)
                                  .change_location, //'Change Location',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                    ),
                    if (Vx.isWeb)Footer(
                      address: PrefUtils.prefs!.getString(
                          "restaurant_address")!,
                    ),
                  ],
                ),
              ),
            ),
          )

      );
    else {
      auth.getuserProfile(onsucsess: (value){
        debugPrint("getuserprofile.....onsucsess");
        HomeStoreScreenController(user: PrefUtils.prefs!.getString("apikey") ?? PrefUtils.prefs!.getString("ftokenid"),  lat: (VxState.store as GroceStore).userData.latitude??PrefUtils.prefs!.getString("latitude"),
            long: (VxState.store as GroceStore).userData.longitude??PrefUtils.prefs!.getString("longitude") );
      }, onerror: (){
      });
     // HomeStoreScreenController(user: PrefUtils.prefs!.getString("apikey") ?? PrefUtils.prefs!.getString("ftokenid"), lat: (VxState.store as GroceStore).userData.latitude,long: (VxState.store as GroceStore).userData.longitude );

      return (kIsWeb && !ResponsiveLayout.isSmallScreen(context))
          ? HomeScreenShimmer()
          : HomeScreenShimmer();
    }
  }



  // Widget loadhomeScreen() {
  //   double deviceWidth = MediaQuery.of(context).size.width;
  //   int widgetsInRow = 1;
  //   MediaQueryData queryData;
  //   queryData = MediaQuery.of(context);
  //   double wid= queryData.size.width;
  //   double maxwid=wid*0.90;
  //   if (deviceWidth > 1200) {
  //     widgetsInRow = 5;
  //   } else if (deviceWidth > 768) {
  //     widgetsInRow = 3;
  //   }
  //   // double aspectRatio = (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160;
  //   double aspectRatio =   (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
  //   (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 372:
  //   (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 115;
  //   final storedata = (VxState.store as GroceStore).homestore;
  //     return
  //       Column(
  //         children: <Widget>[
  //           Carousel(storedata),
  //           SizedBox(height: 15,),
  //           Category(),
  //           SizedBox(height: 15,),
  //           //_featuredItemMobile(storedata),
  //           SizedBox(height: 15,),
  //           // Align(
  //           //   alignment: Alignment.center,
  //           //   child: Container(
  //           //     child:
  //           //     FutureBuilder<OfferByCart> (
  //           //       future: futureproducts,
  //           //       builder: (BuildContext context, AsyncSnapshot<OfferByCart> snapshot){
  //           //         final routeArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  //           //         final seeallpress = "featured";
  //           //         switch(snapshot.connectionState){
  //           //
  //           //           case ConnectionState.none:
  //           //             return SizedBox.shrink();
  //           //             // TODO: Handle this case.
  //           //             break;
  //           //           case ConnectionState.waiting:
  //           //             return (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))
  //           //                 ? ItemListShimmerWeb()
  //           //                 : ItemListShimmer();
  //           //         // TODO: Handle this case.
  //           //           default:
  //           //           //print("selling.."+snapshot.data!.data!.length.toString());
  //           //             if(snapshot.data!=null)
  //           //               return
  //           //                 Column(
  //           //                     children:[
  //           //                       Row(
  //           //                         children: <Widget>[
  //           //                           SizedBox(
  //           //                             width: 10.0,
  //           //                           ),
  //           //                           Text(
  //           //                             S.of(context).all_shop_nearby,
  //           //                             style: TextStyle(
  //           //                                 fontSize: ResponsiveLayout.isSmallScreen(context)
  //           //                                     ? 20.0
  //           //                                     : 23.0,
  //           //                                 color: ColorCodes.blackColor,
  //           //                                 fontWeight: FontWeight.bold),
  //           //                           ),
  //           //                           /*Spacer(),
  //           //                      MouseRegion(
  //           //                        cursor: SystemMouseCursors.click,
  //           //                        child: GestureDetector(
  //           //                          onTap: () {
  //           //                            *//*    Navigator.of(context)
  //           //               .pushNamed(SellingitemScreen.routeName, arguments: {
  //           //             'seeallpress': "featured",
  //           //             'title': storedata.data!.featuredByCart!.label,
  //           //           });*//*
  //           //                            Navigation(context, name: Routename.SellingItem, navigatore: NavigatoreTyp.Push,
  //           //                                parms: {"seeallpress": "featured",});
  //           //                          },
  //           //                          child: Text(
  //           //                            S
  //           //                                .of(context)
  //           //                                .view_all, //'View All',
  //           //                            textAlign: TextAlign.center,
  //           //                            style: TextStyle(
  //           //                                fontWeight: FontWeight.bold,
  //           //                                fontSize: 14,
  //           //                                color: Theme
  //           //                                    .of(context)
  //           //                                    .primaryColor),
  //           //                          ),
  //           //                        ),
  //           //                      ),
  //           //                      SizedBox(
  //           //                        width: 10,
  //           //                      ),*/
  //           //                         ],
  //           //                       ),
  //           //                       SizedBox(height: 8.0),
  //           //                       GridView.builder(
  //           //                           shrinkWrap: true,
  //           //                           itemCount:snapshot.data!.data!.length,
  //           //                           controller: new ScrollController(keepScrollOffset: false),
  //           //                           gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
  //           //                             /*crossAxisCount: 2,
  //           //                       childAspectRatio: 0.55,
  //           //                       crossAxisSpacing: 3,
  //           //                       mainAxisSpacing: 3,*/
  //           //                             crossAxisCount: widgetsInRow,
  //           //                             crossAxisSpacing: 3,
  //           //                             childAspectRatio: aspectRatio,
  //           //                             mainAxisSpacing: 3,
  //           //                           ),
  //           //                           itemBuilder: (BuildContext context, int index) {
  //           //                             return NearShop("sellingitem_screen","featured".toString(), snapshot.data!.data![index],"");
  //           //                             /* return SellingItems(
  //           //                      "sellingitem_screen",
  //           //                      snapshot.data.data[index].id,
  //           //                      snapshot.data.data[index].title,
  //           //                      snapshot.data.data[index].imageUrl,
  //           //                      snapshot.data.data[index].brand,
  //           //                      "",
  //           //                      snapshot.data.data[index].veg_type,
  //           //                      snapshot.data.data[index].type,
  //           //                      snapshot.data.data[index].eligible_for_express,
  //           //                      snapshot.data.data[index].delivery,
  //           //                      snapshot.data.data[index].duration,
  //           //                      snapshot.data.data[index].durationType,
  //           //                      snapshot.data.data[index].note,
  //           //                      snapshot.data.data[index].subscribe,
  //           //                      snapshot.data.data[index].paymentmode,
  //           //                      snapshot.data.data[index].cronTime,
  //           //                      snapshot.data.data[index].name,
  //           //
  //           //                    );*/
  //           //                           }),
  //           //                     ]
  //           //
  //           //                 );
  //           //             else
  //           //               return SizedBox.shrink();
  //           //         }
  //           //
  //           //       },
  //           //     ),
  //           //   ),
  //           //
  //           // ),
  //
  //           ]
  //     );
  //
  // }


  Widget advertisemultivendor(Home_Store homedata) {
    /* return StreamBuilder(
      stream: bloc.featuredAdsOne,
      builder: (context, AsyncSnapshot<List<BrandsFields>> snapshot) {*/

    /*  if (snapshot.hasData) {
          if (snapshot.data.isNotEmpty) {*/
    if (homedata.data!.featuredCategories1!.length > 0) {
      double deviceWidth = MediaQuery
          .of(context)
          .size
          .width;
      int widgetsInRow = (Vx.isWeb &&
          !ResponsiveLayout.isSmallScreen(context)) ? 1 : 2;
      if (deviceWidth > 1200) {
        widgetsInRow = 2;
      } else if (deviceWidth < 768) {
        widgetsInRow = 1;
      }
      double aspectRatio = (Vx.isWeb &&
          !ResponsiveLayout.isSmallScreen(context)) ?
      (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow /
          350 :
      (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow /
          80;
      return GridView.builder(

        //scrollDirection: Axis.vertical,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widgetsInRow,
          crossAxisSpacing: 3,
          childAspectRatio: aspectRatio,

        ),
        shrinkWrap: true,
        controller: new ScrollController(keepScrollOffset: false),
        itemCount: homedata.data!.featuredCategories1!.length,
        itemBuilder: (_, i) =>
            AdvertiseMultivendorItems(
              isvertical: 'home',
              fromScreen: "store",
              allbanners: homedata.data!.featuredCategories1![i],
             /* "horizontal",
              "storeScreen",
              homedata.data!.featuredCategories1![i],*/
            ),
      );
    } else {
      return /*_sliderShimmer()*/SizedBox.shrink();
    }

    /* }
          else return SizedBox.shrink();
        }else if (snapshot.hasError) {
          return Text("snap error . . . . .." + snapshot.error.toString());
        } else if(!snapshot.hasData) {
          return SizedBox.shrink();
        }*/

    /* },
    );*/


  }

  _allShopsNearBy(Home_Store storedata){
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 1;
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    double wid= queryData.size.width;
    double maxwid=wid*0.90;
    if (deviceWidth > 1200) {
      widgetsInRow = 5;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }
    // double aspectRatio = (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160;
    double aspectRatio =   (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 372:
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 120;
    final sellingitemData = Provider.of<SellingItemsList>(context, listen: false);
      if(storedata.data!.nearestStores!.length > 0)
        return Container(
          padding: EdgeInsets.only(right: 15.0, left: 15.0,bottom: 60),
          color: /*Color(0xFFFFE8E8).withOpacity(0.7)*/Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "All Shops Nearby",
                        style: TextStyle(
                            fontSize: ResponsiveLayout.isSmallScreen(context)
                                ? 20.0
                                : 24.0,
                            color: ColorCodes.blackColor,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        storedata.data!.featuredStoreLabelsub!,//"Big Savings on your Loved Eateries",
                        style: TextStyle(
                            fontSize: ResponsiveLayout.isSmallScreen(context)
                                ? 15.0
                                : 16.0,
                            color: ColorCodes.grey,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigation(context, name: Routename.StoreHome,
                            navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "view_all":"near_stores"
                            });
                      },
                      child: Text(
                        S
                            .of(context)
                            .view_all, //'View All',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: ColorCodes.discount),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              SizedBox(height: 10.0),
                                    GridView.builder(
                                        shrinkWrap: true,
                                        itemCount:storedata.data!.nearestStores!.length,
                                        controller: new ScrollController(keepScrollOffset: false),
                                        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                                          /*crossAxisCount: 2,
                                    childAspectRatio: 0.55,
                                    crossAxisSpacing: 3,
                                    mainAxisSpacing: 3,*/
                                          crossAxisCount: widgetsInRow,
                                          crossAxisSpacing: 3,
                                          childAspectRatio: aspectRatio,
                                          mainAxisSpacing: 3,
                                        ),
                                        itemBuilder: (BuildContext context, int index) {
                                          return   NearShop(fromScreen: "homescreen",storedata: storedata.data!.nearestStores![index],);

                                            //NearShop("homescreen", storedata.data!.nearestStores![index],);

                                        }),

            ],
          ),
        );
      else return SizedBox.shrink();
  }
  _featuredItemMobile(Home_Store storedata) {
    // final sellingitemData = Provider.of<SellingItemsList>(context, listen: false);
    // if (Features.isSellingItems)
      if(storedata.data!.featuredStores!.length > 0)
        return Container(
          padding: EdgeInsets.only(right: 15.0, left: 15.0),
          color: /*Color(0xFFFFE8E8).withOpacity(0.7)*/Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storedata.data!.featuredStoreLabel!,
                        style: TextStyle(
                            fontSize: ResponsiveLayout.isSmallScreen(context)
                                ? 20.0
                                : 24.0,
                            color: ColorCodes.blackColor,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        storedata.data!.featuredStoreLabelsub!,//"Big Savings on your Loved Eateries",
                        style: TextStyle(
                            fontSize: ResponsiveLayout.isSmallScreen(context)
                                ? 15.0
                                : 16.0,
                            color: ColorCodes.grey,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Spacer(),
                  if(Features.view_all)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigation(context, name: Routename.StoreHome,
                            navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "view_all":"stores"
                            });
                      },
                      child: Text(
                        S
                            .of(context)
                            .view_all, //'View All',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: ColorCodes.discount),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              SizedBox(
                  height: ResponsiveLayout.isSmallScreen(context) ?
                  200: 250,
                  child: new ListView.builder(
                    padding: EdgeInsets.only(right: 10),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: storedata.data!.featuredStores!.length,
                    itemBuilder: (_, i) {
                      return Column(
                        children: [
                          MultivendorOffers(
                            "home_screen",
                            storedata.data!.featuredStores![i],
                            ),
                            //sellingitemData.items[i].brand,
                      ]


                      );
                    },
                  )),
            ],
          ),
        );
      else return SizedBox.shrink();
  }

  Widget _body() {
    return SingleChildScrollView(
      child: VxBuilder(
        mutations: {HomeStoreScreenController},
        builder: (ctx, store, VxStatus? state) {

          if(VxStatus.success==state)
            return loadhomeScreen();
          else if(state==VxStatus.none){
            print("error loading screen");
            if((VxState.store as GroceStore).homestore.toJson().isEmpty) {
              auth.getuserProfile(onerror: () {
               HomeStoreScreenController(user: PrefUtils.prefs!.getString("apikey") ?? PrefUtils.prefs!.getString("ftokenid"),  lat: (VxState.store as GroceStore).userData.latitude??PrefUtils.prefs!.getString("latitude"),
                                long: (VxState.store as GroceStore).userData.longitude??PrefUtils.prefs!.getString("longitude") );
              }, onsucsess: (value) {
                HomeStoreScreenController(user: PrefUtils.prefs!.getString("apikey") ?? PrefUtils.prefs!.getString("ftokenid"),  lat: (VxState.store as GroceStore).userData.latitude??PrefUtils.prefs!.getString("latitude"),
                    long: (VxState.store as GroceStore).userData.longitude??PrefUtils.prefs!.getString("longitude") );
              });

              //HomeScreenController(user: PrefUtils.prefs!.getString("apikey") ?? PrefUtils.prefs!.getString("ftokenid"), branch: PrefUtils.prefs!.getString("branch") ?? "999", rows: "0",);
              return HomeScreenShimmer();
            }else{
              return loadhomeScreen();
            }
          }
          return HomeScreenShimmer();

        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bottomNavigationbar() {
      return _isDelivering
          ? SingleChildScrollView(
        child: Container(
          height: 60,
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Spacer(),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 7.0,
                  ),
                  CircleAvatar(
                    radius: 13.0,
                    // minRadius: 50,
                    // maxRadius: 50,
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    child: Image.asset(Images.homeImg,
                      //  color:ColorCodes.greenColor,
                      color: IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.maphome,

                      width: 50,
                      height: 30,
                    ),

                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                      S.of(context).home,
                      // "Home",
                      style: TextStyle(
                          color: IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.maphome,
                          //  color: ColorCodes.greenColor,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Spacer(),
              ValueListenableBuilder(
                  valueListenable: IConstants.currentdeliverylocation,
                  builder: (context, value, widget) {
                    return GestureDetector(
                      onTap: () {
                        if (value != S
                            .of(context)
                            .not_available_location)
                          /*Navigator.of(context).pushNamed(
                            CategoryScreen.routeName,
                          );*/
                          Navigation(context, name:Routename.StoreHome, navigatore: NavigatoreTyp.Push);
                      },
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 7.0,
                          ),
                          CircleAvatar(
                            radius: 13.0,
                            backgroundColor: Colors.transparent,
                            child: Image.asset(Images.categoriesImg,
                              color: ColorCodes.lightgrey,
                              width: 50,
                              height: 30,),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                              S
                                  .of(context)
                                  .categories, //"Categories",
                              style: TextStyle(
                                  color: ColorCodes.grey, fontSize: 10.0)),
                        ],
                      ),
                    );
                  }),
              if(Features.isWallet)
                Spacer(),
              if(Features.isWallet)
                ValueListenableBuilder(
                    valueListenable: IConstants.currentdeliverylocation,
                    builder: (context, value, widget) {
                      return GestureDetector(
                        onTap: () {
                          if (value != S
                              .of(context)
                              .not_available_location)
                            !PrefUtils.prefs!.containsKey("apikey")
                                ? /*Navigator.of(context).pushNamed(
                              SignupSelectionScreen.routeName,
                            )*/
                            Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push) :
                            Navigation(context, name: Routename.Wallet, navigatore: NavigatoreTyp.Push,
                                qparms: {"type": "wallet"} );
                          /*Navigator.of(context).pushNamed(
                                WalletScreen.routeName,
                                arguments: {"type": "wallet"});*/
                        },
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 7.0,
                            ),
                            CircleAvatar(
                              radius: 13.0,
                              backgroundColor: Colors.transparent,
                              child: Image.asset(Images.walletImg,
                                color: ColorCodes.lightgrey,
                                width: 50,
                                height: 30,),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                                S .of(context)
                                    .wallet, //"Wallet",
                                style: TextStyle(
                                    color: ColorCodes.grey, fontSize: 10.0)),
                          ],
                        ),
                      );
                    }),

              if(Features.isMembership)
                Spacer(),
              if(Features.isMembership)
                ValueListenableBuilder(
                    valueListenable: IConstants.currentdeliverylocation,
                    builder: (context, value, widget) {
                      return GestureDetector(
                        onTap: () {
                          if (value != S
                              .of(context)
                              .not_available_location)
                            !PrefUtils.prefs!.containsKey("apikey")
                                ? /*Navigator.of(context).pushNamed(
                              SignupSelectionScreen.routeName,
                            )*/
                            Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push)
                                : /*Navigator.of(context).pushNamed(
                              MembershipScreen.routeName,
                            );*/
                            Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                        },
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 7.0,
                            ),
                            CircleAvatar(
                              radius: 13.0,
                              backgroundColor: Colors.transparent,
                              child: Image.asset(
                                Images.bottomnavMembershipImg,
                                color: ColorCodes.lightgrey,
                                width: 50,
                                height: 30,),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                                S.of(context).membership, //"Membership",
                                style: TextStyle(
                                    color: ColorCodes.grey, fontSize: 10.0)),
                          ],
                        ),
                      );
                    }),


              if(!Features.isMembership)
                Spacer(),
              if(!Features.isMembership)
                ValueListenableBuilder(
                    valueListenable: IConstants.currentdeliverylocation,
                    builder: (context, value, widget) {
                      return GestureDetector(
                        onTap: () {
                          if (value != S
                              .of(context)
                              .not_available_location)
                            !PrefUtils.prefs!.containsKey("apikey")
                                ? /*Navigator.of(context).pushNamed(
                              SignupSelectionScreen.routeName,
                            )*/
                            Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push)
                                : /*Navigator.of(context).pushNamed(
                                MyorderScreen.routeName, arguments: {
                              "orderhistory": ""
                            }
                            );*/
                            Navigation(context, name:Routename.MyOrders,navigatore: NavigatoreTyp.Push,
                              /*parms: {
                              "orderhistory": ""
                            }*/);
                        },
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 7.0,
                            ),
                            CircleAvatar(
                              radius: 13.0,
                              backgroundColor: Colors.transparent,
                              child: Image.asset(
                                Images.bag,
                                color: ColorCodes.lightgrey,
                                width: 50,
                                height: 30,),
                            ),

                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                                S
                                    .of(context)
                                    .my_orders, //"My Orders",
                                style: TextStyle(
                                    color: ColorCodes.grey, fontSize: 10.0)),
                          ],
                        ),
                      );
                    }),
              if(Features.isShoppingList)
                Spacer(flex: 1),
              if(Features.isShoppingList)
                ValueListenableBuilder(
                    valueListenable: IConstants.currentdeliverylocation,
                    builder: (context, value, widget) {
                      return GestureDetector(
                        onTap: () {
                          if (value != S
                              .of(context)
                              .not_available_location)
                            !PrefUtils.prefs!.containsKey("apikey")
                                ? /*Navigator.of(context).pushNamed(
                              SignupSelectionScreen.routeName,
                            )*/
                            Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push)
                                :
                            /*Navigator.of(context).pushNamed(
                              ShoppinglistScreen.routeName,
                            );*/
                            Navigation(context, name: Routename.Shoppinglist, navigatore: NavigatoreTyp.Push);
                        },
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 7.0,
                            ),
                            CircleAvatar(
                              radius: 13.0,
                              backgroundColor: Colors.transparent,
                              child: Image.asset(Images.shoppinglistsImg,
                                color: ColorCodes.lightgrey,
                                width: 50,
                                height: 30,),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                                S
                                    .of(context)
                                    .shopping_list, //"Shopping list",
                                style: TextStyle(
                                    color: ColorCodes.grey, fontSize: 10.0)),
                          ],
                        ),
                      );
                    }),
              if(!Features.isShoppingList)
                Spacer(),
              if(!Features.isShoppingList)
                ValueListenableBuilder(
                    valueListenable: IConstants.currentdeliverylocation,
                    builder: (context, value, widget) {
                      return GestureDetector(
                        onTap: () {
                          if (value != S
                              .of(context)
                              .not_available_location)
                            !PrefUtils.prefs!.containsKey("apikey") &&
                                Features.isLiveChat
                                ? /*Navigator.of(context).pushNamed(
                              SignupSelectionScreen.routeName,
                            )*/
                            Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push)
                                : (Features.isLiveChat && Features.isWhatsapp) ?
                            Navigator.of(context)
                                .pushNamed(
                                CustomerSupportScreen.routeName, arguments: {
                              'name': name,
                              'email': email,
                              'photourl': photourl,
                              'phone': phone,
                            }) :
                            (!Features.isLiveChat && !Features.isWhatsapp) ?
                            Navigation(context, navigatore: NavigatoreTyp.Push,name: Routename.search)

                                :
                            Features.isWhatsapp ?/* launchWhatsapp(
                                number: IConstants.countryCode +
                                    IConstants.secondaryMobile,
                                message: "I want to order Grocery") */launchWhatsApp():
                            Navigator.of(context)
                                .pushNamed(
                                CustomerSupportScreen.routeName, arguments: {
                              'name': name,
                              'email': email,
                              'photourl': photourl,
                              'phone': phone,
                            });
                        },
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 7.0,
                            ),
                            CircleAvatar(
                              radius: 13.0,
                              backgroundColor: Colors.transparent,
                              child: (!Features.isLiveChat &&
                                  !Features.isWhatsapp) ?
                              Icon(
                                Icons.search,
                                color: ColorCodes.lightgrey,

                              )
                                  :
                              Image.asset(
                                Features.isLiveChat ? Images.chat : Images
                                    .whatsapp,
                                width: 50,
                                height: 30,
                                color: Features.isLiveChat ? ColorCodes
                                    .lightgrey : null,

                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text((!Features.isLiveChat && !Features.isWhatsapp)
                                ? S
                                .of(context)
                                .search
                                : S
                                .of(context)
                                .chat,
                                style: TextStyle(
                                    color: ColorCodes.grey, fontSize: 10.0)),
                          ],
                        ),
                      );
                    }),
              Spacer(
                flex: 1,
              ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(child: Container());
    }

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    final sliderData = Provider.of<Advertise1ItemsList>(context, listen: false);
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        return Future.value(true);
      },
      child: Scaffold(
        key: StoreScreen.scaffoldKey,
        // appBar: ,

        drawer: ResponsiveLayout.isSmallScreen(context) ? /*Features.ismultivendor?ProfileScreen():*/AppDrawer() : SizedBox.shrink(),
        backgroundColor: Colors.white /*Theme.of(context).primaryColor*/,
        body: SafeArea(bottom: true,
          child: Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  // if(_isRestaurant || !Vx.isWeb)
                  Header(true),
                  if (sliderData.websiteItems.length <= 0) SizedBox(height: 5),
                  Expanded(
                    child: Vx.isWeb ? Align(child: _body()) : RefreshIndicator(
                      onRefresh: () => _refreshProducts(context),
                      child: _body(),
                    ),
                  ),

                ],
              )
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(

            width: MediaQuery.of(context).size.width,

            child: StoreBottomNavigation()),

      ),
    );
  }



  customfloatingbutton() {
    return ValueListenableBuilder(
        valueListenable: IConstants.currentdeliverylocation,
        builder: (context, value, widget){return VxBuilder(
          // valueListenable: Hive.box<Product>(productBoxName).listenable(),
          builder: (context,  box, index) {
            if (CartCalculations.itemCount <= 0)
              return GestureDetector(
                onTap: () {

                  Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
                },
                child: Container(
                  margin: EdgeInsets.only(left: 80.0, top: 80.0, bottom: 10.0),
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Theme
                        .of(context)
                        .primaryColor,
                  ),
                  child: GestureDetector(
                    onTap: () {

                      Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
                    },
                    child: Image.asset(
                      Images.fcartImg,
                      height: 12,
                      fit: BoxFit.contain,
                      // width: 3,
                    ),
                  ),
                ),
              );
            return Consumer<CartCalculations>(
              builder: (_, cart, ch) =>
                  FloatButtonBadge(
                    child: ch!,
                    color: Colors.green,
                    value: CartCalculations.itemCount.toString(),
                  ),
              child: GestureDetector(
                onTap: () {

                  Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
                },
                child: Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Theme
                        .of(context)
                        .primaryColor,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
                    },
                    child: Image.asset(
                      Images.fcartImg,
                      height: 12,
                      fit: BoxFit.contain,
                      // width:3,
                      // fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            );
          },mutations: {SetCartItem},
        );});
    /*if (CartCalculations.itemCount <= 0)
      return GestureDetector(
        onTap: () {
          Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
        },
        child: Container(
          margin: EdgeInsets.only(left: 80.0, top: 80.0, bottom: 10.0),
          width: 50,
          height: 50,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Theme
                .of(context)
                .primaryColor,
          ),
          child: GestureDetector(
            onTap: () {
              Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
            },
            child: Image.asset(
              Images.fcartImg,
              height: 12,
              fit: BoxFit.contain,
              // width: 3,
            ),
          ),
        ),
      );*/
    // return Consumer<CartCalculations>(
    //   builder: (_, cart, ch) =>
    //       FloatButtonBadge(
    //         child: ch!,
    //         color: Colors.green,
    //         value: CartCalculations.itemCount.toString(),
    //       ),
    //   child: GestureDetector(
    //     onTap: () {
    //       Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
    //     },
    //     child: Container(
    //       width: 50,
    //       height: 50,
    //       padding: EdgeInsets.all(10),
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(100),
    //         color: Theme
    //             .of(context)
    //             .primaryColor,
    //       ),
    //       child: GestureDetector(
    //         onTap: () {
    //           Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
    //         },
    //         child: Image.asset(
    //           Images.fcartImg,
    //           height: 12,
    //           fit: BoxFit.contain,
    //           // width:3,
    //           // fit: BoxFit.fill,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
  gradientAppBar(){
    return ;
  }
}
