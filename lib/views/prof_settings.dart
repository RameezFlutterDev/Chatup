import "dart:async";
import "dart:io";

import "package:awesome_dialog/awesome_dialog.dart";
import "package:chatup/services/Auth/auth_service.dart";
import "package:chatup/services/chat/chat_service.dart";
import "package:circular_profile_avatar/circular_profile_avatar.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:image_picker/image_picker.dart";
import "package:path_provider/path_provider.dart";
import "package:provider/provider.dart";
import "package:image/image.dart" as Im;
import "package:uuid/uuid.dart";
import "package:uuid/v4.dart";

class ProfSettings extends StatefulWidget {
  final String username;
  ProfSettings({required this.username});
  @override
  State<ProfSettings> createState() => _ProfSettingsState();
}

class _ProfSettingsState extends State<ProfSettings> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthService auth = AuthService();
  String avURL = "";

  // File? _image;
  // final picker = ImagePicker();
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance;

  // Future<void> _pickImage() async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //     await _uploadImageToFirebase();
  //   }
  // }

  // Future<void> _uploadImageToFirebase() async {
  //   try {
  //     final User? user = _auth.currentUser;
  //     if (user != null) {
  //       final ref = _storage.ref().child('profile_pictures').child(user.uid)
  //         ..putFile(_image!);
  //       ;

  //       final url = await ref.getDownloadURL();

  //       // Update user profile picture URL in Firestore or wherever needed
  //       await FirebaseFirestore.instance
  //           .collection('Users')
  //           .doc(user.uid)
  //           .update({
  //         'profilePicture': url,
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("Profile Picture Uploaded"),
  //           duration: Duration(seconds: 3),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("Error uploading image: $e"),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //   }
  // }

  TextEditingController _controller = TextEditingController();
  ImagePicker _imagePicker = ImagePicker();
  File? file;
  bool isUploading = false;
  String postId = Uuid().v4();
  handleChooseFromGallery() async {
    try {
      var pickedImage = await _imagePicker.pickImage(
          source: ImageSource.gallery, maxHeight: 1080, maxWidth: 1920);

      if (pickedImage != null) {
        File io = File(pickedImage.path);

        setState(() {
          file = io;
        });

        if (file != null) {
          await uploadToStorage();
        }
      } else {
        print("Image selection canceled");
      }
    } catch (e) {
      print("Error in choosing image: $e");
    }
  }

  updateAvatarinFirestore(String mURL) async {
    print("email: $mURL");
    setState(() {
      avURL = mURL;
    });

    await FirebaseFirestore.instance
        .collection("Users")
        .doc(AuthService().getCurrentUser()!.uid)
        .update({"avatarURL": mURL});
  }

  uploadToStorage() async {
    try {
      setState(() {
        isUploading = true;
      });

      await compressImage();
      String? mediaURL = await uploadImage();

      if (mediaURL != null) {
        await updateAvatarinFirestore(mediaURL);
      }
    } catch (e) {
      print("Error in uploadToStorage: $e");
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<String?> uploadImage() async {
    try {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref()
          .child("profilePictures/$postId.jpg")
          .putFile(file!);

      return uploadTask.then(
        (p0) => p0.ref.getDownloadURL(),
      );
    } catch (e) {
      print("Error in uploadImage: $e");
    }
  }

  compressImage() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final path = tempDir.path;
      Im.Image? imageFile = Im.decodeImage(file!.readAsBytesSync());
      final compressedImageFile = File("$path/image_$postId.jpg")
        ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 90));

      setState(() {
        file = compressedImageFile;
      });
    } catch (e) {
      print("Error in compressImage: $e");
    }
  }

  loadAvatar() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(AuthService().getCurrentUser()!.uid)
        .get();
    setState(() {
      avURL = userDoc['avatarURL'];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    loadAvatar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settingspovider =
        Provider.of<ProfSettProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(137, 43, 33, 33),
        centerTitle: true,
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w500),
        ),
        shadowColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            CircularProfileAvatar(
              avURL,
              initialsText: Text("+",
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              backgroundColor: Colors.cyan,
              borderWidth: 1,
              borderColor: Colors.purple,
              elevation: 20,
              radius: 50,
              cacheImage: true,
              errorWidget: (context, url, error) {
                return Icon(
                  Icons.face,
                  size: 50,
                );
              },
              onTap: () async {
                await handleChooseFromGallery();
              },
              animateFromOldImageOnUrlChange: true,
              placeHolder: (context, url) {
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
            SizedBox(
              height: 10,
            ),
            Consumer<ProfSettProvider>(
              builder: (context, value, child) {
                if (value._username.isNotEmpty) {
                  return Text(
                    value._username,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
                if (value._username.isEmpty) {
                  return Text(
                    widget.username,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
                return Text("");
              },
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.red.shade100),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Row(
                  children: [
                    Text(
                      "Change Profile picture",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward,
                        size: 24,
                      ),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.red.shade100),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Row(
                  children: [
                    Text(
                      "Change Username",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward,
                        size: 24,
                      ),
                      onPressed: () {
                        AwesomeDialog(
                            dismissOnBackKeyPress: true,
                            context: context,
                            animType: AnimType.scale,
                            dialogType: DialogType.noHeader,
                            body: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  maxLines: null,
                                  minLines: 1,
                                  controller: _controller,
                                  decoration: InputDecoration(
                                      labelText: "New Username",
                                      labelStyle: GoogleFonts.nunito(
                                          color: Colors.black),
                                      // enabledBorder: OutlineInputBorder(
                                      //     borderRadius:
                                      //         BorderRadius.circular(25),
                                      //     borderSide: BorderSide(
                                      //         color: Colors.green,
                                      //         width: 2)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide(
                                              color: Colors.grey, width: 2)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          borderSide: BorderSide(
                                              color: Colors.purple, width: 2))),
                                ),
                              ),
                            ),
                            btnOkText: "Confirm",
                            buttonsTextStyle:
                                GoogleFonts.poppins(color: Colors.white),
                            btnOkColor: Colors.purple,
                            btnOkOnPress: () async {
                              await settingspovider.changeUsername(
                                  _controller.text.toString(), context);
                            }).show();
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfSettProvider with ChangeNotifier {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String newusername = "";
  String get _username => newusername;

  Future<void> changeUsername(String username, BuildContext context) async {
    try {
      await _firestore
          .collection("Users")
          .doc(AuthService().getCurrentUser()!.uid)
          .update({
        'Username': username,
      });
      newusername = username;
      notifyListeners();
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(e.toString()),
          );
        },
      );
    }
  }
}
