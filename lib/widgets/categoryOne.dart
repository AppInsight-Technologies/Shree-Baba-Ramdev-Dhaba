import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../assets/ColorCodes.dart';
import '../../constants/features.dart';
import '../../models/newmodle/home_page_modle.dart';

import '../constants/IConstants.dart';

import '../blocs/sliderbannerBloc.dart';
import '../models/categoriesModel.dart';
import 'package:shimmer/shimmer.dart';
import '../rought_genrator.dart';
import '../utils/ResponsiveLayout.dart';
import '../assets/images.dart';
import '../screens/items_screen.dart';

class CategoryOne extends StatefulWidget {
  HomePageData homedata;
  CategoryOne(this.homedata);

  @override
  _CategoryOneState createState() => _CategoryOneState();
}

class _CategoryOneState extends State<CategoryOne> with Navigations{
  var subcategoryData;
  bool _isWeb = false;
  var _categoryOne = false;
  @override
  void initState() {
    try {
      if (Platform.isIOS) {
        setState(() {
          _isWeb = false;
        });
      } else {
        setState(() {
          _isWeb = false;
        });
      }
    } catch (e) {
      setState(() {
        _isWeb = true;
      });
    }
    super.initState();
  }

  Widget _horizontalshimmerslider() {

    return _isWeb ?
    SizedBox.shrink()
        :
    Row(
      children: <Widget>[
        Expanded(
            child: Card(
              child: SizedBox(
                height: 100,
                child: Container(
                  padding:EdgeInsets.only(left: 28,right: 28),
                  child: new ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (_, i) => Column(
                      children: [
                        Row(
                          children: <Widget>[
                            Shimmer.fromColors(
                              baseColor: /*Color(0xffd3d3d3)*/Colors.grey[200]!,
                              highlightColor: /*Color(0xffeeeeee)*/Colors.grey[200]!,
                              child: Container(
                                width: 90.0,
                                height: 90.0,
                                color:/* Theme.of(context).buttonColor*/Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.homedata.data!.category1Details!.length > 0) {
      _categoryOne = true;
    } else {
      _categoryOne = false;
    }
    // return StreamBuilder(
    //   stream: bloc.categoryOne,
    //   builder: (context, AsyncSnapshot<List<CategoriesModel>> snapshot) {
        if (_categoryOne) {
          double deviceWidth = MediaQuery.of(context).size.width;
          int widgetsInRow = 4;
          double aspectRatio =
              (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 130;


          if (deviceWidth > 1200) {
            widgetsInRow = 8;
            aspectRatio =
            (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
            (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 165 :
            (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 295;
          } else if (deviceWidth > 968) {
            widgetsInRow = 6;
            aspectRatio =
            (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
            (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 195:
            (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 195;
          } else if (deviceWidth > 768) {
            widgetsInRow = 6;
            aspectRatio =
            (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
            (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 195:
            (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 195;
          }
          return Container(

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                   padding: EdgeInsets.only(left:(_isWeb&& !ResponsiveLayout.isSmallScreen(context))?20:10,right: (_isWeb&& !ResponsiveLayout.isSmallScreen(context))?20:10 ),
                  child:
                  Features.ismultivendor ?
                      SizedBox.shrink() :
                  Text(
                    widget.homedata.data!.categoryLabel!,
                    style: TextStyle(
                        fontSize: ResponsiveLayout.isSmallScreen(context)?18.0:24.0,
                        fontWeight: FontWeight.bold,
                        color:  ColorCodes.black),
                  ),
                ),
                MouseRegion(
                   cursor: MouseCursor.uncontrolled,
                  child: GridView.builder(
                      shrinkWrap: true,
                      controller: new ScrollController(keepScrollOffset: false),
                      itemCount: widget.homedata.data!.category1Details!.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widgetsInRow,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                      ),
                      itemBuilder: (_, i) =>
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                print("fromcatone: "+{'maincategor': widget.homedata.data!.category1Details![i].categoryName,
                                  'catId': widget.homedata.data!.category1Details![i].id,
                                  'catTitle': widget.homedata.data!.category1Details![i].categoryName,
                                  'indexvalue': i.toString(),
                                  'prev': "category_item"}.toString());
                                /*Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
                                  'maincategory': widget.homedata.data!.category1Details![i].categoryName,
                                  'catId':  widget.homedata.data!.category1Details![i].parentId,
                                  'catTitle': widget.homedata.data!.category1Details![i].categoryName,
                                  'indexvalue': i.toString(),
                                  'subcatId':  widget.homedata.data!.category1Details![i].id,
                                  'prev': "category_item"
                                });*/
                                Navigation(context, name: Routename.ItemScreen, navigatore: NavigatoreTyp.Push,
                                qparms: {
                                  'maincategory': widget.homedata.data!.category1Details![i].categoryName,
                                  'catId':  widget.homedata.data!.category1Details![i].parentId,
                                  'catTitle': widget.homedata.data!.category1Details![i].categoryName,
                                  'indexvalue': i.toString(),
                                  'subcatId':  widget.homedata.data!.category1Details![i].id,
                                  'prev': "category_item"
                                });
                              },
                              child: Container(
                                width: ResponsiveLayout.isSmallScreen(context)?100:150,
                                child:  Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(4)),
                                  ),
                                  elevation: 0,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                       //padding: const EdgeInsets.only(left:20.0,right: 5.0,top: 5.0),
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(4),
                                              topRight: Radius.circular(4),
                                              bottomLeft: Radius.circular(4),
                                              bottomRight: Radius.circular(4),
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: widget.homedata.data!.category1Details![i].iconImage,
                                              placeholder: (context, url) =>    Shimmer.fromColors(
                                                  baseColor: /*Color(0xffd3d3d3)*/Colors.grey[200]!,
                                                  highlightColor: /*Color(0xffeeeeee)*/Colors.grey[200]!,
                                                  child: Image.asset(Images.defaultCategoryImg))/*_horizontalshimmerslider()*/,
                                              errorWidget: (context, url, error) => Image.asset(Images.defaultCategoryImg),
                                              height: ResponsiveLayout.isSmallScreen(context)?90:130,
                                              width: ResponsiveLayout.isSmallScreen(context)?90:170,
                                              //fit: BoxFit.fill,
                                            )
                                        ),
                                      ),
                                      // Spacer(),
                                      SizedBox(height: 5,),
                                      Container(height: 30,
                                        padding: EdgeInsets.only(left:(_isWeb&& !ResponsiveLayout.isSmallScreen(context))?12:10 ),
                                        child: Center(

                                          child: Text(widget.homedata.data!.category1Details![i].categoryName!,
                                              overflow: TextOverflow.visible,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: ResponsiveLayout.isSmallScreen(context)?14.0:16.0,
                                                color: Features.ismultivendor ? ColorCodes.emailColor : ColorCodes.blackColor,

                                              )),
                                        ),
                                      ),
                                      //SizedBox(height: 5.0,),
                                    ],
                                  ),
                                ) ,
                                // )
                              ),
                            ),
                          )
                  ),
                ),
              ],
            ),
          );
        } /*else if (snapshot.hasError) {
          return SizedBox.shrink();
        } else if(snapshot.data.toString() == "null") {
          return SizedBox.shrink();
        }*/ else {
          return /*_horizontalshimmerslider()*/SizedBox.shrink();
        }
    //     },
    // );
  }
}

