import '../../controller/mutations/cat_and_product_mutation.dart';

import '../../constants/features.dart';
import '../../controller/mutations/cart_mutation.dart';
import '../../models/VxModels/VxStore.dart';
import '../../models/newmodle/cartModle.dart';
import 'package:velocity_x/velocity_x.dart';
import '../assets/ColorCodes.dart';
import '../generated/l10n.dart';
import '../constants/IConstants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../assets/images.dart';
import '../utils/prefUtils.dart';

class CartitemsDisplay extends StatefulWidget {

  Function? isdbonprocess ;
  var onempty;
  CartItem snapshot;

  CartitemsDisplay(this.snapshot,
      {this.onempty});

  @override
  _CartitemsDisplayState createState() => _CartitemsDisplayState();
}

class _CartitemsDisplayState extends State<CartitemsDisplay> {
  bool _isAddToCart = false;
  var checkmembership = false;
  String _itemPrice = "";
  bool _checkMembership = false;
  bool _isLoading = true;
  bool iphonex = false;
  bool _isaddOn = false;
  List<CartItem> productBox=[];

  @override
  void initState() {
    productBox = (VxState.store as GroceStore).CartItemList;
    Future.delayed(Duration.zero, () async {
    if(widget.snapshot.addOn.toString() == "0"){
      _isaddOn = true;
    }
    else{
      _isaddOn = false;
    }
  });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.snapshot.mode == "1") {
    //   checkmembership = true;
    // } else {
    //   checkmembership = false;
    // }

    if (!_isLoading)
      if ((VxState.store as GroceStore).userData.membership == "1") {
      _checkMembership = true;
    } else {
      _checkMembership = false;
    }
    for (int i = 0; i < (VxState.store as GroceStore).CartItemList.length; i++) {
      if ((VxState.store as GroceStore).CartItemList[i].mode == "1") {
        _checkMembership = true;
      }
    }
    debugPrint("cart item display..."+widget.snapshot.toppings_data!.length.toString());
    if (VxState.store.userData.membership! == "1" || _checkMembership) {
      if(widget.snapshot.toppings_data!.length > 0){
        double itemtotal = 0;
        debugPrint("_itemPrice...."+_itemPrice.toString());
        for(int i = 0 ;i < widget.snapshot.toppings_data!.length;i++) {
          if (widget.snapshot.membershipPrice == '-' ||
              widget.snapshot.membershipPrice == "0") {
            if (double.parse(widget.snapshot.price!) <= 0 ||
                widget.snapshot.price.toString() == "") {
              itemtotal = itemtotal + double.parse(widget.snapshot.toppings_data![i].price!);
              _itemPrice = (double.parse(widget.snapshot.varMrp!)+itemtotal).toString();
            } else {
              itemtotal = itemtotal + double.parse(widget.snapshot.toppings_data![i].price!);
              _itemPrice = (double.parse(widget.snapshot.price!)+itemtotal).toString();
            }
          } else {
            itemtotal = itemtotal + double.parse(widget.snapshot.toppings_data![i].price!);
            _itemPrice = (double.parse(widget.snapshot.membershipPrice!)+itemtotal).toString();
          }
        }
        debugPrint("_itemPrice....1.."+_itemPrice.toString());
      }
      else {
        if (widget.snapshot.membershipPrice == '-' ||
            widget.snapshot.membershipPrice == "0") {
          if (double.parse(widget.snapshot.price!) <= 0 ||
              widget.snapshot.price.toString() == "") {
            _itemPrice = widget.snapshot.varMrp!;
          } else {
            _itemPrice = widget.snapshot.price!;
          }
        } else {
          _itemPrice = widget.snapshot.membershipPrice!;
        }
      }
    }
    else {
      if(widget.snapshot.toppings_data!.length > 0){
        double itemtotal = 0;
        debugPrint("_itemPrice....2..."+_itemPrice.toString());
        for(int i = 0 ;i < widget.snapshot.toppings_data!.length;i++) {
          if (double.parse(widget.snapshot.price!) <= 0 ||
              widget.snapshot.price.toString() == "") {
            itemtotal = itemtotal + double.parse(widget.snapshot.toppings_data![i].price!);
            _itemPrice = (double.parse(widget.snapshot.varMrp!)+itemtotal).toString();
          } else {
            itemtotal = itemtotal + double.parse(widget.snapshot.toppings_data![i].price!);
            _itemPrice = (double.parse(widget.snapshot.price!)+itemtotal).toString();
          }
        }
        debugPrint("_itemPrice....3..."+_itemPrice.toString());
      }
      else {
        if (double.parse(widget.snapshot.price!) <= 0 ||
            widget.snapshot.price.toString() == "") {
          _itemPrice = widget.snapshot.varMrp!;
        } else {
          _itemPrice = widget.snapshot.price!;
        }
      }
    }

    updateCart(int qty,double weight,CartStatus cart,String varid,String increment){
      debugPrint("widget.snapshot.parent_id.toString()...."+widget.snapshot.parent_id.toString());
      switch(cart){
        case CartStatus.increment:
          cartcontroller.update((done){
            setState(() {
              _isAddToCart = !done;
            });
          },price: widget.snapshot.price.toString(),
              quantity:widget.snapshot.type=="1"?"1":( qty+1).toString(),
              type: widget.snapshot.type,
              weight:widget.snapshot.type=="1"?(weight+double.parse(widget.snapshot.increment!)).toString():"1",
              var_id: varid,
            increament: increment,
            cart_id: widget.snapshot.parent_id.toString(),
            toppings: "",
            topping_id: "",);

          // TODO: Handle this case.
          break;
        case CartStatus.remove:
          cartcontroller.update((done){
            setState(() {
              _isAddToCart = !done;
            });
          },price: widget.snapshot.price.toString(),quantity:"0",
              type: widget.snapshot.type,
              weight:"0",var_id: varid,increament: increment,cart_id: widget.snapshot.parent_id.toString(),toppings: "",
            topping_id: "",);
          // TODO: Handle this case.
          break;
        case CartStatus.decrement:
          cartcontroller.update((done){
            setState(() {
              _isAddToCart = !done;
            });
          },price: widget.snapshot.price.toString(),
              quantity:widget.snapshot.type=="1"?((weight)<= (double.parse(widget.snapshot.varMinItem!)*double.parse(widget.snapshot.increment!)))?"0":qty.toString():((qty)<= int.parse(widget.snapshot.varMinItem!))?"0":(qty-1).toString(),
              type: widget.snapshot.type,
              weight:widget.snapshot.type=="1"? ((weight)<= (double.parse(widget.snapshot.varMinItem!)*double.parse(widget.snapshot.increment!)))?"0":(weight-double.parse(widget.snapshot.increment!)).toString():"0",
              var_id: varid,increament: increment,cart_id: widget.snapshot.parent_id.toString(),toppings: "",
            topping_id: "",);
          // TODO: Handle this case.
          break;
      }
    }
    return
      //_isaddOn?
      Column(

        children: [
          Container(
          color: Colors.white,

          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
            child: Row(
              children: <Widget>[

                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          VxBuilder(
                              mutations: {ProductMutation},
                              builder: (context, box, _) {


                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [

                                   Container(
                                    height:40,
                                       width:100,
                                      child: Text(
                                        widget.snapshot.itemName!,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 15,
                                            // fontWeight: FontWeight.w600,
                                            color: Colors.black),
                                      ),
                                   ),

                                  SizedBox(width: 40,),
                                  (double.parse(widget.snapshot.varStock!) == 0 || widget.snapshot.status == "1") ? Text(
                                    double.parse(widget.snapshot.varStock!) == 0 ? S .of(context).out_of_stock/*"Out Of Stock"*/ : S .of(context).unavailable,/*"Unavailable"*/
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red),
                                  )
                                      :
                                  VxBuilder(builder: (context, store,state){
                                    final box = store.CartItemList;
                                    if(box.isNotEmpty){
                                      if(box.isNotEmpty){

                                        return widget.snapshot.type=="1"?Row(
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () async {
                                                if(widget.snapshot.mode == "3"){

                                                }else {
                                                  if (int.parse(
                                                      widget.snapshot.quantity!) <=
                                                      int.parse(widget.snapshot
                                                          .varMinItem!)) {
                                                    setState(() {
                                                      updateCart(int.parse(
                                                          widget.snapshot
                                                              .quantity!),
                                                          double.parse(
                                                              widget.snapshot
                                                                  .weight!),
                                                          CartStatus.decrement,
                                                          widget.snapshot.varId
                                                              .toString(),
                                                          widget.snapshot.increment
                                                              .toString());
                                                    });
                                                  } else {
                                                    setState(() {
                                                      updateCart(int.parse(
                                                          widget.snapshot
                                                              .quantity!),
                                                          double.parse(
                                                              widget.snapshot
                                                                  .weight!),
                                                          CartStatus.decrement,
                                                          widget.snapshot.varId
                                                              .toString(),
                                                          widget.snapshot.increment
                                                              .toString());
                                                    });
                                                  }
                                                  if (widget.snapshot.mode == "1") {
                                                    PrefUtils.prefs!.setString(
                                                        "memberback", "no");
                                                  } else {
                                                    PrefUtils.prefs!.setString(
                                                        "memberback", "");
                                                  }
                                                }
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.maphome,
                                                    border: Border(
                                                      top: BorderSide(
                                                          width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.maphome),
                                                      bottom: BorderSide(
                                                          width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.maphome),
                                                      left: BorderSide(
                                                          width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.maphome),
                                                    ),
                                                  ),
                                                  width: 30,
                                                  height: 25,
                                                  child: Center(
                                                    child: Text(
                                                      "-",
                                                      textAlign: TextAlign.center,
                                                      style:
                                                      TextStyle(color: ColorCodes.whiteColor),
                                                    ),
                                                  )),
                                            ),
                                            _isAddToCart ?
                                            Container(
                                              width: 35,
                                              height: 25,
                                              padding: EdgeInsets.only(left: 7.5, top: 2.5, right: 7.5, bottom: 2.5),
                                              child: SizedBox(
                                                  width: 20.0,
                                                  height: 20.0,
                                                  child: new CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                    valueColor: new AlwaysStoppedAnimation<Color>(IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.maphome),)),
                                            )
                                                :
                                            Container(
                                                width: 45,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                        width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.maphome),
                                                    bottom: BorderSide(
                                                        width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.maphome),
                                                    left: BorderSide(
                                                        width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.maphome),
                                                    right: BorderSide(
                                                        width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.maphome),
                                                  ),
                                                ),
                                                // decoration: BoxDecoration(color: Colors.green,border: Border.),
                                                child: Center(
                                                  child: Text(
                                                    widget.snapshot.weight.toString()+" "+widget.snapshot.unit.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Theme.of(context).primaryColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                )),
                                            GestureDetector(
                                              onTap: () {
                                                if(widget.snapshot.mode == "3"){

                                                }else {
                                                  if (double.parse(
                                                      widget.snapshot.weight!) <
                                                      double.parse(widget.snapshot
                                                          .varStock!)) {
                                                    if (double.parse(
                                                        widget.snapshot.weight!) <
                                                        (double.parse(
                                                            widget.snapshot
                                                                .varMaxItem!) *
                                                            double.parse(
                                                                widget.snapshot
                                                                    .increment!))) {
                                                      updateCart(int.parse(
                                                          widget.snapshot
                                                              .quantity!),
                                                          double.parse(
                                                              widget.snapshot
                                                                  .weight!),
                                                          CartStatus.increment,
                                                          widget.snapshot.itemId!,
                                                          widget.snapshot.increment
                                                              .toString());
                                                    } else {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                          S
                                                              .of(context)
                                                              .cant_add_more_item,
                                                          //"Sorry, you can\'t add more of this item!",
                                                          fontSize: MediaQuery
                                                              .of(context)
                                                              .textScaleFactor * 13,
                                                          backgroundColor: Colors
                                                              .black87,
                                                          textColor: Colors.white);
                                                    }
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg: S
                                                            .of(context)
                                                            .sorry_outofstock,
                                                        //"Sorry, Out of Stock!",
                                                        fontSize: MediaQuery
                                                            .of(context)
                                                            .textScaleFactor * 13,
                                                        backgroundColor: Colors
                                                            .black87,
                                                        textColor: Colors.white);
                                                  }
                                                }
                                              },
                                              child: Container(
                                                  width: 30,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.maphome,
                                                    border: Border(
                                                      top: BorderSide(
                                                          width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.maphome),
                                                      bottom: BorderSide(
                                                          width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.maphome),
                                                      right: BorderSide(
                                                          width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.maphome),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "+",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          color: ColorCodes.whiteColor
                                                        //color: Theme.of(context).buttonColor,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ):Row(
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () async {
                                                if(widget.snapshot.mode == "3"){

                                                }else {
                                                  if (int.parse(
                                                      widget.snapshot.quantity!) <=
                                                      int.parse(widget.snapshot
                                                          .varMinItem!)) {
                                                    setState(() {
                                                      updateCart(int.parse(
                                                          widget.snapshot
                                                              .quantity!),
                                                          double.parse(
                                                              widget.snapshot
                                                                  .weight!),
                                                          CartStatus.decrement,
                                                          widget.snapshot.varId
                                                              .toString(),
                                                          widget.snapshot.increment
                                                              .toString());
                                                    });
                                                  } else {
                                                    setState(() {
                                                      updateCart(int.parse(
                                                          widget.snapshot
                                                              .quantity!),
                                                          double.parse(
                                                              widget.snapshot
                                                                  .weight!),
                                                          CartStatus.decrement,
                                                          widget.snapshot.varId
                                                              .toString(),
                                                          widget.snapshot.increment
                                                              .toString());
                                                    });
                                                  }
                                                  if (widget.snapshot.mode == "1") {
                                                    PrefUtils.prefs!.setString(
                                                        "memberback", "no");
                                                  } else {
                                                    PrefUtils.prefs!.setString(
                                                        "memberback", "");
                                                  }
                                                }
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    color: IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.stepperColor,
                                                    border: Border(
                                                      top: BorderSide(
                                                          width: 1.0, color: IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.stepperColor),
                                                      bottom: BorderSide(
                                                          width: 1.0, color: IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.stepperColor),
                                                      left: BorderSide(
                                                          width: 1.0, color: IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.stepperColor),
                                                    ),
                                                  ),
                                                  width: 30,
                                                  height: 25,
                                                  child: Center(
                                                    child: Text(
                                                      "-",
                                                      textAlign: TextAlign.center,
                                                      style:
                                                      TextStyle(color: ColorCodes.whiteColor),
                                                    ),
                                                  )),
                                            ),
                                            _isAddToCart ?
                                            Container(
                                              width: 35,
                                              height: 25,
                                              padding: EdgeInsets.only(left: 7.5, top: 2.5, right: 7.5, bottom: 2.5),
                                              child: SizedBox(
                                                  width: 20.0,
                                                  height: 20.0,
                                                  child: new CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                    valueColor: new AlwaysStoppedAnimation<Color>(IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.stepperColor),)),
                                            )
                                                :
                                            Container(
                                                width: 35,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                        width: 1.0, color: IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.stepperColor),
                                                    bottom: BorderSide(
                                                        width: 1.0, color: IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.stepperColor),
                                                    left: BorderSide(
                                                        width: 1.0, color: IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.stepperColor),
                                                    right: BorderSide(
                                                        width: 1.0, color: IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.stepperColor),
                                                  ),
                                                ),
                                                // decoration: BoxDecoration(color: Colors.green,border: Border.),
                                                child: Center(
                                                  child: Text(
                                                    widget.snapshot.quantity.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                  ),
                                                )),
                                            GestureDetector(
                                              onTap: () {
                                                if(widget.snapshot.mode == "3"){

                                                }else {
                                                  if (double.parse(
                                                      widget.snapshot.quantity!) <
                                                      double.parse(widget.snapshot
                                                          .varStock!)) {
                                                    if (double.parse(
                                                        widget.snapshot.quantity!) <
                                                        int.parse(widget.snapshot
                                                            .varMaxItem!)) {
                                                      updateCart(int.parse(
                                                          widget.snapshot
                                                              .quantity!),
                                                          double.parse(
                                                              widget.snapshot
                                                                  .weight!),
                                                          CartStatus.increment,
                                                          widget.snapshot.varId!,
                                                          widget.snapshot.increment
                                                              .toString());
                                                    } else {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                          S
                                                              .of(context)
                                                              .cant_add_more_item,
                                                          //"Sorry, you can\'t add more of this item!",
                                                          fontSize: MediaQuery
                                                              .of(context)
                                                              .textScaleFactor * 13,
                                                          backgroundColor: Colors
                                                              .black87,
                                                          textColor: Colors.white);
                                                    }
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg: S
                                                            .of(context)
                                                            .sorry_outofstock,
                                                        //"Sorry, Out of Stock!",
                                                        fontSize: MediaQuery
                                                            .of(context)
                                                            .textScaleFactor * 13,
                                                        backgroundColor: Colors
                                                            .black87,
                                                        textColor: Colors.white);
                                                  }
                                                }
                                              },
                                              child: Container(
                                                  width: 30,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    color: IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.stepperColor,
                                                    border: Border(
                                                      top: BorderSide(
                                                          width: 1.0, color: IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.stepperColor),
                                                      bottom: BorderSide(
                                                          width: 1.0, color: IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.stepperColor),
                                                      right: BorderSide(
                                                          width: 1.0, color: IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.stepperColor),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "+",
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          color: ColorCodes.whiteColor
                                                        //color: Theme.of(context).buttonColor,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        );
                                      }else{
                                        widget.onempty;
                                        return Row(
                                          children: <Widget>[
                                            Container(
                                                decoration: BoxDecoration(
                                                  color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor,
                                                  border: Border(
                                                    top: BorderSide(
                                                        width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                    bottom: BorderSide(
                                                        width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                    left: BorderSide(
                                                        width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                  ),
                                                ),
                                                width: 30,
                                                height: 25,
                                                child: Center(
                                                  child: Text(
                                                    "-",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                    TextStyle(color: ColorCodes.whiteColor),
                                                  ),
                                                )),
                                            Container(
                                              width: 35,
                                              height: 25,
                                              padding: EdgeInsets.only(left: 7.5, top: 2.5, right: 7.5, bottom: 2.5),
                                              child: SizedBox(
                                                  width: 20.0,
                                                  height: 20.0,
                                                  child: new CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                    valueColor: new AlwaysStoppedAnimation<Color>(IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),)),
                                            ),
                                            Container(
                                                width: 30,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                  color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor,
                                                  border: Border(
                                                    top: BorderSide(
                                                        width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                    bottom: BorderSide(
                                                        width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                    right: BorderSide(
                                                        width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "+",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: ColorCodes.whiteColor
                                                      //color: Theme.of(context).buttonColor,
                                                    ),
                                                  ),
                                                )),
                                          ],
                                        );
                                      }
                                    }else if(box.isEmpty){
                                      widget.onempty;
                                      return Row(
                                        children: <Widget>[
                                          Container(
                                              decoration: BoxDecoration(
                                                color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor,
                                                border: Border(
                                                  top: BorderSide(
                                                      width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                  bottom: BorderSide(
                                                      width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                  left: BorderSide(
                                                      width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                ),
                                              ),
                                              width: 30,
                                              height: 25,
                                              child: Center(
                                                child: Text(
                                                  "-",
                                                  textAlign: TextAlign.center,
                                                  style:
                                                  TextStyle(color: ColorCodes.whiteColor),
                                                ),
                                              )),
                                          Container(
                                            width: 35,
                                            height: 25,
                                            padding: EdgeInsets.only(left: 7.5, top: 2.5, right: 7.5, bottom: 2.5),
                                            child: SizedBox(
                                                width: 20.0,
                                                height: 20.0,
                                                child: new CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  valueColor: new AlwaysStoppedAnimation<Color>(IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),)),
                                          ),
                                          Container(
                                              width: 30,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor,
                                                border: Border(
                                                  top: BorderSide(
                                                      width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                  bottom: BorderSide(
                                                      width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                  right: BorderSide(
                                                      width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "+",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: ColorCodes.whiteColor
                                                    //color: Theme.of(context).buttonColor,
                                                  ),
                                                ),
                                              )),
                                        ],
                                      );
                                    }else {
                                      Future.delayed(Duration.zero).then((value) => widget.onempty);
                                      return Row(
                                        children: <Widget>[
                                          Container(
                                              decoration: BoxDecoration(
                                                color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor,
                                                border: Border(
                                                  top: BorderSide(
                                                      width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                  bottom: BorderSide(
                                                      width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                  left: BorderSide(
                                                      width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                ),
                                              ),
                                              width: 30,
                                              height: 25,
                                              child: Center(
                                                child: Text(
                                                  "-",
                                                  textAlign: TextAlign.center,
                                                  style:
                                                  TextStyle(color: ColorCodes.whiteColor),
                                                ),
                                              )),
                                          Container(
                                            width: 35,
                                            height: 25,
                                            padding: EdgeInsets.only(left: 7.5, top: 2.5, right: 7.5, bottom: 2.5),
                                            child: SizedBox(
                                                width: 20.0,
                                                height: 20.0,
                                                child: new CircularProgressIndicator(
                                                  strokeWidth: 2.0,
                                                  valueColor: new AlwaysStoppedAnimation<Color>(IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),)),
                                          ),
                                          Container(
                                              width: 30,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor,
                                                border: Border(
                                                  top: BorderSide(
                                                      width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                  bottom: BorderSide(
                                                      width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                  right: BorderSide(
                                                      width: 1.0, color: IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "+",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: ColorCodes.whiteColor
                                                    //color: Theme.of(context).buttonColor,
                                                  ),
                                                ),
                                              )),
                                        ],
                                      );
                                    }
                                  }, mutations: {SetCartItem}),
                                  Spacer(),

                                  // SizedBox(
                                  //   width: 5,
                                  // ),




                                  if(widget.snapshot.mode != "3")
                                    (widget.snapshot.type=="1")?  Text((double.parse(widget.snapshot.quantity!) == 0 || widget.snapshot.status.toString() == "0") ?
                                    Features.iscurrencyformatalign?
                                    IConstants.numberFormat == "1"?' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.weight!))).toStringAsFixed(0)  + ' ' + IConstants.currencyFormat:
                                    ' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.weight!))).toStringAsFixed(IConstants.decimaldigit)  + ' ' + IConstants.currencyFormat:
                                    IConstants.numberFormat == "1"?IConstants.currencyFormat +  ' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.weight!))).toStringAsFixed(0):
                                    IConstants.currencyFormat + ' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.weight!))).toStringAsFixed(IConstants.decimaldigit)
                                        :
                                    Features.iscurrencyformatalign?
                                    IConstants.numberFormat == "1"?' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.weight!))).toStringAsFixed(0) + ' ' + IConstants.currencyFormat:' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.weight!))).toStringAsFixed(IConstants.decimaldigit)  + ' ' +  IConstants.currencyFormat:
                                    IConstants.numberFormat == "1"?IConstants.currencyFormat +  ' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.weight!))).toStringAsFixed(0):IConstants.currencyFormat + ' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.weight!))).toStringAsFixed(IConstants.decimaldigit),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: 16)):
                                    Text((double.parse(widget.snapshot.quantity!) == 0 || widget.snapshot.status.toString() == "0") ?
                                    Features.iscurrencyformatalign?
                                    IConstants.numberFormat == "1"?' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.quantity!))).toStringAsFixed(0)  + ' ' + IConstants.currencyFormat:
                                    ' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.quantity!))).toStringAsFixed(IConstants.decimaldigit)  + ' ' + IConstants.currencyFormat:
                                    IConstants.numberFormat == "1"?IConstants.currencyFormat +  ' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.quantity!))).toStringAsFixed(0):
                                    IConstants.currencyFormat +  ' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.quantity!))).toStringAsFixed(IConstants.decimaldigit)
                                        :
                                    Features.iscurrencyformatalign?
                                    IConstants.numberFormat == "1"?' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.quantity!))).toStringAsFixed(0) + ' ' + IConstants.currencyFormat:' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.quantity!))).toStringAsFixed(IConstants.decimaldigit)  + ' ' +  IConstants.currencyFormat:
                                    IConstants.numberFormat == "1"?IConstants.currencyFormat + ' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.quantity!))).toStringAsFixed(0):IConstants.currencyFormat + ' ' + (double.parse(_itemPrice)*(double.parse(widget.snapshot.quantity!))).toStringAsFixed(IConstants.decimaldigit),
                                        style: TextStyle(
                                             fontSize: 16)),
                                  SizedBox(
                                    width: 10,
                                  )
                                ],
                              );
                            }
                          ),
                          (widget.snapshot.mode == "3")?
                          Text(
                            "Free Product",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: ColorCodes.redColor),
                          )
                              :SizedBox.shrink(),
                          (widget.snapshot.toppings_data!.length > 0)?
                          SizedBox(
                            height: 20,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: widget.snapshot.toppings_data!.length,
                                itemBuilder: (_, i) {
                                  return Container(
                                    //width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text( widget.snapshot.toppings_data![i].name!, style: TextStyle(fontSize: 12,
                                            color: ColorCodes.greyColor,
                                            fontWeight: FontWeight.bold), ),
                                        (i != widget.snapshot.toppings_data!.length - 1 ) ? const Text(', ') : const Text('.'),
                                        SizedBox(height: 3,)
                                      ],
                                    ),
                                  );
                                }),
                          ):
                              SizedBox.shrink(),

                        ])
           ),

              ],
            )
            ,

          ),
    ),
          Divider(
            color: Color(0xffE0E0E0),
            thickness: 1,
          ),
        ],
      );
    //:SizedBox.shrink();
  }
}
