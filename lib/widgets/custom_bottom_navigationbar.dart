import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

import '../assets/ColorCodes.dart';
import '../assets/images.dart';
import '../constants/IConstants.dart';
import '../constants/features.dart';
import '../controller/mutations/cart_mutation.dart';
import '../data/calculations.dart';
import '../generated/l10n.dart';
import '../models/VxModels/VxStore.dart';
import '../rought_genrator.dart';
import 'dart:io';

import '../screens/category_screen.dart';
import '../screens/home_screen.dart';
import '../utils/prefUtils.dart';
import 'badge.dart';

class CustomBottomNavigationBar extends StatelessWidget with Navigations {
  const CustomBottomNavigationBar({Key? key, required this.openDrawer})
      : super(key: key);
  final VoidCallback openDrawer;

  void launchWhatsApp() async {
    String phone = /*"+918618320591"*/ IConstants.secondaryMobile;
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

  @override
  Widget build(BuildContext context) {
    final bool isHomeScreen =
        '/store/home' == ModalRoute.of(context)?.settings.name;
    return Container(
      // margin: const EdgeInsets.all(10.0),
      margin: const EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          color: ColorCodes.bottomBar),
      height: 50,
      child: Row(
        children: <Widget>[
          const Spacer(),
          GestureDetector(
            onTap: () {
              if (!isHomeScreen) {
                Navigation(context,
                    name: Routename.Home, navigatore: NavigatoreTyp.homenav);
              }
            },
            child: Column(
              children: <Widget>[
                const SizedBox(height: 5.0),
                CircleAvatar(
                  radius: 13.0,
                  // minRadius: 50,
                  // maxRadius: 50,
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    Images.homeImg,
                    //  color:ColorCodes.greenColor,
                    color: isHomeScreen
                        ? ColorCodes.yellowColor
                        : ColorCodes.whiteColor,

                    width: 50,
                    height: 30,
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(S.of(context).home, // "Home",
                    style: TextStyle(
                        color: IConstants.isEnterprise
                            ? (isHomeScreen
                                ? ColorCodes.yellowColor
                                : ColorCodes.whiteColor)
                            : ColorCodes.maphome,
                        //  color: ColorCodes.greenColor,
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Spacer(),
          ValueListenableBuilder(
              valueListenable: IConstants.currentdeliverylocation,
              builder: (context, value, widget) {
                return GestureDetector(
                  onTap: () {
                    if (value != S.of(context).not_available_location) {
                      Navigation(context,
                          name: Routename.Category,
                          navigatore: NavigatoreTyp.Push);
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 5.0),
                      CircleAvatar(
                        radius: 13.0,
                        backgroundColor: Colors.transparent,
                        child: Image.asset(
                          Images.categoriesImg,
                          color: ColorCodes.whiteColor,
                          width: 50,
                          height: 30,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      Text(S.of(context).menu, //"Categories",
                          style: TextStyle(
                              color: ColorCodes.whiteColor, fontSize: 10.0)),
                    ],
                  ),
                );
              }),
          /*
          if(Features.isWallet)
            const Spacer(),
          if(Features.isWallet)
            ValueListenableBuilder(
                valueListenable: IConstants.currentdeliverylocation,
                builder: (context, value, widget) {
                  return GestureDetector(
                    onTap: () {
                      if (value != S
                          .of(context)
                          .not_available_location) {
                        !PrefUtils.prefs!.containsKey("apikey")
                            ? /*Navigator.of(context).pushNamed(
                                SignupSelectionScreen.routeName,
                              )*/
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push) :
                        Navigation(context, name: Routename.Wallet, navigatore: NavigatoreTyp.Push,
                            qparms: {"type": "wallet"} );
                      }
                      /*Navigator.of(context).pushNamed(
                                  WalletScreen.routeName,
                                  arguments: {"type": "wallet"});*/
                    },
                    child:  Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 3.0,
                        ),
                        (PrefUtils.prefs!.containsKey("apikey")) ?((VxState.store as GroceStore).prepaid.prepaid.toString() != null || (VxState.store as GroceStore).prepaid.prepaid.toString() != "null" || (VxState.store as GroceStore).prepaid.prepaid.toString() != "")?Text(
                          Features.iscurrencyformatalign?
                          (VxState.store as GroceStore).prepaid.prepaid!.toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit) + " " + IConstants.currencyFormat:
                          IConstants.currencyFormat + " " + (VxState.store as GroceStore).prepaid.prepaid!.toStringAsFixed(IConstants.numberFormat == "1"?0:IConstants.decimaldigit),
                          style: TextStyle(
                              color: ColorCodes.greenColor,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold
                          ),
                        ):
                        const SizedBox(
                          height: 10.0,
                        ):
                        const SizedBox(
                          height: 10.0,
                        ),
                        CircleAvatar(
                          radius: 13.0,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(Images.walletImg,
                            color: ColorCodes.lightgrey,
                            width: 50,
                            height: 30,),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text( S.of(context).wallet,
                            //"Wallet",
                            style: TextStyle(
                                color: ColorCodes.lightgrey, fontSize: 10.0)),
                      ],
                    ),
                  );
                }),
          */
          if (Features.isMembership) const Spacer(),
          if (Features.isMembership)
            ValueListenableBuilder(
                valueListenable: IConstants.currentdeliverylocation,
                builder: (context, value, widget) {
                  return GestureDetector(
                    onTap: () {
                      if (value != S.of(context).not_available_location) {
                        !PrefUtils.prefs!.containsKey("apikey")
                            ? /*Navigator.of(context).pushNamed(
                                SignupSelectionScreen.routeName,
                              )*/
                            Navigation(context,
                                name: Routename.SignUpScreen,
                                navigatore: NavigatoreTyp.Push)
                            : /*Navigator.of(context).pushNamed(
                                MembershipScreen.routeName,
                              );*/
                            Navigation(context,
                                name: Routename.Membership,
                                navigatore: NavigatoreTyp.Push);
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 5.0,
                        ),
                        CircleAvatar(
                          radius: 13.0,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(
                            Images.bottomnavMembershipImg,
                            color: ColorCodes.whiteColor,
                            width: 50,
                            height: 30,
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(S.of(context).membership, //"Membership",
                            style: TextStyle(
                                color: ColorCodes.whiteColor, fontSize: 10.0)),
                      ],
                    ),
                  );
                }),
          if (!Features.isMembership) Container(child: const Spacer()),
          if (!Features.isMembership)
            ValueListenableBuilder(
                valueListenable: IConstants.currentdeliverylocation,
                builder: (context, value, widget) {
                  return GestureDetector(
                    onTap: () {
                      if (value != S.of(context).not_available_location) {
                        !PrefUtils.prefs!.containsKey("apikey")
                            ? /*Navigator.of(context).pushNamed(
                                SignupSelectionScreen.routeName,
                              )*/
                            Navigation(context,
                                name: Routename.SignUpScreen,
                                navigatore: NavigatoreTyp.Push)
                            : /*Navigator.of(context).pushNamed(
                                  MyorderScreen.routeName, arguments: {
                                "orderhistory": ""
                              }
                              );*/
                            Navigation(context,
                                name: Routename.Cart,
                                navigatore: NavigatoreTyp.Push,
                                qparms: {"afterlogin": null});
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 5.0,
                        ),
                        /*
                        CircleAvatar(
                          radius: 13.0,
                          backgroundColor: Colors.transparent,
                          /*child: Image.asset(
                            Images.cartImg,
                            color: ColorCodes.lightgrey,
                            width: 50,
                            height: 30,),
                        ),*/

                          child:  ValueListenableBuilder(
                              valueListenable: IConstants.currentdeliverylocation,
                              builder: (context, value, widget){return VxBuilder(
                                // valueListenable: Hive.box<Product>(productBoxName).listenable(),
                                builder: (context, GroceStore box, index) {
                                  return Consumer<CartCalculations>(
                                    builder: (_, cart, ch) => Badge(
                                      child: ch!,
                                      color: ColorCodes.darkgreen,
                                      value: CartCalculations.itemCount.toString(),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (value != S.of(context).not_available_location)
                                          Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
                                      },
                                      child: Container(
                                        //margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                                        width: 50,//32,//22,
                                        height: 30,//32,//22,
                                        decoration: BoxDecoration(
                                          //  borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Image.asset(
                                          Images.cartImg,
                                          color: ColorCodes.lightgrey,

                                          //fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),);
                                },mutations: {SetCartItem},
                              );})),

                         */
                        ValueListenableBuilder(
                            valueListenable: IConstants.currentdeliverylocation,
                            builder: (context, value, widget) {
                              return VxBuilder(
                                // valueListenable: Hive.box<Product>(productBoxName).listenable(),
                                builder: (context, box, index) {
                                  return Consumer<CartCalculations>(
                                    builder: (_, cart, ch) => Badge(
                                      child: ch!,
                                      color: ColorCodes.primaryColor,
                                      value:
                                          CartCalculations.itemCount.toString(),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        if (value !=
                                            S
                                                .of(context)
                                                .not_available_location)
                                          Navigation(context,
                                              name: Routename.Cart,
                                              navigatore: NavigatoreTyp.Push,
                                              qparms: {"afterlogin": null});
                                      },
                                      child: Container(
                                        //margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                                        // margin: EdgeInsets.only(top: 12),
                                        // width: 50,//32,//22,
                                        // height: 30,//32,//22,
                                        decoration: BoxDecoration(
                                            //borderRadius: BorderRadius.circular(100),
                                            ),
                                        child: Image.asset(
                                          Images.cartImg,
                                          color: ColorCodes.whiteColor,
                                          width: 22, //32,//22,
                                          height: 22,
                                          //fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                mutations: {SetCartItem},
                              );
                            }),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(S.of(context).my_cart, //"My Orders",
                            style: TextStyle(
                                color: ColorCodes.whiteColor, fontSize: 10.0)),
                      ],
                    ),
                  );
                }),
          if (!Features.isMembership) Container(child: const Spacer()),
          if (!Features.isMembership)
            ValueListenableBuilder(
                valueListenable: IConstants.currentdeliverylocation,
                builder: (context, value, widget) {
                  return GestureDetector(
                    onTap: () {
                      if (value != S.of(context).not_available_location) {
                        openDrawer();
                        // if(!isHomeScreen){
                        //   HomeScreen.scaffoldKey.currentState!.openDrawer();
                        // }else if(true){
                        //  CategoryScreen.categoryScaffoldKey.currentState!.openDrawer();
                        // }
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 5.0,
                        ),
                        CircleAvatar(
                          radius: 13.0,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(
                            Images.Person,
                            color: ColorCodes.whiteColor,
                            width: 50,
                            height: 30,
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(S.of(context).profile, //"My Orders",
                            style: TextStyle(
                                color: ColorCodes.whiteColor, fontSize: 10.0)),
                      ],
                    ),
                  );
                }),
          if (Features.isShoppingList) const Spacer(flex: 1),
          if (Features.isShoppingList)
            ValueListenableBuilder(
                valueListenable: IConstants.currentdeliverylocation,
                builder: (context, value, widget) {
                  return GestureDetector(
                    onTap: () {
                      if (value != S.of(context).not_available_location) {
                        !PrefUtils.prefs!.containsKey("apikey")
                            ? /*Navigator.of(context).pushNamed(
                                SignupSelectionScreen.routeName,
                              )*/
                            Navigation(context,
                                name: Routename.SignUpScreen,
                                navigatore: NavigatoreTyp.Push)
                            :
                            /*Navigator.of(context).pushNamed(
                                ShoppinglistScreen.routeName,
                              );*/
                            Navigation(context,
                                name: Routename.Shoppinglist,
                                navigatore: NavigatoreTyp.Push);
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 5.0,
                        ),
                        CircleAvatar(
                          radius: 13.0,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(
                            Images.shoppinglistsImg,
                            color: ColorCodes.lightgrey,
                            width: 50,
                            height: 30,
                          ),
                        ),
                        const SizedBox(
                          height: 5.0,
                        ),
                        Text(S.of(context).shopping_list, //"Shopping list",
                            style: TextStyle(
                                color: ColorCodes.grey, fontSize: 10.0)),
                      ],
                    ),
                  );
                }),
          if (!Features.isShoppingList) const Spacer(),
          /*
          if(!Features.isShoppingList)
            ValueListenableBuilder(
                valueListenable: IConstants.currentdeliverylocation,
                builder: (context, value, widget) {
                  return GestureDetector(
                    onTap: () {
                      if (value != S
                          .of(context)
                          .not_available_location) {
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
                          'name':  "",//name,
                          'email': "", //email,
                          'photourl': "",//photourl,
                          'phone': "", //phone,
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
                          'name':  "",//name,
                          'email': "", //email,
                          'photourl': "",//photourl,
                          'phone': "", //phone,
                        });
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 17.0,
                        ),
                        CircleAvatar(
                          radius: 13.0,
                          backgroundColor: Colors.transparent,
                          child: (!Features.isLiveChat &&
                              !Features.isWhatsapp) ?
                          Icon(
                              Icons.search,
                              color: ColorCodes.lightgrey
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
                        const SizedBox(
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

          if(Features.isShoppingList)
            const Spacer(
              flex: 1,
            ),

           */
        ],
      ),
    );
  }
}
