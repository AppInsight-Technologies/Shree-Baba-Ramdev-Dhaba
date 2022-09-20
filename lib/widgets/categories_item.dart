import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../assets/ColorCodes.dart';
import 'package:velocity_x/velocity_x.dart';
import '../constants/IConstants.dart';
import '../rought_genrator.dart';
import '../utils/ResponsiveLayout.dart';
import 'package:provider/provider.dart';

import '../providers/notificationitems.dart';
import '../screens/items_screen.dart';
import '../models/categoriesfields.dart';
import '../screens/subcategory_screen.dart';
import '../assets/images.dart';

class CategoriesItem extends StatelessWidget with Navigations {
  final String previousScreen;
  final String maincategory;
  final String mainCategoryId;
  final String subCatId;
  final String subCatTitle;
  final int indexvalue;
  final String imageUrl;
  final String subCatDescription;

  CategoriesItem(this.previousScreen, this.maincategory, this.mainCategoryId,
      this.subCatId, this.subCatTitle, this.indexvalue, this.imageUrl,
      {this.subCatDescription = ''});
  int widgetsInRow = 3;

  @override
  Widget build(BuildContext context) {
    var categoriesData;
    bool _isNotSubCategory = false;
    bool _isSubCategory = false;

    final double width = MediaQuery.of(context).size.width - 20;

    if (previousScreen == "NotSubcategoryScreen") {
      categoriesData =
          Provider.of<NotificationItemsList>(context, listen: false);
      _isNotSubCategory = true;
    } else {
      categoriesData = Provider.of<CategoriesFields>(context, listen: false);
      _isNotSubCategory = false;
    }

    if (previousScreen == "SubcategoryScreen") {
      _isSubCategory = true;
    } else {
      _isSubCategory = false;
    }

    return (IConstants.isEnterprise)
        ? MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if (previousScreen == "SubcategoryScreen") {
                  /*Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
              'maincategory': maincategory,
              */ /*'catId' : categoriesData.catid.toString(),
              'catTitle': categoriesData.title.toString(),
              'subcatId' : categoriesData.subcatid.toString(),*/ /*
              'catId': mainCategoryId,
              'catTitle': subCatTitle,
              'subcatId': subCatId,
              'indexvalue': (indexvalue).toString(),
              'prev': "category_item"
            });*/
                  print("index value...." + indexvalue.toString());
                  Navigation(context,
                      name: Routename.ItemScreen,
                      navigatore: NavigatoreTyp.Push,
                      qparms: {
                        'maincategory': maincategory,
                        'catTitle': categoriesData.title.toString(),
                        'subcatId': categoriesData.subcatid.toString(),
                        'catId': mainCategoryId,
                        'catTitle': subCatTitle,
                        'subcatId': subCatId,
                        'indexvalue': (indexvalue).toString(),
                        'prev': "category_item"
                      });
                } else if (previousScreen == "NotSubcategoryScreen") {
                  /* Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
              'maincategory': maincategory,
              'catId': categoriesData.catitems[indexvalue].catid.toString(),
              'catTitle': categoriesData.catitems[indexvalue].title.toString(),
              'subcatId': categoriesData.catitems[indexvalue].subcatid.toString(),
              'indexvalue': (indexvalue).toString(),
              'prev': "category_item"
            });*/
                  print("index value...." + indexvalue.toString());
                  Navigation(context,
                      name: Routename.ItemScreen,
                      navigatore: NavigatoreTyp.Push,
                      parms: {
                        'maincategory': maincategory,
                        'catId': categoriesData.catitems![indexvalue].catid
                            .toString(),
                        'catTitle': categoriesData.catitems[indexvalue].title
                            .toString(),
                        'subcatId': categoriesData.catitems[indexvalue].subcatid
                            .toString(),
                        'indexvalue': (indexvalue).toString(),
                        'prev': "category_item"
                      });
                } else {
                  /* Navigator.of(context)
                .pushNamed(SubcategoryScreen.routeName, arguments: {
              'catId': categoriesData.catid.toString(),
              'catTitle': categoriesData.title.toString(),
            });*/
                  Navigation(context,
                      name: Routename.SubcategoryScreen,
                      navigatore: NavigatoreTyp.Push,
                      parms: {
                        'catId': categoriesData.catid.toString(),
                        'catTitle': categoriesData.title.toString(),
                      });

                  //  Navigator.of(context).pushNamed(
                  //   SubcategoryScreen.routeName,
                  //  );
                }
              },
              child: Container(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                    color: ColorCodes.headerColor,
                    border: Border.all(color: ColorCodes.headerColor),
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: _isNotSubCategory
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: 100.0,
                                height: 80.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.fill),
                                ),
                              ),
                              placeholder: (context, url) =>
                                  Image.asset(Images.defaultCategoryImg),
                              errorWidget: (context, url, error) =>
                                  Image.asset(Images.defaultCategoryImg),
                              //height: ResponsiveLayout.isSmallScreen(context)?80:120,

                              //height: ResponsiveLayout.isSmallScreen(context) ? 60  : 60,
                              // width: ResponsiveLayout.isSmallScreen(context) ? (width / widgetsInRow) - 50  : 145,
                              fit: BoxFit.contain,
                            )
                          : _isSubCategory
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  // imageBuilder: (context, imageProvider) =>
                                  //     Container(
                                  //   width: 100.0,
                                  //   height: 80.0,
                                  //   decoration: BoxDecoration(
                                  //     shape: BoxShape.circle,
                                  //     image: DecorationImage(
                                  //         image: imageProvider,
                                  //         fit: BoxFit.fill),
                                  //   ),
                                  // ),
                                  placeholder: (context, url) =>
                                      Image.asset(Images.defaultCategoryImg),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(Images.defaultCategoryImg),
                                  height: 100,
                                  width: 100,
                                  // height: ResponsiveLayout.isSmallScreen(context)  ? 60 : 60,
                                  // width: ResponsiveLayout.isSmallScreen(context)  ? (width / widgetsInRow) - 50 : 145,
                                  fit: BoxFit.fill,
                                )
                              : CachedNetworkImage(
                                  imageUrl: categoriesData.imageUrl,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 100.0,
                                    height: 80.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      Image.asset(Images.defaultCategoryImg),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(Images.defaultCategoryImg),
                                  //height:ResponsiveLayout.isSmallScreen(context)? 80:110,
                                  // height: ResponsiveLayout.isSmallScreen(context)  ? 60 : 60,

                                  //width:ResponsiveLayout.isSmallScreen(context)? 80:140,
                                  // width: ResponsiveLayout.isSmallScreen(context)  ? (width / widgetsInRow) - 50 : 145,

                                  fit: BoxFit.fill,
                                ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 8),
                          child: Text(
                            subCatTitle,
                            style: TextStyle(
                                //color: ColorCodes.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(left:8.0),
                        //   child: Text(subCatDescription, style: TextStyle(color: ColorCodes.whiteColor, fontSize: 10),),
                        // )
                      ],
                    ),
                    //SizedBox(height: 6),

                    /*
            Flexible(
                child: Center(
                    child: _isNotSubCategory
                        ? Text(categoriesData.catitems[indexvalue].title,
                        textAlign: TextAlign.center,
                       // maxLines: 2,
                        style: TextStyle(fontWeight: FontWeight.bold,
                            fontSize: ResponsiveLayout.isSmallScreen(context)?12:15))
                        : _isSubCategory
                        ? Text(subCatTitle,
                        textAlign: TextAlign.center,
                      //  maxLines: 2,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: ResponsiveLayout.isSmallScreen(context)?12:15))
                        : Text(categoriesData.title,
                        textAlign: TextAlign.center,
                       // maxLines: 2,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize:ResponsiveLayout.isSmallScreen(context)?12:15))),
            ),
            */
                  ],
                ),
              ),
            ),
          )
        : GestureDetector(
            onTap: () {
              if (previousScreen == "SubcategoryScreen") {
                /* Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
            'maincategory': maincategory,
            */ /*'catId' : categoriesData.catid.toString(),
            'catTitle': categoriesData.title.toString(),
            'subcatId' : categoriesData.subcatid.toString(),*/ /*
            'catId': mainCategoryId,
            'catTitle': subCatTitle,
            'subcatId': subCatId,
            'indexvalue': indexvalue.toString(),
            'prev': "category_item"
          });*/
                print("index value...." + indexvalue.toString());

                Navigation(context,
                    name: Routename.ItemScreen,
                    navigatore: NavigatoreTyp.Push,
                    qparms: {
                      'maincategory': maincategory,
                      'catTitle': categoriesData.title.toString(),
                      'subcatId': categoriesData.subcatid.toString(),
                      'catId': mainCategoryId,
                      'catTitle': subCatTitle,
                      'subcatId': subCatId,
                      'indexvalue': indexvalue.toString(),
                      'prev': "category_item"
                    });
              } else if (previousScreen == "NotSubcategoryScreen") {
                /*Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
            'maincategory': maincategory,
            'catId': categoriesData.catitems[indexvalue].catid.toString(),
            'catTitle': categoriesData.catitems[indexvalue].title.toString(),
            'subcatId': categoriesData.catitems[indexvalue].subcatid.toString(),
            'indexvalue': indexvalue.toString(),
            'prev': "category_item"
          });*/
                print("index value...." + indexvalue.toString());
                Navigation(context,
                    name: Routename.ItemScreen,
                    navigatore: NavigatoreTyp.Push,
                    qparms: {
                      'maincategory': maincategory,
                      'catId':
                          categoriesData.catitems[indexvalue].catid.toString(),
                      'catTitle':
                          categoriesData.catitems[indexvalue].title.toString(),
                      'subcatId': categoriesData.catitems[indexvalue].subcatid
                          .toString(),
                      'indexvalue': indexvalue.toString(),
                      'prev': "category_item"
                    });
              } else {
                /*  Navigator.of(context)
              .pushNamed(SubcategoryScreen.routeName, arguments: {
            'catId': categoriesData.catid.toString(),
            'catTitle': categoriesData.title.toString(),
          });*/
                Navigation(context,
                    name: Routename.SubcategoryScreen,
                    navigatore: NavigatoreTyp.Push,
                    parms: {
                      'catId': categoriesData.catid.toString(),
                      'catTitle': categoriesData.title.toString(),
                    });
                //  Navigator.of(context).pushNamed(
                //   SubcategoryScreen.routeName,
                //  );
              }
            },
            child: Column(
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(3),
                        topRight: Radius.circular(3),
                        bottomLeft: Radius.circular(3),
                        bottomRight: Radius.circular(3),
                      ),
                      child: _isNotSubCategory
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (context, url) =>
                                  Image.asset(Images.defaultCategoryImg),
                              errorWidget: (context, url, error) =>
                                  Image.asset(Images.defaultCategoryImg),
                              height: 90,
                              width: 85,
                            )
                          : _isSubCategory
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  placeholder: (context, url) =>
                                      Image.asset(Images.defaultCategoryImg),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(Images.defaultCategoryImg),
                                  height: 90,
                                  width: 85,
                                )
                              : CachedNetworkImage(
                                  imageUrl: categoriesData.imageUrl,
                                  placeholder: (context, url) =>
                                      Image.asset(Images.defaultCategoryImg),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(Images.defaultCategoryImg),
                                  height: 90,
                                  width: 85,
                                )),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  height: 30,
                  padding: EdgeInsets.only(
                      left:
                          (Vx.isWeb && !ResponsiveLayout.isSmallScreen(context))
                              ? 12
                              : 10),
                  child: Center(
                      child: _isNotSubCategory
                          ? Text(categoriesData.catitems[indexvalue].title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12.0))
                          : _isSubCategory
                              ? Text(subCatTitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0))
                              : Text(categoriesData.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0))),
                ),
              ],
            ),
          );
  }
}
