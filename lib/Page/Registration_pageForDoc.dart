import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Page/Login_page.dart';
import 'package:flutter_application_1/Page/adress.dart';
import 'package:flutter_application_1/Page/showLoading.dart';
import 'package:flutter_application_1/common/them_helper.dart';
import 'package:flutter_application_1/homepage.dart';
import 'package:flutter_application_1/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'VerifyEmailPage.dart';
import 'Widgets/Header_widget.dart';
import 'profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Specialite.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegistrationPageForDoc extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegistrationPageForDocState();
  }
}

List<dynamic> items = [];
var photo;
File? file;

class _RegistrationPageForDocState extends State<RegistrationPageForDoc> {
  final _formKey = GlobalKey<FormState>();
  File? pickedImage;

  // pickImage(ImageSource imageType) async {
  //   try {
  //     photo = await ImagePicker().pickImage(source: imageType);
  //     if (photo == null) return;
  //     final tempImage = File(photo.path);
  //     setState(() {
  //       pickedImage = tempImage;
  //     });

  //     Get.back();
  //   } catch (error) {
  //     debugPrint(error.toString());
  //   }
  // }

  // imagePickerOption() {
  //   var pic;
  //   Get.bottomSheet(
  //     SingleChildScrollView(
  //       child: ClipRRect(
  //         borderRadius: const BorderRadius.only(
  //           topLeft: Radius.circular(10.0),
  //           topRight: Radius.circular(10.0),
  //         ),
  //         child: Container(
  //           color: Colors.white,
  //           height: 250,
  //           child: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: [
  //                 const Text(
  //                   "Choissir Une Image ",
  //                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //                   textAlign: TextAlign.center,
  //                 ),
  //                 const SizedBox(
  //                   height: 20,
  //                 ),
  //                 ElevatedButton.icon(
  //                   onPressed: () async {
  //                     pic = await pickImage(ImageSource.camera);
  //                   },
  //                   icon: const Icon(Icons.camera),
  //                   label: const Text("CAMERA"),
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 ElevatedButton.icon(
  //                   onPressed: () async {
  //                     pic = await pickImage(ImageSource.gallery);
  //                   },
  //                   icon: const Icon(Icons.image),
  //                   label: const Text("GALLERY"),
  //                 ),
  //                 const SizedBox(
  //                   height: 10,
  //                 ),
  //                 ElevatedButton.icon(
  //                   onPressed: () {
  //                     pic = null;
  //                     Get.back();
  //                   },
  //                   icon: const Icon(Icons.close),
  //                   label: const Text("CANCEL"),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  bool checkedValue = false;
  bool checkboxValue = false;
  late UserCredential userCredential;
  var firstname, lastname, email, password, phone,Urldownload;
  // List<String> items = [
  //   "cardiologue",
  //   "pédiatre",
  //   "généraliste",
  //   "radiologue",
  //   "physiatre"
  // ];

  PlatformFile? pickedFile;
  UploadTask? uploadTask;

 Future uploadFile() async {
    final path = 'files/images/${pickedFile!.name}';
    final file = File(pickedFile!.path!);
    //FirebaseStorage
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() {});
    // The link to the profil image ///////////////////////////////////////////////
    final urldownload = await snapshot.ref.getDownloadURL();
    Urldownload=urldownload;
    //////////////////////////////////////---------------------URL --------------------------////////////////////////////////////
    print('Download Link of the profil image: $urldownload');
  }

  Future selectfile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  String? specialite;
  Future signUp() async {
    if (_formKey.currentState!.validate() && specialite != null) {
      var formdata = _formKey.currentState;
      formdata?.save();

      try {
        showLoading(context);
        userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await FirebaseFirestore.instance
            .collection("Docuser")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .set({
          "about": "",
          "owner": FirebaseAuth.instance.currentUser?.uid,
          "email": email,
          "firstname": firstname,
          "lastname": lastname,
          "isAccepted": false,
          "phone": phone,
          "specialité": specialite,
           "picture":Urldownload,
        });

        // await FirebaseFirestore.instance.collection("Docuser").add({
        //   "about":null,
        //    "owner":FirebaseAuth.instance.currentUser?.uid,
        //     "email": email,
        //     "firstname": firstname,
        //     "lastname":lastname,
        //      "isAccepted":false,
        //      "phone":phone,
        //      "specialité":specialite,
        // });

        Navigator.pushReplacementNamed(context, "verify");

        // Navigator.pushReplacementNamed(context, "home");

        //   User? user = FirebaseAuth
        //                 .instance.currentUser;
        //             await user?.sendEmailVerification();
        //             showDialog(
        //                 context: context,
        //                 builder:
        //                     (BuildContext context) {
        //                   return ThemHelper().alartDialog(
        //                       "Email verification:",
        //                       "We have sent a mail to your email to verify it.",
        //                       context);
        //                 },
        //               );
        //                if (userCredential
        //                   .user?.emailVerified ==
        //               true){print(userCredential.user?.emailVerified);
        //               print("==================================");
        //  Navigator.pushReplacementNamed(context, "home");}
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ThemHelper().alartDialog(
                  "Password", "The password provided is too weak.", context);
            },
          );
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          Navigator.of(context).pop();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ThemHelper().alartDialog("Email",
                  "The account already exists for that email.", context);
            },
          );
          print('The account already exists for that email.');
        } else {
          Navigator.of(context).pop();

          print(e);

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ThemHelper()
                  .alartDialog("erreur", e.message.toString(), context);
            },
          );
        }
      }
    }
  }

  Future listing() async {
    print("workiiiiiiiiiiiiiiiiing");
    await FirebaseFirestore.instance
        .collection("Specialities")
        .doc("Cf5dTa9simlqt95ntgxZ")
        .get()
        .then((event) {
      setState(() {
        items = event.get("spec");
      });
      print(items);
      print("yes");
    });
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    listing();
    print("================");
    print(items);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: h * 0.22,
              child:
                  HeaderWidget(h * 0.22, false, Icons.person_add_alt_1_rounded),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(25, 50, 25, 10),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      width: w * 0.005, color: Colors.white),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 20,
                                      offset: const Offset(5, 5),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                  child: pickedFile != null
                      ? Image.file(
                          File(pickedFile!.path!),
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: MediaQuery.of(context).size.height * 0.2,
                          fit: BoxFit.cover,
                        )
                      :  Icon(
                                        Icons.person,
                                        color: Colors.grey.shade300,
                                        size: h * 0.14,
                                      ),
                ),
                               /* child: pickedFile != null
                                    ? Image.file(
                                        File(pickedFile!.path!),
                                        //width:MediaQuery.of(context).size.width * 0.35,
                                        //height:MediaQuery.of(context).size.height *0.2,
                                        fit: BoxFit.cover,
                                      )
                                    :
                                    Icon(
                                        Icons.person,
                                        color: Colors.grey.shade300,
                                        size: h * 0.14,
                                      ),*/
                              ),
                              Container(
                                  padding: EdgeInsets.fromLTRB(80, 80, 0, 0),
                                  child: IconButton(
                                    onPressed: () async {
                                      selectfile();
                                      //  await imagePickerOption();
                                      print("ffffffffffffff");
                                      if (photo != null) {
                                        print(
                                            "YEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEES");
                                        file = File(photo.path);
                                        //  var nameimage = basename()
                                      } else {
                                        print(
                                            "NOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO  OOOOOOO");
                                      }
                                    },
                                    icon: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey.shade700,
                                      size: h * 0.045,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(height: h * 0.01),
                        Text(
                          "Welcome Doctor!".toUpperCase(),
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(
                          height: h * 0.06,
                        ),
                        // profileImage(),
                        Container(
                          child: TextFormField(
                            onSaved: (val) {
                              firstname = val;
                            },
                            decoration: ThemHelper().textInputDecoration(
                                'First Name', 'Enter your first name'),
                            validator: (val) {
                              int? x = val?.length;
                              if (x! > 20) {
                                return "user name cant be larger than 20 letter";
                              }
                              if (x! < 2) {
                                return "user name cant be less than 3 letter";
                              }
                              if (val!.isEmpty) {
                                return "Please enter your first name";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(
                          height: h * 0.03,
                        ),
                        Container(
                          child: TextFormField(
                            onSaved: (val) {
                              lastname = val;
                            },
                            decoration: ThemHelper().textInputDecoration(
                                'Last Name', 'Enter your last name'),
                            validator: (val) {
                              int? x = val?.length;
                              if (x! > 20) {
                                return "user name cant be larger than 20 letter";
                              }
                              if (x! < 2) {
                                return "user name cant be less than 3 letter";
                              }
                              if (val!.isEmpty) {
                                return "Please enter your last name";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(height: h * 0.03),
                        Container(
                          alignment: Alignment.topLeft,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          child: Text(
                            "Selectioner une spécialité :",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.normal,
                                fontSize: 17),
                          ),
                        ),
                        SizedBox(height: h * 0.01),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 17, vertical: 2),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: specialite,
                              isExpanded: true,
                              items: items
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 15),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (item) =>
                                  setState(() => specialite = item),
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12, width: 2),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        // Container(
                        //   child: Specialite(),
                        //   decoration: ThemHelper().inputBoxDecorationShaddow(),
                        // ),
                        SizedBox(height: h * 0.03),
                        Container(
                          child: TextFormField(
                            onSaved: (val) {
                              phone = val;
                            },
                            decoration: ThemHelper().textInputDecoration(
                                "Mobile Number", "Enter your mobile number"),
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if (!(val!.isEmpty) &&
                                  !RegExp(r"^(\d+)*$").hasMatch(val)) {
                                return "Enter a valid phone number";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(height: h * 0.03),
                        Container(
                          child: TextFormField(
                            onSaved: (val) {
                              email = val;
                            },
                            decoration: ThemHelper().textInputDecoration(
                                "E-mail address", "Enter your email"),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (!(val!.isEmpty) &&
                                  !RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                      .hasMatch(val)) {
                                return "Enter a valid email address";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(height: h * 0.03),
                        Container(
                          child: TextFormField(
                            onSaved: (val) {
                              password = val;
                            },
                            obscureText: true,
                            decoration: ThemHelper().textInputDecoration(
                                "Password", "Enter your password"),
                            validator: (val) {
                              int? x = val?.length;
                              if (x! > 20) {
                                return "password cant be larger than 20 letter";
                              }
                              if (x! < 8) {
                                return "password cant be smaller than 8 letter";
                              }
                              if (val!.isEmpty) {
                                return "Please enter your password";
                              }
                              return null;
                            },
                          ),
                          decoration: ThemHelper().inputBoxDecorationShaddow(),
                        ),
                        SizedBox(height: h * 0.03),
                        FormField<bool>(
                          builder: (state) {
                            return Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Checkbox(
                                        value: checkboxValue,
                                        onChanged: (value) {
                                          setState(() {
                                            checkboxValue = value!;
                                            state.didChange(value);
                                          });
                                        }),
                                    Text(
                                      "I accept all terms and conditions.",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    state.errorText ?? '',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Theme.of(context).errorColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                          validator: (value) {
                            if (!checkboxValue) {
                              return 'You need to accept terms and conditions';
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: h * 0.04),
                        Container(
                          decoration: ThemHelper().buttonBoxDecoration(context),
                          child: ElevatedButton(
                              style: ThemHelper().buttonStyle(),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(40, 10, 40, 10),
                                child: Text(
                                  "Register".toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                await uploadFile();
                                if (specialite == null) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ThemHelper().alartDialog(
                                          "Specialité:",
                                          "Selectioner une spécialité svp!.",
                                          context);
                                    },
                                  );
                                }

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Confirmation:"),
                                      content: Text(
                                          "Are you sure your informations?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("CANCEL")),
                                        TextButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              signUp();
                                            },
                                            child: Text("CONFIRMER"))
                                      ],
                                    );

                                    ;
                                  },
                                );
                                // Navigator.of(context).pushAndRemoveUntil(
                                //     MaterialPageRoute(
                                //         builder: (context) => HomePgae()),
                                //     (Route<dynamic> route) => false);

                                // if (_formKey.currentState!.validate() &&
                                //     specialite != null) {
                                //   var formdata = _formKey.currentState;

                                //   formdata?.save();

                                //   try {
                                //     userCredential = await FirebaseAuth.instance
                                //         .createUserWithEmailAndPassword(
                                //       email: email,
                                //       password: password,
                                //     );
                                //     Navigator.pushReplacementNamed(
                                //         context, "home");

                                //     //   User? user = FirebaseAuth
                                //     //                 .instance.currentUser;
                                //     //             await user?.sendEmailVerification();
                                //     //             showDialog(
                                //     //                 context: context,
                                //     //                 builder:
                                //     //                     (BuildContext context) {
                                //     //                   return ThemHelper().alartDialog(
                                //     //                       "Email verification:",
                                //     //                       "We have sent a mail to your email to verify it.",
                                //     //                       context);
                                //     //                 },
                                //     //               );
                                //     //                if (userCredential
                                //     //                   .user?.emailVerified ==
                                //     //               true){print(userCredential.user?.emailVerified);
                                //     //               print("==================================");
                                //     //  Navigator.pushReplacementNamed(context, "home");}
                                //   } on FirebaseAuthException catch (e) {
                                //     if (e.code == 'weak-password') {
                                //       showDialog(
                                //         context: context,
                                //         builder: (BuildContext context) {
                                //           return ThemHelper().alartDialog(
                                //               "Password",
                                //               "The password provided is too weak.",
                                //               context);
                                //         },
                                //       );
                                //       print(
                                //           'The password provided is too weak.');
                                //     } else if (e.code ==
                                //         'email-already-in-use') {
                                //       showDialog(
                                //         context: context,
                                //         builder: (BuildContext context) {
                                //           return ThemHelper().alartDialog(
                                //               "Email",
                                //               "The account already exists for that email.",
                                //               context);
                                //         },
                                //       );
                                //       print(
                                //           'The account already exists for that email.');
                                //     } else {
                                //       print(e);

                                //       showDialog(
                                //         context: context,
                                //         builder: (BuildContext context) {
                                //           return ThemHelper().alartDialog(
                                //               "erreur",
                                //               e.toString().replaceAll(
                                //                   "[firebase_auth/invalid-email]",
                                //                   ""),
                                //               context);
                                //         },
                                //       );
                                //     }
                                //   }

                                //   //  if (userCredential
                                //   //                 .user?.emailVerified ==
                                //   //             false) {
                                //   //           User? user = FirebaseAuth
                                //   //               .instance.currentUser;
                                //   //           await user?.sendEmailVerification();
                                //   //           showDialog(
                                //   //               context: context,
                                //   //               builder:
                                //   //                   (BuildContext context) {
                                //   //                 return ThemHelper().alartDialog(
                                //   //                     "Email verification:",
                                //   //                     "We have sent a mail to your email to verify it.",
                                //   //                     context);
                                //   //               },
                                //   //             );
                                //   //         }
                                // }
                              }),
                        ),
                        SizedBox(height: h * 0.05),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
