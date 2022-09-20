import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../assets/images.dart';
import '../../components/login_web.dart';
import '../../helper/custome_checker.dart';
import '../../models/VxModels/VxStore.dart';
import '../../models/newmodle/repeateToppings.dart';
import '../../models/sellingitemsfields.dart';
import '../../providers/myorderitems.dart';
import '../../utils/ResponsiveLayout.dart';
import '../../utils/facebook_app_events.dart';
import '../../utils/prefUtils.dart';
import '../../widgets/productWidget/item_variation.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../models/newmodle/cartModle.dart';
import '../../constants/IConstants.dart';
import '../assets/ColorCodes.dart';
import '../constants/api.dart';
import '../constants/features.dart';
import '../controller/mutations/cart_mutation.dart';
import '../generated/l10n.dart';
import '../models/newmodle/product_data.dart';
import '../models/newmodle/search_data.dart';
import '../providers/branditems.dart';

import 'package:provider/provider.dart';

import '../rought_genrator.dart';
import 'package:http/http.dart' as http;

enum StepperAlignment{
  Vertical,Horizontal
}

class CustomeStepper extends StatefulWidget {
  PriceVariation? priceVariation;
  PriceVariationSearch? priceVariationSearch;
  String? from;
  ItemData? itemdata;
  StoreSearchData? searchstoredata;
  bool? checkmembership;
  bool subscription;
  StepperAlignment alignmnt;
  final double fontSize;
  final double height;
  final double width;
  Addon? addon;
  int index;
  String? issubscription;
  bool showPrice;
  bool? ismember;
  int selectedindex;
  StoreSearchData? searchdata;
  Function? onselect;
  CustomeStepper({Key? key,this.priceVariation,this.priceVariationSearch,this.itemdata,this.searchstoredata,this.from,this.checkmembership,this.subscription = false,this.alignmnt = StepperAlignment.Vertical,this.fontSize = 12,required this.height ,this.width = double.infinity,this.addon,required this.index,this.issubscription,this.showPrice=false,this.ismember,this.onselect,this.selectedindex = 0,this.searchdata, }) : super(key: key);

  @override
  State<CustomeStepper> createState() => _CustomeStepperState();
}

class _CustomeStepperState extends State<CustomeStepper> with Navigations {

  bool loading = false;
  bool Toppingloading = false;
  bool _checkmembership = false;
  bool _isNotify = false;
  List<CartItem> productBox=[];
  List<Widget> stepperButtons = [];
  final item =(VxState.store as GroceStore).CartItemList;
  int toppings = 0;
  bool? ismember;
  String? toppingscheck;
  int _groupValue = -1;
  String? fromscreen;
  StateSetter? setstate;
  late Future<List<RepeatToppings>> _futureNonavailable = Future.value([]);
  StoreSearchData? searchdata;
  late StateSetter topupState;
  int? varId = 0;
  int? parentId = 0;
  Function? onselect;
  var itemadd = {};
  List toppingsitem = [];
  int selectedindex= 0;
  List product = [];
  ItemData? itemdata;
  List addToppingsProduct = [];
  String? parentidforupdate = "";
  List<String> deliveries = [];

  Widget handler1(int i) {
    print("i...."+i.toString());
    if ((fromscreen == "search_item_multivendor" && Features.ismultivendor)?searchdata!.priceVariation![i].stock! >= 0:widget.itemdata!.priceVariation![i].stock! >= 0) {
      debugPrint("stock...");
      return (selectedindex == i) ?
      Icon(
          Icons.radio_button_checked_outlined,
          color: ColorCodes.primaryColor,)
          :
      Icon(
          Icons.radio_button_off_outlined,
          color: ColorCodes.primaryColor);

    } else {
      debugPrint("out  stock...");
      return (selectedindex == i) ?
      Icon(
          Icons.radio_button_checked_outlined,
          color: ColorCodes.grey)
          :
      Icon(
          Icons.radio_button_off_outlined,
          color: ColorCodes.primaryColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    productBox=  (VxState.store as GroceStore).CartItemList;
    deliveries.clear();
    if(widget.from == "search_screen" && Features.ismultivendor){
      if (widget.searchstoredata!.subscriptionSlot!.length > 0) {
        deliveries.addAll(
            (widget.searchstoredata!.subscriptionSlot![0].deliveries!.split(",")));
      }
    }else {
      if (widget.itemdata!.subscriptionSlot!.length > 0) {
        deliveries.addAll(
            (widget.itemdata!.subscriptionSlot![0].deliveries!.split(",")));
      }
    }
    debugPrint("deliveries...."+deliveries.toString());
    product.clear();
    for( int i = 0;i < productBox.length ;i++){
      if(widget.from == "search_screen" && Features.ismultivendor) {
        if (productBox[i].itemId == widget.searchstoredata!.id &&
            productBox[i].toppings == "0") {
          product.add(productBox[i].quantity);
        }
      }
      else {
        if (productBox[i].itemId == widget.itemdata!.id &&
            productBox[i].toppings == "0") {
          product.add(productBox[i].quantity);
        }
      }

      /* if(box[i].itemId == widget.itemdata!.id && box[i].toppings =="0"){
                      debugPrint("true...1");
                      quantity = quantity +  int.parse(box
                          .where((element) =>
                      element.itemId == widget.itemdata!.id)
                          .first
                          .quantity!);
                      weight = weight + double.parse(box
                          .where((element) =>
                      element.itemId == widget.itemdata!.id)
                          .first
                          .weight!);
                    }*/
    }

    List maxQantity = [];
    List maxWeight = [];
    int quantityTotal = 0;
    double weightTotal = 0;
    debugPrint("weightTotal...");

    if(widget.from == "search_screen" && Features.ismultivendor){
      if(widget.searchstoredata!.type == "1"){
        debugPrint("Single sku....");
        for(int i =0; i< productBox.where((element) => element.itemId == widget.searchstoredata!.id).length ;i++){
          maxWeight.add(productBox[i].weight);
        }
        debugPrint("weightTotal...1"+maxWeight.toString());
        for(int j = 0; j < maxWeight.length; j++){
          weightTotal = weightTotal + double.parse(maxWeight[j]);
        }
        debugPrint("weightTotal...1"+weightTotal.toString());
      }
      else {
        debugPrint("multi sku....");
        for (int i = 0; i < productBox
            .where((element) => element.itemId == widget.searchstoredata!.id)
            .length; i++) {
          maxQantity.add(productBox[i].quantity);
        }
        debugPrint("maxQantity...1" + maxQantity.toString());
        for (int j = 0; j < maxQantity.length; j++) {
          quantityTotal = quantityTotal + int.parse(maxQantity[j]);
        }
        debugPrint("maxQantity...2" + quantityTotal.toString());
      }
    }
    else{
      if(widget.itemdata!.type == "1"){
        debugPrint("Single sku....");
        for(int i =0; i< productBox.where((element) => element.itemId == widget.itemdata!.id).length ;i++){
          maxWeight.add(productBox[i].weight);
        }
        debugPrint("weightTotal...1"+maxWeight.toString());
        for(int j = 0; j < maxWeight.length; j++){
          weightTotal = weightTotal + double.parse(maxWeight[j]);
        }
        debugPrint("weightTotal...1"+weightTotal.toString());
      }
      else {
        debugPrint("multi sku....");
        for (int i = 0; i < productBox
            .where((element) => element.itemId == widget.itemdata!.id)
            .length; i++) {
          maxQantity.add(productBox[i].quantity);
        }
        debugPrint("maxQantity...1" + maxQantity.toString());
        for (int j = 0; j < maxQantity.length; j++) {
          quantityTotal = quantityTotal + int.parse(maxQantity[j]);
        }
        debugPrint("maxQantity...2" + quantityTotal.toString());
      }
    }
    updateCart(int qty,double weight,CartStatus cart,String varid, String parent_id, String toppings, String toppings_id){

      //debugPrint("decrement"+qty.toString());
      switch(cart){
        case CartStatus.increment:
        // print("qunty and stock"+qty.toString()+"...."+widget.priceVariation!.stock.toString()+",,,"+widget.priceVariation!.maxItem.toString());
        // if(qty <double.parse(widget.priceVariation!.stock.toString())) {
        //   if(qty <double.parse(widget.priceVariation!.maxItem.toString())) {
        //     cartcontroller.update((done) {
        //       print("done value in calling update " + done.toString());
        //       setState(() {
        //         loading = !done;
        //         print("value of loading in update cart increment case: " +
        //             loading.toString());
        //       });
        //     }, price: widget.priceVariation!.price.toString(),
        //         quantity: (qty + 1).toString(),
        //         var_id: varid);
        // }else {
        //     Fluttertoast.showToast(
        //         msg:
        //         S.of(context).cant_add_more_item,//"Sorry, you can\'t add more of this item!",
        //         fontSize: MediaQuery.of(context).textScaleFactor *13,
        //         backgroundColor: Colors.black87,
        //         textColor: Colors.white);
        //   }
        // }else{
        //   Fluttertoast.showToast(
        //       msg: S
        //           .of(context)
        //           .sorry_outofstock, //"Sorry, Out of Stock!",
        //       fontSize: MediaQuery
        //           .of(context)
        //           .textScaleFactor * 13,
        //       backgroundColor: Colors.black87,
        //       textColor: Colors.white);
        // }
          if(widget.from == "search_screen" && Features.ismultivendor){
            if(widget.searchstoredata!.type=="1"){
              print("qunty and stock"+qty.toString()+"...."+widget.searchstoredata!.stock.toString()+",,,"+widget.searchstoredata!.maxItem.toString());
              if((productBox.where((element) => element.itemId == widget.searchstoredata!.id).length > 1 ?weightTotal:double.parse(weight.toString()))
                  < double.parse(widget.searchstoredata!.stock.toString())) {
                if((productBox.where((element) => element.itemId == widget.searchstoredata!.id).length > 1 ?weightTotal: double.parse(weight.toString()))
                    <(double.parse(widget.searchstoredata!.maxItem!)*double.parse(widget.searchstoredata!.increament!))) {
                  cartcontroller.update((done) {
                    print("done value in calling update " + done.toString());
                    setState(() {
                      loading = !done;
                      print("value of loading in update cart increment case: " +
                          loading.toString());
                    });
                  }, price: widget.searchstoredata!.price.toString(),
                      quantity: qty.toString(),
                      type: widget.searchstoredata!.type,
                      weight: (weight+double.parse(widget.searchstoredata!.increament!)).toString(),
                      var_id: varid,
                      increament: widget.searchstoredata!.increament,
                      cart_id: parent_id,
                      toppings: toppings,
                      topping_id: toppings_id

                  );
                }
                else {
                  debugPrint("cant_add_more_item......1");
                  Fluttertoast.showToast(
                      msg:
                      S.of(context).cant_add_more_item,//"Sorry, you can\'t add more of this item!",
                      fontSize: MediaQuery.of(context).textScaleFactor *13,
                      backgroundColor: Colors.black87,
                      textColor: Colors.white);
                }
              }else{
                debugPrint("sorry_outofstock.....1");
                Fluttertoast.showToast(
                    msg: S
                        .of(context)
                        .sorry_outofstock, //"Sorry, Out of Stock!",
                    fontSize: MediaQuery
                        .of(context)
                        .textScaleFactor * 13,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white);
              }
            }
            else {
              List<SellingItemsFields> list = [];
              item.forEach((element) {
                debugPrint("ggggg....22..." + element.itemId.toString() + "..." +
                    widget.searchstoredata!.id.toString() + ".." + element.quantity!);
                if (element.itemId == widget.searchstoredata!.id) {
                  //fetchItemData = Provider.of<ItemsList>(context, listen: false).fetchItems();
                  for (int i = 0; i <
                      widget.searchstoredata!.priceVariation!.length; i++) {
                    if (widget.searchstoredata!.priceVariation![i].id == element.varId) {
                      list.add(SellingItemsFields(weight: double.parse(
                          widget.searchstoredata!.priceVariation![i].weight!),
                          varQty: int.parse(element.quantity.toString())));
                    }
                  }
                }
              });
              print("increment to : ${widget.priceVariationSearch!.minItem}....${widget
                  .priceVariationSearch!.maxItem}");
              print("increment to : ${widget.priceVariationSearch!.quantity}....${widget
                  .priceVariationSearch!.stock}");
              if (Features.btobModule ? Check().isOutofStock(
                  maxstock:  double.parse(widget.priceVariationSearch!.stock.toString()),
                  stocktype:  widget.searchstoredata!.type!,
                  qty: (productBox.where((element) => element.itemId == widget.searchstoredata!.id).length > 1)?quantityTotal.toString() :qty.toString(),
                  itemData: [],searchvariation: widget.priceVariationSearch!,screen: "search_screen")
                  : Check().isOutofStock(
                maxstock: double.parse(widget.priceVariationSearch!.stock.toString()),
                stocktype: widget.searchstoredata!.type!,
                qty: (productBox.where((element) => element.itemId == widget.searchstoredata!.id).length > 1)?quantityTotal.toString() :qty.toString(),
                itemData: list,searchvariation: widget.priceVariationSearch!,)) {
                debugPrint("sorry_outofstock.....2");
                Fluttertoast.showToast(
                    msg: S
                        .of(context)
                        .sorry_outofstock,
                    //"Sorry, Out of Stock!",
                    fontSize: MediaQuery
                        .of(context)
                        .textScaleFactor * 13,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white);
              } else {
                if ((productBox.where((element) => element.itemId == widget.searchstoredata!.id).length > 1 ?quantityTotal:qty) < double.parse(widget.priceVariationSearch!.maxItem!)) {
                  cartcontroller.update((done) {
                    print("done value in calling update " + done.toString());
                    setState(() {
                      loading = !done;
                      print("value of loading in update cart increment case: " +
                          loading.toString());
                    });
                  }, price: widget.priceVariationSearch!.price.toString(),
                      quantity: (qty + 1).toString(),
                      type: widget.searchstoredata!.type,
                      weight: "1",
                      var_id: varid,
                      increament: widget.searchstoredata!.increament,
                      cart_id: parent_id,
                      toppings: toppings,
                      topping_id: toppings_id
                  );
                } else {
                  debugPrint("cant_add_more_item......2");
                  Fluttertoast.showToast(
                      msg:
                      S
                          .of(context)
                          .cant_add_more_item,
                      //"Sorry, you can\'t add more of this item!",
                      fontSize: MediaQuery
                          .of(context)
                          .textScaleFactor * 13,
                      backgroundColor: Colors.black87,
                      textColor: Colors.white);
                }
              }
            }
          }
          else {
            if (widget.itemdata!.type == "1") {
              debugPrint("wight stock..."+weight.toString()+"..."+widget.itemdata!.stock.toString());
              if ((productBox.where((element) => element.itemId == widget.itemdata!.id).length > 1 ?weightTotal: double.parse(weight.toString())) <
                  double.parse(widget.itemdata!.stock.toString())) {
                if (double.parse(weight.toString()) <
                    (double.parse(widget.itemdata!.maxItem!) *
                        double.parse(widget.itemdata!.increament!))) {
                  cartcontroller.update((done) {
                    print("done value in calling update " + done.toString());
                    setState(() {
                      loading = !done;
                      print("value of loading in update cart increment case: " +
                          loading.toString());
                    });
                  }, price: widget.itemdata!.price.toString(),
                      quantity: qty.toString(),
                      type: widget.itemdata!.type,
                      weight: (weight +
                          double.parse(widget.itemdata!.increament!)).toString(),
                      var_id: varid,
                      increament: widget.itemdata!.increament,
                      cart_id: parent_id,
                      toppings: toppings,
                      topping_id: toppings_id

                  );
                } else {
                  debugPrint("cant_add_more_item......3");
                  Fluttertoast.showToast(
                      msg:
                      S
                          .of(context)
                          .cant_add_more_item,
                      //"Sorry, you can\'t add more of this item!",
                      fontSize: MediaQuery
                          .of(context)
                          .textScaleFactor * 13,
                      backgroundColor: Colors.black87,
                      textColor: Colors.white);
                }
              } else {
                debugPrint("sorry_outofstock.....3");
                Fluttertoast.showToast(
                    msg: S
                        .of(context)
                        .sorry_outofstock, //"Sorry, Out of Stock!",
                    fontSize: MediaQuery
                        .of(context)
                        .textScaleFactor * 13,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white);
              }
            }
            else {
              List<SellingItemsFields> list = [];
              item.forEach((element) {
                debugPrint("ggggg....22..." + element.itemId.toString() + "..." +
                    widget.itemdata!.id.toString() + ".." + element.quantity!);
                if (element.itemId == widget.itemdata!.id) {
                  //fetchItemData = Provider.of<ItemsList>(context, listen: false).fetchItems();
                  for (int i = 0; i <
                      widget.itemdata!.priceVariation!.length; i++) {
                    if (widget.itemdata!.priceVariation![i].id == element.varId) {
                      list.add(SellingItemsFields(weight: double.parse(
                          widget.itemdata!.priceVariation![i].weight!),
                          varQty: int.parse(element.quantity.toString())));
                    }
                  }
                }
              });
              print("increment to : ${widget.priceVariation!.minItem}....${widget
                  .priceVariation!.maxItem}");
              print("increment to : ${widget.priceVariation!.quantity}....${widget
                  .priceVariation!.stock}");
              if (Features.btobModule ? Check().isOutofStock(
                  maxstock: double.parse(widget.priceVariation!.stock.toString()),
                  stocktype:  widget.itemdata!.type!,
                  qty: (productBox.where((element) => element.itemId == widget.itemdata!.id).length > 1)?quantityTotal.toString() :qty.toString(),
                  itemData: [],
                  variation: widget.priceVariation!)
                  : Check().isOutofStock(
                maxstock: double.parse(widget.priceVariation!.stock.toString()),
                stocktype: widget.itemdata!.type!,
                qty: (productBox.where((element) => element.itemId == widget.itemdata!.id).length > 1)?quantityTotal.toString() :qty.toString(),
                itemData: list, variation: widget.priceVariation!,
              )) {
                debugPrint("sorry_outofstock.....4");
                Fluttertoast.showToast(
                    msg: S
                        .of(context)
                        .sorry_outofstock,
                    //"Sorry, Out of Stock!",
                    fontSize: MediaQuery
                        .of(context)
                        .textScaleFactor * 13,
                    backgroundColor: Colors.black87,
                    textColor: Colors.white);
              } else {
                debugPrint("qty...."+quantityTotal.toString());
                if ((productBox.where((element) => element.itemId == widget.itemdata!.id).length > 1 ?quantityTotal:qty) < double.parse(widget.priceVariation!.maxItem!))
                {
                  cartcontroller.update((done) {
                    print("done value in calling update " + done.toString());
                    setState(() {
                      loading = !done;
                      print("value of loading in update cart increment case: " +
                          loading.toString());
                    });
                  }, price: widget.priceVariation!.price.toString(),
                      quantity: (qty + 1).toString(),
                      type: widget.itemdata!.type,
                      weight: "1",
                      var_id: varid,
                      increament: widget.itemdata!.increament,
                      cart_id: parent_id,
                      toppings: toppings,
                      topping_id: toppings_id
                  );
                }
                else {
                  debugPrint("cant_add_more_item......4");
                  Fluttertoast.showToast(
                      msg:
                      S
                          .of(context)
                          .cant_add_more_item,
                      //"Sorry, you can\'t add more of this item!",
                      fontSize: MediaQuery
                          .of(context)
                          .textScaleFactor * 13,
                      backgroundColor: Colors.black87,
                      textColor: Colors.white);
                }
              }
            }
          }
          // TODO: Handle this case.
          break;
        case CartStatus.remove:
          cartcontroller.update((done){
            setState(() {
              loading = !done;
              print("value of loading in remove cart remove case: "+loading.toString());
            });
          },price: widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.type=="1"?widget.searchstoredata!.price.toString():widget.searchstoredata!.price.toString():
          widget.itemdata!.type=="1"?widget.itemdata!.price.toString():widget.priceVariationSearch!.price.toString(),
              quantity:"0",weight:"0",var_id: widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.type=="1"?widget.searchstoredata!.id!:varid:widget.itemdata!.type=="1"?widget.itemdata!.id!:varid,
              type: widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.type:widget.itemdata!.type,
              increament:widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.increament: widget.itemdata!.increament,cart_id: parent_id,toppings: toppings,
              topping_id: toppings_id);
          // TODO: Handle this case.
          break;
        case CartStatus.decrement:
          print("addddddd,,,,,"+weight.toString()+"...."+(double.parse(widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.minItem!:widget.itemdata!.minItem!)*double.parse(widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.increament!:widget.itemdata!.increament!)).toString());
          cartcontroller.update((done){
            setState(() {
              loading = !done;
              print("value of loading in decrement cart decrement case: "+loading.toString());
            });
          },price: widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.type=="1"?widget.searchstoredata!.price.toString():widget.priceVariationSearch!.price.toString():widget.itemdata!.type=="1"?widget.itemdata!.price.toString():widget.priceVariation!.price.toString(),
              quantity:widget.from == "search_screen" && Features.ismultivendor?
              widget.searchstoredata!.type=="1"?((weight)<= (double.parse(widget.searchstoredata!.minItem!)*double.parse(widget.searchstoredata!.increament!)))?"0":(qty).toString():((qty)<= int.parse(widget.priceVariationSearch!.minItem!))?"0":(qty-1).toString():
              widget.itemdata!.type=="1"?((weight)<= (double.parse(widget.itemdata!.minItem!)*double.parse(widget.itemdata!.increament!)))?"0":(qty).toString():((qty)<= int.parse(widget.priceVariation!.minItem!))?"0":(qty-1).toString(),
              weight:widget.from == "search_screen" && Features.ismultivendor?
              widget.searchstoredata!.type=="1"? ((weight)<= (double.parse(widget.searchstoredata!.minItem!)*double.parse(widget.searchstoredata!.increament!)))?"0":(weight-double.parse(widget.searchstoredata!.increament!)).toString():"0"
                  :widget.itemdata!.type=="1"? ((weight)<= (double.parse(widget.itemdata!.minItem!)*double.parse(widget.itemdata!.increament!)))?"0":(weight-double.parse(widget.itemdata!.increament!)).toString():"0",
              var_id: widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.type=="1"?widget.searchstoredata!.id!:varid:widget.itemdata!.type=="1"?widget.itemdata!.id!:varid,
              type: widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.type:widget.itemdata!.type,
              increament: widget.from == "search_screen" && Features.ismultivendor?widget.searchstoredata!.increament:widget.itemdata!.increament,
              cart_id: parent_id,
              toppings: toppings,
              topping_id: toppings_id
          );
          // TODO: Handle this case.
          break;
      }
    }

    addToCart(String topping_type, String varid, String toppings, String? parent_id, String? newproduct,List addToppings ) async {
      debugPrint("add to cart......"+toppings);
      if(widget.from == "search_screen" && Features.ismultivendor) {
        if (widget.searchstoredata!.type == "1") {

          debugPrint("add to cart......type 1");
          cartcontroller.addtoCart( storeSearchData: widget.searchstoredata!,
              onload: (isloading) {
                setState(() {
                  debugPrint("add to cart......1");
                  loading = isloading;
                  //onload(isloading);
                  //onload(true);
                  // Toppingloading = true;
                  print("value of loading in add cart fn " + loading.toString());
                });
              },topping_type: topping_type,varid: varid,toppings: toppings,parent_id: parent_id!,newproduct: newproduct!,toppingsList: addToppings,fromScreen: "search_screen",context: context);
          if(Features.isfacebookappevent)
            FaceBookAppEvents.facebookAppEvents.logAddToCart(id: int.parse(widget.searchstoredata!.id!).toString(), type: widget.searchstoredata!.itemName!, currency: IConstants.currencyFormat, price: widget.searchstoredata!.type=="1"?double.parse(widget.searchstoredata!.price.toString()):double.parse(widget.priceVariationSearch!.price.toString()));

          //onload(false);
        }
        else {
          debugPrint("add to cart......type 2");
          cartcontroller.addtoCart(storeSearchData: widget.searchstoredata!, onload: (isloading) {
            setState(() {
              debugPrint("add to cart......1");
              loading = isloading;
              //onload(true);
              //onload(isloading);
              print("value of loading in add cart fn " + loading.toString());
            });
          },topping_type: topping_type,varid: varid,toppings: toppings,parent_id: parent_id!,newproduct: newproduct!, toppingsList: addToppings,itembodysearch: widget.priceVariationSearch!,fromScreen: "search_screen",context: context);
          //onload(false);
        }
      }
      else{
        if (widget.itemdata!.type == "1") {

          debugPrint("add to cart......type 1");
          cartcontroller.addtoCart(itemdata: widget.itemdata!, onload: (isloading) {
            setState(() {
              debugPrint("add to cart......1");
              loading = isloading;
              //onload(isloading);
              //onload(true);
              // Toppingloading = true;
              print("value of loading in add cart fn " + loading.toString());
            });
          },topping_type: topping_type,varid: varid,toppings: toppings,parent_id: parent_id!,newproduct: newproduct!,toppingsList: addToppings,context: context);
          //onload(false);
        }
        else {
          debugPrint("add to cart......type 2");
          cartcontroller.addtoCart(itemdata: widget.itemdata!, onload: (isloading) {
            setState(() {
              debugPrint("add to cart......1");
              loading = isloading;
              //onload(true);
              //onload(isloading);
              print("value of loading in add cart fn " + loading.toString());
            });
          },topping_type: topping_type,varid: varid,toppings: toppings,parent_id: parent_id!,newproduct: newproduct!,toppingsList: addToppings, itembody: widget.priceVariation!,context: context);
          //onload(false);
        }
        if(Features.isfacebookappevent)
          FaceBookAppEvents.facebookAppEvents.logAddToCart(id: int.parse(widget.itemdata!.id!).toString(), type: widget.itemdata!.itemName!, currency: IConstants.currencyFormat, price: widget.itemdata!.type=="1"?double.parse(widget.itemdata!.price.toString()):double.parse(widget.priceVariation!.price.toString()));
      }




    }

    toppingsExistance(varid, productid, List checktoppings, List addToppings, ) async {
      List<SellingItemsFields> list = [];
      if(widget.itemdata!.type != "1") {
        item.forEach((element) {
          debugPrint("ggggg....22..." + element.itemId.toString() + "..." +
              widget.itemdata!.id.toString() + ".." + element.quantity!);
          if (element.itemId == widget.itemdata!.id) {
            //fetchItemData = Provider.of<ItemsList>(context, listen: false).fetchItems();
            for (int i = 0; i <
                widget.itemdata!.priceVariation!.length; i++) {
              if (widget.itemdata!.priceVariation![i].id == element.varId) {
                list.add(SellingItemsFields(weight: double.parse(
                    widget.itemdata!.priceVariation![i].weight!),
                    varQty: int.parse(element.quantity.toString())));
              }
            }
            debugPrint("list...."+list.toString());
          }
        });
      }

      debugPrint("varid...product...checktoppings..."+varid.toString()+"...."+productid.toString()+"....."+checktoppings.toString());
      Map<String, String> resBody = {};
      resBody["id"] = (!PrefUtils.prefs!.containsKey("apikey")) ? PrefUtils.prefs!.getString("tokenid")! : PrefUtils.prefs!.getString('apikey')!;
      resBody["product"] = productid;
      resBody["variation"] = varid;
      if(checktoppings.length > 0) {
        for (int i = 0; i < checktoppings.length; i++) {
          resBody["toppings[" + i.toString() + "][id]"] =
          checktoppings[i]["id"];

        }
      }else{
        resBody["toppings[" "][id]"] = "[]";
      }
      debugPrint("resBody....viewToppingsExistingDetails...."+resBody.toString());
      var url = Api.viewToppingsExistingDetails ;
      final response = await http.post(url, body: resBody
      );

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      debugPrint("responseJson....viewToppingsExistingDetails...."+responseJson.toString());
      debugPrint("quantityTotal....viewToppingsExistingDetails...."+quantityTotal.toString());
      debugPrint("weightTotal....viewToppingsExistingDetails...."+weightTotal.toString());
      if((widget.itemdata!.type == "1")?
      (weightTotal < double.parse(widget.itemdata!.stock.toString()))
          :
      !( Check().isOutofStock(
        maxstock: double.parse(widget.priceVariation!.stock.toString()),
        stocktype: widget.itemdata!.type!,
        qty:  getTotalQty().toString(),//quantityTotal.toString() ,
        itemData: list,
        variation: widget.priceVariation!,
      ))) {
        debugPrint("isOutofStock...");
        if ((widget.itemdata!.type == "1") ? (weightTotal <
            (double.parse(widget.itemdata!.maxItem!) *
                double.parse(widget.itemdata!.increament!))) : (quantityTotal <
            double.parse(widget.priceVariation!.maxItem!))) {
          if (responseJson['status'].toString() == "400") {
            debugPrint("update.....");
            final box = (VxState.store as GroceStore).CartItemList;
            String elementParentId = '';
            if (addToppings.isEmpty) {
              bool isItemExist = false;
              for(int i = 0; i < box.length; i++){
                if((box[i].id == widget.itemdata!.id ||(box[i].varId == widget.priceVariation?.id))){
                     isItemExist = true;
                     elementParentId = (box[i].parent_id)!;
                     break;
                }
              }

              if(isItemExist){
                updateCart(
                    widget.itemdata!.type == "1" ? int.parse(box
                        .where((element) =>
                    element.itemId == widget.itemdata!.id &&
                        element.parent_id! == responseJson['parent_id'].toString())
                        .first
                        .quantity!) : //getTotalQty(),
                     int.parse(box
                    .where((element) =>
                element.varId ==
                    widget.priceVariation!.id // && element.parent_id! == responseJson['parent_id'].toString()
                    )
                    .first
                    .quantity!),
                    widget.itemdata!.type == "1" ? double.parse(box
                        .where((element) =>
                    element.itemId == widget.itemdata!.id)
                        .first
                        .weight!) : double.parse(box
                        .where((element) =>
                    element.varId == widget.priceVariation!.id)
                        .first
                        .weight!),
                    CartStatus.increment,
                    widget.itemdata!.type == "1" ? widget.itemdata!.id! : widget
                        .priceVariation!.id!,
                    elementParentId,
                    "0",
                    "");

              }else{
                //add to cart
                debugPrint("add.....");
                await addToCart(
                  addToppingsProduct[0]["Toppings_type"],
                  addToppingsProduct[0]["varId"],
                  addToppingsProduct[0]["toppings"],
                  "",
                  addToppingsProduct[0]["newproduct"],
                  addToppings,
                );
                debugPrint("add toppings data...." + addToppings.toString());
              }

            } else {
              await addToCart(
                  addToppingsProduct[0]["Toppings_type"],
                  addToppingsProduct[0]["varId"],
                  addToppingsProduct[0]["toppings"],
                  "",
                  addToppingsProduct[0]["newproduct"],
                  addToppings
              );
            }
          }
          else if (responseJson['status'].toString() == "200") {
            //update cart
            final box = (VxState.store as GroceStore).CartItemList;
            (widget.from == "search_screen" && Features.ismultivendor) ?
            updateCart(
                widget.searchstoredata!.type == "1" ? int.parse(box
                    .where((element) =>
                element.itemId == widget.searchstoredata!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .quantity!) : getTotalQty(),
                /*int.parse(box
                    .where((element) =>
                element.varId ==
                    widget.priceVariationSearch!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .quantity!),*/
                widget.searchstoredata!.type == "1" ? double.parse(box
                    .where((element) =>
                element.itemId == widget.searchstoredata!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .weight!) : double.parse(box
                    .where((element) =>
                element.itemId == widget.searchstoredata!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .weight!),
                CartStatus.increment,
                widget.searchstoredata!.type == "1"
                    ? widget.searchstoredata!.id!
                    : widget.priceVariationSearch!.id!,
                widget.itemdata!.type! =="1" ?
                box.where((element) => element.itemId == widget.itemdata!.id).first.parent_id!
                    : box.where((element) => element.varId == widget.priceVariation!.id).first.parent_id!,
                "0",
                "") :
            updateCart(
                widget.itemdata!.type == "1" ? int.parse(box
                    .where((element) =>
                element.itemId == widget.itemdata!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .quantity!) : getTotalQty(),
               /* int.parse(box
                    .where((element) =>
                element.varId ==
                    widget.priceVariation!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .quantity!),*/
                widget.itemdata!.type == "1" ? double.parse(box
                    .where((element) =>
                element.itemId == widget.itemdata!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .weight!) : double.parse(box
                    .where((element) =>
                element.itemId == widget.itemdata!.id &&
                    element.parent_id! == responseJson['parent_id'].toString())
                    .first
                    .weight!),
                CartStatus.increment,
                widget.itemdata!.type == "1" ? widget.itemdata!.id! : widget
                    .priceVariation!.id!,
                responseJson['parent_id'].toString(),
                "0",
                "");
          }
          else {
            Fluttertoast.showToast(
              msg: "Something went wrong",
              fontSize: MediaQuery
                  .of(context)
                  .textScaleFactor * 13,
              backgroundColor: ColorCodes.blackColor,
              textColor: ColorCodes.whiteColor,);
          }
        }
        else {
          Fluttertoast.showToast(
              msg:
              S
                  .of(context)
                  .cant_add_more_item,
              //"Sorry, you can\'t add more of this item!",
              fontSize: MediaQuery
                  .of(context)
                  .textScaleFactor * 13,
              backgroundColor: Colors.black87,
              textColor: Colors.white);
        }
      }else{
        Fluttertoast.showToast(
            msg:
            S
                .of(context)
                .sorry_outofstock,
            fontSize: MediaQuery
                .of(context)
                .textScaleFactor * 13,
            backgroundColor: Colors.black87,
            textColor: Colors.white);
      }

    }

    Widget _myRadioButton({ String? title,  int? value,  Function(int?)? onChanged}) {
      return RadioListTile<int>(
        controlAffinity: ListTileControlAffinity.trailing,
        value: value!,
        groupValue: _groupValue,
        onChanged: onChanged!,
        title: Text(title!),
      );
    }

    dialogforToppings(BuildContext context){
      List addToppings = [];
      List checktoppings = [];
      List checktoppings1 =[];
      return
        showModalBottomSheet<dynamic>(
            isScrollControlled: true,
            shape:RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            context: context,
            builder: ( context) {
              return WillPopScope(
                onWillPop: (){
                  return Future.value(true);
                },
                child: Wrap(
                    children: [
                      StatefulBuilder(builder: (context, setState1)
                      {
                        return Container(
                          decoration: BoxDecoration(
                              color: Color(0xFFF0F4F8),
                              borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(25.0),
                                  topRight: const Radius.circular(25.0))),
                          padding: EdgeInsets.only(left: 20, right: 20),
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 25,),
                                Text(
                                  (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.itemName!:widget.itemdata!.itemName!, style: TextStyle(fontSize: 18,
                                  color: ColorCodes.blackColor,
                                ),
                                ),
                                const SizedBox(height: 3,),
                                Text(
                                  "Customize as per your taste", style: TextStyle(fontSize: 18,
                                    color: ColorCodes.blackColor,
                                    fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),
                                Divider(
                                  thickness: 1, color: ColorCodes.lightgrey, height: 1,),
                                const SizedBox(height: 10),
                                Text( S .of(context).choose_variant,
                                    style: TextStyle(fontSize: 16,
                                      color: ColorCodes.blackColor,)),
                                const SizedBox( height: 10),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor :IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight:  Radius.circular(10))),
                                  child:
                                  ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                     // scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: (fromscreen == "search_item_multivendor" && Features.ismultivendor)?searchdata!.priceVariation!.length:widget.itemdata!.priceVariation!.length,
                                      itemBuilder: (_, i) {
                                        double discount = (fromscreen == "search_item_multivendor" && Features.ismultivendor)?
                                        widget.ismember!?searchdata!.priceVariation![i].membershipDisplay!?double.parse((searchdata!.priceVariation![i].membershipPrice!).toString()):double.parse(searchdata!.priceVariation![i].price!):double.parse(searchdata!.priceVariation![i].price!)
                                            :  widget.ismember!?widget.itemdata!.priceVariation![i].membershipDisplay!?double.parse(widget.itemdata!.priceVariation![i].membershipPrice!):double.parse(widget.itemdata!.priceVariation![i].price!):double.parse(widget.itemdata!.priceVariation![i].price!);
                                        debugPrint("discount...1"+discount.toString()+"  "+  widget.ismember.toString());

                                        final variationName = (fromscreen == "search_item_multivendor" && Features.ismultivendor)?searchdata!.priceVariation![i].variationName!:  widget.itemdata!.priceVariation![i].variationName!;
                                        final mrp = (fromscreen == "search_item_multivendor" && Features.ismultivendor)?double.parse(searchdata!.priceVariation![i].mrp!):double.parse(  widget.itemdata!.priceVariation![i].mrp!);
                                        //final discount = discount;
                                        final unit = (fromscreen == "search_item_multivendor" && Features.ismultivendor)?searchdata!.priceVariation![i].unit!:  widget.itemdata!.priceVariation![i].unit!;
                                        //final color = selectedindex==i? ColorCodes.mediumBlueColor: ColorCodes.blackColor;
                                        return GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: (){
                                            setState1((){
                                              selectedindex = i;
                                            });
                                            widget.onselect!(i);
                                          },
                                         /* child: VariationListItem(variationName: (fromscreen == "search_item_multivendor" && Features.ismultivendor)?searchdata!.priceVariation![i].variationName!:  widget.itemdata!.priceVariation![i].variationName!, mrp: (fromscreen == "search_item_multivendor" && Features.ismultivendor)?double.parse(searchdata!.priceVariation![i].mrp!):double.parse(  widget.itemdata!.priceVariation![i].mrp!), discount: discount,
                                          unit: (fromscreen == "search_item_multivendor" && Features.ismultivendor)?searchdata!.priceVariation![i].unit!:  widget.itemdata!.priceVariation![i].unit!, color:selectedindex==i? ColorCodes.mediumBlueColor: ColorCodes.blackColor,
                                              ),*/
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                                              children: [
                                            Text(
                                              variationName,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: ColorCodes.blackColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Text(
                                                    unit + "" + (Features.iscurrencyformatalign
                                                      ? discount.toStringAsFixed(2) + IConstants.currencyFormat + " "
                                                      : IConstants.currencyFormat + discount.toStringAsFixed(2) + " "),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: ColorCodes.blackColor,
                                                      fontWeight: FontWeight.bold)),
                                                handler1(i)
                                              ],
                                            ),

                                            ],),
                                          ),
                                        );
                                      }),
                                ),
                                const SizedBox(height: 10),
                                (widget.addon != null)?
                                Text(
                                  "Add Ons (optional) ", style: TextStyle(fontSize: 16,
                                  color: ColorCodes.blackColor,
                                ),
                                ):const SizedBox.shrink(),
                                const SizedBox(height: 10),
                                (widget.addon != null)?(widget.addon!.type == "1")?
                                Column(
                                  children: [
                                    ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        //scrollDirection: Axis.vertical,
                                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                                        shrinkWrap: true,
                                        itemCount:widget.addon!.list!.length,
                                        itemBuilder: (_, i) {

                                          return

                                            Column(
                                              children: [
                                                GestureDetector(
                                                  onTap:(){
                                                    for(int j =0; j< widget.addon!.list!.length; j++){
                                                      if(i == j){
                                                        setState1((){
                                                          widget.addon!.list![j].isSelected = true;
                                                          varId = j;
                                                          addToppings.clear();
                                                          /* item1["\"toppings_id\""] = "\""+ widget.addon!.list![varId!].id!+"\"";
                                                          item1["\"toppings_name\""] = "\""+ widget.addon!.list![varId!].name!+"\"";
                                                          item1["\"toppings_price\""] = "\""+ widget.addon!.list![varId!].price!+"\"";
                                                         addToppings.add(item1);*/
                                                          addToppings.add({"Toppings_type":"1","toppings_id":  widget.addon!.list![varId!].id!,/*"toppings":"1", "parent_id":  productBox.last.parent_id!,newproduct":"0",*/ "toppings_name":widget.addon!.list![varId!].name,"toppings_price":widget.addon!.list![varId!].price});
                                                        });
                                                       }else{
                                                        setState1((){
                                                          widget.addon!.list![j].isSelected = false;
                                                        });

                                                      }
                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      //const SizedBox(width: 20,),
                                                      Text(
                                                        widget.addon!.list![i].name!+" - "+IConstants.currencyFormat + widget.addon!.list![i].price!,
                                                        style: TextStyle(color: (widget.addon!.list![i].isSelected == true) ?ColorCodes.greenColor:ColorCodes.blackColor,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                      const Spacer(),
                                                      handler(widget.addon!.list![i].isSelected),
                                                      //SizedBox(width: 20,),
                                                    ],
                                                  ),
                                                ),
                                                //SizedBox(height:20,)
                                              ],
                                            );
                                        }),
                                  //  SizedBox(height: 20,),
                                    Row(
                                      children: [
                                        Text(((widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.type == "1" : widget.itemdata!.type=="1")?(widget.from == "search_screen" && Features.ismultivendor)?IConstants.currencyFormat + widget.searchstoredata!.price.toString():IConstants.currencyFormat + widget.itemdata!.price.toString(): (widget.from == "search_screen" && Features.ismultivendor)?IConstants.currencyFormat+widget.priceVariationSearch!.price.toString():IConstants.currencyFormat + widget.priceVariation!.price.toString()
                                          , style: TextStyle(fontSize: 20,
                                              color: ColorCodes.blackColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 10,),
                                        (widget.from == "search_screen" && Features.ismultivendor)?Text((widget.searchstoredata!.type=="1")? (widget.searchstoredata!.mrp.toString() != widget.searchstoredata!.price.toString()) ?"MRP: "+IConstants.currencyFormat + widget.searchstoredata!.mrp.toString():"":(widget.searchstoredata!.mrp.toString() != widget.searchstoredata!.price.toString()) ? "MRP: "+IConstants.currencyFormat + widget.priceVariationSearch!.mrp.toString():"",
                                          style: TextStyle(fontSize: 14,
                                            color: ColorCodes.greyColor,
                                          ),
                                        ):
                                        Text((widget.itemdata!.type=="1")? (widget.itemdata!.mrp.toString() != widget.itemdata!.price.toString()) ?"MRP: "+IConstants.currencyFormat + widget.itemdata!.mrp.toString():"":(widget.itemdata!.mrp.toString() != widget.itemdata!.price.toString()) ? "MRP: "+IConstants.currencyFormat + widget.priceVariation!.mrp.toString():"",
                                          style: TextStyle(fontSize: 14,
                                            color: ColorCodes.greyColor,
                                          ),
                                        ),
                                        const Spacer(),
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () async {
                                            // if(toppingscheck == "yes") {
                                            debugPrint("varid toppings...."+varId.toString()+"..."+parentId.toString());
                                            // addToCart("1",varId!,"1",parentId,"0");
                                            // addToCart("1",widget.addon!.list![varId!].id!,"1",productBox.last.parent_id!,"0");
                                            if(addToppings.length > 0){
                                              checktoppings1.clear();
                                              for(int i =0; i< addToppings.length; i++){
                                                debugPrint("addToppings[i]...."+addToppings[i]["toppings_id"]);
                                                checktoppings1.add(addToppings[i]["toppings_id"]);
                                              }
                                              debugPrint("checktopping....1"+checktoppings1.toString());
                                            }

                                            if(checktoppings1.length > 1){
                                              checktoppings1.sort();
                                            }
                                            debugPrint("after sort checktopping...."+checktoppings1.toString());
                                            checktoppings.clear();
                                            for(int j =0; j< checktoppings1.length; j++){

                                              checktoppings.add({"id":checktoppings1[j]});
                                              debugPrint("checktopping...."+checktoppings.toString());
                                            }
                                            toppingsExistance((widget.itemdata!.type=="1")?addToppingsProduct[0]["productid"] :addToppingsProduct[0]["varId"],addToppingsProduct[0]["productid"],checktoppings,addToppings);

                                            /*for(int i = 0; i< addToppingsProduct.length; i++){
                                              if(addToppings.length > 0){
                                                for(int j = 0; j < addToppings.length; j++) {
                                                  await addToCart(
                                                      addToppingsProduct[i]["Toppings_type"],
                                                      addToppingsProduct[i]["varId"],
                                                      addToppingsProduct[i]["toppings"],
                                                      "",
                                                      addToppingsProduct[i]["newproduct"],
                                                      addToppings,

                                                  );
                                                }
                                              }else {
                                                await addToCart(
                                                    addToppingsProduct[i]["Toppings_type"],
                                                    addToppingsProduct[i]["varId"],
                                                    addToppingsProduct[i]["toppings"],
                                                    "",
                                                    addToppingsProduct[i]["newproduct"],
                                                    addToppings,

                                                );
                                              }
                                            }*/
                                            for (int i = 0; i <
                                                widget.addon!.list!.length; i++)
                                              widget.addon!.list![i].isSelected = false;
                                            Navigator.of(context).pop();

                                            /* }else{
                                      Fluttertoast.showToast(msg: "Please select any toppings" ,
                                          fontSize: MediaQuery.of(context).textScaleFactor *13,
                                          backgroundColor:
                                          Colors.black87,
                                          textColor: Colors.white);
                                    }*/
                                            //addToCart("", "", "0");
                                          },
                                          child: Container(
                                            width: 150,
                                            height: 45,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5.0),
                                              border: Border.all(
                                                  width: 1, color: ColorCodes.primaryColor),
                                            ),
                                            child: Center(
                                              child: Text("ADD ITEMS",style: TextStyle(fontSize: 16,
                                                  color: ColorCodes.primaryColor,
                                                  fontWeight: FontWeight.bold), ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 10,)
                                  ],
                                ):
                                Column(
                                  children: [

                                       Container(
                                        decoration: new BoxDecoration(
                                            color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor :IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
                                            borderRadius: new BorderRadius.only(
                                              topLeft: const Radius.circular(10),
                                              topRight:
                                              const Radius.circular(10),
                                              bottomLeft:
                                              const Radius.circular(10),
                                              bottomRight:
                                              const Radius.circular(10),
                                            )),
                                        child: ListView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                         //   scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            itemCount: widget.addon!.list!.length,
                                            itemBuilder: (_, i) {

                                              return GestureDetector(
                                                behavior: HitTestBehavior.translucent,
                                                onTap: (){

                                                },
                                                child: Container(
                                                  // padding: EdgeInsets.symmetric(horizontal: 10),
                                                  // margin: EdgeInsets.symmetric(vertical: 5),
                                                  width: MediaQuery.of(context).size.width,

                                                  child: Row(
                                                    children: [
                                                      const SizedBox(width:10),
                                                      Text( widget.addon!.list![i].name!, style: TextStyle(fontSize: 16,
                                                          color: ColorCodes.blackColor,
                                                          fontWeight: FontWeight.bold),),
                                                      const Spacer(),
                                                      Text(IConstants.currencyFormat + widget.addon!.list![i].price!,style: TextStyle(fontSize: 16,
                                                          color: ColorCodes.blackColor,
                                                          fontWeight: FontWeight.bold),),
                                                      const SizedBox(width:5),
                                                      Checkbox(
                                                        value: widget.addon!.list![i].isSelected,
                                                        checkColor: ColorCodes.whiteColor,
                                                        activeColor: ColorCodes.primaryColor1,
                                                        onChanged: (bool? val) {
                                                          setState1(() {
                                                            debugPrint("val..."+val.toString());
                                                            widget.addon!.list![i].isSelected = val!;

                                                          });
                                                          // addToppings.clear();
                                                          debugPrint("val..."+widget.addon!.list![i].isSelected.toString()+"......"+widget.index.toString()+"..."+i.toString());
                                                          //  debugPrint("parent id...."+productBox.last.parent_id.toString());

                                                          if (widget.addon!.list![i].isSelected == true) {
                                                            /*item1["\"toppings_id\""] = "\""+ widget.addon!.list![i].id!+"\"";
                                                              item1["\"toppings_name\""] = "\""+ widget.addon!.list![i].name!+"\"";
                                                              item1["\"toppings_price\""] = "\""+ widget.addon!.list![i].price!+"\"";
                                                              addToppings.add(item1);*/

                                                            addToppings.add({"Toppings_type": "0","toppings_id":  widget.addon!.list![i].id!,/*"toppings":"1", "parent_id":  "","newproduct":"0",*/"toppings_name":widget.addon!.list![i].name,"toppings_price":widget.addon!.list![i].price});
                                                            debugPrint("addToppings..."+addToppings.toString()+"...."+addToppings.length.toString());
                                                          }else{

                                                              addToppings.removeWhere((element) => element['toppings_id'] == widget.addon!.list![i].id);

                                                            debugPrint("addToppings...1"+addToppings.toString()+"...."+addToppings.length.toString());
                                                          }

                                                          if(widget.addon!.list![i].isSelected == true) {
                                                            toppingscheck = "yes";
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),

                                  ],
                                ):SizedBox.shrink(),

                                SizedBox(height: 20,),
                                Row(
                                  children: [
                                    (widget.from == "search_screen" && Features.ismultivendor)?
                                    Text((widget.searchstoredata!.type=="1")?IConstants.currencyFormat + widget.searchstoredata!.price.toString(): IConstants.currencyFormat + widget.priceVariationSearch!.price.toString()
                                      , style: TextStyle(fontSize: 20,
                                          color: ColorCodes.blackColor,
                                          fontWeight: FontWeight.bold),
                                    ):
                                    Text((widget.itemdata!.type=="1")?IConstants.currencyFormat + widget.itemdata!.price.toString(): IConstants.currencyFormat + widget.priceVariation!.price.toString()
                                      , style: TextStyle(fontSize: 20,
                                          color: ColorCodes.blackColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 10,),
                                    (widget.from == "search_screen" && Features.ismultivendor)?
                                    Text((widget.searchstoredata!.type=="1")? (widget.searchstoredata!.mrp.toString() != widget.searchstoredata!.price.toString()) ?"MRP: "+IConstants.currencyFormat + widget.searchstoredata!.mrp.toString():"":(widget.searchstoredata!.mrp.toString() != widget.searchstoredata!.price.toString()) ? "MRP: "+IConstants.currencyFormat + widget.priceVariationSearch!.mrp.toString():"",
                                      style: TextStyle(fontSize: 14,
                                        color: ColorCodes.greyColor,
                                      ),
                                    ):
                                    Text((widget.itemdata!.type=="1")? (widget.itemdata!.mrp.toString() != widget.itemdata!.price.toString()) ?"MRP: "+IConstants.currencyFormat + widget.itemdata!.mrp.toString():"":(widget.itemdata!.mrp.toString() != widget.itemdata!.price.toString()) ? "MRP: "+IConstants.currencyFormat + widget.priceVariation!.mrp.toString():"",
                                      style: TextStyle(fontSize: 14,
                                        color: ColorCodes.greyColor,
                                      ),
                                    ),
                                    Spacer(),
                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () async {
                                        debugPrint("addToppingsProduct...."+addToppingsProduct.length.toString()+"  "+addToppings.length.toString());
                                        bool _isProductAdded = false;

                                        if(addToppings.length > 0){
                                          checktoppings.clear();
                                          for(int i =0; i< addToppings.length; i++){
                                            debugPrint("addToppings[i]...."+addToppings[i]["toppings_id"]);
                                            checktoppings.add({"id":addToppings[i]["toppings_id"]});
                                            debugPrint("checktopping...."+checktoppings.toString());
                                          }

                                        }

                                        toppingsExistance((widget.itemdata!.type=="1")?addToppingsProduct[0]["productid"] :addToppingsProduct[0]["varId"],addToppingsProduct[0]["productid"],checktoppings,addToppings);

                                        debugPrint("loading....after product add.."+Toppingloading.toString());
                                        if( widget.addon != null) {
                                          for (int i = 0; i < widget.addon!.list!.length; i++) {
                                            widget.addon!.list![i].isSelected = false;
                                          }
                                        }

                                        Navigator.of(context).pop();

                                      },
                                      child: Container(
                                        width: 150,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color:ColorCodes.blackColor,
                                          borderRadius: BorderRadius.circular(5.0),
                                          border: Border.all(
                                              width: 1, color: ColorCodes.blackColor),
                                        ),
                                        child: Center(
                                          child: Text("Add items to cart",style: TextStyle(fontSize: 16,
                                              color: ColorCodes.whiteColor,
                                              fontWeight: FontWeight.bold), ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 10,)

                              ],
                            ),
                          ),
                        );
                      }),]),
              );
            }
        );
    }

    dialogforUpdateToppings(BuildContext context) async {
      (widget.from == "search_screen" && Features.ismultivendor)?
      MyorderList().GetRepeateToppings((widget.searchstoredata!.type == "1")?
      widget.searchstoredata!.id!:
      widget.priceVariationSearch!.id!,
          widget.searchstoredata!.id!).then((value) {
        print("topupstate"+value!.length.toString());
        topupState(() {
          _futureNonavailable = Future.value(value);

        });
        _futureNonavailable.then((value) {
          parentidforupdate = value.first.parent_id!;
          print("value.." + value.first.data!.first.name.toString()+"  "+parentidforupdate.toString());
        });

      }):
      MyorderList().GetRepeateToppings((widget.itemdata!.type == "1")?
      widget.itemdata!.id!:
      widget.itemdata!.id!,
          widget.itemdata!.id!).then((value) {
        print("topupstate"+value!.length.toString());
        topupState(() {
          _futureNonavailable = Future.value(value);

        });
        if(value.length !=null) {
          _futureNonavailable.then((value) {
            parentidforupdate = value.first.parent_id!;
            print("value.." + value.first.data!.first.name.toString() + "  " +
                parentidforupdate.toString());
          });
        }

      });

      return
        showModalBottomSheet(
            shape:const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            context: context,
            builder: ( context) {
              return Wrap(
                  children: [
                    StatefulBuilder(builder: (context, setState1)
                    {
                      topupState = setState1;
                      return Container(
                        decoration: new BoxDecoration(
                            color: Colors.white,
                            borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(25.0),
                                topRight: const Radius.circular(25.0))),
                        padding: EdgeInsets.only(left: 20, right: 20),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10,),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 40,
                              /*decoration: BoxDecoration(
                                color: ColorCodes.secondaryColor,
                              ),*/
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    (widget.from == "search_screen" && Features.ismultivendor)?"   "+widget.searchstoredata!.itemName!: "   "+ widget.itemdata!.itemName!, style: TextStyle(fontSize: 20,
                                      color: ColorCodes.blackColor,
                                      fontWeight: FontWeight.bold),
                                  ),
                                  /*SizedBox(height: 3,),
                                  Text(
                                   "   "+ IConstants.currencyFormat + widget.itemdata!.price!+"-"+IConstants.currencyFormat + widget.itemdata!.mrp!
                                    , style: TextStyle(fontSize: 12,
                                      color: ColorCodes.blackColor,
                                      fontWeight: FontWeight.bold),
                                  ),*/
                                ],
                              ),
                            ),
                            SizedBox(height: 10,),
                            Divider(
                              thickness: 1, color: ColorCodes.greyColor, height: 1,),
                            SizedBox(height: 10,),
                            Text(
                              "Your Previous customization", style: TextStyle(fontSize: 18,
                                color: ColorCodes.blackColor,
                                fontWeight: FontWeight.w400),
                            ),
                            SizedBox(height: 5,),
                            FutureBuilder<List<RepeatToppings>>(
                              future: _futureNonavailable,
                              builder: (BuildContext context,AsyncSnapshot<List<RepeatToppings>> snapshot){
                                final RepeatToppings = snapshot.data;
                                // if(promoData!.length > 0)
                                if (RepeatToppings!=null)
                                  return
                                    ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        // scrollDirection: Axis.horizontal,
                                        itemCount: RepeatToppings.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Text(RepeatToppings[index].data![index].name!);
                                        });
                                else
                                  return SizedBox.shrink();

                              },
                            ),
                            SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: (){
                                    Navigator.of(context).pop();
                                    //addToCart("", "", "0",/*productBox[widget.index].parent_id*/"","1");
                                    addToppingsProduct.clear();
                                    addToppingsProduct.add({"Toppings_type":"","varId":  (widget.itemdata!.type! =="1")?"":widget.priceVariation!.id!,"toppings":"0", "parent_id":  "","newproduct":"1","productid":widget.itemdata!.id}); //adding product
                                    debugPrint("add Toppings product..."+addToppingsProduct.toString());
                                    dialogforToppings(context);
                                    //addToCart("", "", "0");
                                  },
                                  child: Container(
                                    width: 150,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                          width: 1, color: ColorCodes.primaryColor1)//ColorCodes.primaryColor),
                                    ),
                                    child: Center(
                                      child: Text("I'LL CHOOSE",style: TextStyle(fontSize: 16,
                                          color: ColorCodes.primaryColor1,//ColorCodes.primaryColor,
                                          fontWeight: FontWeight.bold), ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: ()   {
                                    final box = (VxState.store as GroceStore).CartItemList;

                                    Navigator.of(context).pop();
                                    (widget.from == "search_screen" && Features.ismultivendor)?
                                    updateCart(
                                        widget.searchstoredata!.type == "1"? int.parse(box
                                            .where((element) =>
                                        element.itemId == widget.searchstoredata!.id && element.parent_id! == parentidforupdate.toString())
                                            .first
                                            .quantity! ):
                                        int.parse(box
                                            .where((element) =>
                                        element.varId ==
                                            widget.priceVariationSearch!.id && element.parent_id! == parentidforupdate.toString())
                                            .first
                                            .quantity!),
                                        widget.searchstoredata!.type == "1"?  double.parse(box
                                            .where((element) =>
                                        element.itemId == widget.searchstoredata!.id && element.parent_id! == parentidforupdate.toString())
                                            .first
                                            .weight!): double.parse(box
                                            .where((element) =>
                                        element.itemId == widget.searchstoredata!.id && element.parent_id! == parentidforupdate.toString())
                                            .first
                                            .weight!),
                                        CartStatus.increment,
                                        widget.searchstoredata!.type == "1"? widget.searchstoredata!.id!:widget.priceVariationSearch!.id!,
                                        parentidforupdate.toString(),
                                        "0",
                                        ""):
                                    updateCart(
                                         widget.itemdata!.type == "1"? int.parse(box
                                            .where((element) =>
                                        element.itemId == widget.itemdata!.id && element.parent_id! == parentidforupdate.toString())
                                            .first
                                            .quantity!):getTotalQty(),
                                        /*int.parse(box
                                            .where((element) =>
                                        element.varId ==
                                            widget.priceVariation!.id && element.parent_id! == parentidforupdate.toString())
                                            .first
                                            .quantity!),*/
                                        widget.itemdata!.type == "1"?  double.parse(box
                                            .where((element) =>
                                        element.itemId == widget.itemdata!.id && element.parent_id! == parentidforupdate.toString())
                                            .first
                                            .weight!): double.parse(box
                                            .where((element) =>
                                        element.itemId == widget.itemdata!.id && element.parent_id! == parentidforupdate.toString())
                                            .first
                                            .weight!),
                                        CartStatus.increment,
                                        widget.itemdata!.type == "1"? widget.itemdata!.id!:widget.itemdata!.id!,
                                        parentidforupdate.toString(),
                                        "0",
                                        "");
                                    // toppingsExistance(addToppingsProduct[0]["varId"],addToppingsProduct[0]["productid"],checktoppings,addToppings);

                                  },
                                  child: Container(
                                    width: 150,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                          width: 1, color: ColorCodes.primaryColor1),
                                    ),
                                    child: Center(
                                      child: Text("REPEAT",style: TextStyle(fontSize: 16,
                                          color: ColorCodes.primaryColor1,
                                          fontWeight: FontWeight.bold), ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 10,)
                          ],
                        ),
                      );
                    }),]);
            }
        );
    }

    dialogforDeleteToppings(BuildContext context) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0)),
            child: Container(
              height: 150,
              padding: EdgeInsets.only(left: 10),
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Center(child:

                  Text("Remove item from cart", style: TextStyle(fontSize: 20),)
                  ),
                  SizedBox(height: 10,),
                  Text("This item has multiple customization added, Proceed to cart to remove item?",style: TextStyle(fontSize: 14),),
                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).pop();
                          Navigation(context, name: Routename.Cart, navigatore: NavigatoreTyp.Push,qparms: {"afterlogin":null});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: ColorCodes.primaryColor),
                          ),
                          width: 60,
                          height: 30,
                          child: Center(
                            child: Text(
                              S.of(context).yes,style: TextStyle(color: ColorCodes.primaryColor), //'yes'
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 60,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: ColorCodes.primaryColor),
                          ),
                          child: Center(
                            child: Text(
                              S.of(context).no,style: TextStyle(color: ColorCodes.primaryColor), //'no'
                            ),
                          ),
                        ),
                      )

                    ],
                  )
                ],
              ),
            ),

          );
        },
      );
    }


    _notifyMe() async {
      setState(() {
        _isNotify = true;
      });
      //_notifyMe();
      debugPrint("resposne........1");
      int resposne = await Provider.of<BrandItemsList>(context, listen: false).notifyMe((widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.id.toString():widget.itemdata!.id.toString(),(widget.from == "search_screen" && Features.ismultivendor)?widget.priceVariationSearch!.id.toString():widget.priceVariation!.id.toString(),(widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.type!:widget.itemdata!.type!);
      debugPrint("resposne........"+resposne.toString());
      if(resposne == 200) {
        setState(() {
          _isNotify = false;
        });
        //_isWeb?_Toast("You will be notified via SMS/Push notification, when the product is available"):
        Fluttertoast.showToast(msg: S .of(context).you_will_notify,//"You will be notified via SMS/Push notification, when the product is available" ,
            fontSize: MediaQuery.of(context).textScaleFactor *13,
            backgroundColor:
            Colors.black87,
            textColor: Colors.white);

      } else {
        Fluttertoast.showToast(msg: S .of(context).something_went_wrong,//"Something went wrong" ,
            fontSize: MediaQuery.of(context).textScaleFactor *13,
            backgroundColor:
            Colors.black87,
            textColor: Colors.white);
        setState(() {
          _isNotify = false;
        });
      }
    }

    return widget.from == "search_screen" && Features.ismultivendor?
    widget.searchstoredata!.type == "1" ? VxBuilder(
        mutations: {SetCartItem},
        // valueListenable: Hive.box<Product>(productBoxName).listenable(),
        builder: (context, store, index) {
          final box = (VxState.store as GroceStore).CartItemList;
          // if(loading){
          //   print("inside loading");
          //   stepperButtons.clear();
          //stepperButtons.add(Loading(context));
          // stepperButtons.add(Expanded(
          //     flex: 1,
          //     child: SizedBox.shrink())) ;
          // }else{
          stepperButtons.clear();
          if (widget.searchstoredata!.stock! <= 0){
            if(widget.issubscription == "Add")  stepperButtons.add(NotificationStepper(
                context, alignmnt: widget.alignmnt,
                fontsize: widget.fontSize,
                onTap: () {

                  if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                    LoginWeb(context,result: (sucsess){
                      if(sucsess){
                        Navigator.of(context).pop();
                        Navigation(context, navigatore: NavigatoreTyp.homenav);
                        /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                      }else{
                        Navigator.of(context).pop();
                      }
                    });
                  }
                  else{
                    if (!PrefUtils.prefs!.containsKey("apikey")) {
                      Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                    }
                    else {
                      _notifyMe();
                    }
                  }
                }, isnotify: _isNotify));
          }
          else{
            if(widget.alignmnt == StepperAlignment.Vertical) {
              if(widget.issubscription == "Subscribe")  stepperButtons.add(AddSubsciptionStepper(
                  context, search: widget.searchstoredata!,
                  alignmnt: widget.alignmnt,
                  fontsize: widget.fontSize,
                  from_screen: "search_screen",
                  onTap: () {

                    if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    }
                    else{
                      if (!PrefUtils.prefs!.containsKey("apikey")) {
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                      }
                      else {
                        Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "itemid": widget.searchstoredata!.id,
                              "itemname": widget.searchstoredata!.itemName,
                              "itemimg": widget.searchstoredata!.itemFeaturedImage,
                              "itemtype":widget.searchstoredata!.type,
                              "varname": /*widget.itemdata!.priceVariation![0].variationName !+ widget.itemdata!.priceVariation![0].unit!*/widget.searchstoredata!.itemName,
                              "varmrp":widget.searchstoredata!.mrp.toString(),
                              "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.searchstoredata!.membershipPrice.toString()
                                  :widget.searchstoredata!.discointDisplay! ?widget.searchstoredata!.price.toString()
                                  :widget.searchstoredata!.mrp.toString(),
                              "paymentMode": widget.searchstoredata!.paymentMode,
                              "cronTime": widget.searchstoredata!.subscriptionSlot![0].cronTime,
                              "name": widget.searchstoredata!.subscriptionSlot![0].name,
                              "varid":widget.searchstoredata!.id,
                              "brand": widget.searchstoredata!.brand,
                              "deliveriesarray": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                              "daily":(widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                              "dailyDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                              "weekend": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                              "weekendDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                              "weekday": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                              "weekdayDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                              "custom": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                              "customDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,

                            });
                      }
                    }


                  }));
              if(widget.issubscription == "Add") {
                if (box
                    .where((element) => element.itemId == widget.searchstoredata!.id && element.type == widget.searchstoredata!.type)
                    .length <= 0 || double.parse(box
                    .where((element) => element.itemId == widget.searchstoredata!.id)
                    .first
                    .weight!) <= 0){
                  stepperButtons.add(AddItemSteppr(
                      context, fontSize: widget.fontSize,
                      alignmnt: widget.alignmnt,
                      onTap: () {
                          // addToCart("", "", "0","","0");
                          addToppingsProduct.clear();
                          addToppingsProduct.add({
                            "Toppings_type": "",
                            "varId":  (widget.itemdata!.type! =="1")?"":widget.priceVariation!.id!,
                            "toppings": "0",
                            "parent_id": "",
                            "newproduct": "0",
                            "productid":widget.itemdata!.id
                          });
                          debugPrint("add Toppings product..." +
                              addToppingsProduct.toString());
                          dialogforToppings(context);

                        // addToCart();
                      },
                      isloading: loading));}
                else {
                  int quantity = 0;
                  double weight = 0.0;
                  //  if(box.where((element) => element.itemId == widget.itemdata!.id).count() >= 1){
                  for (int i = 0; i < box.length; i++) {
                    if (box[i].itemId == widget.searchstoredata!.id &&
                        box[i].toppings == "0") {
                      quantity = quantity + int.parse(box[i].quantity!);
                      weight = weight + double.parse(box[i].weight!);
                    }
                  }

                  stepperButtons.add(
                      UpdateItemSteppr(context,
                          quantity: (box.where((element) => element.itemId ==
                              widget.searchstoredata!.id && element.toppings == "0")
                              .count() > 1) ?
                          quantity
                              : (widget.addon != null) ? (box
                              .where((element) =>
                          element.itemId == widget.searchstoredata!.id)
                              .length * int.parse(box
                              .where((element) =>
                          element.itemId == widget.searchstoredata!.id)
                              .first
                              .quantity!)) : int.parse(box
                              .where((element) =>
                          element.itemId == widget.searchstoredata!.id)
                              .first
                              .quantity!),
                          weight: (box.where((element) =>
                          element.itemId == widget.searchstoredata!.id &&
                              element.toppings == "0")
                              .count() > 1) ?
                          weight
                              : (widget.addon != null) ?
                          /*double.parse((box.where((element) => element.itemId == widget.itemdata!.id).map((e) => e.weight).count() *  double.parse(box
                            .where((element) =>
                        element.itemId == widget.itemdata!.id)
                            .first
                            .weight!)).toString())*/totalWeight()
                              : double.parse(box
                              .where((element) =>
                          element.itemId == widget.searchstoredata!.id)
                              .first
                              .weight!),
                          fontSize: widget.fontSize,
                          skutype: box
                              .where((element) =>
                          element.itemId == widget.searchstoredata!.id)
                              .first
                              .type!,
                          unit: widget.searchstoredata!.unit ?? "kg",
                          onTap: (cartStatus) {
                            if (cartStatus == CartStatus.increment) {


                                dialogforUpdateToppings(context);

                            } else {
                              if(box.where((element) => element.itemId == widget.searchstoredata!.id).length > 1 ){
                                dialogforDeleteToppings(context);
                              }else {
                                updateCart(
                                  int.parse(box
                                      .where((element) =>
                                  element.itemId == widget.searchstoredata!.id)
                                      .first
                                      .quantity!),
                                  double.parse(box
                                      .where((element) =>
                                  element.itemId == widget.searchstoredata!.id)
                                      .first
                                      .weight!),
                                  cartStatus,
                                  widget.searchstoredata!.id!,
                                  widget.itemdata!.type! =="1" ?
                                  box.where((element) => element.itemId == widget.itemdata!.id).first.parent_id!
                                      : box.where((element) => element.varId == widget.priceVariation!.id).first.parent_id!,

                                  "0",
                                  "",);
                              }
                            }
                          },
                          alignmnt: widget.alignmnt,
                          isloading: loading));
                }
              }

            }
            else {
              if (box
                  .where((element) => element.itemId == widget.searchstoredata!.id && element.type == widget.searchstoredata!.type )
                  .length <= 0 || int.parse(box
                  .where((element) => element.itemId == widget.searchstoredata!.id)
                  .first
                  .quantity!) <= 0)
                stepperButtons.add(AddItemSteppr(
                    context, fontSize: widget.fontSize,
                    alignmnt: widget.alignmnt,
                    onTap: () {
                      //addToCart();

                        //addToCart("", "", "0", "", "0");
                        addToppingsProduct.clear();
                        addToppingsProduct.add({"Toppings_type":"","varId":   (widget.itemdata!.type! =="1")?"":widget.priceVariation!.id!,"toppings":"0", "parent_id":  "","newproduct":"0","productid":widget.itemdata!.id});
                        debugPrint("add Toppings product..."+addToppingsProduct.toString());
                        dialogforToppings(context);

                    },
                    isloading: loading));
              else
              {
                debugPrint("gh....2.."+(box.where((element) => element.itemId == widget.searchstoredata!.id).count().toString()));
                int quantity = 0;
                double weight = 0.0;
                if(box.where((element) => element.itemId == widget.searchstoredata!.id).count() >= 1){
                  for( int i = 0;i < box.length ;i++){
                    if(box[i].itemId == widget.searchstoredata!.id && box[i].toppings =="0"){
                      debugPrint("true...1");
                      /* quantity = quantity +  int.parse(box
                            .where((element) =>
                        element.itemId == widget.itemdata!.id)
                            .first
                            .quantity!);*/
                      quantity = quantity + int.parse(box[i].quantity!);
                      weight = weight + double.parse(box[i].weight!);
                    }

                  }
                }
                debugPrint("weight....2.."+weight.toString());

                stepperButtons.add(
                    UpdateItemSteppr(context, quantity: (box.where((element) => element.itemId == widget.searchstoredata!.id && element.toppings == "0").count() > 1
                    )?
                    quantity
                        :(widget.addon != null)?(box.where((element) => element.itemId == widget.searchstoredata!.id).length * int.parse(box
                        .where((element) =>
                    element.itemId == widget.searchstoredata!.id)
                        .first
                        .quantity!)):int.parse(box
                        .where((element) =>
                    element.itemId == widget.searchstoredata!.id)
                        .first
                        .quantity!),

                        weight: (box.where((element) => element.itemId == widget.searchstoredata!.id && element.toppings == "0").count() >= 1
                            /* && box.where((element) => element.itemId == widget.itemdata!.id).last.toppings! =="0"*/)?
                        weight
                            : (widget.addon != null)?/*double.parse((box.where((element) => element.itemId == widget.itemdata!.id).count()
                                * double.parse(box
                                .where((element) =>
                            element.itemId == widget.itemdata!.id)
                                .first
                                .weight!)).toString())*/totalWeight():
                        double.parse(box
                            .where((element) =>
                        element.itemId == widget.searchstoredata!.id)
                            .first
                            .weight!)/*weight*/,

                        fontSize: widget.fontSize,
                        skutype: box
                            .where((element) =>
                        element.itemId == widget.searchstoredata!.id)
                            .first
                            .type!,
                        unit: widget.searchstoredata!.unit!,
                        onTap: (cartStatus) {
                          if (cartStatus == CartStatus.increment) {

                              dialogforUpdateToppings(context);
                          } else {
                            if(box.where((element) => element.itemId == widget.searchstoredata!.id).length > 1 ){
                              dialogforDeleteToppings(context);
                            }else {
                              updateCart(
                                int.parse(box
                                    .where((element) =>
                                element.itemId == widget.searchstoredata!.id)
                                    .first
                                    .quantity!),
                                double.parse(box
                                    .where((element) =>
                                element.itemId == widget.searchstoredata!.id)
                                    .first
                                    .weight!),
                                cartStatus,
                                widget.searchstoredata!.id!,
                                widget.itemdata!.type! =="1" ?
                                box.where((element) => element.itemId == widget.itemdata!.id).first.parent_id!
                                    : box.where((element) => element.varId == widget.priceVariation!.id).first.parent_id!,

                                "0",
                                "",);
                            }
                          }
                        },
                        alignmnt: widget.alignmnt,
                        isloading: loading));
              }


              stepperButtons.add(AddSubsciptionStepper(
                  context, search: widget.searchstoredata!,
                  alignmnt: widget.alignmnt,
                  fontsize: widget.fontSize,
                  onTap: () {
                    if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    }
                    else{
                      if (!PrefUtils.prefs!.containsKey("apikey")) {
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                      }
                      else {
                        /*      Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "itemid": widget.itemdata!.id,
                              "itemname": widget.itemdata!.itemName,
                              "itemimg": widget.itemdata!.itemFeaturedImage,
                              "varname": widget.itemdata!.priceVariation![0].variationName !+ widget.itemdata!.priceVariation![0].unit!,
                              "varmrp":widget.itemdata!.priceVariation![0].mrp.toString(),
                              "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.priceVariation![0].membershipPrice.toString()
                                  :widget.itemdata!.priceVariation![0].discointDisplay! ?widget.itemdata!.priceVariation![0].price.toString()
                                  :widget.itemdata!.priceVariation![0].mrp.toString(),
                              "paymentMode": widget.itemdata!.paymentMode,
                              "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                              "name": widget.itemdata!.subscriptionSlot![0].name,
                              "varid":widget.itemdata!.priceVariation![0].id,
                              "brand": widget.itemdata!.brand
                            });*/
                      }
                    }


                  }));
            }

          }
          //}
          print("height"+widget.height.toString());
          return widget.alignmnt == StepperAlignment.Vertical
              ? SizedBox(
            //height: widget.priceVariation!.stock!<=0?33:widget.height,
              height: widget.height,
              width: widget.width,
              child:Column(
                children: stepperButtons,
              ))
              : Container(
              height: widget.height,
              width: widget.width,
              child:
              Row(
                children: stepperButtons,

              ));
        })
        :
    VxBuilder(
        mutations: {SetCartItem},
        // valueListenable: Hive.box<Product>(productBoxName).listenable(),
        builder: (context, store, index) {
          final box = (VxState.store as GroceStore).CartItemList;
          // if(loading){
          //   print("inside loading");
          //   stepperButtons.clear();
          //stepperButtons.add(Loading(context));
          // stepperButtons.add(Expanded(
          //     flex: 1,
          //     child: SizedBox.shrink())) ;
          // }else{
          stepperButtons.clear();
          if (widget.priceVariationSearch!.stock! <= 0){
            if(widget.issubscription == "Add")  stepperButtons.add(NotificationStepper(
                context, alignmnt: widget.alignmnt,
                fontsize: widget.fontSize,
                onTap: () {

                  if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                    LoginWeb(context,result: (sucsess){
                      if(sucsess){
                        Navigator.of(context).pop();
                        Navigation(context, navigatore: NavigatoreTyp.homenav);
                        /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                      }else{
                        Navigator.of(context).pop();
                      }
                    });
                  }
                  else{
                    if (!PrefUtils.prefs!.containsKey("apikey")) {
                      Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                    }
                    else {
                      _notifyMe();
                    }
                  }
                }, isnotify: _isNotify));
          }
          else{
            if(widget.alignmnt == StepperAlignment.Vertical) {
              if(widget.issubscription == "Subscribe") stepperButtons.add(AddSubsciptionStepper(
                  context, search: widget.searchstoredata!,
                  alignmnt: widget.alignmnt,
                  fontsize: widget.fontSize,
                  from_screen: "search_screen",
                  onTap: () {

                    if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    }
                    else{
                      if (!PrefUtils.prefs!.containsKey("apikey")) {
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                      }
                      else {
                        Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "itemid": widget.searchstoredata!.id,
                              "itemname": widget.searchstoredata!.itemName,
                              "itemimg": widget.searchstoredata!.itemFeaturedImage,
                              "itemtype":widget.searchstoredata!.type,
                              "varname": widget.searchstoredata!.priceVariation![0].variationName !+ widget.searchstoredata!.priceVariation![0].unit!,
                              "varmrp":widget.searchstoredata!.priceVariation![0].mrp.toString(),
                              "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.searchstoredata!.priceVariation![0].membershipPrice.toString()
                                  :widget.searchstoredata!.priceVariation![0].discointDisplay! ?widget.searchstoredata!.priceVariation![0].price.toString()
                                  :widget.searchstoredata!.priceVariation![0].mrp.toString(),
                              "paymentMode": widget.searchstoredata!.paymentMode,
                              "cronTime": widget.searchstoredata!.subscriptionSlot![0].cronTime,
                              "name": widget.searchstoredata!.subscriptionSlot![0].name,
                              "varid":widget.searchstoredata!.priceVariation![0].id,
                              "brand": widget.searchstoredata!.brand,
                              "deliveriesarray": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                              "daily":(widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                              "dailyDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                              "weekend": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                              "weekendDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                              "weekday": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                              "weekdayDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                              "custom": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                              "customDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,

                            });
                      }
                    }


                  }));
              if(widget.issubscription == "Add") {
                if (box
                    .where((element) =>
                element.varId == widget.priceVariationSearch!.id)
                    .length <= 0 || int.parse(box
                    .where((element) =>
                element.varId == widget.priceVariationSearch!.id).first
                    .quantity!) <= 0){
                  stepperButtons.add(AddItemSteppr(
                      context, fontSize: widget.fontSize,
                      alignmnt: widget.alignmnt,
                      onTap: () {
                        //  addToCart();

                          //addToCart("", "", "0","","0");
                          addToppingsProduct.clear();
                          addToppingsProduct.add({
                            "Toppings_type": "",
                            "varId":  (widget.searchstoredata!.type! =="1")?"":widget.priceVariationSearch!.id!,
                            "toppings": "0",
                            "parent_id": "",
                            "newproduct": "0",
                            "productid":widget.searchstoredata!.id
                          });
                          debugPrint("add Toppings product..." +
                              addToppingsProduct.toString());
                          dialogforToppings(context);

                      },
                      isloading: loading));}
                else {
                  debugPrint("gh....3.." +
                      (box.where((element) => element.varId ==
                          widget.priceVariationSearch!.id)
                          .count()
                          .toString()));
                  int quantity = 0;
                  double weight = 0.0;

                  for (int i = 0; i < box.length; i++) {
                    debugPrint("sss....");
                    if (box[i].varId == widget.priceVariationSearch!.id &&
                        box[i].toppings == "0") {
                      debugPrint("true...1");

                      quantity = quantity + int.parse(box[i].quantity!);
                      weight = weight + double.parse(box[i].weight!);
                    }
                  }

                  stepperButtons.add(
                      UpdateItemSteppr(context,
                          quantity: (box.where((element) => element.varId ==
                              widget.priceVariationSearch!.id &&
                              element.toppings == "1")).count() >= 1 ?
                          quantity
                              : (widget.addon != null) ? /*(box.where((element) => element.varId == widget.priceVariation!.id).length * int.parse(box
                          .where((element) =>
                      element.varId == widget.priceVariation!.id)
                          .first
                          .quantity!))*/totalquantity()
                              : int.parse(box
                              .where((element) =>
                          element.varId == widget.priceVariationSearch!.id)
                              .first
                              .quantity!),
                          weight: ((box.where((element) =>
                          element.itemId == widget.searchstoredata!.id &&
                              element.toppings == "0")
                              .count()) > 1
                              /*&& box.where((element) => element.itemId == widget.itemdata!.id).last.toppings! =="0"*/)
                              ?
                          weight
                              : (widget.addon != null) ? double.parse(
                              (box.where((element) =>
                              element.itemId == widget.searchstoredata!.id).count() *
                                  double.parse(box
                                      .where((element) =>
                                  element.itemId == widget.searchstoredata!.id)
                                      .first
                                      .weight!)).toString()) : double.parse(
                              box
                                  .where((element) =>
                              element.itemId == widget.searchstoredata!.id)
                                  .first
                                  .weight!),
                          fontSize: widget.fontSize,
                          skutype: box
                              .where((element) =>
                          element.varId == widget.priceVariationSearch!.id)
                              .first
                              .type!,
                          unit: widget.priceVariationSearch!.unit!,
                          onTap: (cartStatus) {
                            if (cartStatus == CartStatus.increment) {
                                dialogforUpdateToppings(context);
                            } else {
                              if(box.where((element) => element.itemId == widget.searchstoredata!.id).length > 1 ){
                                dialogforDeleteToppings(context);
                              }else {
                                updateCart(
                                  int.parse(box
                                      .where((element) =>
                                  element.varId ==
                                      widget.priceVariationSearch!.id)
                                      .first
                                      .quantity!),
                                  double.parse(box
                                      .where((element) =>
                                  element.itemId == widget.searchstoredata!.id)
                                      .first
                                      .weight!),
                                  cartStatus,
                                  widget.priceVariationSearch!.id!,
                                  widget.itemdata!.type! =="1" ?
                                  box.where((element) => element.itemId == widget.itemdata!.id).first.parent_id!
                                      : box.where((element) => element.varId == widget.priceVariation!.id).first.parent_id!,

                                  "0",
                                  "",);
                              }
                            }
                          },
                          alignmnt: widget.alignmnt,
                          isloading: loading));
                }
              }
            }
            else{
              if (box.where((element) => element.varId == widget.priceVariationSearch!.id).length <= 0 || int.parse(box.where((element) => element.varId == widget.priceVariationSearch!.id).first.quantity!) <= 0)
              { stepperButtons.add(AddItemSteppr(
                  context, fontSize: widget.fontSize,alignmnt: widget.alignmnt,onTap: () {
                // addToCart();

                  // addToCart("", "", "0","","0");
                  addToppingsProduct.clear();
                  addToppingsProduct.add({"Toppings_type":"","varId":   (widget.searchstoredata!.type! =="1")?"":widget.priceVariationSearch!.id!,"toppings":"0", "parent_id":  "","newproduct":"0","productid":widget.itemdata!.id});
                  debugPrint("add Toppings product..."+addToppingsProduct.toString());
                  dialogforToppings(context);

              },isloading: loading));}
              else {
                debugPrint("gh....4.."+(box.where((element) => element.varId == widget.priceVariationSearch!.id).count().toString()));
                int quantity = 0;
                double weight = 0.0;

                for( int i = 0;i < box.length ;i++){
                  if(box[i].varId == widget.priceVariationSearch!.id && box[i].toppings =="0") {
                    debugPrint("true...1");

                    quantity = quantity + int.parse(box[i].quantity!);
                    weight = weight + double.parse(box
                        .where((element) =>
                    element.itemId == widget.priceVariationSearch!.id)
                        .first
                        .weight!);
                  }

                }

                stepperButtons.add(
                    UpdateItemSteppr(context, quantity:  (box.where((element) =>  element.varId == widget.priceVariationSearch!.id && element.toppings == "1")).count() >= 1?
                    quantity
                        :(widget.addon != null)?/*(box.where((element) => element.varId == widget.priceVariation!.id).length * int.parse(box
                          .where((element) =>
                      element.varId == widget.priceVariation!.id)
                          .first
                          .quantity!))*/totalquantity():int.parse(box
                        .where((element) =>
                    element.varId == widget.priceVariationSearch!.id)
                        .first
                        .quantity!),
                        weight: (box.where((element) => element.itemId == widget.searchstoredata!.id && element.toppings == "0").count()> 1
                            /*&& box.where((element) => element.itemId == widget.itemdata!.id).last.toppings! =="0"*/) ?
                        weight
                            :(widget.addon != null)?double.parse((box.where((element) => element.itemId == widget.searchstoredata!.id).count() *  double.parse(box
                            .where((element) =>
                        element.itemId == widget.searchstoredata!.id)
                            .first
                            .weight!)).toString()): double.parse(box
                            .where((element) =>
                        element.itemId == widget.searchstoredata!.id)
                            .first
                            .weight!),
                        fontSize: widget.fontSize,
                        skutype: box
                            .where((element) =>
                        element.varId == widget.priceVariationSearch!.id)
                            .first
                            .type!,
                        unit: widget.priceVariationSearch!.unit!,
                        onTap: (cartStatus) {
                          if (cartStatus == CartStatus.increment) {
                              dialogforUpdateToppings(context);
                          } else {
                            if(box.where((element) => element.itemId == widget.searchstoredata!.id).length > 1 ){
                              dialogforDeleteToppings(context);
                            }else {
                              updateCart(
                                int.parse(box
                                    .where((element) =>
                                element.varId ==
                                    widget.priceVariationSearch!.id)
                                    .first
                                    .quantity!),
                                double.parse(box
                                    .where((element) =>
                                element.itemId == widget.searchstoredata!.id)
                                    .first
                                    .weight!),
                                cartStatus,
                                widget.priceVariationSearch!.id!,
                                widget.itemdata!.type! =="1" ?
                                box.where((element) => element.itemId == widget.itemdata!.id).first.parent_id!
                                    : box.where((element) => element.varId == widget.priceVariation!.id).first.parent_id!,

                                "0",
                                "",);
                            }
                          }
                        },
                        alignmnt: widget.alignmnt,
                        isloading: loading));
              }

              stepperButtons.add(AddSubsciptionStepper(
                  context, search: widget.searchstoredata!,
                  alignmnt: widget.alignmnt,
                  fontsize: widget.fontSize,
                  from_screen: "search_screen",
                  onTap: () {
                    if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    }
                    else{
                      if (!PrefUtils.prefs!.containsKey("apikey")) {
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                      }
                      else {
                        Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "itemid": widget.searchstoredata!.id,
                              "itemname": widget.searchstoredata!.itemName,
                              "itemimg": widget.searchstoredata!.itemFeaturedImage,
                              "itemtype":widget.searchstoredata!.type,
                              "varname": widget.searchstoredata!.priceVariation![0].variationName !+ widget.searchstoredata!.priceVariation![0].unit!,
                              "varmrp":widget.searchstoredata!.priceVariation![0].mrp.toString(),
                              "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.searchstoredata!.priceVariation![0].membershipPrice.toString()
                                  :widget.searchstoredata!.priceVariation![0].discointDisplay! ?widget.searchstoredata!.priceVariation![0].price.toString()
                                  :widget.searchstoredata!.priceVariation![0].mrp.toString(),
                              "paymentMode": widget.searchstoredata!.paymentMode,
                              "cronTime": widget.searchstoredata!.subscriptionSlot![0].cronTime,
                              "name": widget.searchstoredata!.subscriptionSlot![0].name,
                              "varid":widget.searchstoredata!.priceVariation![0].id,
                              "brand": widget.searchstoredata!.brand,
                              "deliveriesarray": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                              "daily":(widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                              "dailyDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                              "weekend": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                              "weekendDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                              "weekday": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                              "weekdayDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                              "custom": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                              "customDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,
                            });
                      }
                    }


                  }));
            }

          }
          //}
          print("height"+widget.height.toString());
          return widget.alignmnt == StepperAlignment.Vertical
              ? SizedBox(
            //height: widget.priceVariation!.stock!<=0?33:widget.height,
              height: widget.height,
              width: widget.width,
              child:Column(
                children: stepperButtons,
              ))
              : Container(
              height: widget.height,
              width: widget.width,
              child:
              Row(
                children: stepperButtons,

              ));
        })
        :
    widget.itemdata!.type == "1" ? VxBuilder(
        mutations: {SetCartItem},
        // valueListenable: Hive.box<Product>(productBoxName).listenable(),
        builder: (context, store, index) {
          final box = (VxState.store as GroceStore).CartItemList;
          // if(loading){
          //   print("inside loading");
          //   stepperButtons.clear();
          //stepperButtons.add(Loading(context));
          // stepperButtons.add(Expanded(
          //     flex: 1,
          //     child: SizedBox.shrink())) ;
          // }else{
          stepperButtons.clear();
          if (widget.itemdata!.stock! <= 0){
            if(widget.issubscription == "Add")  stepperButtons.add(NotificationStepper(
                context, alignmnt: widget.alignmnt,
                fontsize: widget.fontSize,
                onTap: () {

                  if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                    LoginWeb(context,result: (sucsess){
                      if(sucsess){
                        Navigator.of(context).pop();
                        Navigation(context, navigatore: NavigatoreTyp.homenav);
                        /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                      }else{
                        Navigator.of(context).pop();
                      }
                    });
                  }
                  else{
                    if (!PrefUtils.prefs!.containsKey("apikey")) {
                      Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                    }
                    else {
                      _notifyMe();
                    }
                  }
                }, isnotify: _isNotify));
          }
          else{
            print("ellide..." + widget.issubscription.toString() + "...." + widget.itemdata!.itemName!);
            if(widget.alignmnt == StepperAlignment.Vertical) {
              if(widget.issubscription == "Subscribe")  stepperButtons.add(AddSubsciptionStepper(
                  context, itemdata: widget.itemdata!,
                  alignmnt: widget.alignmnt,
                  fontsize: widget.fontSize,
                  onTap: () {

                    if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    }
                    else{
                      if (!PrefUtils.prefs!.containsKey("apikey")) {
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                      }
                      else {
                        Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "itemid": widget.itemdata!.id,
                              "itemname": widget.itemdata!.itemName,
                              "itemimg": widget.itemdata!.itemFeaturedImage,
                              "itemtype":widget.itemdata!.type,
                              "varname": /*widget.itemdata!.priceVariation![0].variationName !+ widget.itemdata!.priceVariation![0].unit!*/widget.itemdata!.itemName,
                              "varmrp":widget.itemdata!.mrp.toString(),
                              "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.membershipPrice.toString()
                                  :widget.itemdata!.discointDisplay! ?widget.itemdata!.price.toString()
                                  :widget.itemdata!.mrp.toString(),
                              "paymentMode": widget.itemdata!.paymentMode,
                              "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                              "name": widget.itemdata!.subscriptionSlot![0].name,
                              "varid":widget.itemdata!.id,
                              "brand": widget.itemdata!.brand,
                              "deliveriesarray": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                              "daily":(widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                              "dailyDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                              "weekend": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                              "weekendDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                              "weekday": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                              "weekdayDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                              "custom": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                              "customDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,

                            });
                      }
                    }


                  }));
              if(widget.issubscription == "Add") {

                if (box.where((element) => element.itemId == widget.itemdata!.id && element.type == widget.itemdata!.type).length <= 0 ||
                    double.parse(box.where((element) => element.itemId == widget.itemdata!.id).first.weight!) <= 0)
                  stepperButtons.add(AddItemSteppr(
                      context, fontSize: widget.fontSize,
                      alignmnt: widget.alignmnt,
                      onTap: () {

                          // addToCart("", "", "0","","0");
                          addToppingsProduct.clear();
                          addToppingsProduct.add({
                            "Toppings_type": "",
                            "varId":  (widget.itemdata!.type! =="1")?"":widget.priceVariation!.id!,
                            "toppings": "0",
                            "parent_id": "",
                            "newproduct": "0",
                            "productid":widget.itemdata!.id
                          });
                          debugPrint("add Toppings product..." +
                              addToppingsProduct.toString());
                          dialogforToppings(context);

                        // addToCart();
                      },
                      isloading: loading));
                else {
                  debugPrint("gh....1.." +
                      (box.where((element) => element.itemId ==
                          widget.itemdata!.id).count().toString()));

                  int quantity = 0;
                  double weight = 0.0;
                  //  if(box.where((element) => element.itemId == widget.itemdata!.id).count() >= 1){
                  for (int i = 0; i < box.length; i++) {
                    debugPrint("ttttt....." + box[i].itemId! + "  " +
                        widget.itemdata!.id! + "  " + box[i].toppings! + "   " +
                        box.length.toString());
                    if (box[i].itemId == widget.itemdata!.id &&
                        box[i].toppings == "0") {
                      debugPrint("true...1" + quantity.toString() + "..." +
                          box[i].quantity!.toString());

                      quantity = quantity + int.parse(box[i].quantity!);
                      weight = weight + double.parse(box[i].weight!);
                    }
                  }

                  if(VxState.store.userData.membership! == "1"){
                    widget.checkmembership = true;
                  } else {
                    widget.checkmembership = false;
                    for (int i = 0; i < productBox.length; i++) {
                      if (productBox[i].mode == "1") {
                        widget.checkmembership = true;
                      }
                    }
                  }
                  debugPrint("C......" + weight.toString() + "   " +
                      (box.where((element) => element.itemId ==
                          widget.itemdata!.id && element.toppings == "0")
                          .count()
                          .toString()) + "..." +
                      (box.where((element) => element.itemId ==
                          widget.itemdata!.id).map((e) =>
                      e.quantity).count().toString()));

                  stepperButtons.add(
                      UpdateItemSteppr(context,
                          quantity: (box.where((element) => element.itemId ==
                              widget.itemdata!.id && element.toppings == "0")
                              .count() > 1) ?
                          quantity
                              : (widget.addon != null) ? (box
                              .where((element) =>
                          element.itemId == widget.itemdata!.id)
                              .length * int.parse(box
                              .where((element) =>
                          element.itemId == widget.itemdata!.id)
                              .first
                              .quantity!)) : int.parse(box
                              .where((element) =>
                          element.itemId == widget.itemdata!.id)
                              .first
                              .quantity!),


                          weight: (box.where((element) =>
                          element.itemId == widget.itemdata!.id &&
                              element.toppings == "1")
                              .count() >= 1) ?
                          weight
                              : (widget.addon != null) ?
                          totalWeight()
                              : double.parse(box
                              .where((element) =>
                          element.itemId == widget.itemdata!.id)
                              .first
                              .weight!),
                          fontSize: widget.fontSize,
                          skutype: box
                              .where((element) =>
                          element.itemId == widget.itemdata!.id)
                              .first
                              .type!,
                          unit: widget.itemdata!.unit ?? "kg",
                          maxItem: widget.itemdata!.maxItem,
                          minItem: widget.itemdata!.minItem,
                          count: widget.itemdata!.increament,
                          price: widget.checkmembership!?widget.itemdata!.membershipDisplay!?double.parse(widget.itemdata!.membershipPrice!):double.parse(widget.itemdata!.price!):double.parse(widget.itemdata!.price!),
                          varid: widget.itemdata!.id,
                          incvalue: widget.itemdata!.increament,
                          Cart_id: box.last.parent_id,

                          onTap: (cartStatus) {
                            if (cartStatus == CartStatus.increment) {

                                dialogforUpdateToppings(context);

                            } else {
                              if(box.where((element) => element.itemId == widget.itemdata!.id).length > 1 ){
                                dialogforDeleteToppings(context);
                              }else {
                                updateCart(
                                  int.parse(box
                                      .where((element) =>
                                  element.itemId == widget.itemdata!.id)
                                      .first
                                      .quantity!),

                                  double.parse(box
                                      .where((element) =>
                                  element.itemId == widget.itemdata!.id)
                                      .first
                                      .weight!),

                                  cartStatus,
                                  widget.itemdata!.id!,
                                  widget.itemdata!.type! =="1" ?
                                  box.where((element) => element.itemId == widget.itemdata!.id).first.parent_id!
                                      : box.where((element) => element.varId == widget.priceVariation!.id).first.parent_id!,

                                  "0",
                                  "",);
                              }
                            }
                          },
                          alignmnt: widget.alignmnt,
                          isloading: loading));
                }
              }

            }
            else {
              if (box
                  .where((element) => element.itemId == widget.itemdata!.id && element.type == widget.itemdata!.type)
                  .length <= 0 || int.parse(box
                  .where((element) => element.itemId == widget.itemdata!.id)
                  .first
                  .quantity!) <= 0) {
                stepperButtons.add(AddItemSteppr(
                    context, fontSize: widget.fontSize,
                    alignmnt: widget.alignmnt,
                    onTap: () {
                      //addToCart();

                        addToppingsProduct.clear();
                        addToppingsProduct.add(
                            {
                              "Toppings_type": "",
                              "varId": (widget.itemdata!.type! == "1")
                                  ? ""
                                  : widget.priceVariation!.id!,
                              "toppings": "0",
                              "parent_id": "",
                              "newproduct": "0",
                              "productid": widget.itemdata!.id
                            });
                        debugPrint("add Toppings product..." +
                            addToppingsProduct.toString());
                        dialogforToppings(context);

                    },
                    isloading: loading));
              }
              else
              {
                debugPrint("d......");
                int quantity = 0;
                double weight = 0.0;
                if(box.where((element) => element.itemId == widget.itemdata!.id).count() >= 1){
                  for( int i = 0;i < box.length ;i++){
                    if(box[i].itemId == widget.itemdata!.id && box[i].toppings =="0"){
                      debugPrint("true...1");
                      /* quantity = quantity +  int.parse(box
                            .where((element) =>
                        element.itemId == widget.itemdata!.id)
                            .first
                            .quantity!);*/
                      quantity = quantity + int.parse(box[i].quantity!);
                      weight = weight + double.parse(box[i].weight!);
                    }

                  }
                }
                debugPrint("weight....2.."+weight.toString());

                stepperButtons.add(
                    UpdateItemSteppr(context, quantity: (box.where((element) => element.itemId == widget.itemdata!.id && element.toppings == "0").count() > 1
                    )?
                    quantity
                        :(widget.addon != null)?(box.where((element) => element.itemId == widget.itemdata!.id).length * int.parse(box
                        .where((element) =>
                    element.itemId == widget.itemdata!.id)
                        .first
                        .quantity!)):int.parse(box
                        .where((element) =>
                    element.itemId == widget.itemdata!.id)
                        .first
                        .quantity!),

                        weight: (box.where((element) => element.itemId == widget.itemdata!.id && element.toppings == "1").count() >= 1
                            /* && box.where((element) => element.itemId == widget.itemdata!.id).last.toppings! =="0"*/)?
                        weight
                            : (widget.addon != null)?/*double.parse((box.where((element) => element.itemId == widget.itemdata!.id).count()
                                * double.parse(box
                                .where((element) =>
                            element.itemId == widget.itemdata!.id)
                                .first
                                .weight!)).toString())*/totalWeight():
                        double.parse(box
                            .where((element) =>
                        element.itemId == widget.itemdata!.id)
                            .first
                            .weight!)/*weight*/,

                        fontSize: widget.fontSize,
                        skutype: box
                            .where((element) =>
                        element.itemId == widget.itemdata!.id)
                            .first
                            .type!,
                        unit: widget.itemdata!.unit!,
                        onTap: (cartStatus) {
                          if (cartStatus == CartStatus.increment) {
                              dialogforUpdateToppings(context);
                          } else {
                            if(box.where((element) => element.itemId == widget.itemdata!.id).length > 1 ){
                              dialogforDeleteToppings(context);
                            }else {
                              updateCart(
                                int.parse(box
                                    .where((element) =>
                                element.itemId == widget.itemdata!.id)
                                    .first
                                    .quantity!),
                                double.parse(box
                                    .where((element) =>
                                element.itemId == widget.itemdata!.id)
                                    .first
                                    .weight!),
                                cartStatus,
                                widget.itemdata!.id!,
                                widget.itemdata!.type! =="1" ?
                                box.where((element) => element.itemId == widget.itemdata!.id).first.parent_id!
                                    : box.where((element) => element.varId == widget.priceVariation!.id).first.parent_id!,
                                "0",
                                "",);
                            }
                          }
                        },
                        alignmnt: widget.alignmnt,
                        isloading: loading));
              }


              stepperButtons.add(AddSubsciptionStepper(
                  context, itemdata: widget.itemdata!,
                  alignmnt: widget.alignmnt,
                  fontsize: widget.fontSize,
                  onTap: () {
                    if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    }
                    else{
                      if (!PrefUtils.prefs!.containsKey("apikey")) {
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                      }
                      else {
                        /*      Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "itemid": widget.itemdata!.id,
                              "itemname": widget.itemdata!.itemName,
                              "itemimg": widget.itemdata!.itemFeaturedImage,
                              "varname": widget.itemdata!.priceVariation![0].variationName !+ widget.itemdata!.priceVariation![0].unit!,
                              "varmrp":widget.itemdata!.priceVariation![0].mrp.toString(),
                              "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.priceVariation![0].membershipPrice.toString()
                                  :widget.itemdata!.priceVariation![0].discointDisplay! ?widget.itemdata!.priceVariation![0].price.toString()
                                  :widget.itemdata!.priceVariation![0].mrp.toString(),
                              "paymentMode": widget.itemdata!.paymentMode,
                              "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                              "name": widget.itemdata!.subscriptionSlot![0].name,
                              "varid":widget.itemdata!.priceVariation![0].id,
                              "brand": widget.itemdata!.brand
                            });*/
                      }
                    }


                  }));
            }

          }
          //}
          print("height"+widget.height.toString());
          return widget.alignmnt == StepperAlignment.Vertical
              ? SizedBox(
            //height: widget.priceVariation!.stock!<=0?33:widget.height,
              height: widget.height,
              width: widget.width,
              child:Column(
                children: stepperButtons,
              ))
              : Container(
              height: widget.height,
              width: widget.width,
              child:
              Row(
                children: stepperButtons,

              ));
        }):
    VxBuilder(
        mutations: {SetCartItem},
        // valueListenable: Hive.box<Product>(productBoxName).listenable(),
        builder: (context, store, index) {
          final box = (VxState.store as GroceStore).CartItemList;
          // if(loading){
          //   print("inside loading");
          //   stepperButtons.clear();
          //stepperButtons.add(Loading(context));
          // stepperButtons.add(Expanded(
          //     flex: 1,
          //     child: SizedBox.shrink())) ;
          // }else{
          stepperButtons.clear();
          if (widget.priceVariation!.stock! <= 0){
            if(widget.issubscription == "Add")  stepperButtons.add(NotificationStepper(
                context, alignmnt: widget.alignmnt,
                fontsize: widget.fontSize,
                onTap: () {

                  if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                    LoginWeb(context,result: (sucsess){
                      if(sucsess){
                        Navigator.of(context).pop();
                        Navigation(context, navigatore: NavigatoreTyp.homenav);
                        /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                      }else{
                        Navigator.of(context).pop();
                      }
                    });
                  }
                  else{
                    if (!PrefUtils.prefs!.containsKey("apikey")) {
                      Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                    }
                    else {
                      _notifyMe();
                    }
                  }
                }, isnotify: _isNotify));
          }
          else{
            if(widget.alignmnt == StepperAlignment.Vertical) {
              if(widget.issubscription == "Subscribe") stepperButtons.add(AddSubsciptionStepper(
                  context, itemdata: widget.itemdata!,
                  alignmnt: widget.alignmnt,
                  fontsize: widget.fontSize,
                  onTap: () {

                    if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    }
                    else{
                      if (!PrefUtils.prefs!.containsKey("apikey")) {
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                      }
                      else {
                        Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "itemid": widget.itemdata!.id,
                              "itemname": widget.itemdata!.itemName,
                              "itemimg": widget.itemdata!.itemFeaturedImage,
                              "itemtype":widget.itemdata!.type,
                              "varname": widget.itemdata!.priceVariation![0].variationName !+ widget.itemdata!.priceVariation![0].unit!,
                              "varmrp":widget.itemdata!.priceVariation![0].mrp.toString(),
                              "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.priceVariation![0].membershipPrice.toString()
                                  :widget.itemdata!.priceVariation![0].discointDisplay! ?widget.itemdata!.priceVariation![0].price.toString()
                                  :widget.itemdata!.priceVariation![0].mrp.toString(),
                              "paymentMode": widget.itemdata!.paymentMode,
                              "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                              "name": widget.itemdata!.subscriptionSlot![0].name,
                              "varid":widget.itemdata!.priceVariation![0].id,
                              "brand": widget.itemdata!.brand,
                              "deliveriesarray": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                              "daily":(widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                              "dailyDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                              "weekend": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                              "weekendDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                              "weekday": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                              "weekdayDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                              "custom": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                              "customDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,
                            });
                      }
                    }


                  }));
              if(widget.issubscription == "Add") {
                if (box.where((element) => element.varId == widget.priceVariation!.id && element.type == widget.itemdata!.type).length <= 0  ||
                    int.parse(box.where((element) => element.varId == widget.priceVariation!.id).first.quantity!) <= 0) {
                  print("inside if...." + "...." + widget.itemdata!.itemName!);
                  stepperButtons.add(AddItemSteppr(
                      context, fontSize: widget.fontSize,
                      alignmnt: widget.alignmnt,
                      onTap: () {
                        //  addToCart();

                          //addToCart("", "", "0","","0");
                          addToppingsProduct.clear();
                          addToppingsProduct.add({
                            "Toppings_type": "",
                            "varId": (widget.itemdata!.type! == "1")
                                ? ""
                                : widget.priceVariation!.id!,
                            "toppings": "0",
                            "parent_id": "",
                            "newproduct": "0",
                            "productid": widget.itemdata!.id
                          });
                          debugPrint("add Toppings product..." +
                              addToppingsProduct.toString());
                          dialogforToppings(context);

                      },
                      isloading: loading));
                }
                else {
                  print("inside if....1" + "...." + widget.itemdata!.itemName!);
                  debugPrint("gh....3.." +
                      (box.where((element) => element.varId ==
                          widget.priceVariation!.id)
                          .count()
                          .toString()));
                  int quantity = 0;
                  double weight = 0.0;

                  for (int i = 0; i < box.length; i++) {
                    debugPrint("sss....");
                    if (box[i].varId == widget.priceVariation!.id &&
                        box[i].toppings == "0") {
                      debugPrint("true...1");

                      quantity = quantity + int.parse(box[i].quantity!);
                      weight = weight + double.parse(box[i].weight!);
                    }
                  }

                  stepperButtons.add(
                      UpdateItemSteppr(context,
                          quantity: (box.where((element) => element.varId ==
                              widget.priceVariation!.id &&
                              element.toppings == "1")).count() >= 1 ?
                          quantity
                              : (widget.addon != null) ? totalquantity()
                          : getTotalQty(),
                          //     : int.parse(box
                          //     .where((element) {
                          //   print('widget.itemdata.priceVariation : ${widget.itemdata?.priceVariation}');
                          //   int  qty = 0;
                          //   for(int i=0; i< (widget.itemdata?.priceVariation?.length)!; i++ ){
                          //     print('widget.itemdata?.priceVariation $i : ${widget.itemdata?.priceVariation![i].quantity}');
                          //
                          //
                          //    // qty +=  (widget.itemdata?.priceVariation![i].quantity)!;
                          //     final priceVariationId = box.where((element) => element.varId == widget.itemdata?.priceVariation![i].id);
                          //     qty +=  int.parse(priceVariationId.length> 0? priceVariationId.first.quantity! : '0');
                          //   }
                          //
                          //   print('Quantity: $qty');
                          //   return element.varId == widget.priceVariation!.id;
                          // })
                          //     .first
                          //     .quantity!),

                          weight: ((box.where((element) =>
                          element.itemId == widget.itemdata!.id &&
                              element.toppings == "0")
                              .count()) > 1)
                              ?
                          weight
                              : (widget.addon != null) ? double.parse(
                              (box.where((element) =>
                              element.itemId == widget.itemdata!.id).count() *
                                  double.parse(box
                                      .where((element) =>
                                  element.itemId == widget.itemdata!.id)
                                      .first
                                      .weight!)).toString()) : double.parse(
                              box
                                  .where((element) =>
                              element.itemId == widget.itemdata!.id )
                                  .first
                                  .weight!),
                          fontSize: widget.fontSize,
                          skutype: box
                              .where((element) =>
                          element.varId == widget.priceVariation!.id)
                              .first
                              .type!,
                          unit: widget.priceVariation!.unit!,
                          onTap: (cartStatus) {
                            if (cartStatus == CartStatus.increment) {
                                dialogforUpdateToppings(context);
                            } else {
                              if(box.where((element) => element.itemId == widget.itemdata!.id).length > 1 ){
                                dialogforDeleteToppings(context);
                              }else {
                                updateCart(
                                  getTotalQty(),
                                  // int.parse(box
                                  //     .where((element) =>
                                  // element.varId == widget.priceVariation!.id)
                                  //     .first
                                  //     .quantity!),
                                  double.parse(box
                                      .where((element) =>
                                  element.itemId == widget.itemdata!.id)
                                      .first
                                      .weight!),
                                  cartStatus,
                                  widget.priceVariation!.id!,
                                  widget.itemdata!.type! =="1" ?
                                  box.where((element) => element.itemId == widget.itemdata!.id).first.parent_id!
                                      : box.where((element) => element.varId == widget.priceVariation!.id).first.parent_id!,
                                  "0",
                                  "",);
                              }
                            }
                          },
                          alignmnt: widget.alignmnt,
                          isloading: loading));
                }
              }
            }
            else{
              if (box.where((element) => element.varId == widget.priceVariation!.id).length <= 0 || int.parse(box.where((element) => element.varId == widget.priceVariation!.id).first.quantity!) <= 0)
                stepperButtons.add(AddItemSteppr(
                    context, fontSize: widget.fontSize,alignmnt: widget.alignmnt,onTap: () {
                  // addToCart();

                    // addToCart("", "", "0","","0");
                    addToppingsProduct.clear();
                    addToppingsProduct.add({"Toppings_type":"","varId":   (widget.itemdata!.type! =="1")?"":widget.priceVariation!.id!,"toppings":"0", "parent_id":  "","newproduct":"0","productid":widget.itemdata!.id});
                    debugPrint("add Toppings product..."+addToppingsProduct.toString());
                    dialogforToppings(context);

                },isloading: loading));
              else {
                debugPrint("gh....4.."+(box.where((element) => element.varId == widget.priceVariation!.id).count().toString()));
                int quantity = 0;
                double weight = 0.0;

                for( int i = 0;i < box.length ;i++){
                  if(box[i].varId == widget.priceVariation!.id && box[i].toppings =="0") {
                    debugPrint("true...1");

                    quantity = quantity + int.parse(box[i].quantity!);
                    weight = weight + double.parse(box
                        .where((element) =>
                    element.itemId == widget.itemdata!.id)
                        .first
                        .weight!);
                  }

                }

                stepperButtons.add(
                    UpdateItemSteppr(context, quantity:  (box.where((element) =>  element.varId == widget.priceVariation!.id && element.toppings == "1")).count() >= 1?
                    quantity
                        :(widget.addon != null)?totalquantity()
                    :getTotalQty(),
                       /* :int.parse(box
                        .where((element){
                          print('widget.itemdata.priceVariation : ${widget.itemdata?.priceVariation}');
                      return element.varId == widget.priceVariation!.id;
                    }
                   )
                        .first
                        .quantity!),*/
                        weight: (box.where((element) => element.itemId == widget.itemdata!.id && element.toppings == "0").count()> 1) ?
                        weight
                            :(widget.addon != null)?double.parse((box.where((element) => element.itemId == widget.itemdata!.id).count() *  double.parse(box
                            .where((element) =>
                        element.itemId == widget.itemdata!.id)
                            .first
                            .weight!)).toString()): double.parse(box
                            .where((element) =>
                        element.itemId == widget.itemdata!.id)
                            .first
                            .weight!),
                        fontSize: widget.fontSize,
                        skutype: box
                            .where((element) =>
                        element.varId == widget.priceVariation!.id)
                            .first
                            .type!,
                        unit: widget.priceVariation!.unit!,
                        onTap: (cartStatus) {
                          if (cartStatus == CartStatus.increment) {
                            if (widget.addon == null)
                              updateCart(
                                getTotalQty(),
                                /*int.parse(box
                                    .where((element) =>
                                element.varId == widget.priceVariation!.id)
                                    .first
                                    .quantity!),*/
                                double.parse(box
                                    .where((element) =>
                                element.itemId == widget.itemdata!.id)
                                    .first
                                    .weight!),
                                cartStatus,
                                widget.priceVariation!.id!,
                                widget.itemdata!.type! =="1" ?
                                box.where((element) => element.itemId == widget.itemdata!.id).first.parent_id!
                                    : box.where((element) => element.varId == widget.priceVariation!.id).first.parent_id!,
                                "0",
                                "",);
                            else
                              dialogforUpdateToppings(context);
                          } else {
                            if(box.where((element) => element.itemId == widget.itemdata!.id).length > 1 ){
                              dialogforDeleteToppings(context);
                            }else {
                              updateCart(
                                int.parse(box
                                    .where((element) =>
                                element.varId == widget.priceVariation!.id)
                                    .first
                                    .quantity!),
                                double.parse(box
                                    .where((element) =>
                                element.itemId == widget.itemdata!.id)
                                    .first
                                    .weight!),
                                cartStatus,
                                widget.priceVariation!.id!,
                                widget.itemdata!.type! =="1" ?
                                box.where((element) => element.itemId == widget.itemdata!.id).first.parent_id!
                                    : box.where((element) => element.varId == widget.priceVariation!.id).first.parent_id!,
                                "0",
                                "",);
                            }
                          }
                        },
                        alignmnt: widget.alignmnt,
                        isloading: loading));
              }

              stepperButtons.add(AddSubsciptionStepper(
                  context, itemdata: widget.itemdata!,
                  alignmnt: widget.alignmnt,
                  fontsize: widget.fontSize,
                  onTap: () {
                    if(!PrefUtils.prefs!.containsKey("apikey") &&Vx.isWeb && !ResponsiveLayout.isSmallScreen(context)){
                      LoginWeb(context,result: (sucsess){
                        if(sucsess){
                          Navigator.of(context).pop();
                          Navigation(context, navigatore: NavigatoreTyp.homenav);
                          /* Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);*/
                        }else{
                          Navigator.of(context).pop();
                        }
                      });
                    }
                    else{
                      if (!PrefUtils.prefs!.containsKey("apikey")) {
                        Navigation(context, name: Routename.SignUpScreen, navigatore: NavigatoreTyp.Push);

                      }
                      else {
                        Navigation(context, name: Routename.SubscribeScreen, navigatore: NavigatoreTyp.Push,
                            qparms: {
                              "itemid": widget.itemdata!.id,
                              "itemname": widget.itemdata!.itemName,
                              "itemimg": widget.itemdata!.itemFeaturedImage,
                              "itemtype":widget.itemdata!.type,
                              "varname": widget.itemdata!.priceVariation![0].variationName !+ widget.itemdata!.priceVariation![0].unit!,
                              "varmrp":widget.itemdata!.priceVariation![0].mrp.toString(),
                              "varprice":  (VxState.store as GroceStore).userData.membership=="1" ? widget.itemdata!.priceVariation![0].membershipPrice.toString()
                                  :widget.itemdata!.priceVariation![0].discointDisplay! ?widget.itemdata!.priceVariation![0].price.toString()
                                  :widget.itemdata!.priceVariation![0].mrp.toString(),
                              "paymentMode": widget.itemdata!.paymentMode,
                              "cronTime": widget.itemdata!.subscriptionSlot![0].cronTime,
                              "name": widget.itemdata!.subscriptionSlot![0].name,
                              "varid":widget.itemdata!.priceVariation![0].id,
                              "brand": widget.itemdata!.brand,
                              "deliveriesarray": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].deliveries :widget.itemdata!.subscriptionSlot![0].deliveries,
                              "daily":(widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].daily :widget.itemdata!.subscriptionSlot![0].daily,
                              "dailyDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].dailyDays :widget.itemdata!.subscriptionSlot![0].dailyDays,
                              "weekend": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekend :widget.itemdata!.subscriptionSlot![0].weekend,
                              "weekendDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekendDays :widget.itemdata!.subscriptionSlot![0].weekendDays,
                              "weekday": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekday :widget.itemdata!.subscriptionSlot![0].weekday,
                              "weekdayDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].weekdayDays :widget.itemdata!.subscriptionSlot![0].weekdayDays,
                              "custom": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].custom :widget.itemdata!.subscriptionSlot![0].custom,
                              "customDays": (widget.from == "search_screen" && Features.ismultivendor)?widget.searchstoredata!.subscriptionSlot![0].customDays :widget.itemdata!.subscriptionSlot![0].customDays,
                            });
                      }
                    }


                  }));
            }

          }
          //}
          print("height"+widget.height.toString());
          return widget.alignmnt == StepperAlignment.Vertical
              ? SizedBox(
            //height: widget.priceVariation!.stock!<=0?33:widget.height,
              height: widget.height,
              width: widget.width,
              child:Column(
                children: stepperButtons,
              ))
              : Container(
              height: widget.height,
              width: widget.width,
              child:
              Row(
                children: stepperButtons,

              ));
        });
  }

  double totalWeight() {
    double totalWeight = 0.0;
    List<double> weight = [];
    weight.clear();
    (widget.from == "search_screen" && Features.ismultivendor)?
    debugPrint("weight..."+productBox.where((element) => element.itemId == widget.searchstoredata!.id).map((e) =>  double.parse(e.weight!)).toString()):
    debugPrint("weight..."+productBox.where((element) => element.itemId == widget.itemdata!.id).map((e) =>  double.parse(e.weight!)).toString());
    (widget.from == "search_screen" && Features.ismultivendor)?
    weight.addAll(productBox.where((element) => element.itemId == widget.searchstoredata!.id).map((e) =>  double.parse(e.weight!))):
    weight.addAll(productBox.where((element) => element.itemId == widget.itemdata!.id).map((e) =>  double.parse(e.weight!)));
    debugPrint("weight list...."+weight.toString());
    for(int i = 0;i<weight.length; i++){
      totalWeight = totalWeight + weight[i];
    }
    debugPrint("totalWeight...."+totalWeight.toString());
    return totalWeight;
  }

 int getTotalQty(){
   List<CartItem> box = (VxState.store as GroceStore).CartItemList ;
    int  qty = 0;
    for(int i=0; i< (widget.itemdata?.priceVariation?.length)!; i++ ){
      // qty +=  (widget.itemdata?.priceVariation![i].quantity)!;
      /*
      print('widget.itemdata.itemName : ${widget.itemdata?.itemName}');
      final priceVariationId = box.where((element) => element.varId == widget.itemdata?.priceVariation![i].id);
      qty +=  int.parse(priceVariationId.length> 0? priceVariationId.first.quantity! : '0');
      print('element.varId : ${priceVariationId}');
      print('Qty: ' + (priceVariationId.length> 0? priceVariationId.first.quantity! : '0'));
       */

      final priceVariationId = box.where((element) => element.varId == widget.itemdata?.priceVariation![i].id);
      for (var element in priceVariationId) {
        qty += int.parse(element.quantity!);
      }

    }

    print('widget.itemdata.itemName : ${widget.itemdata?.itemName}');
    print(qty);

    return qty;
  }

  int totalquantity() {
    int totalquantity = 0;
    List<int> Lisquantity = [];
    Lisquantity.clear();
    (widget.from == "search_screen" && Features.ismultivendor)?
    debugPrint("weight...priceVariationSearch..."+productBox.where((element) => element.varId == widget.priceVariationSearch!.id).map((e) =>  int.parse(e.quantity!)).toString()):
    debugPrint("weight...priceVariation...."+productBox.where((element) => element.varId == widget.priceVariation!.id).map((e) =>  int.parse(e.quantity!)).toString());
    debugPrint("weight...itemdata..."+productBox.where((element) => element.varId == widget.itemdata!.id).map((e) =>  int.parse(e.quantity!)).toString());
    (widget.from == "search_screen" && Features.ismultivendor)?
    Lisquantity.addAll(productBox.where((element) => element.varId == widget.priceVariationSearch!.id).map((e) =>  int.parse(e.quantity!))):
    Lisquantity.addAll(productBox.where((element) => element.itemId == widget.itemdata!.id).map((e) =>  int.parse(e.quantity!)));
    debugPrint("quantity list...."+Lisquantity.toString());
    for(int i = 0;i< Lisquantity.length; i++){
      totalquantity = totalquantity + Lisquantity[i];
    }
    debugPrint("totalquantity...."+totalquantity.toString());
    return totalquantity;
  }

  bool compare(List<Map<String, dynamic>> toppindfrombackend, List addToppings) {
    bool ismapequal = true;
    addToppings.forEach((element) {
      if(!toppindfrombackend.contains(element)){
        ismapequal = false;
      }
    });
    debugPrint("ismapequal....."+ismapequal.toString());
    return ismapequal;
  }

  Widget AddItemSteppr(BuildContext context,{required double fontSize,required Function() onTap, required StepperAlignment alignmnt, isloading}) {
    debugPrint("testing..." + isloading.toString());
    return (Features.isSubscription)?
    Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: ()=>onTap(),
        child: Padding(
          padding: EdgeInsets.only(/*left:alignmnt == StepperAlignment.Horizontal?10:0,*/bottom: alignmnt == StepperAlignment.Vertical?0:0),
          child: Container(
            margin: EdgeInsets.only(top:alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?5:0),
            height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?55:55:0.0,
            /* decoration: new BoxDecoration(
              color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.stepperColor :IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.stepperColor,
              borderRadius:
              new BorderRadius
                  .all(
                const Radius.circular(
                    2.0),
              )),*/
            decoration: new BoxDecoration(
                color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.yellow1:ColorCodes.yellow1 :IConstants.isEnterprise?ColorCodes.yellow1:ColorCodes.yellow1,
                border: Border.all(color: ColorCodes.yellow1/*Theme
                  .of(context)
                  .primaryColor*/),
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(2),
                  topRight:
                  const Radius.circular(2),
                  bottomLeft:
                  const Radius.circular(2),
                  bottomRight:
                  const Radius.circular(2),
                )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isloading?
                /*CircularProgressIndicator(
                color: (Features.isSubscription)?ColorCodes.whiteColor :ColorCodes.primaryColor,
                strokeWidth: 2.0,
                valueColor: new AlwaysStoppedAnimation<Color>(ColorCodes.whiteColor),
              )*/ Center(
                  child: SizedBox(
                      width: 15.0,
                      height: 15.0,
                      child: new CircularProgressIndicator(
                        color: (Features.isSubscription)?ColorCodes.yellow1 :ColorCodes.yellow1,
                        strokeWidth: 2.0,
                        valueColor: new AlwaysStoppedAnimation<Color>(ColorCodes.yellow1),
                      )
                  ),
                )
                    : Row(
                  children: [

                    SizedBox(width:2),
                    Text(
                      S.current.add,
                      style:
                      TextStyle(
                          color: ColorCodes.blackColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold

                      ),

                      textAlign:
                      TextAlign
                          .center,
                    ),
                    Icon(Icons.add,color: ColorCodes.blackColor,size: 16,),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        :Expanded(
        flex: 1,
        child: GestureDetector(
          onTap: ()=>onTap(),
          child: Padding(
            padding: EdgeInsets.only(top:alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?0:0),
            child: Container(
              //width: MediaQuery.of(context).size.width / 2.9,
              height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?55:55:55.0,
              margin:  EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.only(left:8),
              decoration: new BoxDecoration(
                  color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.addBtn :IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.addBtn,
                  border: Border.all(color: ColorCodes.addBtn/*Theme
                  .of(context)
                  .primaryColor*/),
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(5),
                    topRight:
                    const Radius.circular(5),
                    bottomLeft:
                    const Radius.circular(5),
                    bottomRight:
                    const Radius.circular(5),
                  )),
              child:
              isloading?
              /*CircularProgressIndicator(
                color: (Features.isSubscription)?ColorCodes.whiteColor :ColorCodes.primaryColor,
                strokeWidth: 2.0,
                valueColor: new AlwaysStoppedAnimation<Color>(ColorCodes.whiteColor),
              )*/ Center(
                child: SizedBox(
                    width: 15.0,
                    height: 15.0,
                    child: new CircularProgressIndicator(
                      color: (Features.isSubscription)?ColorCodes.whiteColor :ColorCodes.primaryColor,
                      strokeWidth: 2.0,
                      valueColor: new AlwaysStoppedAnimation<Color>(ColorCodes.greenColor),
                    )
                ),
              )
                  :Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  SizedBox(width:2),
                    Text(
                    S.current.add.allWordsCapitilize(),//'ADD',
                    style: TextStyle(
                        color: ColorCodes.whiteColor, /*Theme.of(context)
                          .buttonColor*/
                        fontSize: widget.showPrice ? 14:19, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(width:3),
                  widget.showPrice ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new RichText(
                        text: new TextSpan(
                          style: new TextStyle(
                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                            new TextSpan(
                                text:  Features.iscurrencyformatalign?
                                '${_checkmembership?widget.itemdata?.priceVariation![widget.index].membershipPrice:widget.itemdata?.priceVariation! [widget.index].price} ' + IConstants.currencyFormat:
                                IConstants.currencyFormat + '${_checkmembership?widget.itemdata?.priceVariation![widget.index].membershipPrice?.split(".")[0]:widget.itemdata?.priceVariation![widget.index].price?.split(".")[0]} ',
                                style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:_checkmembership?ColorCodes.greenColor: Colors.white,
                                  fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                            new TextSpan(
                                text: widget.itemdata?.priceVariation![widget.index].price == widget.itemdata?.priceVariation![widget.index].mrp?
                                Features.iscurrencyformatalign ?
                                '${_checkmembership ? (widget.itemdata?.priceVariation![widget.index].membershipDisplay)! ?
                                widget.itemdata?.priceVariation![widget.index].mrp : "" : ""}' + IConstants.currencyFormat
                                    :
                                '${_checkmembership ? (widget.itemdata?.priceVariation![widget.index].membershipDisplay)! ?
                                IConstants.currencyFormat +(widget.itemdata?.priceVariation![widget.index].mrp)!.split(".")[0] : "" : ""}'
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
                  ): Icon(Icons.add,color: ColorCodes.whiteColor,size: 19,),
                 widget.showPrice ? const SizedBox(width: 2) : Container()
                ],
              ),
            ),
          ),
        )
    );
  }

}
Widget handler(bool? isSelected) {
  debugPrint("isselected..."+isSelected.toString());
  return (isSelected == true )  ?
  Container(
    width: 20.0,
    height: 20.0,
    decoration: BoxDecoration(
      color: ColorCodes.whiteColor,
      border: Border.all(
        color: ColorCodes.greenColor,
      ),
      shape: BoxShape.circle,
    ),
    child: Container(
      margin: EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        color:ColorCodes.whiteColor,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check,
          color: ColorCodes.greenColor,
          size: 15.0),
    ),
  )
      :
  Icon(
      Icons.radio_button_off_outlined,
      color: ColorCodes.blackColor,
      size: 20.0
  );
}

Widget Loading(BuildContext context) {
  return  Container(
    // decoration: BoxDecoration(color: (Features.isSubscription)? ColorCodes.whiteColor:ColorCodes.whiteColor,
    //   border: Border(
    //     //right: BorderSide(width: 1.0, color: ColorCodes.darkgreen,),
    //     bottom: BorderSide(width: 1.0, color: ColorCodes.darkgreen),
    //     top: BorderSide(width: 1.0, color: ColorCodes.darkgreen),
    //   ),),
    height: 60,
    width:35,
    child: Center(
      child: SizedBox(
          width: 15.0,
          height: 15.0,
          child: new CircularProgressIndicator(
            color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.stepperColor:ColorCodes.stepperColor :IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor,
            strokeWidth: 2.0,
            valueColor: new AlwaysStoppedAnimation<Color>(/*Theme.of(context).primaryColor*/(Features.isSubscription)?IConstants.isEnterprise?ColorCodes.stepperColor:ColorCodes.stepperColor :IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor),
          )
      ),
    ),
  );
}

Widget AddItemSteppr(BuildContext context,{required double fontSize,required Function() onTap, required StepperAlignment alignmnt, isloading}) {
  debugPrint("testing..." + isloading.toString());
  return (Features.isSubscription)?
  Expanded(
    flex: 1,
    child: GestureDetector(
      onTap: ()=>onTap(),
      child: Padding(
        padding: EdgeInsets.only(/*left:alignmnt == StepperAlignment.Horizontal?10:0,*/bottom: alignmnt == StepperAlignment.Vertical?0:0),
        child: Container(
          margin: EdgeInsets.only(top:alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?5:0),
          height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?55:55:0.0,
          /* decoration: new BoxDecoration(
              color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.stepperColor :IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.stepperColor,
              borderRadius:
              new BorderRadius
                  .all(
                const Radius.circular(
                    2.0),
              )),*/
          decoration: new BoxDecoration(
              color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.yellow1:ColorCodes.yellow1 :IConstants.isEnterprise?ColorCodes.yellow1:ColorCodes.yellow1,
              border: Border.all(color: ColorCodes.yellow1/*Theme
                  .of(context)
                  .primaryColor*/),
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(2),
                topRight:
                const Radius.circular(2),
                bottomLeft:
                const Radius.circular(2),
                bottomRight:
                const Radius.circular(2),
              )),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isloading?
              /*CircularProgressIndicator(
                color: (Features.isSubscription)?ColorCodes.whiteColor :ColorCodes.primaryColor,
                strokeWidth: 2.0,
                valueColor: new AlwaysStoppedAnimation<Color>(ColorCodes.whiteColor),
              )*/ Center(
                child: SizedBox(
                    width: 15.0,
                    height: 15.0,
                    child: new CircularProgressIndicator(
                      color: (Features.isSubscription)?ColorCodes.yellow1 :ColorCodes.yellow1,
                      strokeWidth: 2.0,
                      valueColor: new AlwaysStoppedAnimation<Color>(ColorCodes.yellow1),
                    )
                ),
              )
                  : Row(
                children: [

                  SizedBox(width:2),
                  Text(
                    S.current.add,
                    style:
                    TextStyle(
                        color: ColorCodes.blackColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold

                    ),

                    textAlign:
                    TextAlign
                        .center,
                  ),
                  Icon(Icons.add,color: ColorCodes.blackColor,size: 16,),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  )
      :Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: ()=>onTap(),
        child: Padding(
          padding: EdgeInsets.only(top:alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?5:0),
          child: Container(
            //width: MediaQuery.of(context).size.width / 2.9,
            height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?55:55:55.0,
            margin:  EdgeInsets.symmetric(horizontal: 8),
            padding: EdgeInsets.only(left:8),
            decoration: new BoxDecoration(
                color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.yellow1:ColorCodes.yellow1 :IConstants.isEnterprise?ColorCodes.yellow1:ColorCodes.yellow1,
                border: Border.all(color: ColorCodes.yellow1/*Theme
                  .of(context)
                  .primaryColor*/),
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(5),
                  topRight:
                  const Radius.circular(5),
                  bottomLeft:
                  const Radius.circular(5),
                  bottomRight:
                  const Radius.circular(5),
                )),
            child:
            isloading?
            /*CircularProgressIndicator(
                color: (Features.isSubscription)?ColorCodes.whiteColor :ColorCodes.primaryColor,
                strokeWidth: 2.0,
                valueColor: new AlwaysStoppedAnimation<Color>(ColorCodes.whiteColor),
              )*/ Center(
              child: SizedBox(
                  width: 15.0,
                  height: 15.0,
                  child: new CircularProgressIndicator(
                    color: (Features.isSubscription)?ColorCodes.whiteColor :ColorCodes.primaryColor,
                    strokeWidth: 2.0,
                    valueColor: new AlwaysStoppedAnimation<Color>(ColorCodes.greenColor),
                  )
              ),
            )
                :Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                SizedBox(width:2),
                Text(
                  S.current.add,//'ADD',
                  style: TextStyle(
                      color: ColorCodes.blackColor, /*Theme.of(context)
                          .buttonColor*/
                      fontSize: 19, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(width:2),
                Icon(Icons.add,color: ColorCodes.blackColor,size: 19,),
              ],
            ),
          ),
        ),
      )
  );
}

Widget UpdateItemSteppr(BuildContext context,{required int quantity,required double weight,required double fontSize,required String skutype,required String unit,required Function(CartStatus) onTap,required StepperAlignment alignmnt,isloading,String? maxItem,String? minItem,String? count,double? price ,String? varid,String? incvalue, String? Cart_id }) {
  debugPrint("skutype..."+skutype+"..."+weight.toString()+"  "+quantity.toString()+"min.."+minItem.toString()+"max.."+maxItem.toString()+"count..."+count.toString());
  final bool isHomeScreen = '/store/home' == ModalRoute.of(context)?.settings.name;
  return  Expanded(
    flex: 1,
    child: Container(
      height: (Features.isSubscription)?90:30,
      padding: EdgeInsets.only(/*left:alignmnt == StepperAlignment.Horizontal?10:0,*/top:alignmnt == StepperAlignment.Vertical?Features.isSubscription?0:0:0,bottom: alignmnt == StepperAlignment.Vertical?(Features.isSubscription)?5:5:0),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () =>onTap(CartStatus.decrement),
            child: Container(
                width: alignmnt == StepperAlignment.Vertical?skutype=="1"?25:25:skutype=="1"?30:30,
                height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?90:40:30,

                decoration: new BoxDecoration(
                    color: (Features.isSubscription)?/*ColorCodes.subscribeColor*/ IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.addBtn:IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.addBtn,

                    border: Border.all(color: ColorCodes.addBtn/*Theme
                  .of(context)
                  .primaryColor*/),
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(2),
                      topRight:
                      const Radius.circular(2),
                      bottomLeft:
                      const Radius.circular(2),
                      bottomRight:
                      const Radius.circular(2),
                    )),
                child: Center(
                  child:
                  Text(
                    "-",
                    textAlign:
                    TextAlign
                        .center,
                    style:
                    TextStyle(
                      color: (Features.isSubscription)?ColorCodes.whiteColor :ColorCodes.whiteColor,
                    ),
                  ),
                )),
          ),
          Expanded(
            child:(isloading)? Loading(context)
                :Container(
              // decoration: new BoxDecoration(
              //   color: (Features.isSubscription)?/*ColorCodes.subscribeColor*/ IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor:IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
              //   border: Border(
              //     // left: BorderSide(width: 1.0, color: ColorCodes.darkgreen,),
              //    // bottom: BorderSide(width: 1.0, color: ColorCodes.darkgreen),
              //    // top: BorderSide(width: 1.0, color: ColorCodes.darkgreen),
              //   ),
              // ),
                height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?150:150:150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        skutype=="1"? weight.toString()+" "+unit: quantity.toStringAsFixed(0),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: skutype=="1"?11:13,
                          color: (Features.isSubscription)?IConstants.isEnterprise?isHomeScreen ? ColorCodes.blackColor :ColorCodes.blackColor:ColorCodes.blackColor :IConstants.isEnterprise?isHomeScreen ? ColorCodes.blackColor :ColorCodes.blackColor: isHomeScreen ? ColorCodes.blackColor :ColorCodes.blackColor, ),

                      ),
                    ),
                    skutype=="1"?
                    GestureDetector(
                        onTap: (){
                          showoptions1(context,count!,minItem!,maxItem!,weight,isloading,skutype,price!,varid,Cart_id,quantity,unit);
                        },
                        child: Icon(Icons.keyboard_arrow_down,color: ColorCodes.darkgreen,size: 20,))
                        :SizedBox.shrink()
                  ],
                )),
          ),
          GestureDetector(
            onTap: () {
              // dialogforUpdateToppings(context);
              onTap(CartStatus.increment);
            },
            child: Container(
                width: alignmnt == StepperAlignment.Vertical?skutype=="1"?25:25:skutype=="1"?60:60,
                height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?80:40:30,
                decoration: new BoxDecoration(
                    color: (Features.isSubscription)?/*ColorCodes.subscribeColor*/ IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.addBtn:IConstants.isEnterprise?ColorCodes.addBtn:ColorCodes.addBtn,
                    border: Border.all(color: ColorCodes.addBtn/*Theme
                  .of(context)
                  .primaryColor*/),
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(2),
                      topRight:
                      const Radius.circular(2),
                      bottomLeft:
                      const Radius.circular(2),
                      bottomRight:
                      const Radius.circular(2),
                    )),
                child: Center(
                  child: Text(
                    "+",
                    textAlign:
                    TextAlign
                        .center,
                    style:
                    TextStyle(
                      color: (Features.isSubscription)?ColorCodes.whiteColor :ColorCodes.whiteColor,
                    ),
                  ),
                )),
          ),
        ],
      ),

    ),

  );
}



Widget AddSubsciptionStepper(BuildContext context,{required StepperAlignment alignmnt, ItemData? itemdata,required Function() onTap,required double fontsize, StoreSearchData? search,String? from_screen}) {
  return (Features.isSubscription)?
  from_screen == "search_screen" && Features.ismultivendor?
  search!.eligibleForSubscription =="0" ?
  Expanded(
    flex: 1,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: ()=>onTap(),
        child: Padding(
          padding:  EdgeInsets.only(left:alignmnt == StepperAlignment.Horizontal?10:0,top: alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?15:0),
          child: Container(
            height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?0:0:0.0,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 5.0, color: ColorCodes.darkgreen),
                // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
              ),
              color: ColorCodes.varcolor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 3),
                Image.asset(Images.subscribeImg,
                  height: 10.0,
                  width: 10.0,),
                SizedBox(width: 3),
                Text(

                  S.current.subscribe,
                  style: TextStyle(
                      fontSize: fontsize,
                      color: ColorCodes.darkgreen/*Theme.of(context)
          .primaryColor*/,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: 5),
              ],
            ) ,
          ),
        ),
      ),
    ),
  ):alignmnt == StepperAlignment.Vertical?Expanded(
      flex: 1,
      child: SizedBox.shrink()):SizedBox.shrink():
  itemdata!.eligibleForSubscription =="0" ?
  Expanded(
    flex: 1,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: ()=>onTap(),
        child: Padding(
          padding:  EdgeInsets.only(left:alignmnt == StepperAlignment.Horizontal?10:0,top: alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?15:0),
          child: Container(
            height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?30:40:30.0,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(width: 5.0, color: ColorCodes.darkgreen),
                // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
              ),
              color: ColorCodes.discountoff1,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 3),
                Image.asset(Images.subscribeImg,
                  height: 10.0,
                  width: 10.0,),
                SizedBox(width: 3),
                Text(

                  S.current.subscribe,
                  style: TextStyle(
                      fontSize: fontsize,
                      color: ColorCodes.darkgreen/*Theme.of(context)
          .primaryColor*/,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: 5),
              ],
            ) ,
          ),
        ),
      ),
    ),
  ):alignmnt == StepperAlignment.Vertical?Expanded(
      flex: 1,
      child: SizedBox.shrink()):SizedBox.shrink():SizedBox.shrink();
}

Widget NotificationStepper(BuildContext context,{required StepperAlignment alignmnt,required Function() onTap, required double fontsize,required bool isnotify}) {
  return Features.isSubscription?Expanded(
    flex: 1,
    child:
    MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Container(
          margin: EdgeInsets.only(top:alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?5:0),
          //height: 30.0,
//height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?30:40:40.0,
          decoration: new BoxDecoration(
              color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor :IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
              border: Border.all(color: ColorCodes.darkgreen/*Theme
    .of(context)
    .primaryColor*/),
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(5),
                topRight:
                const Radius.circular(5),
                bottomLeft:
                const Radius.circular(5),
                bottomRight:
                const Radius.circular(5),
              )),
          child: isnotify ?
          Center(
            child: SizedBox(
                width: 15.0,
                height: 15.0,
                child: new CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: new AlwaysStoppedAnimation<
                      Color>(Colors.green),)),
          ):
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Center(
                  child: Text(S.current.notify_me,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ColorCodes.darkgreen,/*Colors
              .white,*/
                        fontSize: fontsize),
                    textAlign: TextAlign.center,)),
              /*    Spacer(),
                    Container(
                      height: 30,
                      width: 25,
                      decoration: BoxDecoration(
                        color:Features.isSubscription?IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.stepperColor:
                        IConstants.isEnterprise?ColorCodes.cartgreenColor:ColorCodes.stepperColor,

                      ),
                      child: Icon(
                        Icons.add,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),*/
            ],
          ),
        ),
      ),),
  ):Expanded(
    flex: 1,
    child:
    MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Container(
          margin: EdgeInsets.only(top:alignmnt == StepperAlignment.Vertical?0:0,bottom: alignmnt == StepperAlignment.Vertical?5:0),
          //height: 30.0,
          // decoration: new BoxDecoration(
          //   // border: Border.all(
          //   //     color:  (Features.isSubscription)?ColorCodes.primaryColor:ColorCodes.greenColor),
          //     color:  (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.stepperColor:IConstants.isEnterprise?ColorCodes.greenColor:ColorCodes.stepperColor,
          //     borderRadius:
          //     new BorderRadius.all(const Radius.circular(3.0),)),
          decoration: new BoxDecoration(
              color: (Features.isSubscription)?IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor :IConstants.isEnterprise?ColorCodes.whiteColor:ColorCodes.whiteColor,
              border: Border.all(color: ColorCodes.darkgreen/*Theme
         .of(context)
         .primaryColor*/),
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(5),
                topRight:
                const Radius.circular(5),
                bottomLeft:
                const Radius.circular(5),
                bottomRight:
                const Radius.circular(5),
              )),
          child:
          isnotify ?
          Center(
            child: SizedBox(
                width: 15.0,
                height: 15.0,
                child: new CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: new AlwaysStoppedAnimation<
                      Color>(Colors.green),)),
          ):
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Center(
                  child: Text(S.current.notify_me,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors
                            .white,
                        fontSize: fontsize),
                    textAlign: TextAlign.center,)),
              /*Spacer(),
              Container(
                height: (Features.isSubscription)?alignmnt == StepperAlignment.Vertical?30:40:40.0,
                width: 25,
                decoration: BoxDecoration(
                  color:Features.isSubscription?IConstants.isEnterprise?ColorCodes.primaryColor:ColorCodes.stepperColor:
                  IConstants.isEnterprise?ColorCodes.cartgreenColor:ColorCodes.stepperColor,

                ),
                child: Icon(
                  Icons.add,
                  size: 12,
                  color: Colors.white,
                ),
              ),*/
            ],
          ),
        ),
      ),

    ),

  );
}

showoptions1(BuildContext context,String count,String minItem,String maxItem,double weightsku,bool loading, String skutype, double price,String? varid,String? cart_id,int qty, String unit) {
  List weight = [];
  double total_weight = 0.0;
  double total_min = 0.0;
  double total_max = 0.0;
  int? selectedIndex;


  List<double> Listweight = [];
  weight.clear();
  for( int i = int.parse(minItem);i <= int.parse(maxItem);i++){
    weight.add(i);
    selectedIndex = 0;
    total_min = double.parse(minItem) ;/** double.parse(count)*/;
    total_max = double.parse(maxItem) ;/** double.parse(count)*/;
    total_weight = total_min;
  }

  print("count value...." +count.toString());
  Listweight.clear();
  //for (int j = 0; j< weight.length;j++){
  for(int k = total_min.toInt() ; k <= total_max.toInt(); k++) {
    if(k == total_min.toInt()) {
      total_weight =
          total_min * double.parse(count);
    }
    else{
      total_weight =
          total_weight + (double.parse(count));
    }
    //}
    Listweight.add(total_weight);
  }

  (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))?

  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState1) {
          return  Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3.0)),
            child: Container(
                width: MediaQuery.of(context).size.width / 2.5,
                //height: 200,
                padding: EdgeInsets.fromLTRB(30, 20, 20, 20),
                child:
                SingleChildScrollView(
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: weight.length,
                      itemBuilder: (_, i) {
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: (){

                            Navigator.of(context).pop();
                            setState1((){
                              //loading = true;
                              selectedIndex = i;

                            });

                            (loading)? Loading(context)
                                :
                            cartcontroller.update((done) {
                              setState1(() {
                                loading = !done;
                              });
                            }, price: price.toString(),
                                quantity: qty.toString(),
                                type: skutype.toString(),
                                weight: Listweight[i].toString(),
                                var_id: varid!,
                                increament: count,
                                cart_id: cart_id!,
                                toppings: "",
                                topping_id: ""

                            );  },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            margin: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: selectedIndex==i?ColorCodes.fill:ColorCodes.whiteColor,
                              border: Border.all(color: ColorCodes.lightGreyColor),
                            ),
                            child: Row(

                              children: [
                                handlerweight(i,selectedIndex!),
                                SizedBox(width:5),
                                Text(Listweight[i].toString() + unit.toString()),
                                Spacer(),
                                Text(  Features.iscurrencyformatalign?
                                (Listweight[i]*price).toStringAsFixed(2) + " " + IConstants.currencyFormat:
                                IConstants.currencyFormat + " " + (Listweight[i]*price).toStringAsFixed(2),),
                              ],
                            ),
                          ),
                        );
                      }),
                )
            ),
          );
        });
      })
  /*.then((_) => setstate(){}) */:

  showModalBottomSheet<dynamic>(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(

          builder: (BuildContext context, void Function(void Function()) setState) {
            return SingleChildScrollView(
              child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: weight.length,
                  itemBuilder: (_, i) {
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: (){
                        Navigator.of(context).pop();
                        setState((){
                          //loading = true;
                          selectedIndex = i;

                        });

                        (loading)? Loading(context)
                            :
                        cartcontroller.update((done) {
                          setState(() {
                            loading = !done;
                          });
                        }, price: price.toString(),
                            quantity: qty.toString(),
                            type: skutype.toString(),
                            weight: Listweight[i].toString(),
                            var_id: varid!,
                            increament: count,
                            cart_id: cart_id!,
                            toppings: "",
                            topping_id: ""

                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        margin: EdgeInsets.symmetric(vertical: 5),
                        child: Row(

                          children: [
                            handlerweight(i,selectedIndex!),
                            SizedBox(width:5),
                            Text(Listweight[i].toString() + unit.toString()),
                            Spacer(),
                            Text(  Features.iscurrencyformatalign?
                            (Listweight[i]*price).toStringAsFixed(2) + " " + IConstants.currencyFormat:
                            IConstants.currencyFormat + " " + (Listweight[i]*price).toStringAsFixed(2),),
                          ],
                        ),
                      ),
                    );
                  }),
            );
          },
        );
      });
}

Widget handlerweight(int i, int selectedIndex) {
  return (selectedIndex == i) ?
  Icon(
      Icons.radio_button_checked_outlined,
      color: ColorCodes.greenColor)
      :
  Icon(
      Icons.radio_button_off_outlined,
      color: ColorCodes.greenColor);

}
