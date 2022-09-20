import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../constants/features.dart';
import '../controller/mutations/cart_mutation.dart';
import '../data/calculations.dart';
import '../generated/l10n.dart';
import '../models/VxModels/VxStore.dart';
import 'package:velocity_x/velocity_x.dart';
import '../assets/ColorCodes.dart';
import '../assets/images.dart';
import '../constants/IConstants.dart';

class BottomNaviagation extends StatefulWidget {
  final String? itemCount;
  final String? title;
  String? total;
  final GestureTapCallback? onPressed;
  String adonamount;

  BottomNaviagation({Key? key, this.itemCount, this.title, this.total, this.onPressed,this.adonamount = "0"}) : super(key: key);
  @override
  _BottomNaviagationState createState() => _BottomNaviagationState();
}

class _BottomNaviagationState  extends State<BottomNaviagation> {
  CartCalculation _calculation = CartCalculation();

  @override
  Widget build(BuildContext context) {
    debugPrint("title...."+widget.title!+"  "+S.current.subscribe+"  "+widget.itemCount!+"  "+CartCalculations.itemCount.toString());
    return VxBuilder(
        mutations: {SetCartItem},
        builder: (context, store, state){
          if(((widget.title==S.current.subscribe || widget.title == S.of(context).pause)?(widget.itemCount == "0")  : CartCalculations.itemCount>0) && (widget.itemCount != "1 Items") )
            return ((widget.title==S.current.subscribe || widget.title == S.of(context).pause)?widget.itemCount:CartCalculations.itemCount.toString()) == "0"?
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 80,
                padding: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 10),
                color: ColorCodes.whiteColor,
                width: MediaQuery.of(context).size.width,
                child: GestureDetector(
                  onTap: () {
                    widget.onPressed!();
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      //color: ColorCodes.cyanColor,
                      color: ColorCodes.lightBlueColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              child: Text("",
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              child: Text(widget.title!,
                                style: TextStyle(
                                  fontSize: 18,

                                  color: ColorCodes.lightblue,
                                  //color: ColorCodes.discount,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                child:  Icon(Icons.keyboard_arrow_right_sharp, size: 35, color: ColorCodes.lightblue,),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            )
                :MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 80,
                padding: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 10),
                color: ColorCodes.whiteColor,
                width: MediaQuery.of(context).size.width,
                child: GestureDetector(
                  onTap: () {
                    widget.onPressed!();
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      //color: ColorCodes.cyanColor,
                      color: ColorCodes.lightBlueColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          Images.bag, height: 30, width: 30, color: ColorCodes.lightblue,
                        ),
                        SizedBox(width: 5,),
                        (_calculation.getTotal() == "0")? Text(_calculation.getItemCount(),  style: TextStyle(
                          fontSize: 15,
                          color: ColorCodes.lightblue,
                          fontWeight: FontWeight.w700,
                        ),
                        ):Column(
                          mainAxisAlignment: (widget.total=="1")?MainAxisAlignment.center:MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_calculation.getItemCount(),  style: TextStyle(
                              fontSize: 15,
                              color: ColorCodes.lightblue,
                              fontWeight: FontWeight.w700,
                            ),
                            ),
                            SizedBox(height: 3,),
                            (widget.total=="1")?SizedBox.shrink():
                            Text(widget.title==S.current.proceed_pay?
                            Features.iscurrencyformatalign?widget.total !+ IConstants.currencyFormat:IConstants.currencyFormat+widget.total!:
                            Features.iscurrencyformatalign?
                            (IConstants.numberFormat == "1")?
                            (double.parse(_calculation.getTotal())+double.parse(widget.adonamount)).toStringAsFixed(0)+ IConstants.currencyFormat
                                :(double.parse(_calculation.getTotal())+double.parse(widget.adonamount)).toStringAsFixed(IConstants.decimaldigit) + IConstants.currencyFormat :
                            (IConstants.numberFormat == "1")?IConstants.currencyFormat +
                                (double.parse(_calculation.getTotal())+double.parse(widget.adonamount)).toStringAsFixed(0):IConstants.currencyFormat +
                                (double.parse(_calculation.getTotal())+double.parse(widget.adonamount)).toStringAsFixed(IConstants.decimaldigit),  style: TextStyle(
                              fontSize: 15,
                              color: ColorCodes.lightblue,
                              fontWeight: FontWeight.bold,
                            ),),
                          ],
                        ),
                        Spacer(),
                        Text(widget.title!,
                          style: TextStyle(
                            fontSize: 18,
                            color: ColorCodes.lightblue,
                            //color: ColorCodes.discount,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_right_sharp, size: 35, color: ColorCodes.lightblue,),
                      ],
                    ),
                  ),
                ),
              ),
            );
          else if(widget.itemCount == "1 Items"){
            debugPrint("1 Items......");
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 80,
                padding: EdgeInsets.only(left: 15, top: 10, right: 15, bottom: 10),
                color: ColorCodes.whiteColor,
                width: MediaQuery.of(context).size.width,
                child: GestureDetector(
                  onTap: () {
                    widget.onPressed!();
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      //color: ColorCodes.cyanColor,
                      color: ColorCodes.lightBlueColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          Images.bag, height: 30, width: 30, color: ColorCodes.lightblue,
                        ),
                        SizedBox(width: 5,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("1 Items",  style: TextStyle(
                              fontSize: 15,
                              color: ColorCodes.lightblue,
                              fontWeight: FontWeight.w700,
                            ),
                            ),
                            SizedBox(height: 3,),
                            Text(
                              Features.iscurrencyformatalign?
                              widget.total !+ IConstants.currencyFormat:
                              IConstants.currencyFormat +
                                  widget.total!,  style: TextStyle(
                              fontSize: 15,
                              color: ColorCodes.lightblue,
                              fontWeight: FontWeight.bold,
                            ),),
                          ],
                        ),
                        Spacer(),
                        Text(widget.title!,
                          style: TextStyle(
                            fontSize: 18,
                            color: ColorCodes.lightblue,
                            //color: ColorCodes.discount,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_right_sharp, size: 35, color: ColorCodes.lightblue,),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          else
            return  SizedBox.shrink();
        }
    );
  }
}
class CartCalculation{
  String getTotal(){
    return CartCalculations.checkmembership ? (IConstants.numberFormat == "1")
        ?(CartCalculations.totalMember).toStringAsFixed(0):(CartCalculations.totalMember).toStringAsFixed(IConstants.decimaldigit)
        :
    (IConstants.numberFormat == "1")
        ?(CartCalculations.total).toStringAsFixed(0):(CartCalculations.total).toStringAsFixed(IConstants.decimaldigit);
  }
  String getItemCount() {
    return CartCalculations.itemCount.toString() + " " + S.current.items;
  }
}