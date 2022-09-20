import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../screens/cart_screen.dart';
import 'package:share/share.dart';
import '../../constants/IConstants.dart';
import '../../controller/mutations/cart_mutation.dart';
import '../../data/calculations.dart';
import '../../generated/l10n.dart';
import '../../models/newmodle/cartModle.dart';
import '../../providers/branditems.dart';
import '../../widgets/badge.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/footer.dart';
import 'package:readmore/readmore.dart';
import '../../assets/images.dart';
import '../../constants/api.dart';
import '../../rought_genrator.dart';
import '../../utils/prefUtils.dart';
import '../../assets/ColorCodes.dart';
import '../../components/ItemList/item_component.dart';
import '../../constants/features.dart';
import '../../models/VxModels/VxStore.dart';
import '../../models/newmodle/product_data.dart';
import '../../repository/productandCategory/category_or_product.dart';
import '../../utils/ResponsiveLayout.dart';
import '../../widgets/custome_stepper.dart';
import '../../widgets/productWidget/item_detais_widget.dart';
import '../../widgets/productWidget/membership_info_widget.dart';
import '../../widgets/productWidget/product_info_widget.dart';
import '../../widgets/productWidget/product_sliding_image_widget.dart';
import '../../widgets/simmers/singel_item_of_list_shimmer.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../widgets/productWidget/item_variation.dart';
import 'package:http/http.dart' as http;

import '../login_web.dart';

class SingleItemMobileComponent extends StatefulWidget {
  final Future<ItemModle>? similarProduct;
  final ItemData product;
  final String variationId;
  final bool iphonex = false;
  const SingleItemMobileComponent(
      {Key? key,
      this.similarProduct,
      required this.product,
      required this.variationId,
      required bool iphonex})
      : super(key: key);

  @override
  _SingleItemMobileComponentState createState() =>
      _SingleItemMobileComponentState();
}

class _SingleItemMobileComponentState extends State<SingleItemMobileComponent>
    with Navigations, TickerProviderStateMixin {
  int itemindex = 0;
  int itemindex1 = 0;
  String page = "SingleProduct";
  var _checkmembership = false;
  List<CartItem> productBox = [];
  bool _isIOS = !Vx.isWeb && !Vx.isAndroid;
  String comment = S.current.good;
  double ratings = 3.0;
  final TextEditingController commentController = new TextEditingController();
  late AnimationController _ColorAnimationController;
  late AnimationController _TextAnimationController;
  late Animation _colorTween, _iconColorTween;
  late Animation<Offset> _transTween;
  @override
  void initState() {
    _ColorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _colorTween = ColorTween(begin: Colors.transparent, end: Color(0xFFffffff))
        .animate(_ColorAnimationController);
    _iconColorTween = ColorTween(begin: Colors.grey, end: Colors.white)
        .animate(_ColorAnimationController);
    _TextAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _transTween = Tween(begin: Offset(-10, 40), end: Offset(-10, 0))
        .animate(_TextAnimationController);

    super.initState();
  }

  bool _scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.axis == Axis.vertical) {
      _ColorAnimationController.animateTo(scrollInfo.metrics.pixels / 350);
      _TextAnimationController.animateTo(
          (scrollInfo.metrics.pixels - 350) / 50);
      return true;
    }
    return true;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    productBox = (VxState.store as GroceStore).CartItemList;
    if ((VxState.store as GroceStore).userData.membership == "1") {
      setState(() {
        _checkmembership = true;
      });
    } else {
      setState(() {
        _checkmembership = false;
      });
      for (int i = 0;
          i < (VxState.store as GroceStore).CartItemList.length;
          i++) {
        if ((VxState.store as GroceStore).CartItemList[i].mode == "1") {
          setState(() {
            _checkmembership = true;
          });
        }
      }
    }

    BuildBottomNavigationBar(ItemData product, String VariationId, bool iphonex,
        int itemindex, String type) {
      print("DISPLAYING BOTTEM NAVIGATION BAR");
      // singleitemData = Provider.of<ItemsList>(context, listen: false);

/* return type=="1"?CustomeStepper(itemdata: product,alignmnt: StepperAlignment.Horizontal,height:(Features.isSubscription)?40:60,addon:(product.addon!.length > 0)?product.addon![itemindex]:null,index:itemindex)
     :CustomeStepper(priceVariation:product.priceVariation![itemindex],itemdata: product,alignmnt: StepperAlignment.Horizontal,
     height:(Features.isSubscription)?40:60,addon:(product.addon!.length > 0)?product.addon![itemindex]:null,index:itemindex);*/
      return VxBuilder(
        mutations: {SetCartItem},
        // valueListenable: Hive.box<Product>(productBoxName).listenable(),
        builder: (context, store, index) {
          final box = (VxState.store as GroceStore).CartItemList;
          if (box.isEmpty) return SizedBox.shrink();
          return BottomNaviagation(
            itemCount: CartCalculations.itemCount.toString() +
                " " +
                S.of(context).items,
            title: S.current.view_cart,
            total: ((VxState.store as GroceStore).userData.membership == "1")
                ? (CartCalculations.totalMember).toStringAsFixed(
                    IConstants.numberFormat == "1"
                        ? 0
                        : IConstants.decimaldigit)
                : (CartCalculations.total).toStringAsFixed(
                    IConstants.numberFormat == "1"
                        ? 0
                        : IConstants.decimaldigit),
            onPressed: () {
              setState(() {
                Navigation(context,
                    name: Routename.Cart,
                    navigatore: NavigatoreTyp.Push,
                    qparms: {"afterlogin": null});
              });
            },
          );
        },
      );
    }

    _dialogforProcessing() {
      return showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return AbsorbPointer(
                child: Container(
                  color: Colors.transparent,
                  height: double.infinity,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              );
            });
          });
    }

    Future<void> RateProduct(var rating) async {
      try {
        debugPrint("hihii...." +
            {
              "user": PrefUtils.prefs!.getString('apikey'),
              "itemId": widget.product.id.toString(),
              "star": rating.toString(),
              "comment": commentController.text.toString(),
              "branch": PrefUtils.prefs!.getString('branch').toString(),
              "ref": IConstants.isEnterprise && Features.ismultivendor
                  ? IConstants.refIdForMultiVendor.toString()
                  : "",
            }.toString());
        final response = await http.post(Api.addRatingsProduct, body: {
          "user": PrefUtils.prefs!.getString('apikey'),
          "itemId": widget.product.id.toString(),
          "star": rating.toString(),
          "comment": commentController.text.toString(),
          "branch": PrefUtils.prefs!.getString('branch').toString(),
          "ref": IConstants.isEnterprise && Features.ismultivendor
              ? IConstants.refIdForMultiVendor.toString()
              : "",
        });
        final responseJson = json.decode(response.body);
        debugPrint("responseJson...rate.." + responseJson.toString());

        Navigator.pop(context);
        if (responseJson['status'].toString() == "200") {
          Navigation(context,
              name: Routename.SingleProduct,
              navigatore: NavigatoreTyp.Push,
              parms: {
                "varid": widget.product.type == "1"
                    ? widget.product.id.toString()
                    : widget.variationId,
                "productId": widget.product.id.toString()
              });
          //  Navigator.pop(context);
          Fluttertoast.showToast(
            msg: "Review added successfully, it is sent for approval.",
            fontSize: MediaQuery.of(context).textScaleFactor * 13,
          );
        } else {
          Navigator.pop(context);
          Fluttertoast.showToast(
            msg: S.current.something_went_wrong,
            fontSize: MediaQuery.of(context).textScaleFactor * 13,
          );
        }
      } catch (error) {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: S.current.something_went_wrong,
          fontSize: MediaQuery.of(context).textScaleFactor * 13,
        );
        throw error;
      }
    }

    showpopforRateorder() {
      return showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0)),
                  child: Container(
                    height: 300,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Rate our Product",
                              style: TextStyle(
                                  fontSize: 18.0, color: ColorCodes.greyColor),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 120.0),
                              child: Divider(
                                color: ColorCodes.darkgreen,
                                thickness: 2,
                              ),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              comment,
                              style: TextStyle(
                                  fontSize: 20.0, color: ColorCodes.greyColor),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            RatingBar.builder(
                              initialRating: ratings,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 30,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star_rate,
                                color: ColorCodes.ratestarcolor,
                              ),
                              onRatingUpdate: (rating) {
                                ratings = rating;
                                if (ratings == 5) {
                                  setState(() {
                                    comment =
                                        S.of(context).excellent; //"Excellent";
                                  });
                                } else if (ratings == 4) {
                                  setState(() {
                                    comment = S.of(context).good; //"Good";
                                  });
                                } else if (ratings == 3) {
                                  setState(() {
                                    comment =
                                        S.of(context).average; //"Average";
                                  });
                                } else if (ratings == 2) {
                                  setState(() {
                                    comment = S.of(context).bad; //"Bad";
                                  });
                                } else if (ratings == 1) {
                                  setState(() {
                                    comment =
                                        S.of(context).verybad; //"Very Bad";
                                  });
                                }
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextFormField(
                              textAlign: TextAlign.left,
                              controller: commentController,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                hintText: '*Comment',
                                hoverColor: ColorCodes.primaryColor,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                      color: ColorCodes.primaryColor),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                      color: ColorCodes.primaryColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                      color: ColorCodes.primaryColor),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  if (commentController.text == "") {
                                    Fluttertoast.showToast(
                                      msg: "Please enter comment",
                                      fontSize: MediaQuery.of(context)
                                              .textScaleFactor *
                                          13,
                                    );
                                  } else {
                                    _dialogforProcessing();
                                    // debugPrint(":widget.itemId...."+widget.itemId+"...."+widget.itemname);
                                    RateProduct(ratings);
                                  }
                                },
                                child: Container(
                                  height: 35,
                                  width:
                                      MediaQuery.of(context).size.width / 1.5,
                                  //color: ColorCodes.greenColor,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    color: ColorCodes.greenColor,
                                    border: Border.all(
                                        color: ColorCodes.greenColor),
                                    // color: Theme.of(context).primaryColor
                                  ),
                                  child: Center(
                                      child: Text(
                                    S.of(context).rate_order.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: ColorCodes
                                          .whiteColor, //Theme.of(context).buttonColor,
                                    ),
                                  )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ));
            });
          });
    }

    print("sp,,," + Features.isMembership.toString());
    return Scaffold(
      backgroundColor: Colors.white,
      key: Key("single_mobile"),
      body: NotificationListener<ScrollNotification>(
        onNotification: _scrollListener,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // SlidingImage(productdata: widget.product,varid:widget.variationId,itemindexs:itemindex,ontap: (){},),

                ProductInfoWidget(
                  itemdata: widget.product,
                  varid: widget.variationId,
                  variationId: widget.variationId,
                  itemindexs: itemindex,
                  ontap: () {},
                ),
                // if(Features.isMembership)
                //   MembershipInfoWidget(itemdata: widget.product,varid:widget.variationId ,itemindexs:itemindex,ontap:(){
                //     (!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?
                //     // _dialogforSignIn() :
                //     LoginWeb(context,result: (sucsess){
                //       if(sucsess){
                //         Navigator.of(context).pop();
                //         Navigation(context, navigatore: NavigatoreTyp.homenav);
                //        /* Navigator.pushNamedAndRemoveUntil(
                //             context, HomeScreen.routeName, (route) => false);*/
                //       }else{
                //         Navigator.of(context).pop();
                //       }
                //     })
                //         :
                //     (!PrefUtils.prefs!.containsKey("apikey") && !Vx.isWeb)?
                //    /* Navigator.of(context).pushReplacementNamed(
                //         SignupSelectionScreen.routeName)*/
                //     Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.PushReplacment)
                //         :/*Navigator.of(context).pushNamed(
                //       MembershipScreen.routeName,
                //     );*/
                //     Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                //   }),//TODO:Add Variation Widget
                /* widget.product.type=="1"?SizedBox.shrink():
                ItemVariation(widget.product,ismember: _checkmembership,selectedindex: itemindex,page:page,onselect: (i){
                  //for changing color
                  itemindex1 = i;
                 setState(() {
                   //for changing product price
                    itemindex = i;
                    print("apppp..."+itemindex.toString()+"index.."+itemindex1.toString());
                    // Navigator.of(context).pop();
                  });
                },),*/
                //  ItemDetailsWidget(itmdata: widget.product,ontap: (){},),

                // (widget.product.manufacturer_description! != ""  || widget.product.item_description! != "")?  SizedBox(
                //   height: 6.0,
                // ):SizedBox.shrink(),
                // if(widget.product.item_description! != "")
                //   Column(
                //     children: [
                //        Container(
                //             width: MediaQuery.of(context).size.width,
                //             decoration: BoxDecoration(
                //
                //               color: Colors.white,
                //               // borderRadius: BorderRadius.circular(12)
                //             ),
                //            // margin: EdgeInsets.only(bottom: (!_ismanufacturer)?70.0:0.0),
                //             padding: EdgeInsets.only(
                //                 left: 10.0, top: 10.0, right: 15.0, bottom: 10.0),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Text(
                //                   "Product Description",
                //                   style: TextStyle(
                //                     fontSize: 17,
                //                     fontWeight: FontWeight.w800,
                //                   ),
                //                 ),
                //
                //               ],
                //             ),
                //
                //           ),
                //       Container(
                //         width: MediaQuery.of(context).size.width,
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //         ),
                //         margin: EdgeInsets.only(bottom: (widget.product.manufacturer_description! == "")?80.0:0.0),
                //         padding: EdgeInsets.only(
                //             left: 9.0, top: 5.0, right: 15.0, bottom: 10.0),
                //         child: ReadMoreText(
                //           widget.product.item_description!,
                //           style: TextStyle(color: ColorCodes.greyColor),
                //           trimLines: 2,
                //           trimCollapsedText: '...Show more',
                //           trimExpandedText: '...Show less',
                //           colorClickableText: Theme
                //               .of(context)
                //               .primaryColor,
                //         )
                //       ),
                //     ],
                //   ),
                // (widget.product.manufacturer_description! != "")?  SizedBox(
                //   height: 6.0,
                // ):SizedBox.shrink(),
                // if(widget.product.manufacturer_description! != "")
                //   Column(
                //     children: [
                //        Container(
                //               width: MediaQuery.of(context).size.width,
                //               decoration: BoxDecoration(
                //                 color: Colors.white,
                //                 // borderRadius: BorderRadius.circular(12)
                //               ),
                //               // margin: EdgeInsets.only(bottom: (!_ismanufacturer)?70.0:0.0),
                //               padding: EdgeInsets.only(
                //                   left: 10.0, top: 10.0, right: 15.0, bottom: 10.0),
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   Text(
                //                     "Important Information",
                //                     style: TextStyle(
                //                       fontSize: 17,
                //                       fontWeight: FontWeight.w800,
                //                     ),
                //                   ),
                //
                //                 ],
                //               ),
                //
                //             ),
                //       Container(
                //         width: MediaQuery.of(context).size.width,
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //         ),
                //      //   margin: EdgeInsets.only(bottom: 80.0),
                //         padding: EdgeInsets.only(
                //             left: 9.0, top: 5.0, right: 15.0, bottom: 10.0),
                //         child: ReadMoreText(
                //           widget.product.manufacturer_description!,
                //           style: TextStyle(color: ColorCodes.greyColor),
                //           trimLines: 2,
                //           trimCollapsedText: '...Show more',
                //           trimExpandedText: '...Show less',
                //           colorClickableText: Theme
                //               .of(context)
                //               .primaryColor,
                //         )
                //       ),
                //     ],
                //   ),
                // SizedBox(height: 10,),
                if (Features.isRateOrderProduct)
                  Container(
                    width:
                        (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))
                            ? MediaQuery.of(context).size.width * 0.40
                            : MediaQuery.of(context).size.width,
                    // padding: EdgeInsets.only(top: 15.0, bottom: 10.0,left:(Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?20:0,right: (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?20:0 ),
                    color: /*Color(0xFFFFE8E8).withOpacity(0.7)*/ ColorCodes
                        .whiteColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10, bottom: 5),
                              child: Text(
                                "Ratings & Reviews",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (Features.isRateOrderProduct)
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  showpopforRateorder();
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    right: 10,
                                  ),
                                  height: 30,
                                  decoration: new BoxDecoration(
                                      color: ColorCodes.whiteColor,
                                      border: Border.all(
                                          color: ColorCodes.darkgreen),
                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(5),
                                        topRight: const Radius.circular(5),
                                        bottomLeft: const Radius.circular(5),
                                        bottomRight: const Radius.circular(5),
                                      )),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: 10,
                                      left: 10,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Rate Product",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          width: (Vx.isWeb &&
                                  !ResponsiveLayout.isSmallScreen(context))
                              ? MediaQuery.of(context).size.width * 0.40
                              : MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.product.rating!.toStringAsFixed(2),
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: ColorCodes.greenColor),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Image.asset(
                                    Images.starImg,
                                    width: 9,
                                    height: 9,
                                    color: ColorCodes.greenColor,
                                    fit: BoxFit.fill,
                                  ),
                                  Spacer(),
                                  (widget.product.ratingCount != 0)
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.arrow_forward_ios,
                                            color: ColorCodes.greenColor,
                                            size: 16,
                                          ),
                                          onPressed: () {
                                            Navigation(context,
                                                name:
                                                    Routename.RateReviewScreen,
                                                navigatore: NavigatoreTyp.Push,
                                                parms: {
                                                  "varid": widget.variationId
                                                });
                                          },
                                        )
                                      : SizedBox.shrink(),
                                ],
                              ),
                              Text(widget.product.ratingCount.toString() +
                                  " ratings & " +
                                  widget.product.ratingCount.toString() +
                                  " reviews")
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        if (widget.product.ratingCount != 0)
                          Divider(
                            color: ColorCodes.lightGreyWebColor,
                            thickness: 1,
                          ),
                        if (widget.product.ratingCount != 0)
                          Container(
                            width: (Vx.isWeb &&
                                    !ResponsiveLayout.isSmallScreen(context))
                                ? MediaQuery.of(context).size.width * 0.40
                                : MediaQuery.of(context).size.width,
                            child: ListView.separated(
                                separatorBuilder: (context, index) => Divider(
                                      color: ColorCodes.lightGreyWebColor,
                                      thickness: 1,
                                    ),
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: (widget.product.reviews!.length) > 5
                                    ? 5
                                    : widget.product.reviews!.length,
                                itemBuilder: (_, i) {
                                  return Container(
                                    padding: const EdgeInsets.only(
                                        left: 10.0, right: 10),
                                    width: (Vx.isWeb &&
                                            !ResponsiveLayout.isSmallScreen(
                                                context))
                                        ? MediaQuery.of(context).size.width *
                                            0.40
                                        : MediaQuery.of(context).size.width,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            widget.product.reviews![i].comment!,
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                color: ColorCodes.borderColor)),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(widget.product.reviews![i].user!,
                                            style: TextStyle(
                                                fontSize: 10.0,
                                                color:
                                                    ColorCodes.lightGreyColor)),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        if (widget.product.ratingCount != 0)
                          Divider(
                            color: ColorCodes.lightGreyWebColor,
                            thickness: 1,
                          ),
                        // SizedBox(height: 10,),
                        if (widget.product.ratingCount != 0)
                          GestureDetector(
                            onTap: () {
                              Navigation(context,
                                  name: Routename.RateReviewScreen,
                                  navigatore: NavigatoreTyp.Push,
                                  parms: {"varid": widget.variationId});
                            },
                            child: Container(
                              //  padding: const EdgeInsets.only(left:10.0,right:10),
                              width: (Vx.isWeb &&
                                      !ResponsiveLayout.isSmallScreen(context))
                                  ? MediaQuery.of(context).size.width * 0.40
                                  : MediaQuery.of(context).size.width,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "View all Reviews",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: ColorCodes.redColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: ColorCodes.redColor,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                if (widget.similarProduct != null)
                  FutureBuilder<ItemModle>(
                    future: widget.similarProduct, // async work
                    builder: (BuildContext context,
                        AsyncSnapshot<ItemModle> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return SingelItemOfList();
                        // TODO: Handle this case.

                        default:
                          // TODO: Handle this case.
                          if (snapshot.hasError)
                            return SizedBox.shrink();
                          else
                            return snapshot.data!.data!.length > 0
                                ? Container(
                                    width: (Vx.isWeb &&
                                            !ResponsiveLayout.isSmallScreen(
                                                context))
                                        ? MediaQuery.of(context).size.width *
                                            0.40
                                        : MediaQuery.of(context).size.width,
                                    //padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
                                    padding: EdgeInsets.only(
                                        top: 15.0,
                                        bottom: 10.0,
                                        left: (Vx.isWeb &&
                                                !ResponsiveLayout.isSmallScreen(
                                                    context))
                                            ? 20
                                            : 0,
                                        right: (Vx.isWeb &&
                                                !ResponsiveLayout.isSmallScreen(
                                                    context))
                                            ? 20
                                            : 0),
                                    color: /*Color(0xFFFFE8E8).withOpacity(0.7)*/ ColorCodes
                                        .whiteColor,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10.0, right: 10),
                                          child: Text(
                                            snapshot.data!.label!,
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                            height: ResponsiveLayout
                                                    .isSmallScreen(context)
                                                ? Features.btobModule
                                                    ? 420
                                                    : (Features.isSubscription)
                                                        ? 270
                                                        : 270
                                                : ResponsiveLayout
                                                        .isMediumScreen(context)
                                                    ? Features.btobModule
                                                        ? 420
                                                        : (Features
                                                                .isSubscription)
                                                            ? 270
                                                            : 270
                                                    : Features.btobModule
                                                        ? 420
                                                        : (Features
                                                                .isSubscription)
                                                            ? 270
                                                            : 270,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: new ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    snapshot.data!.data!.length,
                                                itemBuilder: (_, i) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: Column(
                                                    children: [
                                                      Itemsv2(
                                                        "Forget",
                                                        snapshot.data!.data![i],
                                                        (VxState.store
                                                                as GroceStore)
                                                            .userData,
                                                        //sellingitemData.items[i].brand,
                                                      ), /* Itemsv2(
                                                              "Forget",
                                                              snapshot.data.data[i],
                                                              (VxState.store as GroceStore).userData,
                                                              //sellingitemData.items[i].brand,
                                                            ),*/
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                  )
                                : SizedBox.shrink();
                      }
                    },
                  ),

                SizedBox(
                  height: 10,
                ),
                if (Vx.isWeb)
                  Footer(
                      address:
                          PrefUtils.prefs!.getString("restaurant_address")!),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
          /*(Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)) ? SizedBox.shrink():
      BuildBottomNavigationBar(widget.product,widget.variationId,widget.iphonex),*/
          (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))
              ? SizedBox.shrink()
              : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Row(
                          children: [
                            AnimatedBuilder(
                                animation: _ColorAnimationController,
                                builder: (context, child) => Container(
                                      height: 60,
                                      width: MediaQuery.of(context).size.width,
                                      color: _colorTween.value,
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              String routeName = "";
                                              var route =
                                                  ModalRoute.of(context);
                                              if (GoRouter.of(context)
                                                  .navigator!
                                                  .canPop())
                                                Navigation(context,
                                                    navigatore:
                                                        NavigatoreTyp.Pop);
                                              else
                                                Navigation(
                                                  context,
                                                  navigatore:
                                                      NavigatoreTyp.homenav,
                                                );
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  top: 15,
                                                  left: 15,
                                                  bottom: 15),
                                              width: 33,
                                              height: 33,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: ColorCodes.whiteColor),
                                              child: Center(
                                                  child: Icon(
                                                Icons.arrow_back,
                                                size: 28,
                                                color: ColorCodes.blackColor,
                                              )),
                                            ),
                                          ),
                                          Spacer(),
                                          //           if(Features.isShare)
                                          // GestureDetector(
                                          // onTap: (){
                                          //   Navigator.of(context).pop();
                                          //   if (_isIOS) {
                                          //     Share.share(S.current.download_app +
                                          //         IConstants.APP_NAME +
                                          //         '${S.current.from_app_store} https://apps.apple.com/us/app/id' + IConstants.appleId);
                                          //   } else {
                                          //     Share.share(S.current.download_app +
                                          //         IConstants.APP_NAME +
                                          //         '${S.current.from_google_play_store} https://play.google.com/store/apps/details?id=' + IConstants.androidId);
                                          //   }
                                          // },
                                          //              child:Container(
                                          //             margin: EdgeInsets.only(top: 15,bottom: 15),
                                          //             width: 28,
                                          //             height: 28,
                                          //             decoration: BoxDecoration(
                                          //                 borderRadius: BorderRadius.circular(100),
                                          //                 color: ColorCodes.whiteColor),
                                          //             child: Icon(
                                          //               Icons.share_outlined,
                                          //               size: 23,
                                          //               color: ColorCodes.blackColor,
                                          //             ),
                                          //           ),
                                          // ),
                                          //           SizedBox(
                                          //             width: 15,
                                          //           ),
                                          VxBuilder(
                                            mutations: {SetCartItem},
                                            // valueListenable: Hive.box<Product>(productBoxName).listenable(),
                                            builder: (context, store,
                                                index) {
                                              final box =
                                                  (VxState.store as GroceStore)
                                                      .CartItemList;

                                              if (box.isEmpty)
                                                return GestureDetector(
                                                  onTap: () {
                                                    /*  Navigator.of(context).pushNamed(CartScreen.routeName,arguments: {
                       "afterlogin": ""
                     });*/
                                                    Navigation(context,
                                                        name: Routename.Cart,
                                                        navigatore:
                                                            NavigatoreTyp.Push,
                                                        qparms: {
                                                          "afterlogin": null
                                                        });
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 15,
                                                        right: 10,
                                                        bottom: 15),
                                                    width: 28,
                                                    height: 28,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        color: ColorCodes
                                                            .whiteColor),
                                                    child: Image.asset(
                                                      Images.header_cart,
                                                      height: 28,
                                                      width: 28,
                                                      color:
                                                          ColorCodes.blackColor,
                                                    ),
                                                  ),
                                                );

                                              return Consumer<CartCalculations>(
                                                builder: (_, cart, ch) => Badge(
                                                  child: ch!,
                                                  color:
                                                      ColorCodes.primaryColor,
                                                  value: CartCalculations
                                                      .itemCount
                                                      .toString(),
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    /*      Navigator.of(context).pushNamed(CartScreen.routeName,arguments: {
                      "afterlogin": ""
                    });*/
                                                    Navigation(context,
                                                        name: Routename.Cart,
                                                        navigatore:
                                                            NavigatoreTyp.Push,
                                                        qparms: {
                                                          "afterlogin": null
                                                        });
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 15,
                                                        right: 10,
                                                        bottom: 15),
                                                    width: 22,
                                                    height: 22,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        color: ColorCodes
                                                            .whiteColor),
                                                    child: Image.asset(
                                                      Features.ismultivendor
                                                          ? Images
                                                              .MultivendorCart
                                                          : Images.header_cart,
                                                      height: 22,
                                                      width: 22,
                                                      color:
                                                          ColorCodes.blackColor,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                        ],
                                      ),
                                    )),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 8.0,
                              top: 0.0,
                              right: 8.0,
                              bottom: widget.iphonex ? 16.0 : 5.0),
                          child: BuildBottomNavigationBar(
                              widget.product,
                              widget.variationId,
                              widget.iphonex,
                              itemindex,
                              widget.product.type.toString()),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
