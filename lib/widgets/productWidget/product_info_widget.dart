import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import '../../assets/ColorCodes.dart';
import '../../assets/images.dart';
import '../../components/login_web.dart';
import '../../constants/IConstants.dart';
import '../../constants/features.dart';
import '../../generated/l10n.dart';
import '../../helper/custome_calculation.dart';
import '../../helper/custome_checker.dart';
import '../../models/VxModels/VxStore.dart';
import '../../models/newmodle/product_data.dart';
import '../../rought_genrator.dart';
import '../../utils/ResponsiveLayout.dart';
import '../../utils/prefUtils.dart';
import '../../widgets/custome_stepper.dart';
import '../../widgets/productWidget/product_sliding_image_widget.dart';
import 'package:velocity_x/velocity_x.dart';

import 'item_variation.dart';
import 'membership_info_widget.dart';

class ProductInfoWidget extends StatefulWidget {
  final ItemData itemdata;
  late int itemindex;
  late int itemindexs;
  final String variationId;
  Function() ontap;
  ProductInfoWidget(
      {Key? key,
        required this.itemdata,
        required String varid,
        required this.itemindexs,
        required this.ontap,
        required this.variationId}) {
    this.itemindex =
        itemdata.priceVariation!.indexWhere((element) => element.id == varid);
  }

  @override
  State<ProductInfoWidget> createState() => _ProductInfoWidgetState();
}

class _ProductInfoWidgetState extends State<ProductInfoWidget>
    with Navigations {
  @override
  Widget build(BuildContext context) {
    StateSetter? stateSetter;
    var _checkmembership = false;
    print("express ..." + VxState.store.userData.membership!.toString());
    debugPrint("widget.itemindexs...." + widget.itemindexs.toString());
    if ((VxState.store as GroceStore).userData.membership! == "1") {
      _checkmembership = true;
    } else {
      _checkmembership = false;
      for (int i = 0;
      i < (VxState.store as GroceStore).CartItemList.length;
      i++) {
        if ((VxState.store as GroceStore).CartItemList[i].mode == "1") {
          _checkmembership = true;
        }
      }
    }
    showoptions1(/*StateSetter setState*/) {
      (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))
          ? showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState1) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0)),
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  //height: 200,
                  padding: EdgeInsets.fromLTRB(30, 20, 20, 20),
                  child: ItemVariation(
                    itemdata: widget.itemdata,
                    ismember: _checkmembership,
                    selectedindex: widget.itemindexs,
                    onselect: (i) {
                      setState1(() {
                        widget.itemindex = i;
                        // Navigator.of(context).pop();
                      });
                    },
                  ),
                ),
              );
            });
          }).then((_) => stateSetter!(() {}))
          : showModalBottomSheet<dynamic>(
          isScrollControlled: true,
          context: context,
          builder: (context) {
            //return StatefulBuilder(builder: (context, setState){
            return ItemVariation(
              itemdata: widget.itemdata,
              ismember: _checkmembership,
              selectedindex: widget.itemindexs,
              onselect: (i) {
                debugPrint("stateSetter.....1");
                setState(() {
                  debugPrint("stateSetter.....");
                  widget.itemindexs = i;
                  debugPrint(
                      "itemindexs...." + widget.itemindexs.toString());
                });
              },
            );
            // }
            // );
          });
    }

    String _priceDisplay = "";
    String _mrpDisplay = "";
    String _mrp = "0";
    String _price = "0";
    bool _isSingleSKU = widget.itemdata.type == "1" ? true : false;

    if(Check().checkmembership()) { //Membered user
      if(_isSingleSKU ? widget.itemdata.membershipDisplay! : widget.itemdata.priceVariation![widget.itemindexs].membershipDisplay!){ //Eligible to display membership price
        _priceDisplay = _isSingleSKU ? widget.itemdata.membershipPrice! : widget.itemdata.priceVariation![ widget.itemindexs].membershipPrice.toString();
        _mrpDisplay = _isSingleSKU ? widget.itemdata.mrp! : widget.itemdata.priceVariation![ widget.itemindexs].mrp!;
        _mrp = _mrpDisplay;
      } else if(_isSingleSKU ? widget.itemdata.discointDisplay! : widget.itemdata.priceVariation![widget.itemindexs].discointDisplay!){ //Eligible to display discounted price
        _priceDisplay = _isSingleSKU ? widget.itemdata.price! : widget.itemdata.priceVariation![ widget.itemindexs].price!;
        _mrpDisplay = _isSingleSKU ? widget.itemdata.mrp! : widget.itemdata.priceVariation![ widget.itemindexs].mrp!;
        _mrp = _mrpDisplay;
      } else { //Otherwise display mrp
        _priceDisplay = _isSingleSKU ? widget.itemdata.mrp! : widget.itemdata.priceVariation![ widget.itemindexs].mrp!;
        _mrp = _priceDisplay;
      }
    } else { //Non membered user
      if(_isSingleSKU ? widget.itemdata.discointDisplay! : widget.itemdata.priceVariation![ widget.itemindexs].discointDisplay!){ //Eligible to display discounted price
        _priceDisplay = _isSingleSKU ? widget.itemdata.price! : widget.itemdata.priceVariation![ widget.itemindexs].price!;
        _mrpDisplay = _isSingleSKU ? widget.itemdata.mrp! : widget.itemdata.priceVariation![ widget.itemindexs].mrp!;
        _mrp = _mrpDisplay;
      } else { //Otherwise display mrp
        _priceDisplay = _isSingleSKU ? widget.itemdata.mrp! : widget.itemdata.priceVariation![ widget.itemindexs].mrp!;
        _mrp = _priceDisplay;
      }
    }

    _price = _priceDisplay;

    if(Features.iscurrencyformatalign) {
      _priceDisplay = '${double.parse(_priceDisplay).toStringAsFixed(IConstants.decimaldigit)} ' + IConstants.currencyFormat;
      if(_mrpDisplay != "")
        _mrpDisplay = '${double.parse(_mrpDisplay).toStringAsFixed(IConstants.decimaldigit)} ' + IConstants.currencyFormat;
    } else {
      _priceDisplay = IConstants.currencyFormat + '${double.parse(_priceDisplay).toStringAsFixed(IConstants.decimaldigit)} ';
      if(_mrpDisplay != "")
        _mrpDisplay =  IConstants.currencyFormat + '${double.parse(_mrpDisplay).toStringAsFixed(IConstants.decimaldigit)} ';
    }

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal:
              Vx.isWeb && !ResponsiveLayout.isSmallScreen(context) ? 0 : 0),
          child: Container(
            // width: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
            // MediaQuery.of(context).size.width / 2:(MediaQuery.of(context)
            //     .size
            //     .width) -
            //     20 ,
            child: Column(
              children: [
                (Vx.isWeb && ResponsiveLayout.isSmallScreen(context))
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SlidingImage(
                      productdata: widget.itemdata,
                      varid: widget.variationId,
                      itemindexs: widget.itemindexs,
                      ontap: () {},
                    ),
                  ],
                )
                    : (Vx.isWeb)
                    ? SizedBox.shrink()
                    : SlidingImage(
                  productdata: widget.itemdata,
                  varid: widget.variationId,
                  itemindexs: widget.itemindexs,
                  ontap: () {},
                ),
                Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)
                    ? Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 3.0,
                      horizontal: Vx.isWeb &&
                          !ResponsiveLayout.isSmallScreen(context)
                          ? 0
                          : 0),
                  child: Row(
                    children: [
                      ///Show Brands
                      // Text(
                      //   widget.itemdata.brand.toString(),
                      //   style: TextStyle(
                      //     fontSize: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?20:12,
                      //     fontWeight: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?FontWeight.bold:FontWeight.normal,
                      //   ),
                      // ),
                      // Spacer(),
                      ///Show margin
                      if (widget.itemdata.type == "1"
                          ? Calculate().getmargin(_mrp, _price
                        /*widget.itemdata.mrp,
                                        VxState.store.userData.membership! ==
                                                    "0" ||
                                                VxState.store.userData
                                                        .membership! ==
                                                    "2"
                                            ? widget.itemdata.discointDisplay!
                                                ? widget.itemdata.price
                                                : widget.itemdata.mrp
                                            : widget.itemdata.membershipDisplay!
                                                ? widget
                                                    .itemdata.membershipPrice
                                                : widget.itemdata.price*/) >
                          0
                          : Calculate().getmargin(_mrp, _price
                        /*widget
                                            .itemdata
                                            .priceVariation![widget.itemindexs]
                                            .mrp,
                                        VxState.store.userData.membership! ==
                                                    "0" ||
                                                VxState.store.userData
                                                        .membership! ==
                                                    "2"
                                            ? widget
                                                    .itemdata
                                                    .priceVariation![
                                                        widget.itemindexs]
                                                    .discointDisplay!
                                                ? widget
                                                    .itemdata
                                                    .priceVariation![
                                                        widget.itemindexs]
                                                    .price
                                                : widget
                                                    .itemdata
                                                    .priceVariation![
                                                        widget.itemindexs]
                                                    .mrp
                                            : widget
                                                    .itemdata
                                                    .priceVariation![
                                                        widget.itemindexs]
                                                    .membershipDisplay!
                                                ? widget
                                                    .itemdata
                                                    .priceVariation![
                                                        widget.itemindexs]
                                                    .membershipPrice
                                                : widget
                                                    .itemdata
                                                    .priceVariation![
                                                        widget.itemindexs]
                                                    .price*/) >
                          0)
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context)
                                  .viewInsets
                                  .bottom),
                          child: Container(
                            //margin: EdgeInsets.only(right:5.0),
                            height:
                            MediaQuery.of(context).size.height / 2.1,
                            // color: Theme.of(context).accentColor,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0),
                              ),
                              color: ColorCodes.whiteColor,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 40,
                              minHeight: 38,
                            ),
                            child: Text(
                              widget.itemdata.type == "1"
                                  ? Calculate()
                                  .getmargin(_mrp,_price
                                /*widget.itemdata.mrp,
                                                    VxState.store.userData.membership! == "0" ||
                                                            VxState
                                                                    .store
                                                                    .userData
                                                                    .membership! ==
                                                                "2"
                                                        ? widget.itemdata
                                                                .discointDisplay!
                                                            ? widget
                                                                .itemdata.price
                                                            : widget
                                                                .itemdata.mrp
                                                        : widget.itemdata
                                                                .membershipDisplay!
                                                            ? widget.itemdata
                                                                .membershipPrice
                                                            : widget
                                                                .itemdata.price*/)
                                  .toStringAsFixed(2) +
                                  S.current.off
                                  : Calculate()
                                  .getmargin(_mrp , _price
                                /* widget
                                                        .itemdata
                                                        .priceVariation![
                                                            widget.itemindexs]
                                                        .mrp,
                                                    VxState.store.userData.membership! ==
                                                                "0" ||
                                                            VxState
                                                                    .store
                                                                    .userData
                                                                    .membership! ==
                                                                "2"
                                                        ? widget
                                                                .itemdata
                                                                .priceVariation![widget
                                                                    .itemindexs]
                                                                .discointDisplay!
                                                            ? widget
                                                                .itemdata
                                                                .priceVariation![widget.itemindexs]
                                                                .price
                                                            : widget.itemdata.priceVariation![widget.itemindexs].mrp
                                                        : widget.itemdata.priceVariation![widget.itemindexs].membershipDisplay!
                                                            ? widget.itemdata.priceVariation![widget.itemindexs].membershipPrice
                                                            : widget.itemdata.priceVariation![widget.itemindexs].price*/)
                                  .toStringAsFixed(0) +
                                  S.current.off,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: ColorCodes.darkgreen,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
                    : SizedBox.shrink(),
                Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)
                    ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),

                    // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 3.0,
                        horizontal: Vx.isWeb &&
                            !ResponsiveLayout.isSmallScreen(context)
                            ? 0
                            : 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///Show Product Name
                            Vx.isWeb &&
                                !ResponsiveLayout.isSmallScreen(
                                    context)
                                ? SizedBox(
                              height: 20,
                            )
                                : SizedBox.shrink(),
                            Text(
                              widget.itemdata.itemName.toString(),
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: Vx.isWeb &&
                                    !ResponsiveLayout.isSmallScreen(
                                        context)
                                    ? 16
                                    : 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Vx.isWeb &&
                                !ResponsiveLayout.isSmallScreen(
                                    context)
                                ? SizedBox(
                              height: 20.0,
                            )
                                : SizedBox(
                              height: 10.0,
                            ),

                            /// Show Product Price
                            Row(
                              children: [
                                if (Features.isMembership)
                                  widget.itemdata.type == "1"
                                      ? RichText(
                                    text: new TextSpan(
                                      style: new TextStyle(
                                        fontSize: ResponsiveLayout
                                            .isSmallScreen(
                                            context)
                                            ? 14
                                            : ResponsiveLayout
                                            .isMediumScreen(
                                            context)
                                            ? 18
                                            : 20,
                                        color: Colors.black,
                                      ),
                                      children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                                        new TextSpan(
                                            text: _priceDisplay,/*Features
                                                                .iscurrencyformatalign
                                                            ? '${Check().checkmembership() ? widget.itemdata.membershipPrice : widget.itemdata.price} ' +
                                                                IConstants
                                                                    .currencyFormat
                                                            : IConstants
                                                                    .currencyFormat +
                                                                '${Check().checkmembership() ? widget.itemdata.membershipPrice : widget.itemdata.price} ',*/
                                            style: new TextStyle(
                                              fontWeight:
                                              FontWeight.bold,
                                              color: _checkmembership
                                                  ? ColorCodes
                                                  .greenColor
                                                  : Colors.black,
                                              fontSize: ResponsiveLayout
                                                  .isSmallScreen(
                                                  context)
                                                  ? 14
                                                  : ResponsiveLayout
                                                  .isMediumScreen(
                                                  context)
                                                  ? 18
                                                  : 20,
                                            )),
                                        new TextSpan(
                                            text: _mrpDisplay/*widget.itemdata
                                                                    .price ==
                                                                widget.itemdata
                                                                    .mrp
                                                            ? Features
                                                                    .iscurrencyformatalign
                                                                ? '${_checkmembership ? widget.itemdata.membershipDisplay! ? widget.itemdata.mrp : "" : ""}' +
                                                                    IConstants
                                                                        .currencyFormat
                                                                : '${_checkmembership ? widget.itemdata.membershipDisplay! ? IConstants.currencyFormat + widget.itemdata.mrp! : "" : ""}'
                                                            : ""*/,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              decoration:
                                              TextDecoration
                                                  .lineThrough,
                                              fontSize: ResponsiveLayout
                                                  .isSmallScreen(
                                                  context)
                                                  ? 12
                                                  : ResponsiveLayout
                                                  .isMediumScreen(
                                                  context)
                                                  ? 18
                                                  : 20,
                                            )),
                                      ],
                                    ),
                                  )
                                      : RichText(
                                    text: new TextSpan(
                                      style: new TextStyle(
                                        fontSize: ResponsiveLayout
                                            .isSmallScreen(
                                            context)
                                            ? 14
                                            : ResponsiveLayout
                                            .isMediumScreen(
                                            context)
                                            ? 18
                                            : 20,
                                        color: Colors.black,
                                      ),
                                      children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                                        new TextSpan(
                                            text: _priceDisplay,/*Features
                                                                .iscurrencyformatalign
                                                            ? '${Check().checkmembership() ? widget.itemdata.priceVariation![widget.itemindexs].membershipPrice : widget.itemdata.priceVariation![widget.itemindexs].price} ' +
                                                                IConstants
                                                                    .currencyFormat
                                                            : IConstants
                                                                    .currencyFormat +
                                                                '${Check().checkmembership() ? widget.itemdata.priceVariation![widget.itemindexs].membershipPrice : widget.itemdata.priceVariation![widget.itemindexs].price} ',*/
                                            style: new TextStyle(
                                              fontWeight:
                                              FontWeight.bold,
                                              color: _checkmembership
                                                  ? ColorCodes
                                                  .greenColor
                                                  : Colors.black,
                                              fontSize: ResponsiveLayout
                                                  .isSmallScreen(
                                                  context)
                                                  ? 14
                                                  : ResponsiveLayout
                                                  .isMediumScreen(
                                                  context)
                                                  ? 18
                                                  : 20,
                                            )),
                                        new TextSpan(
                                            text: _mrpDisplay/*widget
                                                                    .itemdata
                                                                    .priceVariation![
                                                                        widget
                                                                            .itemindexs]
                                                                    .price ==
                                                                widget
                                                                    .itemdata
                                                                    .priceVariation![
                                                                        widget
                                                                            .itemindexs]
                                                                    .mrp
                                                            ? Features
                                                                    .iscurrencyformatalign
                                                                ? '${_checkmembership ? widget.itemdata.priceVariation![widget.itemindexs].membershipDisplay! ? widget.itemdata.priceVariation![widget.itemindexs].mrp : "" : ""}' +
                                                                    IConstants
                                                                        .currencyFormat
                                                                : '${_checkmembership ? widget.itemdata.priceVariation![widget.itemindexs].membershipDisplay! ? IConstants.currencyFormat + widget.itemdata.priceVariation![widget.itemindexs].mrp! : "" : ""}'
                                                            : ""*/,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              decoration:
                                              TextDecoration
                                                  .lineThrough,
                                              fontSize: ResponsiveLayout
                                                  .isSmallScreen(
                                                  context)
                                                  ? 12
                                                  : ResponsiveLayout
                                                  .isMediumScreen(
                                                  context)
                                                  ? 18
                                                  : 20,
                                            )),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              S.current.inclusive_of_all_tax,
                              style: TextStyle(
                                  fontSize: Vx.isWeb &&
                                      !ResponsiveLayout.isSmallScreen(
                                          context)
                                      ? 12
                                      : 8,
                                  color: Colors.grey),
                            )
                          ],
                        ),

                        ///Show Loyalty
                        widget.itemdata.type == "1"
                            ? Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: [
                            if (Features.isLoyalty)
                              if (double.parse(widget
                                  .itemdata.loyalty
                                  .toString()) >
                                  0)
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: [
                                      Image.asset(
                                        Images.coinImg,
                                        height: 15.0,
                                        width: 20.0,
                                      ),
                                      SizedBox(width: 4),
                                      Text(widget.itemdata.loyalty
                                          .toString()),
                                    ],
                                  ),
                                ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            (widget.itemdata.eligibleForExpress ==
                                "0")
                                ? Image.asset(
                              Images.express,
                              height: 20.0,
                              width: 25.0,
                            )
                                : SizedBox.shrink(),
                          ],
                        )
                            : Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: [
                            if (Features.isLoyalty)
                              if (double.parse(widget
                                  .itemdata
                                  .priceVariation![
                              widget.itemindexs]
                                  .loyalty
                                  .toString()) >
                                  0)
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: [
                                      Image.asset(
                                        Images.coinImg,
                                        height: 15.0,
                                        width: 20.0,
                                      ),
                                      SizedBox(width: 4),
                                      Text(widget
                                          .itemdata
                                          .priceVariation![
                                      widget.itemindexs]
                                          .loyalty
                                          .toString()),
                                    ],
                                  ),
                                ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            (widget.itemdata.eligibleForExpress ==
                                "0")
                                ? Image.asset(
                              Images.express,
                              height: 20.0,
                              width: 25.0,
                            )
                                : SizedBox.shrink(),
                          ],
                        )
                      ],
                    ),
                  ),
                )
                    : SizedBox.shrink(),
                (Vx.isWeb && ResponsiveLayout.isSmallScreen(context))
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            widget.itemdata.brand.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              //fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        ///Show Product Name
                        Vx.isWeb &&
                            !ResponsiveLayout.isSmallScreen(context)
                            ? SizedBox(
                          height: 10,
                        )
                            : SizedBox.shrink(),
                        Container(
                          height: 45,
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            widget.itemdata.itemName.toString(),
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: Vx.isWeb &&
                                  !ResponsiveLayout.isSmallScreen(
                                      context)
                                  ? 16
                                  : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Vx.isWeb &&
                            !ResponsiveLayout.isSmallScreen(context)
                            ? SizedBox(
                          height: 20.0,
                        )
                            : SizedBox(
                          height: 10.0,
                        ),

                        /// Show Product Price
                        (widget.itemdata.type == "1")
                            ? SizedBox.shrink()
                            : (widget.itemdata.priceVariation!.length > 1)
                            ?
                        //StatefulBuilder(builder: (context, setState) {
                        //debugPrint("sttateful...");
                        /*return*/ MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              return showoptions1(/*setState*/);
                            },
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                      new BorderRadius.only(
                                        topLeft:
                                        const Radius.circular(
                                            2.0),
                                        bottomLeft:
                                        const Radius.circular(
                                            2.0),
                                      )),
                                  height: 18,
                                  padding: EdgeInsets.fromLTRB(
                                      0.0, 0, 0.0, 0),
                                  child: Text(
                                    "${widget.itemdata.priceVariation![widget.itemindexs].variationName}" +
                                        " " +
                                        "${widget.itemdata.priceVariation![widget.itemindexs].unit}",
                                    style: TextStyle(
                                        color: ColorCodes
                                            .darkgreen /*Colors.black*/,
                                        fontWeight:
                                        FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: ColorCodes.darkgreen,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                              ],
                            ),
                          ),
                        )
                        //}
                        //)
                            : Container(
                          decoration: BoxDecoration(
                              borderRadius:
                              new BorderRadius.only(
                                topLeft: const Radius.circular(2.0),
                                topRight:
                                const Radius.circular(2.0),
                                bottomLeft:
                                const Radius.circular(2.0),
                                bottomRight:
                                const Radius.circular(2.0),
                              )),
                          height: 18,
                          padding: EdgeInsets.fromLTRB(
                              0.0, 0, 0.0, 0.0),
                          child: Text(
                            "${widget.itemdata.priceVariation![widget.itemindexs].variationName}" +
                                " " +
                                "${widget.itemdata.priceVariation![widget.itemindexs].unit}",
                            style: TextStyle(
                                color: ColorCodes.greyColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        widget.itemdata.type == "1"
                            ? Container(
                          width:
                          MediaQuery.of(context).size.width / 2,
                          child: Text(
                            widget.itemdata.singleshortNote
                                .toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorCodes.greyColor,
                            ),
                          ),
                        )
                            : SizedBox.shrink(),
                        Row(
                          children: [
                            if (Features.isMembership)
                              (_checkmembership)
                                  ? Container(
                                width: 10.0,
                                height: 9.0,
                                margin: EdgeInsets.only(right: 3.0),
                                child: Image.asset(
                                  Images.starImg,
                                  color: ColorCodes.starColor,
                                ),
                              )
                                  : SizedBox.shrink(),
                            widget.itemdata.type == "1"
                                ? RichText(
                              text: new TextSpan(
                                style: new TextStyle(
                                  fontSize: ResponsiveLayout
                                      .isSmallScreen(context)
                                      ? 14
                                      : ResponsiveLayout
                                      .isMediumScreen(
                                      context)
                                      ? 18
                                      : 20,
                                  color: Colors.black,
                                ),
                                children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                                  new TextSpan(
                                      text: _priceDisplay,/*Features
                                                          .iscurrencyformatalign
                                                      ? '${Check().checkmembership() ? widget.itemdata.membershipPrice : widget.itemdata.price} ' +
                                                          IConstants
                                                              .currencyFormat
                                                      : IConstants
                                                              .currencyFormat +
                                                          '${Check().checkmembership() ? widget.itemdata.membershipPrice : widget.itemdata.price} ',*/
                                      style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: ResponsiveLayout
                                            .isSmallScreen(
                                            context)
                                            ? 14
                                            : ResponsiveLayout
                                            .isMediumScreen(
                                            context)
                                            ? 18
                                            : 20,
                                      )),
                                  new TextSpan(
                                      text: _mrpDisplay/*widget.itemdata.price !=
                                                          widget.itemdata.mrp
                                                      ? Features
                                                              .iscurrencyformatalign
                                                          ? '${widget.itemdata.mrp} ' +
                                                              IConstants
                                                                  .currencyFormat
                                                          : IConstants
                                                                  .currencyFormat +
                                                              '${widget.itemdata.mrp} '
                                                      : ""*/,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        decoration: TextDecoration
                                            .lineThrough,
                                        fontSize: ResponsiveLayout
                                            .isSmallScreen(
                                            context)
                                            ? 12
                                            : ResponsiveLayout
                                            .isMediumScreen(
                                            context)
                                            ? 18
                                            : 20,
                                      )),
                                ],
                              ),
                            )
                                : RichText(
                              text: new TextSpan(
                                style: new TextStyle(
                                  fontSize: ResponsiveLayout
                                      .isSmallScreen(context)
                                      ? 14
                                      : ResponsiveLayout
                                      .isMediumScreen(
                                      context)
                                      ? 18
                                      : 20,
                                  color: Colors.black,
                                ),
                                children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                                  new TextSpan(
                                      text: _priceDisplay,/*Features
                                                          .iscurrencyformatalign
                                                      ? '${Check().checkmembership() ? widget.itemdata.priceVariation![widget.itemindexs].membershipPrice : widget.itemdata.priceVariation![widget.itemindexs].price} ' +
                                                          IConstants
                                                              .currencyFormat
                                                      : IConstants
                                                              .currencyFormat +
                                                          '${Check().checkmembership() ? widget.itemdata.priceVariation![widget.itemindexs].membershipPrice : widget.itemdata.priceVariation![widget.itemindexs].price} ',*/
                                      style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: ResponsiveLayout
                                            .isSmallScreen(
                                            context)
                                            ? 14
                                            : ResponsiveLayout
                                            .isMediumScreen(
                                            context)
                                            ? 18
                                            : 20,
                                      )),
                                  new TextSpan(
                                      text: /*widget
                                                              .itemdata
                                                              .priceVariation![
                                                                  widget
                                                                      .itemindexs]
                                                              .price !=
                                                          widget
                                                              .itemdata
                                                              .priceVariation![
                                                                  widget
                                                                      .itemindexs]
                                                              .mrp
                                                      ? Features
                                                              .iscurrencyformatalign
                                                          ? '${widget.itemdata.priceVariation![widget.itemindexs].mrp} ' +
                                                              IConstants
                                                                  .currencyFormat
                                                          : IConstants
                                                                  .currencyFormat +
                                                              '${widget.itemdata.priceVariation![widget.itemindexs].mrp} '
                                                      : ""*/_mrpDisplay,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        decoration: TextDecoration
                                            .lineThrough,
                                        fontSize: ResponsiveLayout
                                            .isSmallScreen(
                                            context)
                                            ? 12
                                            : ResponsiveLayout
                                            .isMediumScreen(
                                            context)
                                            ? 18
                                            : 20,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    ///Show Loyalty
                    widget.itemdata.type == "1"
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Features.isSubscription &&
                            widget.itemdata
                                .eligibleForSubscription ==
                                "0"
                            ? widget.itemdata.type == "1"
                            ? Container(
                          height:
                          (Features.isSubscription)
                              ? 45
                              : 55,
                          width: (MediaQuery.of(context)
                              .size
                              .width /
                              3) +
                              5,
                          child: Padding(
                            padding:
                            const EdgeInsets.only(
                                left: 5, right: 5.0),
                            child: CustomeStepper(
                              itemdata: widget.itemdata,
                              from: "item_screen",
                              height: (Features
                                  .isSubscription)
                                  ? 90
                                  : 60,
                              addon: (widget.itemdata
                                  .addon!.length >
                                  0)
                                  ? widget
                                  .itemdata.addon![0]
                                  : null,
                              index: widget.itemindexs,
                              issubscription: "Subscribe",
                              ismember: _checkmembership,
                              selectedindex:
                              widget.itemindex,
                              onselect: (i) {
                                setState(() {
                                  widget.itemindex = i;
                                  // Navigator.of(context).pop();
                                });
                              },
                            ),
                          ),
                        )
                            : Container(
                          height:
                          (Features.isSubscription)
                              ? 45
                              : 55,
                          width: (MediaQuery.of(context)
                              .size
                              .width /
                              3) +
                              5,
                          child: Padding(
                            padding:
                            const EdgeInsets.only(
                                left: 5, right: 5.0),
                            child: CustomeStepper(
                                priceVariation: widget
                                    .itemdata
                                    .priceVariation![
                                widget.itemindexs],
                                itemdata: widget.itemdata,
                                from: "item_screen",
                                height: (Features
                                    .isSubscription)
                                    ? 90
                                    : 40,
                                issubscription:
                                "Subscribe",
                                addon: (widget
                                    .itemdata
                                    .addon!
                                    .length >
                                    0)
                                    ? widget.itemdata
                                    .addon![0]
                                    : null,
                                index: widget.itemindexs),
                          ),
                        )
                            : SizedBox(
                          height: 35,
                        ),
                        if (Features.isLoyalty)
                          if (double.parse(widget.itemdata.loyalty
                              .toString()) >
                              0)
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.end,
                                children: [
                                  Image.asset(
                                    Images.coinImg,
                                    height: 15.0,
                                    width: 20.0,
                                  ),
                                  SizedBox(width: 4),
                                  Text(widget.itemdata.loyalty
                                      .toString()),
                                ],
                              ),
                            ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        (widget.itemdata.eligibleForExpress == "0")
                            ? Image.asset(
                          Images.express,
                          height: 20.0,
                          width: 25.0,
                        )
                            : SizedBox.shrink(),
                      ],
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Features.isSubscription &&
                            widget.itemdata
                                .eligibleForSubscription ==
                                "0"
                            ? widget.itemdata.type == "1"
                            ? Container(
                          height:
                          (Features.isSubscription)
                              ? 45
                              : 55,
                          width: (MediaQuery.of(context)
                              .size
                              .width /
                              3) +
                              5,
                          child: Padding(
                            padding:
                            const EdgeInsets.only(
                                left: 5, right: 5.0),
                            child: CustomeStepper(
                              itemdata: widget.itemdata,
                              from: "item_screen",
                              height: (Features
                                  .isSubscription)
                                  ? 90
                                  : 60,
                              addon: (widget.itemdata
                                  .addon!.length >
                                  0)
                                  ? widget
                                  .itemdata.addon![0]
                                  : null,
                              index: widget.itemindexs,
                              issubscription: "Subscribe",
                              ismember: _checkmembership,
                              selectedindex:
                              widget.itemindex,
                              onselect: (i) {
                                setState(() {
                                  widget.itemindex = i;
                                  // Navigator.of(context).pop();
                                });
                              },
                            ),
                          ),
                        )
                            : Container(
                          height:
                          (Features.isSubscription)
                              ? 45
                              : 55,
                          width: (MediaQuery.of(context)
                              .size
                              .width /
                              3) +
                              5,
                          child: Padding(
                            padding:
                            const EdgeInsets.only(
                                left: 5, right: 5.0),
                            child: CustomeStepper(
                              priceVariation: widget
                                  .itemdata
                                  .priceVariation![
                              widget.itemindexs],
                              itemdata: widget.itemdata,
                              from: "item_screen",
                              height: (Features
                                  .isSubscription)
                                  ? 90
                                  : 40,
                              issubscription: "Subscribe",
                              addon: (widget.itemdata
                                  .addon!.length >
                                  0)
                                  ? widget
                                  .itemdata.addon![0]
                                  : null,
                              index: widget.itemindexs,
                              ismember: _checkmembership,
                              selectedindex:
                              widget.itemindex,
                              onselect: (i) {
                                setState(() {
                                  widget.itemindex = i;
                                  // Navigator.of(context).pop();
                                });
                              },
                            ),
                          ),
                        )
                            : SizedBox(
                          height: 35,
                        ),
                        if (Features.isLoyalty)
                          if (double.parse(widget
                              .itemdata
                              .priceVariation![
                          widget.itemindexs]
                              .loyalty
                              .toString()) >
                              0)
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.end,
                                children: [
                                  Image.asset(
                                    Images.coinImg,
                                    height: 15.0,
                                    width: 20.0,
                                  ),
                                  SizedBox(width: 4),
                                  Text(widget
                                      .itemdata
                                      .priceVariation![
                                  widget.itemindexs]
                                      .loyalty
                                      .toString()),
                                ],
                              ),
                            ),
                        (widget.itemdata.eligibleForExpress == "0")
                            ? Image.asset(
                          Images.express,
                          height: 20.0,
                          width: 25.0,
                        )
                            : SizedBox.shrink(),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                  ],
                )
                    : (Vx.isWeb)
                    ? SizedBox.shrink()
                    : Container(
                  decoration: new BoxDecoration(
                    // color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.yellow1:ColorCodes.yellow1 :IConstants.isEnterprise?ColorCodes.yellow1:ColorCodes.yellow1,
                      border: Border.all(
                          color: ColorCodes
                              .whiteColor /*Theme
                      .of(context)
                      .primaryColor*/
                      ),
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(30),
                        topRight: const Radius.circular(30),
                      )),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding:
                        EdgeInsets.only(left: 10.0, right: 5.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // Container(
                            //   width: MediaQuery.of(context).size.width/2,
                            //   child: Text(
                            //     widget.itemdata.brand.toString(),
                            //     style: TextStyle(
                            //       fontSize: 10,
                            //       //fontWeight: FontWeight.bold,
                            //     ),
                            //   ),
                            // ),
                            ///Show Product Name
                            Vx.isWeb &&
                                !ResponsiveLayout.isSmallScreen(
                                    context)
                                ? SizedBox(
                              height: 10,
                            )
                                : SizedBox.shrink(),
                            Container(
                              height: 40,
                              width:
                              MediaQuery.of(context).size.width /
                                  1.1,
                              child: Text(
                                widget.itemdata.itemName.toString(),
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: Vx.isWeb &&
                                      !ResponsiveLayout
                                          .isSmallScreen(context)
                                      ? 15
                                      : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Vx.isWeb &&
                                !ResponsiveLayout.isSmallScreen(
                                    context)
                                ? SizedBox(
                              height: 5.0,
                            )
                                : SizedBox(
                              height: 5.0,
                            ),
                            //product desc
                            if (widget.itemdata.item_description! !=
                                "")
                              Column(
                                children: [
                                  // Container(
                                  //   width: MediaQuery.of(context).size.width,
                                  //   decoration: BoxDecoration(
                                  //
                                  //     color: Colors.white,
                                  //     // borderRadius: BorderRadius.circular(12)
                                  //   ),
                                  //   // margin: EdgeInsets.only(bottom: (!_ismanufacturer)?70.0:0.0),
                                  //   // padding: EdgeInsets.only(
                                  //   //     left: 10.0, top: 10.0, right: 15.0, bottom: 10.0),
                                  //   child: Column(
                                  //     crossAxisAlignment: CrossAxisAlignment.start,
                                  //     children: [
                                  //       Text(
                                  //         "Product Description",
                                  //         style: TextStyle(
                                  //           fontSize: 17,
                                  //           fontWeight: FontWeight.w800,
                                  //         ),
                                  //       ),
                                  //
                                  //     ],
                                  //   ),
                                  //
                                  // ),
                                  Container(
                                      width: MediaQuery.of(context)
                                          .size
                                          .width /
                                          1.1,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      margin: EdgeInsets.only(
                                          bottom: (widget.itemdata
                                              .item_description! ==
                                              "")
                                              ? 70.0
                                              : 0.0),
                                      padding: EdgeInsets.only(
                                          left: 3.0,
                                          top: 0.0,
                                          right: 0.0,
                                          bottom: 5.0),
                                      child: ReadMoreText(
                                        widget.itemdata
                                            .item_description!,
                                        style: TextStyle(
                                            color:
                                            ColorCodes.greyColor),
                                        trimLines: 2,
                                        trimCollapsedText:
                                        '...Show more',
                                        trimExpandedText:
                                        '...Show less',
                                        colorClickableText:
                                        Theme.of(context)
                                            .primaryColor,
                                      )),
                                ],
                              ),

                            /// Show Product Price
                            /*
                              (widget.itemdata.type == "1")?
                              SizedBox.shrink()
                                  :
                              ( widget.itemdata.priceVariation!.length > 1)
                                  ?
                              //StatefulBuilder(builder: (context, setState) {
                              //debugPrint("sttateful...");
                              /*return*/ MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {

                                    return showoptions1(/*setState*/);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(

                                        decoration: BoxDecoration(

                                            borderRadius: new BorderRadius.only(
                                              topLeft: const Radius.circular(2.0),
                                              bottomLeft: const Radius.circular(2.0),
                                            )),
                                        height: 18,
                                        padding: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0),
                                        child: Text(
                                          "${widget.itemdata.priceVariation![widget.itemindexs].variationName}"+" "+"${widget.itemdata.priceVariation![widget.itemindexs].unit}",
                                          style: TextStyle(color: ColorCodes.darkgreen/*Colors.black*/,fontWeight: FontWeight.bold,fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: ColorCodes.darkgreen,
                                        size: 20,
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              //}
                              //)
                                  :
                              Container(
                                decoration: BoxDecoration(

                                    borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(2.0),
                                      topRight: const Radius.circular(2.0),
                                      bottomLeft: const Radius.circular(2.0),
                                      bottomRight: const Radius.circular(2.0),
                                    )),
                                height: 18,
                                padding: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0.0),
                                child: Text(
                                  "${widget.itemdata.priceVariation![widget.itemindexs].variationName}"+" "+"${widget.itemdata.priceVariation![widget.itemindexs].unit}",
                                  style: TextStyle(color:ColorCodes.greyColor,fontWeight: FontWeight.bold,fontSize: 12),
                                ),
                              ),
                              */
                            SizedBox(
                              height: 5.0,
                            ),

                            /*
                                      widget.itemdata.type == "1"
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                              child: Text(
                                                widget.itemdata.singleshortNote
                                                    .toString(),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: ColorCodes.greyColor,
                                                ),
                                              ),
                                            )
                                          : SizedBox.shrink(),
                                      Container(
                                        padding: EdgeInsets.only(left: 2),
                                        child: Row(
                                          children: [
                                            widget.itemdata.type == "1"
                                                ? RichText(
                                                    text: new TextSpan(
                                                      style: new TextStyle(
                                                        fontSize: ResponsiveLayout
                                                                .isSmallScreen(
                                                                    context)
                                                            ? 14
                                                            : ResponsiveLayout
                                                                    .isMediumScreen(
                                                                        context)
                                                                ? 18
                                                                : 20,
                                                        color: Colors.black,
                                                      ),
                                                      children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                                                        new TextSpan(
                                                            text: Features
                                                                    .iscurrencyformatalign
                                                                ? '${_checkmembership ? widget.itemdata.membershipPrice : widget.itemdata.price} ' +
                                                                    IConstants
                                                                        .currencyFormat
                                                                : IConstants
                                                                        .currencyFormat +
                                                                    '${_checkmembership ? widget.itemdata.membershipPrice : widget.itemdata.price} ',
                                                            style:
                                                                new TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: _checkmembership
                                                                  ? ColorCodes
                                                                      .greenColor
                                                                  : Colors
                                                                      .black,
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
                                                            text: widget.itemdata
                                                                        .price ==
                                                                    widget
                                                                        .itemdata
                                                                        .mrp
                                                                ? Features
                                                                        .iscurrencyformatalign
                                                                    ? '${_checkmembership ? widget.itemdata.membershipDisplay! ? widget.itemdata.mrp : "" : ""}' +
                                                                        IConstants
                                                                            .currencyFormat
                                                                    : '${_checkmembership ? widget.itemdata.membershipDisplay! ? IConstants.currencyFormat + widget.itemdata.mrp! : "" : ""}'
                                                                : "",
                                                            style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
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
                                                  )
                                                : RichText(
                                                    text: new TextSpan(
                                                      style: new TextStyle(
                                                        fontSize: ResponsiveLayout
                                                                .isSmallScreen(
                                                                    context)
                                                            ? 14
                                                            : ResponsiveLayout
                                                                    .isMediumScreen(
                                                                        context)
                                                                ? 18
                                                                : 20,
                                                        color: Colors.black,
                                                      ),
                                                      children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                                                        new TextSpan(
                                                            text: Features
                                                                    .iscurrencyformatalign
                                                                ? '${Check().checkmembership() ? widget.itemdata.priceVariation![widget.itemindexs].membershipPrice : widget.itemdata.priceVariation![widget.itemindexs].price} ' +
                                                                    IConstants
                                                                        .currencyFormat
                                                                : IConstants
                                                                        .currencyFormat +
                                                                    '${Check().checkmembership() ? widget.itemdata.priceVariation![widget.itemindexs].membershipPrice : widget.itemdata.priceVariation![widget.itemindexs].price} ',
                                                            style:
                                                                new TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: _checkmembership
                                                                  ? ColorCodes
                                                                      .greenColor
                                                                  : Colors
                                                                      .black,
                                                              fontSize: ResponsiveLayout
                                                                      .isSmallScreen(
                                                                          context)
                                                                  ? 14
                                                                  : ResponsiveLayout
                                                                          .isMediumScreen(
                                                                              context)
                                                                      ? 18
                                                                      : 20,
                                                            )),
                                                        // new TextSpan(
                                                        //     text: widget.itemdata.priceVariation![widget.itemindexs].price!=widget.itemdata.priceVariation![widget.itemindexs].mrp?
                                                        //     Features.iscurrencyformatalign?
                                                        //     '${widget.itemdata.priceVariation![widget.itemindexs].mrp} ' + IConstants.currencyFormat:
                                                        //     IConstants.currencyFormat + '${widget.itemdata.priceVariation![widget.itemindexs].mrp} ':"",
                                                        //     style: TextStyle(
                                                        //       color: Colors.grey,
                                                        //       decoration:
                                                        //       TextDecoration.lineThrough,
                                                        //       fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                                                        new TextSpan(
                                                            text: widget
                                                                        .itemdata
                                                                        .priceVariation![widget
                                                                            .itemindexs]
                                                                        .price ==
                                                                    widget
                                                                        .itemdata
                                                                        .priceVariation![widget
                                                                            .itemindexs]
                                                                        .mrp
                                                                ? Features
                                                                        .iscurrencyformatalign
                                                                    ? '${_checkmembership ? widget.itemdata.priceVariation![widget.itemindexs].membershipDisplay! ? widget.itemdata.priceVariation![widget.itemindexs].mrp : "" : ""}' +
                                                                        IConstants
                                                                            .currencyFormat
                                                                    : '${_checkmembership ? widget.itemdata.priceVariation![widget.itemindexs].membershipDisplay! ? IConstants.currencyFormat + widget.itemdata.priceVariation![widget.itemindexs].mrp! : "" : ""}'
                                                                : "",
                                                            style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              fontSize: ResponsiveLayout
                                                                      .isSmallScreen(
                                                                          context)
                                                                  ? 11
                                                                  : ResponsiveLayout
                                                                          .isMediumScreen(
                                                                              context)
                                                                      ? 12
                                                                      : 13,
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),

                                       */
                          ],
                        ),
                      ),

                      ///Show Loyalty
                      widget.itemdata.type == "1"
                          ? Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Features.isSubscription &&
                              widget.itemdata
                                  .eligibleForSubscription ==
                                  "0"
                              ? widget.itemdata.type == "1"
                              ? Container(
                            height: (Features
                                .isSubscription)
                                ? 45
                                : 55,
                            width: (MediaQuery.of(
                                context)
                                .size
                                .width /
                                3) +
                                5,
                            child: Padding(
                              padding:
                              const EdgeInsets
                                  .only(
                                  left: 5,
                                  right: 5.0),
                              child: CustomeStepper(
                                itemdata:
                                widget.itemdata,
                                from: "item_screen",
                                height: (Features
                                    .isSubscription)
                                    ? 90
                                    : 60,
                                addon: (widget
                                    .itemdata
                                    .addon!
                                    .length >
                                    0)
                                    ? widget.itemdata
                                    .addon![0]
                                    : null,
                                index:
                                widget.itemindexs,
                                issubscription:
                                "Subscribe",
                                ismember:
                                _checkmembership,
                                selectedindex:
                                widget.itemindex,
                                onselect: (i) {
                                  setState(() {
                                    widget.itemindex =
                                        i;
                                    // Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ),
                          )
                              : Container(
                            height: (Features
                                .isSubscription)
                                ? 45
                                : 55,
                            width: (MediaQuery.of(
                                context)
                                .size
                                .width /
                                3) +
                                5,
                            child: Padding(
                              padding:
                              const EdgeInsets
                                  .only(
                                  left: 5,
                                  right: 5.0),
                              child: CustomeStepper(
                                priceVariation: widget
                                    .itemdata
                                    .priceVariation![
                                widget
                                    .itemindexs],
                                itemdata:
                                widget.itemdata,
                                from: "item_screen",
                                height: (Features
                                    .isSubscription)
                                    ? 90
                                    : 40,
                                issubscription:
                                "Subscribe",
                                addon: (widget
                                    .itemdata
                                    .addon!
                                    .length >
                                    0)
                                    ? widget.itemdata
                                    .addon![0]
                                    : null,
                                index:
                                widget.itemindexs,
                                ismember:
                                _checkmembership,
                                selectedindex:
                                widget.itemindex,
                                onselect: (i) {
                                  setState(() {
                                    widget.itemindex =
                                        i;
                                    // Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ),
                          )
                              : SizedBox(
                            height: 35,
                          ),
                          if (Features.isLoyalty)
                            if (double.parse(widget
                                .itemdata.loyalty
                                .toString()) >
                                0)
                              Container(
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: [
                                    Image.asset(
                                      Images.coinImg,
                                      height: 15.0,
                                      width: 20.0,
                                    ),
                                    SizedBox(width: 4),
                                    Text(widget.itemdata.loyalty
                                        .toString()),
                                  ],
                                ),
                              ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          (widget.itemdata.eligibleForExpress ==
                              "0")
                              ? Image.asset(
                            Images.express,
                            height: 20.0,
                            width: 25.0,
                          )
                              : SizedBox.shrink(),
                        ],
                      )
                          : Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Features.isSubscription &&
                              widget.itemdata
                                  .eligibleForSubscription ==
                                  "0"
                              ? widget.itemdata.type == "1"
                              ? Container(
                            height: (Features
                                .isSubscription)
                                ? 45
                                : 55,
                            width: (MediaQuery.of(
                                context)
                                .size
                                .width /
                                3) +
                                5,
                            child: Padding(
                              padding:
                              const EdgeInsets
                                  .only(
                                  left: 5,
                                  right: 5.0),
                              child: CustomeStepper(
                                itemdata:
                                widget.itemdata,
                                from: "item_screen",
                                height: (Features
                                    .isSubscription)
                                    ? 90
                                    : 60,
                                addon: (widget
                                    .itemdata
                                    .addon!
                                    .length >
                                    0)
                                    ? widget.itemdata
                                    .addon![0]
                                    : null,
                                index:
                                widget.itemindexs,
                                issubscription:
                                "Subscribe",
                                ismember:
                                _checkmembership,
                                selectedindex:
                                widget.itemindex,
                                onselect: (i) {
                                  setState(() {
                                    widget.itemindex =
                                        i;
                                    // Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ),
                          )
                              : Container(
                            height: (Features
                                .isSubscription)
                                ? 45
                                : 55,
                            width: (MediaQuery.of(
                                context)
                                .size
                                .width /
                                3) +
                                5,
                            child: Padding(
                              padding:
                              const EdgeInsets
                                  .only(
                                  left: 5,
                                  right: 5.0),
                              child: CustomeStepper(
                                priceVariation: widget
                                    .itemdata
                                    .priceVariation![
                                widget
                                    .itemindexs],
                                itemdata:
                                widget.itemdata,
                                from: "item_screen",
                                height: (Features
                                    .isSubscription)
                                    ? 90
                                    : 40,
                                issubscription:
                                "Subscribe",
                                addon: (widget
                                    .itemdata
                                    .addon!
                                    .length >
                                    0)
                                    ? widget.itemdata
                                    .addon![0]
                                    : null,
                                index:
                                widget.itemindexs,
                                ismember:
                                _checkmembership,
                                selectedindex:
                                widget.itemindex,
                                onselect: (i) {
                                  setState(() {
                                    widget.itemindex =
                                        i;
                                    // Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ),
                          )
                              : SizedBox(
                            height: 35,
                          ),
                          if (Features.isLoyalty)
                            if (double.parse(widget
                                .itemdata
                                .priceVariation![
                            widget.itemindexs]
                                .loyalty
                                .toString()) >
                                0)
                              Container(
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: [
                                    Image.asset(
                                      Images.coinImg,
                                      height: 15.0,
                                      width: 20.0,
                                    ),
                                    SizedBox(width: 4),
                                    Text(widget
                                        .itemdata
                                        .priceVariation![
                                    widget.itemindexs]
                                        .loyalty
                                        .toString()),
                                  ],
                                ),
                              ),
                          (widget.itemdata.eligibleForExpress ==
                              "0")
                              ? Image.asset(
                            Images.express,
                            height: 20.0,
                            width: 25.0,
                          )
                              : SizedBox.shrink(),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                (Vx.isWeb && ResponsiveLayout.isSmallScreen(context))
                    ? SizedBox(
                  height: 10,
                )
                    : (Vx.isWeb)
                    ? SizedBox.shrink()
                    : SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            widget.itemdata.type == "1"
                                ? Container(
                              width:
                              MediaQuery.of(context).size.width / 2,
                              child: Text(
                                widget.itemdata.singleshortNote
                                    .toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ColorCodes.greyColor,
                                ),
                              ),
                            )
                                : SizedBox.shrink(),
                            Container(
                              padding: EdgeInsets.only(left: 2),
                              child: Row(
                                children: [
                                  widget.itemdata.type == "1"
                                      ? RichText(
                                    text: new TextSpan(
                                      style: new TextStyle(
                                        fontSize: ResponsiveLayout
                                            .isSmallScreen(context)
                                            ? 14
                                            : ResponsiveLayout
                                            .isMediumScreen(
                                            context)
                                            ? 18
                                            : 20,
                                        color: Colors.black,
                                      ),
                                      children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                                        new TextSpan(
                                            text: _priceDisplay/*Features
                                                          .iscurrencyformatalign
                                                      ? '${_checkmembership ? widget.itemdata.membershipPrice : widget.itemdata.price} ' +
                                                          IConstants
                                                              .currencyFormat
                                                      : IConstants
                                                              .currencyFormat +
                                                          '${_checkmembership ? widget.itemdata.membershipPrice : widget.itemdata.price} '*/,
                                            style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _checkmembership
                                                  ? ColorCodes.greenColor
                                                  : Colors.black,
                                              fontSize: ResponsiveLayout
                                                  .isSmallScreen(
                                                  context)
                                                  ? 20
                                                  : ResponsiveLayout
                                                  .isMediumScreen(
                                                  context)
                                                  ? 15
                                                  : 16,
                                            )),

                                        new TextSpan(
                                            text:/* widget.itemdata.price ==
                                                          widget.itemdata.mrp
                                                      ? Features
                                                              .iscurrencyformatalign
                                                          ? '${_checkmembership ? widget.itemdata.membershipDisplay! ? widget.itemdata.mrp : "" : ""}' +
                                                              IConstants
                                                                  .currencyFormat
                                                          : '${_checkmembership ? widget.itemdata.membershipDisplay! ? IConstants.currencyFormat + widget.itemdata.mrp! : "" : ""}'
                                                      : ""*/_mrpDisplay,
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
                                  )
                                      : RichText(
                                    text: new TextSpan(
                                      style: new TextStyle(
                                        fontSize: ResponsiveLayout
                                            .isSmallScreen(context)
                                            ? 16
                                            : ResponsiveLayout
                                            .isMediumScreen(
                                            context)
                                            ? 18
                                            : 20,
                                        color: Colors.black,
                                      ),
                                      children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                                        new TextSpan(
                                            text: _priceDisplay,/*Features
                                                          .iscurrencyformatalign
                                                      ? '${Check().checkmembership() ? widget.itemdata.priceVariation![widget.itemindexs].membershipPrice : widget.itemdata.priceVariation![widget.itemindexs].price} ' +
                                                          IConstants
                                                              .currencyFormat
                                                      : IConstants
                                                              .currencyFormat +
                                                          '${Check().checkmembership() ? widget.itemdata.priceVariation![widget.itemindexs].membershipPrice : widget.itemdata.priceVariation![widget.itemindexs].price} ',*/
                                            style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: _checkmembership
                                                  ? ColorCodes.greenColor
                                                  : Colors.black,
                                              fontSize: ResponsiveLayout
                                                  .isSmallScreen(
                                                  context)
                                                  ? 20
                                                  : ResponsiveLayout
                                                  .isMediumScreen(
                                                  context)
                                                  ? 18
                                                  : 20,
                                            )),
                                        // new TextSpan(
                                        //     text: widget.itemdata.priceVariation![widget.itemindexs].price!=widget.itemdata.priceVariation![widget.itemindexs].mrp?
                                        //     Features.iscurrencyformatalign?
                                        //     '${widget.itemdata.priceVariation![widget.itemindexs].mrp} ' + IConstants.currencyFormat:
                                        //     IConstants.currencyFormat + '${widget.itemdata.priceVariation![widget.itemindexs].mrp} ':"",
                                        //     style: TextStyle(
                                        //       color: Colors.grey,
                                        //       decoration:
                                        //       TextDecoration.lineThrough,
                                        //       fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                                        new TextSpan(
                                            text: /*widget
                                                              .itemdata
                                                              .priceVariation![
                                                                  widget
                                                                      .itemindexs]
                                                              .price ==
                                                          widget
                                                              .itemdata
                                                              .priceVariation![
                                                                  widget
                                                                      .itemindexs]
                                                              .mrp
                                                      ? Features
                                                              .iscurrencyformatalign
                                                          ? '${_checkmembership ? widget.itemdata.priceVariation![widget.itemindexs].membershipDisplay! ? widget.itemdata.priceVariation![widget.itemindexs].mrp : "" : ""}' +
                                                              IConstants
                                                                  .currencyFormat
                                                          : '${_checkmembership ? widget.itemdata.priceVariation![widget.itemindexs].membershipDisplay! ? IConstants.currencyFormat + widget.itemdata.priceVariation![widget.itemindexs].mrp! : "" : ""}'
                                                      : ""*/_mrpDisplay,
                                            style: TextStyle(
                                              decoration: TextDecoration
                                                  .lineThrough,
                                              fontSize: ResponsiveLayout
                                                  .isSmallScreen(
                                                  context)
                                                  ? 11
                                                  : ResponsiveLayout
                                                  .isMediumScreen(
                                                  context)
                                                  ? 12
                                                  : 13,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: (Vx.isWeb &&
                            ResponsiveLayout.isSmallScreen(context))
                            ? (Features.isMembership)
                            ? MembershipInfoWidget(
                            itemdata: widget.itemdata,
                            varid: widget.variationId,
                            itemindexs: widget.itemindexs,
                            ontap: () {
                              (!PrefUtils.prefs!
                                  .containsKey("apikey") &&
                                  Vx.isWeb &&
                                  !ResponsiveLayout.isSmallScreen(
                                      context))
                                  ?
                              // _dialogforSignIn() :
                              LoginWeb(context, result: (sucsess) {
                                if (sucsess) {
                                  Navigator.of(context).pop();
                                  Navigation(context,
                                      navigatore:
                                      NavigatoreTyp.homenav);
                                  /* Navigator.pushNamedAndRemoveUntil(
                                        context, HomeScreen.routeName, (route) => false);*/
                                } else {
                                  Navigator.of(context).pop();
                                }
                              })
                                  : (!PrefUtils.prefs!
                                  .containsKey("apikey") &&
                                  !Vx.isWeb)
                                  ?
                              /* Navigator.of(context).pushReplacementNamed(
                                    SignupSelectionScreen.routeName)*/
                              Navigation(context,
                                  name: Routename.SignUpScreen,
                                  navigatore: NavigatoreTyp
                                      .PushReplacment)
                                  : /*Navigator.of(context).pushNamed(
                                  MembershipScreen.routeName,
                                );*/
                              Navigation(context,
                                  name: Routename.Membership,
                                  navigatore:
                                  NavigatoreTyp.Push);
                            })
                            : widget.itemdata.type == "1"
                            ? Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            height: (Features.isSubscription)
                                ? 45
                                : 55,
                            width: (MediaQuery.of(context)
                                .size
                                .width /
                                3) +
                                5,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5.0),
                              child: CustomeStepper(
                                itemdata: widget.itemdata,
                                from: "item_screen",
                                height: (Features.isSubscription)
                                    ? 90
                                    : 60,
                                addon: (widget.itemdata.addon!
                                    .length >
                                    0)
                                    ? widget.itemdata.addon![0]
                                    : null,
                                index: widget.itemindexs,
                                issubscription: "Add",
                                ismember: _checkmembership,
                                selectedindex: widget.itemindex,
                                onselect: (i) {
                                  setState(() {
                                    widget.itemindex = i;
                                    // Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ),
                          ),
                        )
                            : Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            height: (Features.isSubscription)
                                ? 45
                                : 55,
                            width: (MediaQuery.of(context)
                                .size
                                .width /
                                3) +
                                5,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5.0),
                              child: CustomeStepper(
                                priceVariation: widget
                                    .itemdata.priceVariation![
                                widget.itemindexs],
                                itemdata: widget.itemdata,
                                from: "item_screen",
                                height: (Features.isSubscription)
                                    ? 90
                                    : 40,
                                issubscription: "Add",
                                addon: (widget.itemdata.addon!
                                    .length >
                                    0)
                                    ? widget.itemdata.addon![0]
                                    : null,
                                index: widget.itemindexs,
                                ismember: _checkmembership,
                                selectedindex: widget.itemindex,
                                onselect: (i) {
                                  setState(() {
                                    widget.itemindex = i;
                                    // Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ),
                          ),
                        )
                            : (Vx.isWeb)
                            ? SizedBox.shrink()
                            : (Features.isMembership)
                            ? MembershipInfoWidget(
                            itemdata: widget.itemdata,
                            varid: widget.variationId,
                            itemindexs: widget.itemindexs,
                            ontap: () {
                              (!PrefUtils.prefs!
                                  .containsKey("apikey") &&
                                  Vx.isWeb &&
                                  !ResponsiveLayout
                                      .isSmallScreen(context))
                                  ?
                              // _dialogforSignIn() :
                              LoginWeb(context,
                                  result: (sucsess) {
                                    if (sucsess) {
                                      Navigator.of(context).pop();
                                      Navigation(context,
                                          navigatore:
                                          NavigatoreTyp
                                              .homenav);
                                      /* Navigator.pushNamedAndRemoveUntil(
                                        context, HomeScreen.routeName, (route) => false);*/
                                    } else {
                                      Navigator.of(context).pop();
                                    }
                                  })
                                  : (!PrefUtils.prefs!.containsKey(
                                  "apikey") &&
                                  !Vx.isWeb)
                                  ?
                              /* Navigator.of(context).pushReplacementNamed(
                                    SignupSelectionScreen.routeName)*/
                              Navigation(context,
                                  name: Routename
                                      .SignUpScreen,
                                  navigatore: NavigatoreTyp
                                      .PushReplacment)
                                  : /*Navigator.of(context).pushNamed(
                                  MembershipScreen.routeName,
                                );*/
                              Navigation(context,
                                  name:
                                  Routename.Membership,
                                  navigatore:
                                  NavigatoreTyp.Push);
                            })
                            : widget.itemdata.type == "1"
                            ? Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.end,
                            crossAxisAlignment:
                            CrossAxisAlignment.end,
                            children: [
                              (widget.itemdata.addon!.length >
                                  0)
                                  ? Align(
                                alignment:
                                Alignment.topRight,
                                child: Container(
                                    padding:
                                    EdgeInsets.only(
                                        right:
                                        10.0),
                                    width: (MediaQuery.of(context)
                                        .size
                                        .width /
                                        3) +
                                        5,
                                    child: Center(
                                        child: Text(
                                            S
                                                .of(
                                                context)
                                                .customize,
                                            style: TextStyle(
                                                fontSize:
                                                9,
                                                color: ColorCodes
                                                    .lightgrey,
                                                fontWeight:
                                                FontWeight.bold)))),
                              )
                                  : SizedBox.shrink(),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                height:
                                (Features.isSubscription)
                                    ? 45
                                    : 55,
                                width: (MediaQuery.of(context)
                                    .size
                                    .width /
                                    2) +
                                    4.5,
                                child: Padding(
                                  padding:
                                  const EdgeInsets.only(
                                      left: 5,
                                      right: 5.0),
                                  child: CustomeStepper(
                                    itemdata: widget.itemdata,
                                    from: "item_screen",
                                    height: (Features
                                        .isSubscription)
                                        ? 90
                                        : 60,
                                    addon: (widget
                                        .itemdata
                                        .addon!
                                        .length >
                                        0)
                                        ? widget.itemdata
                                        .addon![0]
                                        : null,
                                    index: widget.itemindexs,
                                    issubscription: "Add",
                                    ismember:
                                    _checkmembership,
                                    selectedindex:
                                    widget.itemindex,
                                    onselect: (i) {
                                      setState(() {
                                        widget.itemindex = i;
                                        // Navigator.of(context).pop();
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            : Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.end,
                            crossAxisAlignment:
                            CrossAxisAlignment.end,
                            children: [
                              (widget.itemdata.addon!.length >
                                  0)
                                  ? Align(
                                alignment:
                                Alignment.topRight,
                                child: Container(
                                    padding: EdgeInsets.only(
                                        right: 10.0),
                                    width: (MediaQuery.of(
                                        context)
                                        .size
                                        .width /
                                        2) +
                                        4.5,
                                    child: Center(
                                        child: Text(
                                            S
                                                .of(
                                                context)
                                                .customize,
                                            style: TextStyle(
                                                fontSize:
                                                9,
                                                color: ColorCodes
                                                    .lightgrey,
                                                fontWeight:
                                                FontWeight.bold)))),
                              )
                                  : SizedBox.shrink(),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                height:
                                (Features.isSubscription)
                                    ? 55
                                    : 55,
                                width: (MediaQuery.of(context)
                                    .size
                                    .width /
                                    2) +
                                    4.5,
                                child: Padding(
                                  padding:
                                  const EdgeInsets.only(
                                      left: 5,
                                      right: 5.0),
                                  child: CustomeStepper(
                                    priceVariation: widget
                                        .itemdata
                                        .priceVariation![
                                    widget.itemindexs],
                                    itemdata: widget.itemdata,
                                    from: "item_screen",
                                    height: (Features
                                        .isSubscription)
                                        ? 90
                                        : 40,
                                    issubscription: "Add",
                                    addon: (widget
                                        .itemdata
                                        .addon!
                                        .length >
                                        0)
                                        ? widget.itemdata
                                        .addon![0]
                                        : null,
                                    index: widget.itemindexs,
                                    ismember:
                                    _checkmembership,
                                    selectedindex:
                                    widget.itemindex,
                                    onselect: (i) {
                                      setState(() {
                                        widget.itemindex = i;
                                        // Navigator.of(context).pop();
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))
                  Row(
                    children: [
                      widget.itemdata.type == "1"
                          ? Container(
                        //width: (MediaQuery.of(context).size.width / 7) ,
                        padding: EdgeInsets.only(
                            bottom: 10, left: 10, right: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            /* border: Border.all(
                                        color: ColorCodes.greenColor,),*/
                              color: ColorCodes.whiteColor,
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(2.0),
                                topRight: const Radius.circular(2.0),
                                bottomLeft: const Radius.circular(2.0),
                                bottomRight: const Radius.circular(2.0),
                              )),
                          height: 30,
                          width: (MediaQuery.of(context).size.width / 7),
                          padding:
                          EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                          child: SizedBox.shrink(),
                        ),
                      )
                          : Container(
                        //width: (MediaQuery.of(context).size.width / 7) ,
                        padding: EdgeInsets.only(
                            bottom: 10, left: 10, right: 10),
                        child: (widget.itemdata.priceVariation!.length >
                            1)
                            ? GestureDetector(
                          onTap: () {
                            widget.ontap();
                          },
                          child: Container(
                            height: 30,
                            width:
                            (MediaQuery.of(context).size.width /
                                7),
                            decoration: BoxDecoration(
                              /*border: Border.all(
                                                color: ColorCodes.greenColor,),*/
                                color: ColorCodes.varcolor,
                                borderRadius: new BorderRadius.only(
                                  topLeft:
                                  const Radius.circular(2.0),
                                  bottomLeft:
                                  const Radius.circular(2.0),
                                  topRight:
                                  const Radius.circular(2.0),
                                  bottomRight:
                                  const Radius.circular(2.0),
                                )),
                            child: Row(
                              children: [
                                Text(
                                  "${widget.itemdata.priceVariation![widget.itemindexs].variationName}" +
                                      " " +
                                      "${widget.itemdata.priceVariation![widget.itemindexs].unit}",
                                  style: TextStyle(
                                      color: ColorCodes.darkgreen,
                                      fontWeight: FontWeight.bold),
                                ),
                                // ),
                                Spacer(),
                                Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                      color: ColorCodes.varcolor,
                                      borderRadius:
                                      new BorderRadius.only(
                                        topRight:
                                        const Radius.circular(
                                            2.0),
                                        bottomRight:
                                        const Radius.circular(
                                            2.0),
                                      )),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: ColorCodes.darkgreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            : Container(
                          decoration: BoxDecoration(
                            /* border: Border.all(
                                        color: ColorCodes.greenColor,),*/
                              color: ColorCodes.varcolor,
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(2.0),
                                topRight:
                                const Radius.circular(2.0),
                                bottomLeft:
                                const Radius.circular(2.0),
                                bottomRight:
                                const Radius.circular(2.0),
                              )),
                          height: 30,
                          width:
                          (MediaQuery.of(context).size.width /
                              7),
                          padding: EdgeInsets.fromLTRB(
                              5.0, 4.5, 0.0, 4.5),
                          child: Text(
                            "${widget.itemdata.priceVariation![widget.itemindexs].variationName}" +
                                " " +
                                "${widget.itemdata.priceVariation![widget.itemindexs].unit}",
                            style: TextStyle(
                                color: ColorCodes.darkgreen,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                widget.itemdata.type == "1"
                                    ? Container(
                                  width:
                                  MediaQuery.of(context).size.width /
                                      7,
                                  child: CustomeStepper(
                                    itemdata: widget.itemdata,
                                    alignmnt: StepperAlignment.Vertical,
                                    height: (Features.isSubscription)
                                        ? 40
                                        : 40,
                                    addon:
                                    (widget.itemdata.addon!.length >
                                        0)
                                        ? widget.itemdata.addon![0]
                                        : null,
                                    index: widget.itemindexs,
                                    issubscription: "Subscribe",
                                    ismember: _checkmembership,
                                    selectedindex: widget.itemindex,
                                    onselect: (i) {
                                      setState(() {
                                        widget.itemindex = i;
                                        // Navigator.of(context).pop();
                                      });
                                    },
                                  ),
                                )
                                    : Container(
                                  width:
                                  MediaQuery.of(context).size.width /
                                      7,
                                  child: CustomeStepper(
                                    priceVariation:
                                    widget.itemdata.priceVariation![
                                    widget.itemindexs],
                                    itemdata: widget.itemdata,
                                    alignmnt: StepperAlignment.Vertical,
                                    height: (Features.isSubscription)
                                        ? 40
                                        : 40,
                                    addon:
                                    (widget.itemdata.addon!.length >
                                        0)
                                        ? widget.itemdata.addon![0]
                                        : null,
                                    index: widget.itemindexs,
                                    issubscription: "Subscribe",
                                    ismember: _checkmembership,
                                    selectedindex: widget.itemindex,
                                    onselect: (i) {
                                      setState(() {
                                        widget.itemindex = i;
                                        // Navigator.of(context).pop();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                widget.itemdata.type == "1"
                                    ? Container(
                                  width:
                                  MediaQuery.of(context).size.width /
                                      7,
                                  child: CustomeStepper(
                                    itemdata: widget.itemdata,
                                    alignmnt: StepperAlignment.Vertical,
                                    height: (Features.isSubscription)
                                        ? 40
                                        : 40,
                                    addon:
                                    (widget.itemdata.addon!.length >
                                        0)
                                        ? widget.itemdata.addon![0]
                                        : null,
                                    index: widget.itemindexs,
                                    issubscription: "Add",
                                    ismember: _checkmembership,
                                    selectedindex: widget.itemindex,
                                    onselect: (i) {
                                      setState(() {
                                        widget.itemindex = i;
                                        // Navigator.of(context).pop();
                                      });
                                    },
                                  ),
                                )
                                    : Container(
                                  width:
                                  MediaQuery.of(context).size.width /
                                      7,
                                  child: CustomeStepper(
                                    priceVariation:
                                    widget.itemdata.priceVariation![
                                    widget.itemindexs],
                                    itemdata: widget.itemdata,
                                    alignmnt: StepperAlignment.Vertical,
                                    height: (Features.isSubscription)
                                        ? 40
                                        : 40,
                                    addon:
                                    (widget.itemdata.addon!.length >
                                        0)
                                        ? widget.itemdata.addon![0]
                                        : null,
                                    index: widget.itemindexs,
                                    issubscription: "Add",
                                    ismember: _checkmembership,
                                    selectedindex: widget.itemindex,
                                    onselect: (i) {
                                      setState(() {
                                        widget.itemindex = i;
                                        // Navigator.of(context).pop();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))
            ? Container()
            : Positioned(
            top: 230,
            left: 0,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              width: MediaQuery.of(context).size.width,
              height: 20,
            )),
      ],
    );
  }
}
