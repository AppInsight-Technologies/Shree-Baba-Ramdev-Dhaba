import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../controller/mutations/cat_and_product_mutation.dart';
import '../../../widgets/custome_stepper.dart';
import '../../../controller/mutations/cart_mutation.dart';
import '../../../helper/custome_calculation.dart';
import '../../../models/VxModels/VxStore.dart';
import '../../../models/newmodle/cartModle.dart';
import '../../../models/newmodle/product_data.dart';
import '../../../models/newmodle/user.dart';
import '../../../components/login_web.dart';
import '../../rought_genrator.dart';
import '../../widgets/productWidget/item_badge.dart';
import '../../widgets/productWidget/item_variation.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../generated/l10n.dart';
import '../../../screens/signup_selection_screen.dart';
import '../../../screens/subscribe_screen.dart';
import '../../../constants/IConstants.dart';
import '../../../screens/home_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../constants/features.dart';
import '../../../main.dart';
import '../../../screens/singleproduct_screen.dart';
import '../../../screens/membership_screen.dart';
import '../../../data/hiveDB.dart';
import '../../../assets/images.dart';
import '../../../utils/prefUtils.dart';
import '../../../utils/ResponsiveLayout.dart';
import '../../../assets/ColorCodes.dart';

class Itemsv2 extends StatefulWidget {
  final String _fromScreen;
  final ItemData _itemdata;
  final UserData _customerDetail;
  Itemsv2(this._fromScreen, this._itemdata, this._customerDetail);

  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Itemsv2> with Navigations {
  int itemindex = 0;
  var textcolor;
  bool _isNotify = false;
  bool _checkmembership = false;
  List<CartItem> productBox = [];
  int _groupValue = 0;
  int quantity = 0;
  double weight = 0.0;

  @override
  void initState() {
    productBox = (VxState.store as GroceStore).CartItemList;
    // if(widget._itemdata.priceVariation==null)
    print("item components of ${widget._itemdata.toJson().toString()}");

    super.initState();
  }

  showoptions1() {
    // _checkmembership?widget._itemdata.priceVariation[itemindex].membershipPrice:widget._itemdata.priceVariation[itemindex].price
    (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))
        ? showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0)),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 2.5,
                    //height: 200,
                    padding: EdgeInsets.fromLTRB(30, 20, 20, 20),
                    child: ItemVariation(
                      itemdata: widget._itemdata,
                      ismember: _checkmembership,
                      selectedindex: itemindex,
                      onselect: (i) {
                        setState(() {
                          itemindex = i;
                          // Navigator.of(context).pop();
                        });
                      },
                    ),
                  ),
                );
              });
            }).then((_) => setState(() {}))
        : showModalBottomSheet<dynamic>(
            isScrollControlled: true,
            context: context,
            builder: (context) {
              return ItemVariation(
                itemdata: widget._itemdata,
                ismember: _checkmembership,
                selectedindex: itemindex,
                onselect: (i) {
                  setState(() {
                    itemindex = i;
                    // Navigator.of(context).pop();
                  });
                },
              );
            }).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    print("stock..." + widget._itemdata.type.toString());
    const double top1 = 130;
    final double height = ResponsiveLayout.isSmallScreen(context)
        ? Features.btobModule
            ? 430
            : (Features.isSubscription)
                ? 230
                : 230
        : ResponsiveLayout.isMediumScreen(context)
            ? Features.btobModule
                ? 430
                : (Features.isSubscription)
                    ? 230
                    : 230
            : Features.btobModule
                ? 430
                : (Features.isSubscription)
                    ? 230
                    : 230;

    if (productBox
            .where((element) => element.itemId == widget._itemdata.id)
            .count() >=
        1) {
      debugPrint("count...1");
      for (int i = 0; i < productBox.length; i++) {
        if (productBox[i].itemId == widget._itemdata.id &&
            productBox[i].toppings == "0") {
          debugPrint("true...1");
          quantity = quantity +
              int.parse(productBox
                  .where((element) => element.itemId == widget._itemdata.id)
                  .first
                  .quantity!);
          weight = weight +
              double.parse(productBox
                  .where((element) => element.itemId == widget._itemdata.id)
                  .first
                  .weight!);
        }
      }
    }

    final isVeg = (widget._itemdata.vegType == "standard") ?? false;
    final isNonVeg = (widget._itemdata.vegType == "fish" ||
            widget._itemdata.vegType == "meat") ??
        false;

    double margins = (widget._itemdata.type == "1")
        ? Calculate().getmargin(
            widget._itemdata.mrp,
            VxState.store.userData.membership! == "0" ||
                    VxState.store.userData.membership! == "2"
                ? widget._itemdata.discointDisplay!
                    ? widget._itemdata.price
                    : widget._itemdata.mrp
                : widget._itemdata.membershipDisplay!
                    ? widget._itemdata.membershipPrice
                    : widget._itemdata.price)
        : Calculate().getmargin(
            widget._itemdata.priceVariation![itemindex].mrp,
            VxState.store.userData.membership! == "0" ||
                    VxState.store.userData.membership! == "2"
                ? widget._itemdata.priceVariation![itemindex].discointDisplay!
                    ? widget._itemdata.priceVariation![itemindex].price
                    : widget._itemdata.priceVariation![itemindex].mrp
                : widget._itemdata.priceVariation![itemindex].membershipDisplay!
                    ? widget
                        ._itemdata.priceVariation![itemindex].membershipPrice
                    : widget._itemdata.priceVariation![itemindex].price);

    print("margi..." +
        widget._itemdata.itemName! +
        "..." +
        margins.toString() +
        "..." +
        widget._itemdata.unit.toString() +
        "...." +
        widget._itemdata.eligibleForExpress.toString());
    return widget._itemdata.type == "1"
        ? Card(
            elevation: 1,
            margin: EdgeInsets.all(5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(15),
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            )),
            child: Container(
              width: _checkmembership ? 210 : 220.0,
              decoration: BoxDecoration(
                  color: ColorCodes.backgroundcolor,
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                  border: Border.all(color: ColorCodes.backgroundcolor)),
              //height: MediaQuery.of(context).size.height,//aaaaaaaaaaaaaaaaaa
              child: Container(
                //   margin: EdgeInsets.only(left: 10.0, top: 5.0, right: 2.0, bottom: 5.0),
                decoration: new BoxDecoration(
                    color: Colors.white,
                    //border: Border.all(color: Colors.black26),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[300]!,
                          blurRadius: 10.0,
                          offset: Offset(0.0, 0.50)),
                    ],
                    borderRadius: new BorderRadius.all(
                      const Radius.circular(8.0),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        ItemBadge(
                          outOfStock: widget._itemdata.stock! <= 0
                              ? OutOfStock(
                                  singleproduct: false,
                                )
                              : null,
                          badgeDiscount:
                              BadgeDiscounts(value: margins.toStringAsFixed(0)),
                          /*  widgetBadge: WidgetBadge(isdisplay: true,child: widget._itemdata.eligibleForExpress=="0"?Padding(
                      padding: EdgeInsets.only(right: 5.0,),
                      child: Image.asset(Images.express,
                        height: 20.0,
                        width: 25.0,),
                    ):SizedBox.shrink()),*/
                          child: Align(
                            alignment: Alignment.center,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  debugPrint("single product...." +
                                      {
                                        "itemid": widget._itemdata.id,
                                        "itemname": widget._itemdata.itemName,
                                        "itemimg":
                                            widget._itemdata.itemFeaturedImage,
                                        "eligibleforexpress":
                                            widget._itemdata.eligibleForExpress,
                                        "delivery": widget._itemdata.delivery,
                                        "duration": widget._itemdata.duration,
                                        "durationType": widget._itemdata
                                            .deliveryDuration.durationType,
                                        "note": widget
                                            ._itemdata.deliveryDuration.note,
                                        "fromScreen": widget._fromScreen,
                                      }.toString());
                                  /*     Navigator.of(context).pushNamed(
                                SingleproductScreen.routeName,
                                arguments: {
                                  "itemid": widget._itemdata.id.toString(),
                                  "itemname": widget._itemdata.itemName,
                                  "itemimg": widget._itemdata.itemFeaturedImage,
                                  "eligibleforexpress": widget._itemdata.eligibleForExpress,
                                  "delivery": widget._itemdata.delivery,
                                  "duration": widget._itemdata.duration,
                                  "durationType":widget._itemdata.deliveryDuration.durationType,
                                  "note":widget._itemdata.deliveryDuration.note,
                                  "fromScreen":widget._fromScreen,
                                });*/

                                  // debugPrint("varid......"+widget._itemdata.priceVariation![itemindex].id.toString());
                                  Navigation(context,
                                      name: Routename.SingleProduct,
                                      navigatore: NavigatoreTyp.Push,
                                      parms: {
                                        "varid": widget._itemdata.id.toString(),
                                        "productId": widget._itemdata.id!
                                      });
                                },
                                child: ClipRRect(
                                  //margin: EdgeInsets.only(top: 10.0, bottom: 8.0),
                                  borderRadius: BorderRadius.circular(22.0),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        widget._itemdata.itemFeaturedImage,
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      Images.defaultProductImg,
                                      //width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                      //height: height, //ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                    ),
                                    placeholder: (context, url) => Image.asset(
                                      Images.defaultProductImg,
                                      //width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                      // height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                    ),
                                    // width: ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                    // height: ResponsiveLayout.isSmallScreen(context) ? 80 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                    //  fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    widget._itemdata.eligibleForExpress == "0"
                        ? Padding(
                            padding: EdgeInsets.only(right: 5.0, left: 10),
                            child: Container(
                              width: 80,
                              height: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                border:
                                    Border.all(color: ColorCodes.greenColor),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Express",
                                    style: TextStyle(
                                        fontSize: 9,
                                        color: ColorCodes.checkmarginColor),
                                  ),
                                  Image.asset(
                                    Images.express,
                                    height: 20.0,
                                    width: 25.0,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    Row(
                      children: [
                        SizedBox(
                          width: 10.0,
                        ),
                        // Expanded(
                        //   child: Text(
                        //     widget._itemdata.brand!,
                        //     style: TextStyle(
                        //         fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 12 : 13,
                        //         color: ColorCodes.lightGreyColor,fontWeight: FontWeight.bold
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(
                        //   width: 10.0,
                        // ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: Container(
                            height: 35,
                            child: Text(
                              widget._itemdata.itemName!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: ResponsiveLayout.isSmallScreen(
                                          context)
                                      ? 12
                                      : ResponsiveLayout.isMediumScreen(context)
                                          ? 13
                                          : 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Features.isSubscription &&
                                widget._itemdata.eligibleForSubscription == "0"
                            ? Container(
                                height: 40,
                                width: (Vx.isWeb) ? 60 : 85,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0, right: 5.0),
                                  child: CustomeStepper(
                                    itemdata: widget._itemdata,
                                    from: "item_screen",
                                    height: (Features.isSubscription) ? 90 : 60,
                                    issubscription: "Subscribe",
                                    addon: (widget._itemdata.addon!.length > 0)
                                        ? widget._itemdata.addon![0]
                                        : null,
                                    index: itemindex,
                                    ismember: _checkmembership,
                                    selectedindex: itemindex,
                                    onselect: (i) {
                                      setState(() {
                                        itemindex = i;
                                        // Navigator.of(context).pop();
                                      });
                                    },
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                    // Spacer(),

                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10.0,
                        ),
                        /*VxBuilder(
                    mutations: {ProductMutation},
                    builder: (context, GroceStore box, _) {
                      if(VxState.store.userData.membership! == "1"){
                        _checkmembership = true;
                      } else {
                        _checkmembership = false;
                        for (int i = 0; i < productBox.length; i++) {
                          if (productBox[i].mode == "1") {
                            _checkmembership = true;
                          }
                        }
                      }
                      return  Row(
                        children: <Widget>[
                          if(Features.isMembership)
                            _checkmembership?Container(
                              width: 10.0,
                              height: 9.0,
                              margin: EdgeInsets.only(right: 3.0),
                              child: Image.asset(
                                Images.starImg,
                                color: ColorCodes.starColor,
                              ),
                            ):SizedBox.shrink(),

                          new RichText(
                            text: new TextSpan(
                              style: new TextStyle(
                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                new TextSpan(
                                    text:  Features.iscurrencyformatalign?
                                    '${_checkmembership?widget._itemdata.membershipPrice:widget._itemdata.price} ' + IConstants.currencyFormat:
                                    IConstants.currencyFormat + '${_checkmembership?widget._itemdata.membershipPrice:widget._itemdata.price} ',
                                    style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,)),
                                new TextSpan(
                                    text: widget._itemdata.price!=widget._itemdata.mrp?
                                    Features.iscurrencyformatalign?
                                    '${widget._itemdata.mrp} ' + IConstants.currencyFormat:
                                    IConstants.currencyFormat + '${widget._itemdata.mrp} ':"",
                                    style: TextStyle(
                                      decoration:
                                      TextDecoration.lineThrough,
                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                                TextSpan(
                                    text:  (widget._itemdata.unit==null ||widget._itemdata.unit=="")?"":" /"+widget._itemdata.unit.toString(),
                                    style: TextStyle(
                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,))
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),*/
                        Spacer(),
                        if (Features.isLoyalty)
                          if (double.parse(
                                  widget._itemdata.loyalty.toString()) >
                              0)
                            Container(
                              height: 18,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    Images.coinImg,
                                    height: 13.0,
                                    width: 20.0,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    widget._itemdata.loyalty.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                        SizedBox(width: 10)
                      ],
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    (Features.netWeight && widget._itemdata.vegType == "fish")
                        ? Row(
                            children: [
                              SizedBox(
                                width: 8.0,
                              ),
                              Text(
                                Features.iscurrencyformatalign
                                    ? "Whole Uncut:" +
                                        " " +
                                        widget._itemdata.salePrice! +
                                        IConstants.currencyFormat +
                                        " / " +
                                        "500 G"
                                    : "Whole Uncut:" +
                                        " " +
                                        IConstants.currencyFormat +
                                        widget._itemdata.salePrice! +
                                        " / " +
                                        "500 G",
                                style: new TextStyle(
                                    fontSize:
                                        ResponsiveLayout.isSmallScreen(context)
                                            ? 10
                                            : ResponsiveLayout.isMediumScreen(
                                                    context)
                                                ? 11
                                                : 11,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                            ],
                          )
                        : SizedBox.shrink(),
                    /* SizedBox(
                height: 10,
              ),*/
                    (Features.netWeight && widget._itemdata.vegType == "fish")
                        ? SizedBox(
                            height: 2,
                          )
                        : /*SizedBox(
                height: 2,
              )*/
                        SizedBox.shrink(),
                    (Features.netWeight && widget._itemdata.vegType == "fish")
                        ? Row(children: [
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "G Weight:" +
                                        " " +
                                        /*'$weight '*/ widget._itemdata.weight!,
                                    style: new TextStyle(
                                        fontSize: ResponsiveLayout
                                                .isSmallScreen(context)
                                            ? 10
                                            : ResponsiveLayout.isMediumScreen(
                                                    context)
                                                ? 11
                                                : 11,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(width: 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    "N Weight:" +
                                        " " +
                                        /*'$netWeight '*/ widget
                                            ._itemdata.netWeight!,
                                    style: new TextStyle(
                                        fontSize: ResponsiveLayout
                                                .isSmallScreen(context)
                                            ? 10
                                            : ResponsiveLayout.isMediumScreen(
                                                    context)
                                                ? 11
                                                : 11,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(width: 10),
                          ])
                        : SizedBox.shrink(),
                    SizedBox(
                      height: 18,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 10),
                        Text(
                          widget._itemdata.singleshortNote.toString(),
                          style: TextStyle(
                              fontSize: 12,
                              color: ColorCodes.greyColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    /*       ( widget._itemdata.priceVariation!.length > 1)
                  ? Features.btobModule?
              Container(
                // height: 200,
                  child: SingleChildScrollView(
                      child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: widget._itemdata.priceVariation!.length,
                          itemBuilder: (_, i) {
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  //showoptions1();
                                  setState(() {
                                    _groupValue = i;
                                  });
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Expanded(
                                      child: Container(
                                          decoration: BoxDecoration(
                                            // border: Border.all(color: ColorCodes.greenColor),
                                            color: _groupValue == i ? ColorCodes.mediumgren : ColorCodes.whiteColor,
                                            borderRadius: BorderRadius.circular(5.0),
                                            border: Border.all(
                                              color: ColorCodes.greenColor,
                                            ),
                                       */ /*      borderRadius: new BorderRadius.only(
                                         topLeft: const Radius.circular(2.0),
                                         bottomLeft: const Radius.circular(2.0),
                                       )*/ /*),
                                          height: 30,
                                          margin: EdgeInsets.only(bottom:5),
                                          padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                                          child:
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${widget._itemdata.priceVariation![i].minItem}"+"-"+"${widget._itemdata.priceVariation![i].maxItem}"+" "+"${widget._itemdata.priceVariation![i].unit}",
                                                style: TextStyle(color: ColorCodes.darkgreen*/ /*Colors.black*/ /*,fontWeight: FontWeight.bold),
                                              ),
                                              _groupValue == i ?
                                              Container(
                                                width: 18.0,
                                                height: 18.0,
                                                padding: EdgeInsets.only(right:3),
                                                decoration: BoxDecoration(
                                                  color: ColorCodes.greenColor,
                                                  border: Border.all(
                                                    color: ColorCodes.greenColor,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Container(
                                                  margin: EdgeInsets.all(1.5),
                                                  decoration: BoxDecoration(
                                                    color: ColorCodes.greenColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(Icons.check,
                                                      color: ColorCodes.whiteColor,
                                                      size: 12.0),
                                                ),
                                              )
                                                  :
                                              Icon(
                                                  Icons.radio_button_off_outlined,
                                                  color: ColorCodes.greenColor),

                                            ],
                                          )

                                      ),
                                    ),
                                     Container(
                                 height: 30,
                                 decoration: BoxDecoration(
                                     color: ColorCodes.varcolor,
                                     borderRadius: new BorderRadius.only(
                                       topRight: const Radius.circular(2.0),
                                       bottomRight: const Radius.circular(2.0),
                                     )),
                                 child: Icon(
                                   Icons.keyboard_arrow_down,
                                   color: ColorCodes.darkgreen,
                                 ),
                               ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      )
                  )
              )
                  :
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    showoptions1();
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            // border: Border.all(color: ColorCodes.greenColor),
                              color: ColorCodes.varcolor,
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(2.0),
                                bottomLeft: const Radius.circular(2.0),
                              )),
                          height: 30,
                          padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                          child: Text(
                            "${widget._itemdata.priceVariation![itemindex].variationName}"+" "+"${widget._itemdata.priceVariation![itemindex].unit}",
                            style: TextStyle(color: ColorCodes.darkgreen*/ /*Colors.black*/ /*,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                            color: ColorCodes.varcolor,
                            borderRadius: new BorderRadius.only(
                              topRight: const Radius.circular(2.0),
                              bottomRight: const Radius.circular(2.0),
                            )),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: ColorCodes.darkgreen,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                ),
              ) :
              Features.btobModule?
              Container(
                // height: 200,
                  child: SingleChildScrollView(
                      child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: widget._itemdata.priceVariation!.length,
                          itemBuilder: (_, i) {
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  //showoptions1();
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Expanded(
                                      child: Container(
                                          decoration: BoxDecoration(
                                            // border: Border.all(color: ColorCodes.greenColor),
                                            color: _groupValue == i ? ColorCodes.mediumgren : ColorCodes.whiteColor,
                                            borderRadius: BorderRadius.circular(5.0),
                                            border: Border.all(
                                              color: ColorCodes.greenColor,
                                            ),
                                         */ /*    borderRadius: new BorderRadius.only(
                                         topLeft: const Radius.circular(2.0),
                                         bottomLeft: const Radius.circular(2.0),
                                       )*/ /*),
                                          height: 30,
                                          margin: EdgeInsets.only(bottom:5),
                                          padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                                          child:
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${widget._itemdata.priceVariation![i].minItem}"+"-"+"${widget._itemdata.priceVariation![i].maxItem}"+" "+"${widget._itemdata.priceVariation![i].unit}",
                                                style: TextStyle(color: ColorCodes.darkgreen*/ /*Colors.black*/ /*,fontWeight: FontWeight.bold),
                                              ),
                                              _groupValue == i ?
                                              Container(
                                                width: 18.0,
                                                height: 18.0,
                                                padding: EdgeInsets.only(right:3),
                                                decoration: BoxDecoration(
                                                  color: ColorCodes.greenColor,
                                                  border: Border.all(
                                                    color: ColorCodes.greenColor,
                                                  ),
                                                  shape: BoxShape.circle,

                                                ),
                                                child: Container(
                                                  margin: EdgeInsets.all(1.5),
                                                  decoration: BoxDecoration(
                                                    color: ColorCodes.greenColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(Icons.check,
                                                      color: ColorCodes.whiteColor,
                                                      size: 12.0),
                                                ),
                                              )
                                                  :
                                              Icon(
                                                  Icons.radio_button_off_outlined,
                                                  color: ColorCodes.greenColor),

                                            ],
                                          )

                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      )
                  )
              ):*/
                    // Row(
                    //   children: [
                    //     SizedBox(
                    //       width: 13.0,
                    //     ),
                    //     Expanded(
                    //       child: Container(
                    //         decoration: BoxDecoration(
                    //             color: ColorCodes.whiteColor,
                    //             // border: Border.all(color: ColorCodes.greenColor),
                    //             borderRadius: new BorderRadius.only(
                    //               topLeft: const Radius.circular(2.0),
                    //               topRight: const Radius.circular(2.0),
                    //               bottomLeft: const Radius.circular(2.0),
                    //               bottomRight: const Radius.circular(2.0),
                    //             )),
                    //         height: 10,
                    //         padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                    //         child: SizedBox.shrink(),
                    //       ),
                    //     ),
                    //     SizedBox(
                    //       width: 10.0,
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 5),
                    //
                    //  (Features.isSubscription)?(widget._itemdata.eligibleForSubscription == "0")?
                    //  MouseRegion(
                    //    cursor: SystemMouseCursors.click,
                    //    child: (widget._itemdata.priceVariation![itemindex].stock !<= 0) ?
                    //    SizedBox(height: 30,)
                    //        :GestureDetector(
                    //      onTap: () {
                    // //TODO: on click subscribe
                    //        if(!PrefUtils.prefs!.containsKey("apikey"))
                    //        if(kIsWeb&&  !ResponsiveLayout.isSmallScreen(context)){
                    //          LoginWeb(context,result: (sucsess){
                    //            if(sucsess){
                    //              Navigator.of(context).pop();
                    //              Navigator.pushNamedAndRemoveUntil(
                    //                  context, HomeScreen.routeName, (route) => false);
                    //            }else{
                    //              Navigator.of(context).pop();
                    //            }
                    //          });
                    //        }else{
                    //          Navigator.of(context).pushNamed(
                    //            SignupSelectionScreen.routeName,
                    //          );
                    //        }else{
                    //          Navigator.of(context).pushNamed(
                    //              SubscribeScreen.routeName,
                    //              arguments: {
                    //                "itemid": widget._itemdata.id,
                    //                "itemname": widget._itemdata.itemName,
                    //                "itemimg": widget._itemdata.itemFeaturedImage,
                    //                "varname": widget._itemdata.priceVariation![itemindex].variationName!+widget._itemdata.priceVariation![itemindex].unit!,
                    //                "varmrp":widget._itemdata.priceVariation![itemindex].mrp,
                    //                "varprice":  widget._customerDetail.membership=="1" ? widget._itemdata.priceVariation![itemindex].membershipPrice.toString():widget._itemdata.priceVariation![itemindex].discointDisplay! ?widget._itemdata.priceVariation![itemindex].price.toString():widget._itemdata.priceVariation![itemindex].mrp.toString(),
                    //                "paymentMode": widget._itemdata.paymentMode,
                    //                "cronTime": widget._itemdata.subscriptionSlot![0].cronTime,
                    //                "name": widget._itemdata.subscriptionSlot![0].name,
                    //                "varid":widget._itemdata.priceVariation![itemindex].id,
                    //                "brand": widget._itemdata.brand
                    //              }
                    //          );
                    //        }
                    //      },
                    //      child: Row(
                    //        children: [
                    //          SizedBox(
                    //            width: 10,
                    //          ),
                    //          Expanded(
                    //            child: Container(
                    //              height: 30.0,
                    //              decoration: new BoxDecoration(
                    //                  color: ColorCodes.whiteColor,
                    //                  border: Border.all(color: Theme.of(context).primaryColor),
                    //                  borderRadius: new BorderRadius.only(
                    //                    topLeft: const Radius.circular(2.0),
                    //                    topRight:
                    //                    const Radius.circular(2.0),
                    //                    bottomLeft:
                    //                    const Radius.circular(2.0),
                    //                    bottomRight:
                    //                    const Radius.circular(2.0),
                    //                  )),
                    //              child: Row(
                    //                mainAxisAlignment: MainAxisAlignment.center,
                    //                crossAxisAlignment: CrossAxisAlignment.center,
                    //                children: [
                    //
                    //                  Text(
                    //                    S .of(context).subscribe,//'SUBSCRIBE',
                    //                    style: TextStyle(
                    //                        color: Theme.of(context).primaryColor,
                    //                        fontSize: 12, fontWeight: FontWeight.bold),
                    //                    textAlign: TextAlign.center,
                    //                  ),
                    //                ],
                    //              ) ,
                    //            ),
                    //          ),
                    //          SizedBox(
                    //            width: 10,
                    //          ),
                    //        ],
                    //      ),
                    //    ),
                    //  ):SizedBox(height: 30,):SizedBox.shrink(),
                    //  SizedBox(
                    //    height: 8,
                    //  ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10, /*right:10.0*/
                      ),
                      child: Container(
                          //  height:50,
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          VxBuilder(
                            mutations: {ProductMutation},
                            builder: (context, box, _) {
                              if (VxState.store.userData.membership! == "1") {
                                _checkmembership = true;
                              } else {
                                _checkmembership = false;
                                for (int i = 0; i < productBox.length; i++) {
                                  if (productBox[i].mode == "1") {
                                    _checkmembership = true;
                                  }
                                }
                              }
                              return Row(
                                children: <Widget>[
                                  /* if(Features.isMembership)
                                  _checkmembership?Container(
                                    width: 10.0,
                                    height: 9.0,
                                    margin: EdgeInsets.only(right: 3.0),
                                    child: Image.asset(
                                      Images.starImg,
                                      color: ColorCodes.starColor,
                                    ),
                                  ):SizedBox.shrink(),*/

                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      new RichText(
                                        text: new TextSpan(
                                          style: new TextStyle(
                                            fontSize: ResponsiveLayout
                                                    .isSmallScreen(context)
                                                ? 12
                                                : ResponsiveLayout
                                                        .isMediumScreen(context)
                                                    ? 13
                                                    : 14,
                                            color: Colors.black,
                                          ),
                                          children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                            new TextSpan(
                                                text: Features
                                                        .iscurrencyformatalign
                                                    ? '${_checkmembership ? widget._itemdata.membershipPrice : widget._itemdata.price} ' +
                                                        IConstants
                                                            .currencyFormat
                                                    : IConstants
                                                            .currencyFormat +
                                                        '${_checkmembership ? widget._itemdata.membershipPrice : widget._itemdata.price} ',
                                                style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _checkmembership
                                                      ? ColorCodes.greenColor
                                                      : Colors.black,
                                                  fontSize: ResponsiveLayout
                                                          .isSmallScreen(
                                                              context)
                                                      ? 12
                                                      : ResponsiveLayout
                                                              .isMediumScreen(
                                                                  context)
                                                          ? 13
                                                          : 14,
                                                )),
                                            new TextSpan(
                                                text: widget._itemdata.price !=
                                                        widget._itemdata.mrp
                                                    ? Features
                                                            .iscurrencyformatalign
                                                        ? '${widget._itemdata.mrp} ' +
                                                            IConstants
                                                                .currencyFormat
                                                        : IConstants
                                                                .currencyFormat +
                                                            '${widget._itemdata.mrp} '
                                                    : "",
                                                style: TextStyle(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontSize: ResponsiveLayout
                                                          .isSmallScreen(
                                                              context)
                                                      ? 12
                                                      : ResponsiveLayout
                                                              .isMediumScreen(
                                                                  context)
                                                          ? 13
                                                          : 14,
                                                )),
                                            TextSpan(
                                                text: (widget._itemdata.unit ==
                                                            null ||
                                                        widget._itemdata.unit ==
                                                            "")
                                                    ? ""
                                                    : " /" +
                                                        widget._itemdata.unit
                                                            .toString(),
                                                style: TextStyle(
                                                  fontSize: ResponsiveLayout
                                                          .isSmallScreen(
                                                              context)
                                                      ? 11
                                                      : ResponsiveLayout
                                                              .isMediumScreen(
                                                                  context)
                                                          ? 12
                                                          : 13,
                                                ))
                                          ],
                                        ),
                                      ),
                                      _checkmembership
                                          ? Text(
                                              "Membership Price",
                                              style: TextStyle(
                                                  color: ColorCodes.greenColor,
                                                  fontSize: 7),
                                            )
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                  Spacer(),
                                  _checkmembership
                                      ? (int.parse(widget._itemdata.mrp!) -
                                                  int.parse(widget._itemdata
                                                      .membershipPrice!)) >
                                              0
                                          ? Container(
                                              height: 22,
                                              // width: 80,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(
                                                      width: 5.0,
                                                      color:
                                                          ColorCodes.darkgreen),
                                                  // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                                ),
                                                color: ColorCodes.varcolor,
                                              ),

                                              child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text("Membership Savings ",
                                                      style: TextStyle(
                                                          fontSize: 8.5,
                                                          color: ColorCodes
                                                              .darkgreen,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      Features.iscurrencyformatalign
                                                          ? (int.parse(widget._itemdata.mrp!) -
                                                                      int.parse(widget
                                                                          ._itemdata
                                                                          .membershipPrice!))
                                                                  .toString() +
                                                              IConstants
                                                                  .currencyFormat
                                                          : IConstants.currencyFormat +
                                                              (int.parse(widget._itemdata.mrp!) -
                                                                      int.parse(widget
                                                                          ._itemdata
                                                                          .membershipPrice!))
                                                                  .toString() /*+ " " +S.of(context).membership_price*/,
                                                      style: TextStyle(
                                                          fontSize: 8.5,
                                                          /*fontWeight: FontWeight.bold,*/ color:
                                                              ColorCodes
                                                                  .darkgreen,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  SizedBox(width: 5),
                                                ],
                                              ),
                                            )
                                          : SizedBox.shrink()
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5.0),
                                          child: VxBuilder(
                                            mutations: {SetCartItem},
                                            builder: (context, box,
                                                index) {
                                              return Column(
                                                children: [
                                                  if (Features.isMembership &&
                                                      int.parse(widget._itemdata
                                                              .membershipPrice
                                                              .toString()) >
                                                          0)
                                                    Row(
                                                      children: <Widget>[
                                                        !_checkmembership
                                                            ? widget._itemdata
                                                                    .membershipDisplay!
                                                                ? GestureDetector(
                                                                    onTap: () {
                                                                      if (!PrefUtils
                                                                          .prefs!
                                                                          .containsKey(
                                                                              "apikey")) {
                                                                        if (kIsWeb &&
                                                                            !ResponsiveLayout.isSmallScreen(context)) {
                                                                          LoginWeb(
                                                                              context,
                                                                              result: (sucsess) {
                                                                            if (sucsess) {
                                                                              Navigator.of(context).pop();
                                                                              /* Navigator.pushNamedAndRemoveUntil(
                                              context, HomeScreen.routeName, (
                                              route) => false);*/
                                                                              Navigation(context, navigatore: NavigatoreTyp.homenav);
                                                                            } else {
                                                                              Navigator.of(context).pop();
                                                                            }
                                                                          });
                                                                        } else {
                                                                          /* Navigator.of(context).pushNamed(
                                        SignupSelectionScreen.routeName,
                                      );*/
                                                                          Navigation(
                                                                              context,
                                                                              name: Routename.SignUpScreen,
                                                                              navigatore: NavigatoreTyp.Push);
                                                                        }
                                                                      } else {
                                                                        /*Navigator.of(context).pushNamed(
                                      MembershipScreen.routeName,
                                    );*/
                                                                        Navigation(
                                                                            context,
                                                                            name:
                                                                                Routename.Membership,
                                                                            navigatore: NavigatoreTyp.Push);
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          22,
                                                                      // width: 178,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border:
                                                                            Border(
                                                                          right: BorderSide(
                                                                              width: 5.0,
                                                                              color: ColorCodes.darkgreen),
                                                                          // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                                                        ),
                                                                        color: ColorCodes
                                                                            .varcolor,
                                                                      ),
                                                                      child:
                                                                          Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                              // S .of(context).membership_price+ " " +//"Membership Price "
                                                                              Features.iscurrencyformatalign ? widget._itemdata.membershipPrice.toString() + IConstants.currencyFormat : IConstants.currencyFormat + widget._itemdata.membershipPrice.toString() + " Membership Price",
                                                                              style: TextStyle(fontSize: 9.0, color: ColorCodes.darkgreen, fontWeight: FontWeight.bold)),
                                                                          /* Spacer(),
                                                        Icon(
                                                          Icons.lock,
                                                          color: Colors.black,
                                                          size: 10,
                                                        ),
                                                        SizedBox(width: 2),
                                                        Icon(
                                                          Icons.arrow_forward_ios_sharp,
                                                          color: Colors.black,
                                                          size: 10,
                                                        ),*/
                                                                          SizedBox(
                                                                              width: 5),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                : SizedBox
                                                                    .shrink()
                                                            : SizedBox.shrink(),
                                                      ],
                                                    ),
                                                  !_checkmembership
                                                      ? widget._itemdata
                                                              .membershipDisplay!
                                                          ? SizedBox(
                                                              height: (Vx.isWeb &&
                                                                      !ResponsiveLayout
                                                                          .isSmallScreen(
                                                                              context))
                                                                  ? 0
                                                                  : 1,
                                                            )
                                                          : SizedBox(
                                                              height: (Vx.isWeb &&
                                                                      !ResponsiveLayout
                                                                          .isSmallScreen(
                                                                              context))
                                                                  ? 0
                                                                  : 1,
                                                            )
                                                      : SizedBox(
                                                          height: (Vx.isWeb &&
                                                                  !ResponsiveLayout
                                                                      .isSmallScreen(
                                                                          context))
                                                              ? 0
                                                              : 1,
                                                        )
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                ],
                              );
                            },
                          ),
                        ],
                      )),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 5.0,
                        right: 5.0,
                      ),
                      child: Container(
                          height: 40,
                          child: Row(
                            children: [
                              Container(
                                  height: (Features.isSubscription) ? 40 : 40,
                                  width: _checkmembership ? 180 : 180,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5.0),
                                    child: CustomeStepper(
                                      itemdata: widget._itemdata,
                                      from: "item_screen",
                                      height:
                                          (Features.isSubscription) ? 90 : 60,
                                      addon:
                                          (widget._itemdata.addon!.length > 0)
                                              ? widget._itemdata.addon![0]
                                              : null,
                                      index: itemindex,
                                      issubscription: "Add",
                                      ismember: _checkmembership,
                                      selectedindex: itemindex,
                                      onselect: (i) {
                                        setState(() {
                                          itemindex = i;
                                          // Navigator.of(context).pop();
                                        });
                                      },
                                    ),
                                  )),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Card(
            elevation: 1,
            margin: EdgeInsets.all(5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(15),
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            )),
            child: Container(
              // width:  _checkmembership? 230:230.0,
              width: _checkmembership ? 230 : 230.0,
              // decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(22)), border: Border.all(color: ColorCodes.backgroundcolor)),
              //height: MediaQuery.of(context).size.height,//aaaaaaaaaaaaaaaaaa
              child: Container(
                //margin: EdgeInsets.only(left: 10.0, top: 5.0, right: 2.0, bottom: 5.0),
                decoration: new BoxDecoration(
                  //color: Colors.white,
                  //border: Border.all(color: Colors.black26),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[300]!,
                        blurRadius: 10.0,
                        offset: Offset(0.0, 0.50)),
                  ],
                ),

                child: Stack(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      children: [
                        //SizedBox(height: 8,),
                        ItemBadge(
                          outOfStock: widget._itemdata
                                      .priceVariation![itemindex].stock! <=
                                  0
                              ? OutOfStock(
                                  singleproduct: false,
                                )
                              : null,
                          badgeDiscount:
                              BadgeDiscounts(value: margins.toStringAsFixed(0)),
                          // widgetBadge: WidgetBadge(isdisplay: true,child: widget._itemdata.eligibleForExpress=="0"?Padding(
                          //   padding: EdgeInsets.only(right: 5.0,),//EdgeInsets.all(3.0),
                          //   child: Image.asset(Images.express,
                          //     height: 20.0,
                          //     width: 25.0,),
                          // ):SizedBox.shrink()),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                debugPrint("single product...." +
                                    {
                                      "itemid": widget._itemdata.id,
                                      "itemname": widget._itemdata.itemName,
                                      "itemimg":
                                          widget._itemdata.itemFeaturedImage,
                                      "eligibleforexpress":
                                          widget._itemdata.eligibleForExpress,
                                      "delivery": widget._itemdata.delivery,
                                      "duration": widget._itemdata.duration,
                                      "durationType": widget._itemdata
                                          .deliveryDuration.durationType,
                                      "note": widget
                                          ._itemdata.deliveryDuration.note,
                                      "fromScreen": widget._fromScreen,
                                    }.toString());
                                /*     Navigator.of(context).pushNamed(
                                SingleproductScreen.routeName,
                                arguments: {
                                  "itemid": widget._itemdata.id.toString(),
                                  "itemname": widget._itemdata.itemName,
                                  "itemimg": widget._itemdata.itemFeaturedImage,
                                  "eligibleforexpress": widget._itemdata.eligibleForExpress,
                                  "delivery": widget._itemdata.delivery,
                                  "duration": widget._itemdata.duration,
                                  "durationType":widget._itemdata.deliveryDuration.durationType,
                                  "note":widget._itemdata.deliveryDuration.note,
                                  "fromScreen":widget._fromScreen,
                                });*/

                                debugPrint("varid......" +
                                    widget._itemdata.priceVariation![itemindex]
                                        .menuItemId
                                        .toString());
                                if (widget._fromScreen == "Forget") {
                                  Navigation(context,
                                      navigatore: NavigatoreTyp.Pop);
                                  Navigation(context,
                                      name: Routename.SingleProduct,
                                      navigatore: NavigatoreTyp.Push,
                                      parms: {
                                        "varid": widget
                                            ._itemdata
                                            .priceVariation![itemindex]
                                            .menuItemId
                                            .toString(),
                                        "productId": widget
                                            ._itemdata
                                            .priceVariation![itemindex]
                                            .menuItemId
                                            .toString()
                                      });
                                } else {
                                  Navigation(context,
                                      name: Routename.SingleProduct,
                                      navigatore: NavigatoreTyp.Push,
                                      parms: {
                                        "varid": widget
                                            ._itemdata
                                            .priceVariation![itemindex]
                                            .menuItemId
                                            .toString(),
                                        "productId": widget
                                            ._itemdata
                                            .priceVariation![itemindex]
                                            .menuItemId
                                            .toString()
                                      });
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(8),
                                  topRight: const Radius.circular(8),
                                ),
                                //margin: EdgeInsets.only(top: 10.0, bottom: 8.0),
                                child: CachedNetworkImage(
                                  imageUrl: widget
                                              ._itemdata
                                              .priceVariation![itemindex]
                                              .images!
                                              .length <=
                                          0
                                      ? widget._itemdata.itemFeaturedImage
                                      : widget
                                          ._itemdata
                                          .priceVariation![itemindex]
                                          .images![0]
                                          .image,
                                  errorWidget: (context, url, error) => Image.asset(
                                      Images.defaultProductImg,
                                      width:
                                          230, //ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                      height:
                                          top1 //ResponsiveLayout.isSmallScreen(context) ? 100 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                      ),
                                  placeholder: (context, url) => Image.asset(
                                      Images.defaultProductImg,
                                      width:
                                          230, //ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                      height:
                                          top1 // ResponsiveLayout.isSmallScreen(context) ? 100 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                      ),
                                  width:
                                      230, //ResponsiveLayout.isSmallScreen(context) ? 106 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                  height:
                                      top1, // ResponsiveLayout.isSmallScreen(context) ? 100 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: top1, bottom: 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: ColorCodes.whiteColor,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8))),
                        child: Column(
                          children: [
                            //   SizedBox(
                            //
                            //   height: 5,
                            // ),
                            widget._itemdata.eligibleForExpress == "0"
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        right: 5.0, left: 10),
                                    child: Container(
                                      width: 80,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                            color: ColorCodes.greenColor),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Express",
                                            style: TextStyle(
                                                fontSize: 9,
                                                color: ColorCodes
                                                    .checkmarginColor),
                                          ),
                                          Image.asset(
                                            Images.express,
                                            height: 20.0,
                                            width: 25.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
                            Row(
                              children: [
                                /* SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Text(
                              widget._itemdata.brand!,
                              style: TextStyle(
                                  fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 10 : 10,
                                  color: Colors.white,fontWeight: FontWeight.bold
                              ),
                            ),
                          ),*/
                                SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10.0,
                                ),
                                Expanded(
                                  child: Container(
                                    //color: Colors.black,
                                    height: 50,
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      widget._itemdata.itemName!,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: ResponsiveLayout
                                                  .isSmallScreen(context)
                                              ? 16
                                              : ResponsiveLayout.isMediumScreen(
                                                      context)
                                                  ? 12
                                                  : 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    //child: (widget._itemdata.vegType == "fish" || widget._itemdata.vegType == "meat") ? Image.asset( Images.nonVeg,height: 15, width: 15) : (widget._itemdata.vegType == "standard") ?Image.asset( Images.nonVeg,height: 15, width: 15) : const SizedBox(height: 15, width: 15),
                                    child: FoodType(
                                        isVeg: isVeg, isNonVeg: isNonVeg)),
                                Features.isSubscription &&
                                        widget._itemdata
                                                .eligibleForSubscription ==
                                            "0"
                                    ? Container(
                                        height: (Vx.isWeb) ? 35 : 35,
                                        width: (Vx.isWeb) ? 85 : 85,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 0, right: 5.0),
                                          child: CustomeStepper(
                                            priceVariation: widget._itemdata
                                                .priceVariation![itemindex],
                                            itemdata: widget._itemdata,
                                            from: "item_screen",
                                            height: (Features.isSubscription)
                                                ? 90
                                                : 60,
                                            issubscription: "Subscribe",
                                            addon: (widget._itemdata.addon!
                                                        .length >
                                                    0)
                                                ? widget._itemdata.addon![0]
                                                : null,
                                            index: itemindex,
                                            ismember: _checkmembership,
                                            selectedindex: itemindex,
                                            onselect: (i) {
                                              setState(() {
                                                itemindex = i;
                                                // Navigator.of(context).pop();
                                              });
                                            },
                                          ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                            // Spacer(),

//               Row(
//                 children: <Widget>[
//                   SizedBox(
//                     width: 10.0,
//                   ),
//                   VxBuilder(
//                     mutations: {ProductMutation},
//                     builder: (context, GroceStore box, _) {
//                       if(VxState.store.userData.membership! == "1"){
//                         _checkmembership = true;
//                       } else {
//                         _checkmembership = false;
//                         for (int i = 0; i < productBox.length; i++) {
//                           if (productBox[i].mode == "1") {
//                             _checkmembership = true;
//                           }
//                         }
//                       }
//                       return  Row(
//                         children: <Widget>[
//                           if(Features.isMembership)
//                             _checkmembership?Container(
//                               width: 10.0,
//                               height: 9.0,
//                               margin: EdgeInsets.only(right: 3.0),
//                               child: Image.asset(
//                                 Images.starImg,
//                                 color: ColorCodes.starColor,
//                               ),
//                             ):SizedBox.shrink(),
//
//                           new RichText(
//                             text: new TextSpan(
//                               style: new TextStyle(
//                                 fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,
//                                 color: Colors.black,
//                               ),
//                               children: <TextSpan>[
// //                            if(varmemberprice.toString() == varmrp.toString())
//                                 new TextSpan(
//                                     text:  Features.iscurrencyformatalign?
//                                     '${_checkmembership?widget._itemdata.priceVariation![itemindex].membershipPrice:widget._itemdata.priceVariation! [itemindex].price} ' + IConstants.currencyFormat:
//                                     IConstants.currencyFormat + '${_checkmembership?widget._itemdata.priceVariation![itemindex].membershipPrice:widget._itemdata.priceVariation![itemindex].price} ',
//                                     style: new TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black,
//                                       fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,)),
//                                 new TextSpan(
//                                     text: _checkmembership?
//                                     widget._itemdata.priceVariation![itemindex].membershipPrice==widget._itemdata.priceVariation![itemindex].price||widget._itemdata.priceVariation![itemindex].membershipPrice==widget._itemdata.priceVariation![itemindex].mrp ?""
//                                         : widget._itemdata.priceVariation![itemindex].price!=widget._itemdata.priceVariation![itemindex].mrp?
//                                         Features.iscurrencyformatalign?
//                                         '${widget._itemdata.priceVariation![itemindex].mrp} ' + IConstants.currencyFormat:
//                                     IConstants.currencyFormat + '${widget._itemdata.priceVariation![itemindex].mrp} ':""
//                                     :widget._itemdata.priceVariation![itemindex].price!=widget._itemdata.priceVariation![itemindex].mrp?
//                                     Features.iscurrencyformatalign?
//                                     '${widget._itemdata.priceVariation![itemindex].mrp} ' + IConstants.currencyFormat:
//                                     IConstants.currencyFormat + '${widget._itemdata.priceVariation![itemindex].mrp} ':"",
//                                     style: TextStyle(
//                                       decoration:
//                                       TextDecoration.lineThrough,
//                                       fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
//                               ],
//                             ),
//                           )
//                         ],
//                       );
//                     },
//                   ),
//                   Spacer(),
//                   if(Features.isLoyalty)
//                     if(double.parse(widget._itemdata.priceVariation![itemindex].loyalty.toString()) > 0)
//                       Container(
//                         child: Row(
//                           children: [
//                             Image.asset(Images.coinImg,
//                               height: 15.0,
//                               width: 20.0,),
//                             SizedBox(width: 4),
//                             Text(widget._itemdata.priceVariation![itemindex].loyalty.toString()),
//                           ],
//                         ),
//                       ),
//                   SizedBox(width: 10)
//                 ],
//               ),
//               SizedBox(
//                 height: 2,
//               ),
                            (Features.netWeight &&
                                    widget._itemdata.vegType == "fish")
                                ? Row(
                                    children: [
                                      SizedBox(
                                        width: 8.0,
                                      ),
                                      Text(
                                        Features.iscurrencyformatalign
                                            ? "Whole Uncut:" +
                                                " " +
                                                widget._itemdata.salePrice! +
                                                IConstants.currencyFormat +
                                                " / " +
                                                "500 G"
                                            : "Whole Uncut:" +
                                                " " +
                                                IConstants.currencyFormat +
                                                widget._itemdata.salePrice! +
                                                " / " +
                                                "500 G",
                                        style: new TextStyle(
                                            fontSize: ResponsiveLayout
                                                    .isSmallScreen(context)
                                                ? 10
                                                : ResponsiveLayout
                                                        .isMediumScreen(context)
                                                    ? 11
                                                    : 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(),
                            /*SizedBox(
                      height: 5,
                    ),*/
                            (Features.netWeight &&
                                    widget._itemdata.vegType == "fish")
                                ? SizedBox(
                                    height: 2,
                                  )
                                : SizedBox
                                    .shrink() /*SizedBox(
                    height: 2,
              )*/
                            ,
                            (Features.netWeight &&
                                    widget._itemdata.vegType == "fish")
                                ? Row(children: [
                                    SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "G Weight:" +
                                                " " +
                                                /*'$weight '*/ widget
                                                    ._itemdata
                                                    .priceVariation![itemindex]
                                                    .weight!,
                                            style: new TextStyle(
                                                fontSize: ResponsiveLayout
                                                        .isSmallScreen(context)
                                                    ? 10
                                                    : ResponsiveLayout
                                                            .isMediumScreen(
                                                                context)
                                                        ? 11
                                                        : 11,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    SizedBox(width: 5),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                            "N Weight:" +
                                                " " +
                                                /*'$netWeight '*/ widget
                                                    ._itemdata
                                                    .priceVariation![itemindex]
                                                    .netWeight!,
                                            style: new TextStyle(
                                                fontSize: ResponsiveLayout
                                                        .isSmallScreen(context)
                                                    ? 10
                                                    : ResponsiveLayout
                                                            .isMediumScreen(
                                                                context)
                                                        ? 11
                                                        : 11,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    SizedBox(width: 10),
                                  ])
                                : /*SizedBox(height: 5,)*/ SizedBox.shrink(),
                            /*
                      ( widget._itemdata.priceVariation!.length > 1)
                          ? Features.btobModule?
                      Container(
                        // height: 200,
                          child: SingleChildScrollView(
                              child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: widget._itemdata.priceVariation!.length,
                                  itemBuilder: (_, i) {
                                    return MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          //showoptions1();
                                          setState(() {
                                            _groupValue = i;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Expanded(
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    // border: Border.all(color: ColorCodes.greenColor),
                                                    color: _groupValue == i ? ColorCodes.mediumgren : ColorCodes.whiteColor,
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    border: Border.all(
                                                      color: ColorCodes.greenColor,
                                                    ),
                                                    /* borderRadius: new BorderRadius.only(
                                               topLeft: const Radius.circular(2.0),
                                               bottomLeft: const Radius.circular(2.0),
                                             )*/),
                                                  height: 30,
                                                  margin: EdgeInsets.only(bottom:5),
                                                  padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                                                  child:
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "${widget._itemdata.priceVariation![i].minItem}"+"-"+"${widget._itemdata.priceVariation![i].maxItem}"+" "+"${widget._itemdata.priceVariation![i].unit}",
                                                        style: TextStyle(color: ColorCodes.darkgreen/*Colors.black*/,fontWeight: FontWeight.bold),
                                                      ),
                                                      _groupValue == i ?
                                                      Container(
                                                        width: 18.0,
                                                        height: 18.0,
                                                        padding: EdgeInsets.only(right:3),
                                                        decoration: BoxDecoration(
                                                          color: ColorCodes.greenColor,
                                                          border: Border.all(
                                                            color: ColorCodes.greenColor,
                                                          ),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Container(
                                                          margin: EdgeInsets.all(1.5),
                                                          decoration: BoxDecoration(
                                                            color: ColorCodes.greenColor,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: Icon(Icons.check,
                                                              color: ColorCodes.whiteColor,
                                                              size: 12.0),
                                                        ),
                                                      )
                                                          :
                                                      Icon(
                                                          Icons.radio_button_off_outlined,
                                                          color: ColorCodes.greenColor),

                                                    ],
                                                  )

                                              ),
                                            ),
                                            /* Container(
                                       height: 30,
                                       decoration: BoxDecoration(
                                           color: ColorCodes.varcolor,
                                           borderRadius: new BorderRadius.only(
                                             topRight: const Radius.circular(2.0),
                                             bottomRight: const Radius.circular(2.0),
                                           )),
                                       child: Icon(
                                         Icons.keyboard_arrow_down,
                                         color: ColorCodes.darkgreen,
                                       ),
                                     ),*/
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                              )
                          )
                      )
                          :
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            showoptions1();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 10.0,
                              ),
                              /*
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    // border: Border.all(color: ColorCodes.greenColor),
                                    //color: ColorCodes.varcolor,
                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(2.0),
                                        bottomLeft: const Radius.circular(2.0),
                                      )),
                                  height: 18,
                                  padding: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0),
                                  child: Text(
                                    "${widget._itemdata.priceVariation![itemindex].variationName}"+" "+"${widget._itemdata.priceVariation![itemindex].unit}",
                                    style: TextStyle(color: ColorCodes.darkgreen/*Colors.black*/,fontWeight: FontWeight.bold,fontSize: 12),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: ColorCodes.darkgreen,
                                size: 18,
                              ),
                              */
                              SizedBox(
                                width: 10.0,
                              ),
                              if(Features.isLoyalty)
                                if(double.parse(widget._itemdata.priceVariation![itemindex].loyalty.toString()) > 0)
                                  Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(Images.coinImg,
                                          height: 13.0,
                                          width: 20.0,),
                                        SizedBox(width: 2),
                                        Text(widget._itemdata.priceVariation![itemindex].loyalty.toString(),
                                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),
                                      ],
                                    ),
                                  ),
                              SizedBox(
                                width: 10.0,
                              ),
                            ],
                          ),
                        ),
                      ) :
                      Features.btobModule?
                      Container(
                        // height: 200,
                          child: SingleChildScrollView(
                              child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: widget._itemdata.priceVariation!.length,
                                  itemBuilder: (_, i) {
                                    return MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          //showoptions1();
                                        },
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Expanded(
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    // border: Border.all(color: ColorCodes.greenColor),
                                                    color: _groupValue == i ? ColorCodes.mediumgren : ColorCodes.whiteColor,
                                                    borderRadius: BorderRadius.circular(5.0),
                                                    border: Border.all(
                                                      color: ColorCodes.greenColor,
                                                    ),
                                                    /* borderRadius: new BorderRadius.only(
                                               topLeft: const Radius.circular(2.0),
                                               bottomLeft: const Radius.circular(2.0),
                                             )*/),
                                                  height: 30,
                                                  margin: EdgeInsets.only(bottom:5),
                                                  padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                                                  child:
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "${widget._itemdata.priceVariation![i].minItem}"+"-"+"${widget._itemdata.priceVariation![i].maxItem}"+" "+"${widget._itemdata.priceVariation![i].unit}",
                                                        style: TextStyle(color: ColorCodes.darkgreen/*Colors.black*/,fontWeight: FontWeight.bold),
                                                      ),
                                                      _groupValue == i ?
                                                      Container(
                                                        width: 18.0,
                                                        height: 18.0,
                                                        padding: EdgeInsets.only(right:3),
                                                        decoration: BoxDecoration(
                                                          color: ColorCodes.greenColor,
                                                          border: Border.all(
                                                            color: ColorCodes.greenColor,
                                                          ),
                                                          shape: BoxShape.circle,

                                                        ),
                                                        child: Container(
                                                          margin: EdgeInsets.all(1.5),
                                                          decoration: BoxDecoration(
                                                            color: ColorCodes.greenColor,
                                                            shape: BoxShape.circle,
                                                          ),
                                                          child: Icon(Icons.check,
                                                              color: ColorCodes.whiteColor,
                                                              size: 12.0),
                                                        ),
                                                      )
                                                          :
                                                      Icon(
                                                          Icons.radio_button_off_outlined,
                                                          color: ColorCodes.greenColor),

                                                    ],
                                                  )

                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                              )
                          )
                      ):
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //SizedBox(width: 10.0,),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                //color: ColorCodes.varcolor,
                                // border: Border.all(color: ColorCodes.greenColor),
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(2.0),
                                    topRight: const Radius.circular(2.0),
                                    bottomLeft: const Radius.circular(2.0),
                                    bottomRight: const Radius.circular(2.0),
                                  )),
                              height: 18,
                              padding: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0.0),
                              child: Text(
                                "${widget._itemdata.priceVariation![itemindex].variationName}"+" "+"${widget._itemdata.priceVariation![itemindex].unit}",
                                style: TextStyle(color:ColorCodes.whiteColor,fontWeight: FontWeight.bold,fontSize: 12),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          if(Features.isLoyalty)
                            if(double.parse(widget._itemdata.priceVariation![itemindex].loyalty.toString()) > 0)
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image.asset(Images.coinImg,
                                      height: 13.0,
                                      width: 20.0,),
                                    SizedBox(width: 2),
                                    Text(widget._itemdata.priceVariation![itemindex].loyalty.toString(),
                                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),
                                  ],
                                ),
                              ),
                          SizedBox(
                            width: 10.0,
                          ),
                        ],
                      ),

                       */
                            /*
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //SizedBox(width:10),
                          Text(widget._itemdata.singleshortNote.toString(),style: TextStyle(fontSize: 10,color: ColorCodes.greyColor,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      */
                            /*
                      SizedBox(height:5),

                      Padding(
                        padding: const EdgeInsets.only(left:10.0/*,right:10*/),
                        child: Container(
                          // height:50,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              VxBuilder(
                                mutations: {ProductMutation},
                                builder: (context, GroceStore box, _) {
                                  if(VxState.store.userData.membership! == "1"){
                                    _checkmembership = true;
                                  } else {
                                    _checkmembership = false;
                                    for (int i = 0; i < productBox.length; i++) {
                                      if (productBox[i].mode == "1") {
                                        _checkmembership = true;
                                      }
                                    }
                                  }
                                  return  Row(
                                    children: <Widget>[
                                      /* if(Features.isMembership)
                                      _checkmembership?Container(
                                        width: 10.0,
                                        height: 9.0,
                                        margin: EdgeInsets.only(right: 3.0),
                                        child: Image.asset(
                                          Images.starImg,
                                          color: ColorCodes.starColor,
                                        ),
                                      ):SizedBox.shrink(),*/

                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          new RichText(
                                            text: new TextSpan(
                                              style: new TextStyle(
                                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,
                                                color: Colors.black,
                                              ),
                                              children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                                new TextSpan(
                                                    text:  Features.iscurrencyformatalign?
                                                    '${_checkmembership?widget._itemdata.priceVariation![itemindex].membershipPrice:widget._itemdata.priceVariation! [itemindex].price} ' + IConstants.currencyFormat:
                                                    IConstants.currencyFormat + '${_checkmembership?widget._itemdata.priceVariation![itemindex].membershipPrice:widget._itemdata.priceVariation![itemindex].price} ',
                                                    style: new TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color:_checkmembership?ColorCodes.greenColor: Colors.black,
                                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                                                new TextSpan(
                                                    text: widget._itemdata.priceVariation![itemindex].price == widget._itemdata.priceVariation![itemindex].mrp?
                                                    Features.iscurrencyformatalign ?
                                                    '${_checkmembership ?  widget._itemdata.priceVariation![itemindex].membershipDisplay! ?
                                                    widget._itemdata.priceVariation![itemindex].mrp : "" : ""}' + IConstants.currencyFormat
                                                        :
                                                    '${_checkmembership ? widget._itemdata.priceVariation![itemindex].membershipDisplay! ?
                                                    IConstants.currencyFormat + widget._itemdata.priceVariation![itemindex].mrp! : "" : ""}'
                                                        : "",
                                                    style: TextStyle(
                                                      decoration:
                                                      TextDecoration.lineThrough,
                                                      fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 13,)),
                                              ],
                                            ),
                                          ),
                                          _checkmembership ?Text("Membership Price",style: TextStyle(color: ColorCodes.greenColor,fontSize: 7),):SizedBox.shrink(),

                                        ],
                                      ),


                                      Spacer(),
                                      /*_checkmembership?(int.parse(widget._itemdata.priceVariation![itemindex].mrp!) - int.parse(widget._itemdata.priceVariation![itemindex].membershipPrice!))>0?
                                    Container(
                                      height: 22,
                                      // width: 80,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          right: BorderSide(width: 5.0, color: ColorCodes.darkgreen),
                                          // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                        ),
                                        color: ColorCodes.varcolor,
                                      ),

                                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text( "Membership Savings ",style: TextStyle(fontSize: 8.5,color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),
                                          Text(
                                              Features.iscurrencyformatalign?
                                              (int.parse(widget._itemdata.priceVariation![itemindex].mrp!) - int.parse(widget._itemdata.priceVariation![itemindex].membershipPrice!)).toString() + IConstants.currencyFormat:
                                              IConstants.currencyFormat +
                                                  (int.parse(widget._itemdata.priceVariation![itemindex].mrp!) - int.parse(widget._itemdata.priceVariation![itemindex].membershipPrice!)).toString() *//*+ " " +S.of(context).membership_price*//*,
                                              style: TextStyle(fontSize: 8.5,*//*fontWeight: FontWeight.bold,*//*color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),

                                          SizedBox(width: 5),
                                        ],
                                      ),
                                    ):SizedBox.shrink()
                                        :*/
                                      Padding(
                                        padding: const EdgeInsets.only(right: 5.0),
                                        child: VxBuilder(
                                          mutations: {SetCartItem},
                                          builder: (context, GroceStore box, index) {
                                            return Column(
                                              children: [
                                                if(Features.isMembership && double.parse(widget._itemdata.priceVariation![itemindex].membershipPrice.toString()) > 0)
                                                  Row(
                                                    children: <Widget>[
                                                      !_checkmembership
                                                          ? widget._itemdata.priceVariation![itemindex].membershipDisplay!
                                                          ? GestureDetector(
                                                        onTap: () {
                                                          if(!PrefUtils.prefs!.containsKey("apikey")) {
                                                            if (kIsWeb && !ResponsiveLayout.isSmallScreen(
                                                                context)) {
                                                              LoginWeb(context, result: (sucsess) {
                                                                if (sucsess) {
                                                                  Navigator.of(context).pop();
                                                                  /* Navigator.pushNamedAndRemoveUntil(
                                                              context, HomeScreen.routeName, (
                                                              route) => false);*/
                                                                  Navigation(context, navigatore: NavigatoreTyp.homenav);
                                                                } else {
                                                                  Navigator.of(context).pop();
                                                                }
                                                              });
                                                            } else {
                                                              /* Navigator.of(context).pushNamed(
                                                        SignupSelectionScreen.routeName,
                                                      );*/
                                                              Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);
                                                            }
                                                          }
                                                          else{
                                                            /*Navigator.of(context).pushNamed(
                                                      MembershipScreen.routeName,
                                                    );*/
                                                            Navigation(context, name: Routename.Membership, navigatore: NavigatoreTyp.Push);
                                                          }
                                                        },
                                                        child: Container(
                                                          height: 22,
                                                          // width: 80,
                                                          decoration: BoxDecoration(
                                                            border: Border(
                                                              right: BorderSide(width: 5.0, color: ColorCodes.darkgreen),
                                                              // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                                            ),
                                                            color: ColorCodes.varcolor,
                                                          ),

                                                          child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                                            children: <Widget>[

                                                              Text(
                                                                // S .of(context).membership_price+ " " +//"Membership Price "
                                                                  Features.iscurrencyformatalign?
                                                                  widget._itemdata.priceVariation![itemindex].membershipPrice.toString() + IConstants.currencyFormat:
                                                                  IConstants.currencyFormat +
                                                                      widget._itemdata.priceVariation![itemindex].membershipPrice.toString() /*+ " " +S.of(context).membership_price*/+" Membership Price",
                                                                  style: TextStyle(fontSize: 9.0,/*fontWeight: FontWeight.bold,*/color: ColorCodes.darkgreen,fontWeight: FontWeight.bold)),

                                                              SizedBox(width: 5),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                          : SizedBox.shrink()
                                                          : SizedBox.shrink(),
                                                    ],
                                                  ),
                                                !_checkmembership
                                                    ? widget._itemdata.priceVariation![itemindex].membershipDisplay!
                                                    ? SizedBox(
                                                  height:( Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?0:1,
                                                )
                                                    : SizedBox(
                                                  height:( Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?0:1,
                                                )
                                                    : SizedBox(
                                                  height:( Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?0:1,
                                                )
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),


                            ],
                          ),
                        ),
                      ),
                      */

                            (widget._itemdata.item_description != null &&
                                    widget._itemdata.item_description != "")
                                ? SizedBox(
                                    height: 30,
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            widget._itemdata.item_description!,
                                            overflow: TextOverflow.ellipsis,
                                            //softWrap: true,
                                            //maxLines: 2,
                                            style: TextStyle(
                                                color: ColorCodes.blackColor,
                                                fontSize: ResponsiveLayout
                                                        .isSmallScreen(context)
                                                    ? 10
                                                    : ResponsiveLayout
                                                            .isMediumScreen(
                                                                context)
                                                        ? 13
                                                        : 13),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(height: 35),
                            // Text( widget._itemdata.item_description != null ? widget._itemdata.item_description!.substring(0,widget._itemdata.item_description!.length > 30 ?  30 : widget._itemdata.item_description!.length) + "...More" : "", style:TextStyle(fontSize: 10,color: ColorCodes.whiteColor,fontWeight: FontWeight.bold)),
                            // SizedBox(height:10),
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0, bottom: 8),
                              height: 40,
                              child: Row(
                                mainAxisAlignment:
                                    widget._itemdata.addon!.length > 0
                                        ? MainAxisAlignment.spaceBetween
                                        : MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      widget._itemdata.addon!.length > 0
                                          ? Text('Customize',
                                              style: TextStyle(
                                                  fontSize: 8,
                                                  color: ColorCodes.blackColor,
                                                  fontWeight:
                                                      FontWeight.normal))
                                          : const SizedBox(height: 12),
                                      const SizedBox(height: 2),
                                      RichText(
                                        text: new TextSpan(
                                          style: new TextStyle(
                                            fontSize: ResponsiveLayout
                                                    .isSmallScreen(context)
                                                ? 14
                                                : ResponsiveLayout
                                                        .isMediumScreen(context)
                                                    ? 15
                                                    : 16,
                                            color: Colors.black,
                                          ),
                                          children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                                            new TextSpan(
                                                text:
                                                    //'${_checkmembership?widget.itemdata!.priceVariation![itemindex].membershipPrice:widget.itemdata!.priceVariation![itemindex].price} ' + IConstants.currencyFormat:
                                                    Features.iscurrencyformatalign
                                                        ? '${_checkmembership ? widget._itemdata.priceVariation![itemindex].membershipPrice : widget._itemdata.priceVariation![itemindex].price} ' +
                                                            IConstants
                                                                .currencyFormat
                                                        : IConstants
                                                                .currencyFormat +
                                                            '${_checkmembership ? widget._itemdata.priceVariation![itemindex].membershipPrice : widget._itemdata.priceVariation![itemindex].price} ',
                                                style: new TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _checkmembership
                                                      ? ColorCodes.greenColor
                                                      : Colors.black,
                                                  fontSize: ResponsiveLayout
                                                          .isSmallScreen(
                                                              context)
                                                      ? 15
                                                      : ResponsiveLayout
                                                              .isMediumScreen(
                                                                  context)
                                                          ? 15
                                                          : 16,
                                                )),
                                            new TextSpan(
                                                text: widget
                                                            ._itemdata
                                                            .priceVariation![
                                                                itemindex]
                                                            .price ==
                                                        widget
                                                            ._itemdata
                                                            .priceVariation![
                                                                itemindex]
                                                            .mrp
                                                    ? Features
                                                            .iscurrencyformatalign
                                                        ? '${_checkmembership ? widget._itemdata.priceVariation![itemindex].membershipDisplay! ? widget._itemdata.priceVariation![itemindex].mrp : "" : ""}' +
                                                            IConstants
                                                                .currencyFormat
                                                        : '${_checkmembership ? widget._itemdata.priceVariation![itemindex].membershipDisplay! ? IConstants.currencyFormat + widget._itemdata.priceVariation![itemindex].mrp! : "" : ""}'
                                                    : "",
                                                style: TextStyle(
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontSize: ResponsiveLayout
                                                          .isSmallScreen(
                                                              context)
                                                      ? 10
                                                      : ResponsiveLayout
                                                              .isMediumScreen(
                                                                  context)
                                                          ? 13
                                                          : 14,
                                                )),
                                          ],
                                        ),
                                      ),
                                      _checkmembership
                                          ? Text(
                                              " Membership Price",
                                              style: TextStyle(
                                                  color: ColorCodes.greenColor,
                                                  fontSize: 7),
                                            )
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                  Container(
                                    height: (Features.isSubscription) ? 40 : 40,
                                    width: _checkmembership ? 100 : 100,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 2, right: 0.0),
                                      child: CustomeStepper(
                                        priceVariation: widget._itemdata
                                            .priceVariation![itemindex],
                                        itemdata: widget._itemdata,
                                        from: "item_screen",
                                        height:
                                            (Features.isSubscription) ? 90 : 40,
                                        issubscription: "Add",
                                        addon:
                                            (widget._itemdata.addon!.length > 0)
                                                ? widget._itemdata.addon![0]
                                                : null,
                                        index: itemindex,
                                        showPrice: false,
                                        ismember: _checkmembership,
                                        selectedindex: itemindex,
                                        onselect: (i) {
                                          setState(() {
                                            itemindex = i;
                                            // Navigator.of(context).pop();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}

class FoodType extends StatelessWidget {
  const FoodType({Key? key, this.isNonVeg = false, this.isVeg = false})
      : super(key: key);
  final bool isVeg;
  final bool isNonVeg;

  @override
  Widget build(BuildContext context) {
    return isNonVeg
        ? Image.asset(Images.nonVeg, height: 15, width: 15)
        : isVeg
            ? Image.asset(Images.veg, height: 15, width: 15)
            : const SizedBox(height: 15, width: 15);
  }
}
