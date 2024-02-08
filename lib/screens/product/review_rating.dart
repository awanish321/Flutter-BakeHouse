import 'package:flutter/material.dart';

import 'package:bakery_user_app/model/userDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bakery_user_app/model/product.dart';
import 'package:bakery_user_app/widgets/appBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// ignore: must_be_immutable
class RatingScreen extends StatefulWidget {
  RatingScreen({super.key, required this.productItem});

  ProductItem productItem;

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double rating = 0;
  List<UserDetails> userDetails = [];
  TextEditingController reviewController = TextEditingController();
  bool hasRated = false;

  @override
  void initState() {
    super.initState();
    checkIfUserRated();
  }

  void checkIfUserRated() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('Product')
          .doc(widget.productItem.id)
          .collection('Rating')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final existingRating = snapshot.docs.first.data()['Rating'];
        final existingReview = snapshot.docs.first.data()['Review'];

        setState(() {
          rating = double.parse(existingRating);
          reviewController.text = existingReview;
          hasRated = true;
        });
      }
    } catch (e) {
      debugPrint('Error checking if user has rated: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationBar(title: 'Review Product', context: context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Image.network(
                  widget.productItem.ImageUrl[0],
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Center(
                child: Text(
                  widget.productItem.Product,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 0),
              child: Center(
                child: Text(
                  'Rate this product',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
              child: Center(
                child: Text(
                  'How did you find this product based on your usage?',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: RatingBar.builder(
                  initialRating: rating,
                  minRating: 1,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                  allowHalfRating: true,
                  unratedColor: Colors.grey,
                  updateOnDrag: true,
                  itemBuilder: (context, index) {
                    return const Icon(
                      Icons.star,
                      color: Colors.amber,
                    );
                  },
                  onRatingUpdate: (value) {
                    setState(() {
                      rating = value;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 0),
              child: Center(
                child: Text(
                  'Write a Review',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
              child: TextFormField(
                controller: reviewController,
                keyboardType: TextInputType.text,
                maxLines: 5,
                minLines: 1,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
                decoration: InputDecoration(
                  hintText:
                      'How is the product? What do you like? What do you hate?',
                  hintStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 14,
                      ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 0),
              child: Center(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final data = snapshot.data!.docs;
                    userDetails = data
                        .map((e) => UserDetails.fromJson(e))
                        .where((element) =>
                            element.userId ==
                            FirebaseAuth.instance.currentUser!.uid)
                        .toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: userDetails.length,
                      itemBuilder: (context, index) {
                        return ElevatedButton(
                          onPressed: () async {
                            if (hasRated) {
                              try {
                                final userId =
                                    FirebaseAuth.instance.currentUser!.uid;
                                await FirebaseFirestore.instance
                                    .collection('Product')
                                    .doc(widget.productItem.id)
                                    .collection('Rating')
                                    .where('userId', isEqualTo: userId)
                                    .get()
                                    .then((snapshot) {
                                  final docId = snapshot.docs.first.id;
                                  FirebaseFirestore.instance
                                      .collection('Product')
                                      .doc(widget.productItem.id)
                                      .collection('Rating')
                                      .doc(docId)
                                      .update({
                                    'Rating': rating.toString(),
                                    'Review': reviewController.text.trim(),
                                  });
                                });

                                if (!context.mounted) {
                                  return;
                                }
                                Navigator.of(context).pop();
                              } catch (e) {
                                debugPrint('Error updating review: $e');
                              }
                            } else {
                              try {
                                await FirebaseFirestore.instance
                                    .collection('Product')
                                    .doc(widget.productItem.id)
                                    .collection('Rating')
                                    .add({
                                  'Image': userDetails[index].ImageUrl,
                                  'Name': userDetails[index].Name.toString(),
                                  'Time': FieldValue.serverTimestamp(),
                                  'Rating': rating.toString(),
                                  'Review': reviewController.text.trim(),
                                  'Reply': '',
                                  "userId":
                                      FirebaseAuth.instance.currentUser!.uid,
                                });

                                if (!context.mounted) {
                                  return;
                                }
                                Navigator.of(context).pop();
                              } catch (e) {
                                debugPrint(
                                    'Error adding List to Firestore: $e');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.onSecondary,
                          ),
                          child: Text(
                            hasRated ? 'Edit' : 'Submit',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
