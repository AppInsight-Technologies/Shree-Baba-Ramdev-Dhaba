import 'package:flutter/material.dart';
import '../../helper/custome_checker.dart';
import '../../utils/ResponsiveLayout.dart';
import '../../assets/ColorCodes.dart';
import '../../assets/images.dart';
import '../../constants/IConstants.dart';
import '../../models/newmodle/product_data.dart';
import '../../constants/features.dart';
import '../../models/VxModels/VxStore.dart';
import '../../models/newmodle/cartModle.dart';
import 'package:velocity_x/velocity_x.dart';

import '../custome_stepper.dart';

class MembershipInfoWidget extends StatefulWidget {
  final ItemData itemdata;
  late int itemindex;
  final int itemindexs;
  final Function() ontap;
  MembershipInfoWidget({Key? key,required this.itemdata,required String varid, required this.itemindexs, required this.ontap}){
    this.itemindex = itemdata.priceVariation!.indexWhere((element) => element.id == varid);
  }

  @override
  State<MembershipInfoWidget> createState() => _MembershipInfoWidgetState();
}

class _MembershipInfoWidgetState extends State<MembershipInfoWidget> {
  var _checkmembership = false;

  List<CartItem> productBox = /*Hive.box<Product>(productBoxName)*/(VxState.store as GroceStore).CartItemList;

  @override
  Widget build(BuildContext context)  {
    print("member");

    return (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?Padding(
      padding: EdgeInsets.symmetric(horizontal: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?30:0),
      child: widget.itemdata.type=="1"?
      Column(
        children: [
          if(Features.isMembership  && int.parse(widget.itemdata.membershipPrice.toString()) > 0)
            Row(
              children: [
                !_checkmembership
                    ? widget.itemdata.membershipDisplay!
                    ? GestureDetector(
                  onTap: () {
                    widget.ontap();

                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                    padding: EdgeInsets.symmetric(vertical: 5,),
                    height: 35,
                    width: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                    MediaQuery.of(context).size.width / 2.03:(MediaQuery.of(context)
                        .size
                        .width) -
                        20 ,
                    decoration: BoxDecoration(
                        color: ColorCodes.membershipColor),
                    child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(width: 10),
                        Image.asset(
                          Images.starImg,
                          height: 12,
                        ),
                        SizedBox(width: 2),
                        Text(
                            Features.iscurrencyformatalign ?
                            widget.itemdata.membershipPrice
                                .toString() + IConstants.currencyFormat :
                            IConstants.currencyFormat +
                                widget.itemdata
                                    .membershipPrice.toString(),
                            style: TextStyle(
                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,)),
                        Spacer(),
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
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                )
                    : SizedBox.shrink()
                    : SizedBox.shrink(),
              ],
            ),
          !_checkmembership
              ? widget.itemdata.membershipDisplay!
              ? SizedBox(
            height: 1,
          )
              : SizedBox(
            height: 1,
          )
              : SizedBox(
            height: 1,
          ),
        ],
      ):
      Column(
        children: [
          if(Features.isMembership  && double.parse(widget.itemdata.priceVariation![widget.itemindexs].membershipPrice.toString()) > 0)
            Row(
              children: [
                !_checkmembership
                    ? widget.itemdata.priceVariation![widget.itemindexs].membershipDisplay!
                    ? GestureDetector(
                  onTap: () {
                    widget.ontap();

                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                    padding: EdgeInsets.symmetric(vertical: 5,),
                    height: 35,
                    width: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                    MediaQuery.of(context).size.width / 2.03:(MediaQuery.of(context)
                        .size
                        .width) -
                        20 ,
                    decoration: BoxDecoration(
                        color: ColorCodes.membershipColor),
                    child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(width: 10),
                        Image.asset(
                          Images.starImg,
                          height: 12,
                        ),
                        SizedBox(width: 2),
                        Text(
                            Features.iscurrencyformatalign ?
                            widget.itemdata.priceVariation![widget.itemindexs].membershipPrice
                                .toString() + IConstants.currencyFormat :
                            IConstants.currencyFormat +
                                widget.itemdata.priceVariation![widget.itemindexs]
                                    .membershipPrice.toString(),
                            style: TextStyle(
                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,)),
                        Spacer(),
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
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                )
                    : SizedBox.shrink()
                    : SizedBox.shrink(),
              ],
            ),
          !_checkmembership
              ? widget.itemdata.priceVariation![widget.itemindexs].membershipDisplay!
              ? SizedBox(
            height: 1,
          )
              : SizedBox(
            height: 1,
          )
              : SizedBox(
            height: 1,
          ),
        ],
      ),
    ):
    Padding(
      padding: EdgeInsets.symmetric(horizontal: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?30:0),
      child: widget.itemdata.type=="1"?
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              if(Features.isMembership  && int.parse(widget.itemdata.membershipPrice.toString()) > 0)
                Row(
                  children: [
                    !_checkmembership
                        ? widget.itemdata.membershipDisplay!
                        ? GestureDetector(
                      onTap: () {
                        widget.ontap();

                      },
                      child: Container(
                        // margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                        // padding: EdgeInsets.symmetric(vertical: 5,),
                        height: 35,
                        width: Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)?
                        MediaQuery.of(context).size.width / 2.03:(MediaQuery
                            .of(context)
                            .size
                            .width / 3) + 5 ,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(width: 5.0, color: ColorCodes.darkgreen),
                            // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                          ),
                          color: ColorCodes.varcolor,
                        ),
                        child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(width: 10),

                            Text(
                                Features.iscurrencyformatalign ?
                                widget.itemdata.membershipPrice
                                    .toString() + IConstants.currencyFormat :
                                IConstants.currencyFormat +
                                    widget.itemdata
                                        .membershipPrice.toString()+" Membership Price",
                                style: TextStyle(
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,color: ColorCodes.greenColor)),

                          ],
                        ),
                      ),
                    )
                        : SizedBox.shrink()
                        : SizedBox.shrink(),
                  ],
                ),
              !_checkmembership
                  ? widget.itemdata.membershipDisplay!
                  ? SizedBox(
                height: 1,
              )
                  : SizedBox(
                height: 1,
              )
                  : SizedBox(
                height: 1,
              ),
            ],
          ),
          Spacer(),
          widget.itemdata.type=="1"?
          Container(
            height:(Features.isSubscription)?35:55,
            width:  (MediaQuery.of(context).size.width/3)+5,
            child: Padding(
              padding: const EdgeInsets.only(left:5,right:5.0),
              child: CustomeStepper(itemdata:widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs,issubscription: "Add",  ismember: _checkmembership,selectedindex: widget.itemindex,onselect: (i){
                setState(() {
                  widget.itemindex = i;
                  // Navigator.of(context).pop();
                });
              }, ),
            ),
          )
              :Container(
            height:(Features.isSubscription)?35:55,
            width:  (MediaQuery.of(context).size.width/3)+5,
            child: Padding(
              padding: const EdgeInsets.only(left:5,right:5.0),
              child: CustomeStepper(priceVariation:widget.itemdata.priceVariation![widget.itemindexs],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs,  ismember: _checkmembership,selectedindex: widget.itemindex,onselect: (i){
                setState(() {
                  widget.itemindex = i;
                  // Navigator.of(context).pop();
                });
              },),
            ),
          ),
        ],
      ):
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              if(Features.isMembership  && double.parse(widget.itemdata.priceVariation![widget.itemindexs].membershipPrice.toString()) > 0)
                Row(
                  children: [
                    !_checkmembership
                        ? widget.itemdata.priceVariation![widget.itemindexs].membershipDisplay!
                        ? GestureDetector(
                      onTap: () {
                        widget.ontap();

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
                                widget.itemdata.priceVariation![widget.itemindex].membershipPrice.toString() + IConstants.currencyFormat:
                                IConstants.currencyFormat +
                                   widget.itemdata.priceVariation![widget.itemindex].membershipPrice.toString() /*+ " " +S.of(context).membership_price*/+" Membership Price",
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
                  ? widget.itemdata.priceVariation![widget.itemindexs].membershipDisplay!
                  ? SizedBox(
                height: 1,
              )
                  : SizedBox(
                height: 1,
              )
                  : SizedBox(
                height: 1,
              ),
            ],
          ),
          Spacer(),
          widget.itemdata.type=="1"?
          Container(
            height:(Features.isSubscription)?35:55,
            width:  (MediaQuery.of(context).size.width/3)+5,
            child: Padding(
              padding: const EdgeInsets.only(left:5,right:5.0),
              child: CustomeStepper(itemdata:widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:60,addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs,issubscription: "Add",   ismember: _checkmembership,selectedindex: widget.itemindex,onselect: (i){
                setState(() {
                  widget.itemindex = i;
                  // Navigator.of(context).pop();
                });
              },),
            ),
          )
              :Container(
            height:(Features.isSubscription)?35:55,
            width:  (MediaQuery.of(context).size.width/3)+5,
            child: Padding(
              padding: const EdgeInsets.only(left:5,right:5.0),
              child: CustomeStepper(priceVariation:widget.itemdata.priceVariation![widget.itemindexs],itemdata: widget.itemdata,from:"item_screen",height: (Features.isSubscription)?90:40,issubscription: "Add",addon:(widget.itemdata.addon!.length > 0)?widget.itemdata.addon![0]:null, index: widget.itemindexs,  ismember: _checkmembership,selectedindex: widget.itemindex,onselect: (i){
                setState(() {
                  widget.itemindex = i;
                  // Navigator.of(context).pop();
                });
              },),
            ),
          ),
        ],
      ),
    );
  }
}

