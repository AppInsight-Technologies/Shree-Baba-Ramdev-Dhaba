import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/components/carousel/gf_carousel.dart';
import '../../assets/ColorCodes.dart';
import '../../assets/images.dart';
import '../../data/calculations.dart';
import '../../generated/l10n.dart';
import '../../helper/custome_calculation.dart';
import '../../models/newmodle/product_data.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../badge_ofstock.dart';

class SlidingImage extends StatefulWidget {
  final Function() ontap;
  final ItemData productdata;
  final String varid;
  final int itemindexs;
  const SlidingImage(
      {Key? key,
      required this.ontap,
      required this.productdata,
      required this.varid,
      required this.itemindexs})
      : super(key: key);

  @override
  State<SlidingImage> createState() => _SlidingImageState();
}

class _SlidingImageState extends State<SlidingImage> {
  @override
  Widget build(BuildContext context) {
    debugPrint("spppppp...." + widget.varid.toString());
    return widget.productdata.type == "1"
        ? widget.productdata.stock! <= 0
            ? Consumer<CartCalculations>(
                builder: (_, cart, ch) => BadgeOfStock(
                  child: ch!,
                  value: "10",
                  singleproduct: true,
                ),
                child: GestureDetector(
                    onTap: () {
                      widget.ontap();
                    },
                    child: /*GFCarousel(
          autoPlay: true,
          viewportFraction: 1.0,
          height: 173,
          pagination: true,
          passiveIndicator: Colors.white,
          activeIndicator:
          Theme.of(context).accentColor,
          autoPlayInterval: Duration(seconds: 8),
          items: <Widget>[
            ... productdata.priceVariation!.elementAt(productdata.priceVariation!.indexWhere((element) => element.id == varid)).images!.map((e) =>  Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                  },
                  child: Container(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(
                          horizontal: 5.0,vertical: 10),
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.all(
                            Radius.circular(
                                5.0)),
                        child:
                        CachedNetworkImage(
                            imageUrl: productdata.itemFeaturedImage,
                            placeholder: (context, url) => Image.asset(Images.defaultProductImg),
                            errorWidget: (context, url, error) => Image.asset(Images.defaultProductImg),
                            fit: BoxFit.fill),
                        */ /*],
                                            )*/ /*
                      )),
                );
              },
            )).toList()
          ],
        ),*/
                        Container(
                            color: Colors.white,
                            height: 200,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              child: CachedNetworkImage(
                                  imageUrl:
                                      widget.productdata.itemFeaturedImage,
                                  placeholder: (context, url) =>
                                      Image.asset(Images.defaultProductImg),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(Images.defaultProductImg),
                                  fit: BoxFit.fill),
                              /*],
                                            )*/
                            ))),
              )
            : Stack(
                children: [
                  if (!Vx.isWeb)
                    if (widget.productdata.type == "1"
                        ? Calculate().getmargin(
                                widget.productdata.mrp,
                                VxState.store.userData.membership! == "0" ||
                                        VxState.store.userData.membership! ==
                                            "2"
                                    ? widget.productdata.discointDisplay!
                                        ? widget.productdata.price
                                        : widget.productdata.mrp
                                    : widget.productdata.membershipDisplay!
                                        ? widget.productdata.membershipPrice
                                        : widget.productdata.price) >
                            0
                        : Calculate().getmargin(
                                widget.productdata
                                    .priceVariation![widget.itemindexs].mrp,
                                VxState.store.userData.membership! == "0" ||
                                        VxState.store.userData.membership! ==
                                            "2"
                                    ? widget
                                            .productdata
                                            .priceVariation![widget.itemindexs]
                                            .discointDisplay!
                                        ? widget
                                            .productdata
                                            .priceVariation![widget.itemindexs]
                                            .price
                                        : widget
                                            .productdata
                                            .priceVariation![widget.itemindexs]
                                            .mrp
                                    : widget
                                            .productdata
                                            .priceVariation![widget.itemindexs]
                                            .membershipDisplay!
                                        ? widget
                                            .productdata
                                            .priceVariation![widget.itemindexs]
                                            .membershipPrice
                                        : widget
                                            .productdata
                                            .priceVariation![widget.itemindexs]
                                            .price) >
                            0)
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          //margin: EdgeInsets.only(right:5.0),

                          // color: Theme.of(context).accentColor,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.0),
                            color: ColorCodes.greenColor, //Color(0xff6CBB3C),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 28,
                            minHeight: 18,
                          ),
                          child: Text(
                            widget.productdata.type == "1"
                                ? Calculate()
                                        .getmargin(
                                            widget.productdata.mrp,
                                            VxState.store.userData.membership! ==
                                                        "0" ||
                                                    VxState.store.userData
                                                            .membership! ==
                                                        "2"
                                                ? widget.productdata
                                                        .discointDisplay!
                                                    ? widget.productdata.price
                                                    : widget.productdata.mrp
                                                : widget.productdata
                                                        .membershipDisplay!
                                                    ? widget.productdata
                                                        .membershipPrice
                                                    : widget.productdata.price)
                                        .toStringAsFixed(2) +
                                    S.current.off
                                : Calculate()
                                        .getmargin(
                                            widget
                                                .productdata
                                                .priceVariation![
                                                    widget.itemindexs]
                                                .mrp,
                                            VxState.store.userData.membership! ==
                                                        "0" ||
                                                    VxState.store.userData
                                                            .membership! ==
                                                        "2"
                                                ? widget
                                                        .productdata
                                                        .priceVariation![
                                                            widget.itemindexs]
                                                        .discointDisplay!
                                                    ? widget
                                                        .productdata
                                                        .priceVariation![widget.itemindexs]
                                                        .price
                                                    : widget.productdata.priceVariation![widget.itemindexs].mrp
                                                : widget.productdata.priceVariation![widget.itemindexs].membershipDisplay!
                                                    ? widget.productdata.priceVariation![widget.itemindexs].membershipPrice
                                                    : widget.productdata.priceVariation![widget.itemindexs].price)
                                        .toStringAsFixed(0) +
                                    S.current.off,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color: ColorCodes.whiteColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  GestureDetector(
                    onTap: () {
                      widget.ontap();
                    },
                    child: /* GFCarousel(
            autoPlay: true,
            viewportFraction: 1.0,
            height: 180,
            pagination: true,
            passiveIndicator: Colors.white,
            activeIndicator:
            Theme.of(context).accentColor,
            autoPlayInterval: Duration(seconds: 8),
            items: <Widget>[
              // if(productdata.priceVariation!.length<0)
              //
              //   else
              if(productdata.priceVariation!.elementAt(productdata.priceVariation!.indexWhere((element) => element.id == varid)).images!.isNotEmpty)
                ... productdata.priceVariation!.elementAt(productdata.priceVariation!.indexWhere((element) => element.id == varid)).images!.map((e) =>  GestureDetector(
                  onTap: () {
                  },
                  child: Container(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(
                          horizontal: 5.0,vertical: 10),
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.all(
                            Radius.circular(
                                5.0)),
                        child:
                        CachedNetworkImage(
                            imageUrl: e.image,
                            placeholder: (context, url) => Image.asset(Images.defaultProductImg),
                            errorWidget: (context, url, error) => Image.asset(Images.defaultProductImg),
                            fit: BoxFit.fill),
                        */ /*],
                                                )*/ /*
                      )),
                )).toList()
              else
                GestureDetector(
                  onTap: () {
                  },
                  child: Container(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(
                          horizontal: 5.0,vertical: 10),
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.all(
                            Radius.circular(
                                5.0)),
                        child:
                        CachedNetworkImage(
                            imageUrl:productdata.itemFeaturedImage,
                            placeholder: (context, url) => Image.asset(Images.defaultProductImg),
                            errorWidget: (context, url, error) => Image.asset(Images.defaultProductImg),
                            fit: BoxFit.fill),
                        */ /*],
                                                )*/ /*
                      )),
                )
            ],
      )*/
                        GFCarousel(
                      autoPlay: true,
                      viewportFraction: 1.0,
                      height: 200,
                      pagination: true,
                      passiveIndicator: Colors.white,
                      activeIndicator: Theme.of(context).accentColor,
                      autoPlayInterval: Duration(seconds: 8),
                      items: <Widget>[
                        Container(
                            color: Colors.white,
                            height: 200,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              child: CachedNetworkImage(
                                  imageUrl:
                                      widget.productdata.itemFeaturedImage,
                                  placeholder: (context, url) =>
                                      Image.asset(Images.defaultProductImg),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(Images.defaultProductImg),
                                  fit: BoxFit.fill),
                              /*],
                                                    )*/
                            )),
                      ],
                    ),
                  ),
                ],
              )
        : widget.productdata.priceVariation!
                    .elementAt(widget.productdata.priceVariation!.indexWhere(
                        (element) => element.menuItemId == widget.varid))
                    .stock! <=
                0
            ? Consumer<CartCalculations>(
                builder: (_, cart, ch) => BadgeOfStock(
                  child: ch!,
                  value: "10",
                  singleproduct: true,
                ),
                child: GestureDetector(
                  onTap: () {
                    widget.ontap();
                  },
                  child: GFCarousel(
                    autoPlay: true,
                    viewportFraction: 1.0,
                    height: 190,
                    pagination: true,
                    passiveIndicator: Colors.white,
                    activeIndicator: Theme.of(context).accentColor,
                    autoPlayInterval: Duration(seconds: 8),
                    items: <Widget>[
                      ...widget.productdata.priceVariation!
                          .elementAt(widget.productdata.priceVariation!
                              .indexWhere((element) =>
                                  element.menuItemId == widget.varid))
                          .images!
                          .map((e) => Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                        color: Colors.white,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          child: CachedNetworkImage(
                                              imageUrl: e.image,
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                      Images.defaultProductImg),
                                              errorWidget: (context, url,
                                                      error) =>
                                                  Image.asset(
                                                      Images.defaultProductImg),
                                              fit: BoxFit.fill),
                                          /*],
                                            )*/
                                        )),
                                  );
                                },
                              ))
                          .toList()
                    ],
                  ),
                ),
              )
            : Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.ontap();
                    },
                    child: GFCarousel(
                      autoPlay: true,
                      viewportFraction: 1.0,
                      height: 250,
                      pagination: true,
                      passiveIndicator: Colors.black,
                      activeIndicator: Colors.white,
                      autoPlayInterval: Duration(seconds: 8),
                      items: <Widget>[
                        // if(productdata.priceVariation!.length<0)
                        //
                        //   else
                        if (widget.productdata.priceVariation!
                            .elementAt(widget.productdata.priceVariation!
                                .indexWhere((element) =>
                                    element.menuItemId == widget.varid))
                            .images!
                            .isNotEmpty)
                          ...widget.productdata.priceVariation!
                              .elementAt(widget.productdata.priceVariation!
                                  .indexWhere((element) =>
                                      element.menuItemId == widget.varid))
                              .images!
                              .map((e) => GestureDetector(
                                    onTap: () {},
                                    child: Center(
                                      child: Container(
                                          color: Colors.black,
                                          child: CachedNetworkImage(
                                              width: 500,
                                              imageUrl: e.image,
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                      Images.defaultProductImg,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              10,
                                                      height: 300),
                                              errorWidget: (context, url, error) =>
                                                  Image.asset(
                                                      Images.defaultProductImg,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              10,
                                                      height: 300),
                                              fit: BoxFit.cover)),
                                    ),
                                  ))
                              .toList()
                        else
                          GestureDetector(
                            onTap: () {},
                            child: Center(
                              child: Container(
                                  color: Colors.white,
                                  child: CachedNetworkImage(
                                      width: 500,
                                      imageUrl:
                                          widget.productdata.itemFeaturedImage,
                                      placeholder: (context, url) =>
                                          Image.asset(Images.defaultProductImg,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  10,
                                              height: 300),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(Images.defaultProductImg,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  10,
                                              height: 300),
                                      fit: BoxFit.cover)),
                            ),
                          )
                      ],
                    ),
                  ),
                  if (!Vx.isWeb)
                    if (widget.productdata.type == "1"
                        ? Calculate().getmargin(
                                widget.productdata.mrp,
                                VxState.store.userData.membership! == "0" ||
                                        VxState.store.userData.membership! ==
                                            "2"
                                    ? widget.productdata.discointDisplay!
                                        ? widget.productdata.price
                                        : widget.productdata.mrp
                                    : widget.productdata.membershipDisplay!
                                        ? widget.productdata.membershipPrice
                                        : widget.productdata.price) >
                            0
                        : Calculate().getmargin(
                                widget.productdata
                                    .priceVariation![widget.itemindexs].mrp,
                                VxState.store.userData.membership! == "0" ||
                                        VxState.store.userData.membership! ==
                                            "2"
                                    ? widget
                                            .productdata
                                            .priceVariation![widget.itemindexs]
                                            .discointDisplay!
                                        ? widget
                                            .productdata
                                            .priceVariation![widget.itemindexs]
                                            .price
                                        : widget
                                            .productdata
                                            .priceVariation![widget.itemindexs]
                                            .mrp
                                    : widget
                                            .productdata
                                            .priceVariation![widget.itemindexs]
                                            .membershipDisplay!
                                        ? widget
                                            .productdata
                                            .priceVariation![widget.itemindexs]
                                            .membershipPrice
                                        : widget
                                            .productdata
                                            .priceVariation![widget.itemindexs]
                                            .price) >
                            0)
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          //margin: EdgeInsets.only(right:5.0),
                          padding: EdgeInsets.all(8.0),
                          // color: Theme.of(context).accentColor,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.0),
                            color: ColorCodes.greenColor, //Color(0xff6CBB3C),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 28,
                            minHeight: 18,
                          ),
                          child: Text(
                            widget.productdata.type == "1"
                                ? Calculate()
                                        .getmargin(
                                            widget.productdata.mrp,
                                            VxState.store.userData.membership! ==
                                                        "0" ||
                                                    VxState.store.userData
                                                            .membership! ==
                                                        "2"
                                                ? widget.productdata
                                                        .discointDisplay!
                                                    ? widget.productdata.price
                                                    : widget.productdata.mrp
                                                : widget.productdata
                                                        .membershipDisplay!
                                                    ? widget.productdata
                                                        .membershipPrice
                                                    : widget.productdata.price)
                                        .toStringAsFixed(2) +
                                    S.current.off
                                : Calculate()
                                        .getmargin(
                                            widget
                                                .productdata
                                                .priceVariation![
                                                    widget.itemindexs]
                                                .mrp,
                                            VxState.store.userData.membership! ==
                                                        "0" ||
                                                    VxState.store.userData
                                                            .membership! ==
                                                        "2"
                                                ? widget
                                                        .productdata
                                                        .priceVariation![
                                                            widget.itemindexs]
                                                        .discointDisplay!
                                                    ? widget
                                                        .productdata
                                                        .priceVariation![widget.itemindexs]
                                                        .price
                                                    : widget.productdata.priceVariation![widget.itemindexs].mrp
                                                : widget.productdata.priceVariation![widget.itemindexs].membershipDisplay!
                                                    ? widget.productdata.priceVariation![widget.itemindexs].membershipPrice
                                                    : widget.productdata.priceVariation![widget.itemindexs].price)
                                        .toStringAsFixed(0) +
                                    S.current.off,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color: ColorCodes.whiteColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                ],
              );
  }
}
