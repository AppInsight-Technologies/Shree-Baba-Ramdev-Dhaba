import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../constants/features.dart';
import '../models/VxModels/VxStore.dart';
import '../rought_genrator.dart';
import '../screens/otpconfirm_screen.dart';
import 'package:velocity_x/velocity_x.dart';
import '../constants/api.dart';
import '../generated/l10n.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../assets/ColorCodes.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../utils/prefUtils.dart';
import '../screens/home_screen.dart';
import '../constants/IConstants.dart';

class EditScreen extends StatefulWidget {
  static const routeName = '/edit-screen';

  @override
  EditScreenState createState() => EditScreenState();
}

class EditScreenState extends State<EditScreen> with Navigations{
  final _lnameFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  String fn = "";
  String ln = "";
  String ea = "";
  String mb = "";
  var name = "", email = "", phone = "";
  bool _isWeb = false;
  final TextEditingController firstnamecontroller = new TextEditingController();
  final TextEditingController mobileNumberController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  bool iphonex = false;
  GroceStore store = VxState.store;
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
    Future.delayed(Duration.zero, () async {
      try {
        if (Platform.isIOS) {
          setState(() {
            _isWeb = false;
            iphonex = MediaQuery
                .of(context)
                .size
                .height >= 812.0;
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
      setState(() {
       /* if (PrefUtils.prefs!.getString('FirstName') != null) {
          if (PrefUtils.prefs!.getString('LastName') != null) {
            name = PrefUtils.prefs!.getString('FirstName') +
                " " +
                PrefUtils.prefs!.getString('LastName');
          } else {
            name = PrefUtils.prefs!.getString('FirstName');
          }
        } else {
          name = "";
        }
*/
        name = store.userData.username!;
        phone = store.userData.mobileNumber!;
        email = store.userData.email!;
     /*   if (PrefUtils.prefs!.getString('mobile') != null) {
          phone = PrefUtils.prefs!.getString('mobile')!;
        } else {
          phone = "";
        }*/
      /*  if (PrefUtils.prefs!.getString('Email') != null) {
          email = PrefUtils.prefs!.getString('Email')!;
        } else {
          email = "";
        }*/
        firstnamecontroller.text = name;
        mobileNumberController.text = phone;
        emailController.text = email;
      });
    });
    super.initState();
  }
  Future<void> checkemail(String email) async {
    print("emailcheck....");
    try {
      final response = await http.post(Api.emailCheck, body: {
        "email": email,
      });
      final responseJson = json.decode(response.body);

      if (responseJson['status'].toString() == "true") {
        if (responseJson['type'].toString() == "old") {
          print("emailcheck....old");
          Navigator.of(context).pop();
          //Fluttertoast.showToast(msg: 'Email id already exists!!!');
          Fluttertoast.showToast(
              msg: S .of(context).email_exist,//"Email id already exists",
              fontSize: MediaQuery.of(context).textScaleFactor *13,
              backgroundColor: Colors.black87,
              textColor: Colors.white);;
        } else if (responseJson['type'].toString() == "new") {
          print("emailcheck....new");
          return UpdateProfile();
        }
      } else {
        Fluttertoast.showToast(msg: S .of(context).something_went_wrong,//"Something went wrong!!!"
        );
      }
    } catch (error) {
      throw error;
    }
  }


  Future<void> _getOtp(String mobile) async {
    try {
      final response = await http.post(Api.preRegister, body: {
        // await keyword is used to wait to this operation is complete.
        "mobileNumber": mobile,
        "tokenId": PrefUtils.prefs!.getString('ftokenid'),
        "signature": PrefUtils.prefs!.containsKey("signature") ? PrefUtils.prefs!.getString('signature') : "",
        "branch" : PrefUtils.prefs!.getString("branch"),
      });
      final responseJson = json.decode(response.body);
      print("respobse edit ..."+responseJson.toString());
      final data = responseJson['data'] as Map<String, dynamic>;


      if (responseJson['status'].toString() == "true") {
        if(responseJson['type'].toString() == "old") {
          Navigator.of(context).pop();
           Fluttertoast.showToast(msg:
          S .of(context).mobile_exists,
          // "Mobile Number already exists!",
            fontSize: MediaQuery.of(context).textScaleFactor *13,);
        } else {
          Navigator.of(context).pop();
          PrefUtils.prefs!.setString("userapikey", PrefUtils.prefs!.getString('apikey').toString());
          PrefUtils.prefs!.setString('Otp', data['otp'].toString());
          PrefUtils.prefs!.setString('Mobilenum',mobileNumberController.text);
          PrefUtils.prefs!.setBool('type',false);

          store.userData.mobileNumber = mobileNumberController.text;
          debugPrint("otp...edit apikey "+PrefUtils.prefs!.getString('userapikey')!);
          debugPrint("otp...edit apikey "+PrefUtils.prefs!.getString('apikey')!);
          debugPrint("otp...edit"+PrefUtils.prefs!.getString('Otp')!);

         /* Navigator.of(context).pushNamed(OtpconfirmScreen.routeName,
              arguments: {
               "prev":"editscreen",
                "firstName":firstnamecontroller.text,
                "mobileNum":mobileNumberController.text,
                "email":emailController.text,
              });*/

          Navigation(context, name: Routename.OtpConfirm, navigatore: NavigatoreTyp.Push,
              qparms: {
                "prev":"editscreen",
                "firstName":firstnamecontroller.text,
                "mobileNum":mobileNumberController.text,
                "email":emailController.text,
              });
        }
//        Navigator.of(context).pushNamed(
//          OtpconfirmScreen.routeName,
//        );

      } else if (responseJson['status'].toString() == "false") {}
    } catch (error) {
      throw error;
    }
  }

  Future<void> UpdateProfile() async {
    try {
      final response = await http.post(Api.updateCustomerProfile, body: {
        "id": PrefUtils.prefs!.getString('apikey'),
        "name": firstnamecontroller.text,
        "mobile": mobileNumberController.text,
        "email": emailController.text,
      });

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson["status"] == 200) {
        PrefUtils.prefs!.setString('FirstName', firstnamecontroller.text);
        PrefUtils.prefs!.setString('LastName', "");
        PrefUtils.prefs!.setString('mobile', mobileNumberController.text);
        PrefUtils.prefs!.setString('Email', emailController.text);

        store.userData.username = firstnamecontroller.text;
        store.userData.mobileNumber = mobileNumberController.text;
        store.userData.email = emailController.text;

        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigation(context, navigatore: NavigatoreTyp.homenav);
        //Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
      } else {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: S .of(context).something_went_wrong,
            // "Something went wrong",
            fontSize: MediaQuery.of(context).textScaleFactor *13,
            backgroundColor: Colors.black87,
            textColor: Colors.white);
      }
    } catch (error) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg:S .of(context).something_went_wrong,
          // "Something went wrong",
          fontSize: MediaQuery.of(context).textScaleFactor *13,
          backgroundColor: Colors.black87,
          textColor: Colors.white);
      throw error;
    }
  }

  @override
  void dispose() {
    firstnamecontroller.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    super.dispose();
  }

  _dialogforProcessing() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AbsorbPointer(
              child: Container(
                color: Colors.transparent,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            );
          });
        });
  }

  _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState!.save();

    if(mobileNumberController.text == /*PrefUtils.prefs!.getString("mobile")*/store.userData.mobileNumber!
    && emailController.text == store.userData.email) {
      _dialogforProcessing();
      UpdateProfile();
    } else {
      if(mobileNumberController.text != store.userData.mobileNumber){
        _dialogforProcessing();
        _getOtp(mobileNumberController.text);
      }
      else {
        _dialogforProcessing();
        checkemail(emailController.text);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: ResponsiveLayout.isSmallScreen(context) ?
      gradientappbarmobile() : null,
      backgroundColor: ColorCodes.whiteColor,
      body:  Column(
        children: <Widget>[
          if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
            Header(false),
          _body(),
        ],
      ),
      bottomNavigationBar: _isWeb ? SizedBox.shrink() : Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
        child:_bottomNavigationBar(),
      ),
    );
  }
  _bottomNavigationBar() {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          _saveForm();
        },
        child: Container(
          height: 50,
          width: double.infinity,
          color: Theme.of(context).primaryColor,
          child: Center(
            child: Text(
              S .of(context).update_profile,
              // 'UPDATE PROFILE',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
  _body(){
    return Expanded(
      child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 30.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        S .of(context).what_should_we_call_you,
                       // '* What should we call you?',
                        style: TextStyle(fontSize: 17, color: ColorCodes.lightBlack),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        textAlign: TextAlign.left,
                        controller: firstnamecontroller,
                        decoration: InputDecoration(
                          hoverColor: ColorCodes.greenColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: ColorCodes.greenColor),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: ColorCodes.greenColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: ColorCodes.greenColor),
                          ),
                        ),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_lnameFocusNode);
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            setState(() {
                              fn = "  Please enter name";
                            });
                            return '';
                          }
                          setState(() {
                            fn = "";
                          });
                          return null;
                        },
                        onSaved: (value) {
                          //addFirstnameToSF(value);
                        },
                      ),
                      Text(
                        fn,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        S .of(context).mobile_number,
                        // 'Mobile number',
                        style: TextStyle(fontSize: 17, color: ColorCodes.lightBlack),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.number,
                        controller: mobileNumberController,
                        style: new TextStyle(
                            decorationColor: Theme.of(context).primaryColor),
                        inputFormatters: [LengthLimitingTextInputFormatter(12)],
                        decoration: InputDecoration(
                          hintText: S .of(context).your_number,
                          // 'Your number',
                          fillColor: ColorCodes.greenColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: ColorCodes.greenColor),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: ColorCodes.greenColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                            BorderSide(color: ColorCodes.greenColor, width: 1.2),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            setState(() {
                              mb = "  Please enter number";
                            });
                            return '';
                          }
                          setState(() {
                            mb = "";
                          });
                          return null;
                        },
                        onSaved: (value) {
                          //addEmailToSF(value);
                        },
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        mb,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        S .of(context).tell_us_your_email,
                        // 'Tell us your e-mail',
                        style: TextStyle(fontSize: 17, color: ColorCodes.lightBlack),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        style: new TextStyle(
                            decorationColor: Theme.of(context).primaryColor),
                        decoration: InputDecoration(
                          hintText: 'xyz@gmail.com',
                          fillColor: ColorCodes.greenColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: ColorCodes.greenColor),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: ColorCodes.greenColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                            BorderSide(color: ColorCodes.greenColor, width: 1.2),
                          ),
                        ),
                        validator: (value) {
                          bool emailValid;
                          if (value == "")
                            emailValid = true;
                          else
                            emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value!);

                          if (!emailValid) {
                            setState(() {
                              ea = ' Please enter a valid email address';
                            });
                            return '';
                          }
                          setState(() {
                            ea = "";
                          });
                          return null; //it means user entered a valid input
                        },
                        onSaved: (value) {
                          // addEmailToSF(value);
                        },
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            ea,
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20,),
              if(_isWeb)
                _bottomNavigationBar(),
              SizedBox(height: 30,),
              if(_isWeb) Footer(address: PrefUtils.prefs!.getString("restaurant_address")!),
            ],

          ),
        ),
    );


  }
gradientappbarmobile() {
  return  AppBar(
    brightness: Brightness.dark,
    toolbarHeight: 60.0,
    elevation: (IConstants.isEnterprise)?0:1,
    automaticallyImplyLeading: false,
    leading: IconButton(icon: Icon(Icons.arrow_back,size: 20, color: ColorCodes.iconColor),onPressed: ()=>
        Navigator.of(context).pop()),
    title: Text(
      S .of(context).edit_info,

      // 'Edit your info',
      style: TextStyle(color: ColorCodes.iconColor),
    ),
    titleSpacing: 0,
    flexibleSpace: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                ColorCodes.appbarColor,
                ColorCodes.appbarColor2
              ]
          )
      ),
    ),
  );
}
}
