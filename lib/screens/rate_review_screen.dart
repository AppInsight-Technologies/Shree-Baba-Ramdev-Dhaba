
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import '../assets/ColorCodes.dart';
import '../assets/images.dart';
import '../constants/IConstants.dart';
import '../constants/features.dart';
import '../controller/mutations/cat_and_product_mutation.dart';
import '../helper/custome_checker.dart';
import '../models/VxModels/VxStore.dart';
import '../repository/productandCategory/category_or_product.dart';
import '../rought_genrator.dart';
import '../utils/ResponsiveLayout.dart';
import '../utils/prefUtils.dart';
import '../widgets/eception_widget/product_not_found.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/simmers/singel_item_screen_shimmer.dart';

class RateReviewScreen extends StatefulWidget{
  String _varid;
  RateReviewScreen(this._varid);
  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> with Navigations{
  bool _isLoading = true;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      ProductController().getprodut(widget._varid.toString(),"").whenComplete(() {
        setState(() {
          _isLoading= false;
        });

      });
    });

    // TODO: implement initState
    super.initState();

  }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
     onWillPop: () {
       Navigator.of(context).pop();
       return Future.value(false);
     },
     child: Scaffold(
       appBar: ResponsiveLayout.isSmallScreen(context)
           ? gradientappbarmobile()
           : null,
       backgroundColor: ColorCodes.whiteColor,
       body: _isLoading? SingelItemScreenShimmer():  SingleChildScrollView(
         child: Column(
           children: <Widget>[
             if(Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))
               Header(false),
            _body(),
           ],
         ),
       ),
     ),
   );
  }

  _body(){
    return VxBuilder(builder: (context,store,state){
        return  Container(
          width: (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width:MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 15.0, bottom: 10.0,left:(Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?20:0,right: (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?20:0 ),
          color:ColorCodes.whiteColor,
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                      color: Colors.white,
                      height: (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))? MediaQuery.of(context).size.height/5:100,
                      width: (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))? MediaQuery.of(context).size.width/5:100,
                      margin:EdgeInsets.symmetric(
                          horizontal: 5.0,vertical: 10),
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.all(
                            Radius.circular(
                                5.0)),
                        child:
                        CachedNetworkImage(
                            imageUrl:store.singelproduct!.itemFeaturedImage,
                            placeholder: (context, url) => Image.asset(Images.defaultProductImg),
                            errorWidget: (context, url, error) => Image.asset(Images.defaultProductImg),
                            fit: BoxFit.fill),
                        /*],
                                                )*/
                      )),
                    SizedBox(width: 10,),
                    Column(mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 45,
                          width: (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))? MediaQuery.of(context).size.width/2.5:MediaQuery.of(context).size.width/1.5,
                          child: Text(
                            store.singelproduct!.itemName.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 14,
                                color: ColorCodes.black,
                              fontWeight: FontWeight.bold
                               ),
                          ),
                        ),
                        SizedBox(height: 5,),
                        store.singelproduct!.type=="1"?
                        RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: Features.iscurrencyformatalign?
                                  '${Check().checkmembership()?store.singelproduct!.membershipPrice:store.singelproduct!.price} ' + IConstants.currencyFormat:
                                  IConstants.currencyFormat + '${Check().checkmembership()?store.singelproduct!.membershipPrice:store.singelproduct!.price} ',
                                  style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                              new TextSpan(
                                  text: store.singelproduct!.price!=store.singelproduct!.mrp?
                                  Features.iscurrencyformatalign?
                                  '${store.singelproduct!.mrp} ' + IConstants.currencyFormat:
                                  IConstants.currencyFormat + '${store.singelproduct!.mrp} ':"",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    decoration:
                                    TextDecoration.lineThrough,
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                            ],
                          ),
                        ):
                        RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())

                              new TextSpan(
                                  text: Features.iscurrencyformatalign?
                                  '${Check().checkmembership()?store.singelproduct!.priceVariation![0].membershipPrice:store.singelproduct!.priceVariation![0].price} ' + IConstants.currencyFormat:
                                  IConstants.currencyFormat + '${Check().checkmembership()?store.singelproduct!.priceVariation![0].membershipPrice:store.singelproduct!.priceVariation![0].price} ',
                                  style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                              new TextSpan(
                                  text: store.singelproduct!.priceVariation![0].price!=store.singelproduct!.priceVariation![0].mrp?
                                  Features.iscurrencyformatalign?
                                  '${store.singelproduct!.priceVariation![0].mrp} ' + IConstants.currencyFormat:
                                  IConstants.currencyFormat + '${store.singelproduct!.priceVariation![0].mrp} ':"",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    decoration:
                                    TextDecoration.lineThrough,
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 18 : 20,)),
                            ],
                          ),
                        ),
                      ],
                    )
                ],
              ),
             if(Vx.isWeb) SizedBox(height: 10,),
              Padding(
                padding: const EdgeInsets.only(left:10.0,right:10,bottom: 5),
                child: Text(
                  "Ratings & Reviews",
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme
                          .of(context)
                          .primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left:10.0,right:10),
                width: (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width:MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          store.singelproduct!.rating!.toStringAsFixed(2), style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: ColorCodes.greenColor),
                        ),
                        SizedBox(width: 5,),
                        Image.asset(
                          Images.starImg,
                          width: 9,
                          height: 9,
                          color: ColorCodes.greenColor,
                          fit: BoxFit.fill,
                        ),

                      ],
                    ),
                    Text(store.singelproduct!.ratingCount.toString()+" ratings & "+store.singelproduct!.ratingCount.toString()+" reviews")
                  ],
                ),
              ),
              SizedBox(height: 15,),

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:10.0,right:10,bottom: 5),
                    child: Text(
                      "Product Reviews",
                      style: TextStyle(
                          fontSize: 16,
                          color: ColorCodes.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Spacer(),
                  Text(
                    store.singelproduct!.ratingCount.toString()+" Reviews",
                    style: TextStyle(
                        fontSize: 12,
                        color: ColorCodes.black,
                        ),
                  ),
                  SizedBox(width: 10,),
                ],
              ),
              Divider(color: ColorCodes.lightGreyWebColor,thickness: 1,),
              Container(
                width: (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.40:MediaQuery.of(context).size.width,
                child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(color: ColorCodes.lightGreyWebColor,thickness: 1,),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: store.singelproduct!.reviews!.length,
                    itemBuilder: (_, i) {
                      return Container(
                        padding: const EdgeInsets.only(left:10.0,right:10),
                        width: (Vx.isWeb&& !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.40:MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(store.singelproduct!.reviews![i].comment!,
                                style: TextStyle(fontSize: 12.0,color: ColorCodes.borderColor)),
                            SizedBox(height: 10,),
                            Text(store.singelproduct!.reviews![i].user!,
                                style: TextStyle(fontSize: 10.0,color: ColorCodes.lightGreyColor)),
                            SizedBox(height: 10,),
                          ],
                        ),
                      );
                    }
                ),
              ),
              Divider(color: ColorCodes.lightGreyWebColor,thickness: 1,),
              // SizedBox(height: 10,),
              if(Vx.isWeb) Footer(address: PrefUtils.prefs!.getString("restaurant_address")!),
            ],
          ),
        );

    }, mutations: {ProductMutation},);
  }
  gradientappbarmobile() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: (IConstants.isEnterprise)?0:1,
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorCodes.iconColor),
          onPressed: () {
            Navigator.of(context).pop();

          }),
      titleSpacing: 0,
      title: Text(
        "Product Review",
        style: TextStyle(color: ColorCodes.iconColor),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  ColorCodes.appbarColor,
                  ColorCodes.appbarColor2
                ])),
      ),
    );
  }
}