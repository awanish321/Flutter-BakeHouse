import 'package:flutter/material.dart';

import 'dart:io';
import 'dart:math';
import 'package:bakery_user_app/widgets/appBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bakery_user_app/model/userDetails.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key, required this.user});

  UserDetails user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phnController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool edit = false;
  File? _image;

  @override
  void initState() {
    nameController.text = widget.user.Name;
    phnController.text = widget.user.MobileNumber;
    emailController.text = widget.user.Email;
    passwordController.text = widget.user.Password;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationBar(title: 'Profile', context: context, actions: [
        TextButton(
          onPressed: () {
            setState(() {
              edit = true;
            });
          },
          child: Text(
            'Edit',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
      ]),
      body: SingleChildScrollView(
        child: edit == true
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        widget.user.ImageUrl != '' && _image == null
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(widget.user.ImageUrl),
                                radius: 80,
                              )
                            : _image != null
                                ? CircleAvatar(
                                    backgroundImage: FileImage(_image!),
                                    radius: 80,
                                  )
                                : const CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/images/per.png'),
                                    radius: 80,
                                  ),
                        Positioned(
                          bottom: 0,
                          left: 100,
                          right: 0,
                          child: InkWell(
                            onTap: () async {
                              final image = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (image != null) {
                                setState(() {
                                  _image = File(image.path);
                                });
                              }
                            },
                            child: Image(
                              image: const AssetImage('assets/images/icon.png'),
                              color: Theme.of(context).colorScheme.primary,
                              height: 40,
                              width: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: TextFormField(
                      controller: nameController,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 18),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: TextFormField(
                      controller: phnController,
                      keyboardType: TextInputType.number,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        labelStyle: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 18),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: TextFormField(
                      controller: emailController,
                      enabled: false,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 18),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      validator: (value) => EmailValidator.validate(value!)
                          ? null
                          : 'Please enter valid email',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: TextFormField(
                      obscureText: true,
                      controller: passwordController,
                      enabled: false,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 18),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: InkWell(
                      onTap: () async {
                        if (_image != null) {
                          int random = Random().nextInt(10000);
                          String imageRef = '${random}.jpg';

                          Reference store =
                              FirebaseStorage.instance.ref(imageRef);
                          await store.putFile(_image!);
                          final imageURl = await store.getDownloadURL();

                          await FirebaseFirestore.instance
                              .collection('Users')
                              .doc(widget.user.Id)
                              .update({
                            "ImageUrl": _image != null ? imageURl : 'img',
                            "Name": nameController.text.trim(),
                            "MobileNumber": phnController.text.trim(),
                          });
                        }

                        setState(() {
                          edit = false;
                        });

                        Navigator.of(context).pop();
                        Navigator.of(context).pop();

                        Fluttertoast.showToast(
                          msg: 'Profile successfully updated.',
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.background,
                          fontSize: 14,
                          timeInSecForIosWeb: 1,
                          gravity: ToastGravity.TOP,
                          toastLength: Toast.LENGTH_LONG,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        height: 50,
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            'Update',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 18,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: widget.user.ImageUrl == ''
                        ? const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/per.png'),
                            radius: 80,
                          )
                        : CircleAvatar(
                            backgroundImage:
                                NetworkImage(widget.user.ImageUrl.toString()),
                            radius: 80,
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: TextFormField(
                      controller: nameController,
                      enabled: false,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 18),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: TextFormField(
                      controller: phnController,
                      enabled: false,
                      keyboardType: TextInputType.number,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        labelStyle: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 18),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: TextFormField(
                      controller: emailController,
                      enabled: false,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 18),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      validator: (value) => EmailValidator.validate(value!)
                          ? null
                          : 'Please enter valid email',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: TextFormField(
                      obscureText: true,
                      controller: passwordController,
                      enabled: false,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.secondary),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 18),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
