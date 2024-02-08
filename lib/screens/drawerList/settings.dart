import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:bakery_user_app/model/address.dart';
import 'package:bakery_user_app/model/userDetails.dart';
import 'package:bakery_user_app/screens/checkout/address.dart';
import 'package:bakery_user_app/screens/drawerList/profile.dart';
import 'package:bakery_user_app/widgets/shimmerEffect.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bakery_user_app/widgets/appBar.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<UserDetails> user = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationBar(title: 'Settings', context: context),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(3, 8, 3, 0),
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Text(
                    'Account Settings',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(),
                StreamBuilder(
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
                    user = data
                        .map((e) => UserDetails.fromJson(e))
                        .where((element) =>
                            element.userId ==
                            FirebaseAuth.instance.currentUser!.uid)
                        .toList();

                    return ListTileItem(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              user: user.first,
                            ),
                          ),
                        );
                      },
                      title: 'Edit Profile',
                      icon: Icons.person_pin,
                    );
                  },
                ),
                ListTileItem(
                  onTap: () {},
                  title: 'Manage Notifications',
                  icon: Icons.edit_notifications_sharp,
                ),
                ListTileItem(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Addresses(),
                      ),
                    );
                  },
                  title: 'Saved Addresses',
                  icon: Icons.location_pin,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(3, 8, 3, 0),
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Text(
                    'Feedback & Information',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Divider(),
                ListTileItem(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TermsOfUse(),
                      ),
                    );
                  },
                  title: 'Terms Of Use',
                  icon: Icons.security,
                ),
                ListTileItem(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicy(),
                      ),
                    );
                  },
                  title: 'Privacy Policy',
                  icon: Icons.policy,
                ),
                ListTileItem(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ReturnPolicy(),
                      ),
                    );
                  },
                  title: 'Return Policy',
                  icon: CupertinoIcons.cube_fill,
                ),
                ListTileItem(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const HelpCenter(),
                      ),
                    );
                  },
                  title: 'Help Center',
                  icon: Icons.headset_mic_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListTileItem extends StatelessWidget {
  const ListTileItem({
    super.key,
    required this.onTap,
    required this.title,
    required this.icon,
  });

  final void Function() onTap;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.secondary,
        size: 20,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        size: 15,
      ),
    );
  }
}

class Addresses extends StatefulWidget {
  const Addresses({super.key});

  @override
  State<Addresses> createState() => _AddressesState();
}

class _AddressesState extends State<Addresses> {
  List<AddressItem> address = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationBar(title: 'Saved Addresses', context: context),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Wishlist')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .collection('Addresses')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display shimmer effect during the waiting state
            return SettingAddressShimmer(
              itemCount: address.length,
            );
          } else if (snapshot.hasError) {
            // Handle error, for example, show an error message
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!.docs;
          address = data.map((e) => AddressItem.fromJson(e)).toList();

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: address.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(5.0),
                color:
                    Theme.of(context).colorScheme.onSecondary.withOpacity(0.4),
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address[index].FullName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            address[index].Address,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            address[index].PhoneNumber,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Address(
                                  addressItem: address[index],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.025,
                            width: MediaQuery.of(context).size.width * 0.1,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSecondary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Center(
                              child: Text(
                                'Edit',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class LabelText extends StatelessWidget {
  final String text;

  const LabelText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class BodyText extends StatelessWidget {
  final String text;

  const BodyText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
      ),
    );
  }
}

class BulletText extends StatelessWidget {
  final String text;

  const BulletText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Icon(
              Icons.circle,
              size: 5,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.justify,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.5),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class PhoneCallText extends StatelessWidget {
  final String text;
  final String phoneNumber;

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  const PhoneCallText({
    super.key,
    required this.text,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _launchPhoneCall(phoneNumber);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Text.rich(
          TextSpan(
            text: text,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                ),
            children: <TextSpan>[
              TextSpan(
                text: phoneNumber,
                style: const TextStyle(
                  color: Colors.blue, // Highlight the phone number
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationBar(title: 'Terms Of Use', context: context),
      body: ListView(
        children: const [
          LabelText(text: 'Effective Date: 23/09/2021'),
          LabelText(text: '1. Acceptance of Terms'),
          BodyText(
              text:
                  'By using the Bakery App, you agree to comply with and be bound by these Terms of Use. If you do not agree to these terms, please do not use the App.'),
          SizedBox(height: 10),
          LabelText(text: '2. Privacy Policy'),
          BodyText(
              text:
                  'Your use of the App is also governed by our Privacy Policy, which is available at [Link to Privacy Policy]. By using the App, you consent to the terms of our Privacy Policy.'),
          SizedBox(height: 10),
          LabelText(text: '3. Use of the App'),
          BulletText(
              text:
                  'You must be at least 18 years old to use the App or have permission from a parent or guardian.'),
          BulletText(
              text: 'You agree to use the App for lawful purposes only.'),
          BulletText(
              text:
                  'You will not use the App to engage in any form of harassment, spam, or any illegal or harmful activity.'),
          SizedBox(height: 10),
          LabelText(text: '4. User Accounts'),
          BulletText(
              text:
                  'You may be required to create a user account to access certain features of the App. You are responsible for maintaining the confidentiality of your account information and are liable for all activities associated with your account.'),
          BulletText(
              text:
                  'You agree to provide accurate, current, and complete information during the registration process.'),
          SizedBox(height: 10),
          LabelText(text: '5. Intellectual Property'),
          BulletText(
              text:
                  'The content, trademarks, logos, and other intellectual property on the App are protected by applicable intellectual property laws. You may not use, modify, distribute, or reproduce any content from the App without prior written consent.'),
          SizedBox(height: 10),
          LabelText(text: '6. User-Generated Content'),
          BulletText(
              text:
                  'By posting content on the App, you grant us a non-exclusive, royalty-free, worldwide license to use, display, and distribute the content.'),
          BulletText(
              text:
                  'You are solely responsible for the content you post, and it must comply with our Content Guidelines.'),
          SizedBox(height: 10),
          LabelText(text: '7. Termination'),
          BodyText(
              text:
                  'We reserve the right to suspend, restrict, or terminate your access to the App at our discretion, without notice, if you violate these Terms of Use.'),
          SizedBox(height: 10),
          LabelText(text: '8. Changes to Terms'),
          BodyText(
              text:
                  'We may update these Terms of Use from time to time. It is your responsibility to review these terms periodically. Continued use of the App after any changes constitute your acceptance of those changes.'),
          SizedBox(height: 10),
          LabelText(text: '9. Disclaimers'),
          BulletText(
              text:
                  "The App is provided on an 'as-is' basis. We make no warranties or guarantees regarding the App's accuracy, availability, or functionality."),
          BulletText(
              text:
                  'We are not liable for any damages resulting from your use of the App.'),
          SizedBox(height: 10),
          LabelText(text: '10. Governing Law'),
          BodyText(
              text:
                  'These Terms of Use are governed by and construed in accordance with the laws of [Your Jurisdiction]. Any disputes arising from these terms will be subject to the exclusive jurisdiction of the courts in [Your Jurisdiction].'),
          SizedBox(height: 10),
          LabelText(text: '11. Contact Information'),
          PhoneCallText(
            text:
                'If you have any questions or concerns about these Terms of Use, please contact us at ',
            phoneNumber: '079-71123711',
          ),
          SizedBox(height: 20),
          BodyText(
              text:
                  'By using the Bakery App, you agree to these Terms of Use. If you do not agree, please do not use the App.'),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationBar(title: 'Privacy Policy', context: context),
      body: ListView(
        children: const [
          LabelText(text: 'Effective Date: 23/09/2021'),
          SizedBox(height: 5),
          BodyText(
              text:
                  'Welcome to Bakery! We are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and protect your information when you use our bakery products application.'),
          LabelText(text: '1. Information We Collect'),
          SizedBox(height: 10),
          LabelText(text: '1.1 Personal Information'),
          BodyText(
              text:
                  'We may collect personal information that you voluntarily provide to us when you use the App. This may include, but is not limited to:'),
          BulletText(text: 'Your name'),
          BulletText(text: 'Email address'),
          BulletText(text: 'Phone number'),
          BulletText(text: 'Address'),
          SizedBox(height: 10),
          LabelText(text: '1.2 Non-Personal Information'),
          BodyText(
              text: 'We may also collect non-personal information, such as:'),
          BulletText(text: 'App usage data'),
          BulletText(text: 'Device information'),
          BulletText(text: 'Cookies and similar tracking technologies'),
          SizedBox(height: 10),
          LabelText(text: '2. How We Use Your Information'),
          BodyText(text: 'We use your information for the following purposes:'),
          BulletText(text: 'To provide and maintain the App'),
          BulletText(text: 'To process orders and deliver bakery products'),
          BulletText(text: 'To send transaction notifications and updates'),
          BulletText(text: 'To respond to your inquiries and requests'),
          BulletText(text: 'To improve our products and services'),
          BulletText(text: 'To comply with legal and regulatory requirements'),
          SizedBox(height: 10),
          LabelText(text: '3. Disclosure of Your Information'),
          BodyText(text: 'We may share your information with:'),
          BulletText(
              text:
                  'Service providers and business partners who assist us in delivering our services'),
          BulletText(text: 'Legal authorities when required by law'),
          BulletText(text: 'Other users with your explicit consent'),
          SizedBox(height: 10),
          LabelText(text: '4. Security'),
          BodyText(
              text:
                  'We take reasonable measures to protect your information from unauthorized access, disclosure, alteration, or destruction. However, no method of transmission over the internet or electronic storage is entirely secure.'),
          SizedBox(height: 10),
          LabelText(text: '5. Third-Party Links and Services'),
          BodyText(
              text:
                  'The App may contain links to third-party websites or services that are not under our control. We are not responsible for the privacy practices or content of these third-party websites or services.'),
          SizedBox(height: 10),
          LabelText(text: "6. Children's Privacy"),
          BodyText(
              text:
                  'The App is not intended for children under the age of 13. We do not knowingly collect personal information from children. If you believe a child has provided us with their information, please contact us, and we will delete it.'),
          SizedBox(height: 10),
          LabelText(text: '7. Changes to this Privacy Policy'),
          BodyText(
              text:
                  'We may update this Privacy Policy to reflect changes in our practices and legal requirements. We will notify you of any material changes by posting the new policy on our website or through the App.'),
          SizedBox(height: 10),
          LabelText(text: '8. Contact Information'),
          PhoneCallText(
            text:
                'If you have any questions or concerns about this Privacy Policy, please contact us at ',
            phoneNumber: '079-71123711',
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ReturnPolicy extends StatelessWidget {
  const ReturnPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationBar(title: 'Return Policy', context: context),
      body: ListView(
        children: const [
          LabelText(text: 'Effective Date: 23/09/2021'),
          SizedBox(height: 5),
          BodyText(
              text:
                  'Thank you for choosing Bakery App for your bakery product needs. We strive to provide the best quality products and services. If you are not completely satisfied with your purchase, please read our return policy below.'),
          LabelText(text: '1. Returns'),
          SizedBox(height: 10),
          LabelText(text: '1.1 Eligibility'),
          BodyText(
              text:
                  'To be eligible for a return, your item must be unused and in the same condition that you received it. It must also be in the original packaging.'),
          SizedBox(height: 10),
          LabelText(text: '1.2 Timeframe'),
          BodyText(
              text:
                  'You must initiate a return request within [Number of Days] days from the date of purchase or delivery.'),
          SizedBox(height: 10),
          LabelText(text: '1.3 Non-Returnable Items'),
          BodyText(text: 'The following items are not eligible for return:'),
          BulletText(text: 'Perishable bakery products'),
          BulletText(text: 'Custom or personalized items'),
          SizedBox(height: 10),
          LabelText(text: '2. Refunds'),
          SizedBox(height: 10),
          LabelText(text: '2.1 Eligibility'),
          BodyText(
              text:
                  'To be eligible for a refund, your item must meet the return eligibility criteria (as described in Section 1).'),
          SizedBox(height: 10),
          LabelText(text: '2.2 Refund Process'),
          BodyText(
              text:
                  'Once your return is received and inspected, we will send you an email to notify you that we have received your returned item. We will also notify you of the approval or rejection of your refund.'),
          SizedBox(height: 10),
          LabelText(text: '2.3 Refund Method'),
          BodyText(
              text:
                  'If your refund is approved, it will be processed, and a credit will be automatically applied to your original method of payment. Please allow [Number of Days] days for the refund to appear in your account.'),
          SizedBox(height: 10),
          LabelText(text: '3. Exchanges'),
          SizedBox(height: 10),
          LabelText(text: '3.1 Eligibility'),
          BodyText(
              text:
                  'We only replace items if they are defective or damaged. If you need to exchange an item for the same product, please contact us within [Number of Days] days of receiving the product.'),
          SizedBox(height: 10),
          LabelText(text: '3.2 Exchange Process'),
          BodyText(
              text:
                  'To initiate an exchange, please contact us at [Contact Email] with details about the issue and a photo of the damaged or defective item. We will provide further instructions on the exchange process.'),
          SizedBox(height: 10),
          LabelText(text: '4. Contact Us'),
          PhoneCallText(
            text:
                'If you have any questions or concerns about our return policy, please contact us at ',
            phoneNumber: '079-71123711',
          ),
          SizedBox(height: 20),
          BodyText(
              text:
                  'We are here to assist you and ensure that you have a satisfying experience with our bakery products.'),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class HelpCenter extends StatefulWidget {
  const HelpCenter({super.key});

  @override
  State<HelpCenter> createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationBar(title: 'Help Center', context: context),
      body: ListView(
        children: const [
          SizedBox(height: 10),
          BodyText(
              text:
                  "Welcome to the Bakery App Help Center. We are here to assist you with any questions or issues you may have while using our bakery products application. Please find answers to some common questions below. If you don't find the information you're looking for, feel free to contact our support team at [Contact Information]."),
          SizedBox(height: 10),
          LabelText(text: 'Frequently Asked Questions'),
          SizedBox(height: 10),
          LabelText(text: '1. How do I place an order?'),
          BodyText(text: 'To place an order, follow these simple steps:'),
          BulletText(text: 'Open the Bakery application.'),
          BulletText(text: 'Browse our bakery products.'),
          BulletText(
              text:
                  'Select the items you wish to purchase and add them to your cart.'),
          BulletText(
              text:
                  'Proceed to the checkout and provide your delivery information.'),
          BulletText(text: 'Review your order and make the payment.'),
          BulletText(
              text:
                  'You will receive an order confirmation once your order is placed.'),
          SizedBox(height: 10),
          LabelText(text: '2. What are the payment options?'),
          BodyText(text: 'We accept the following payment methods:'),
          BulletText(text: 'Credit cards'),
          BulletText(text: 'Debit cards'),
          BulletText(text: 'UPI'),
          BulletText(text: 'Net banking'),
          BulletText(text: 'Cash on delivery'),
          SizedBox(height: 10),
          LabelText(text: '3. Can I modify or cancel an order?'),
          BodyText(
              text:
                  'Once an order is placed, it cannot be modified or canceled. If you have any concerns or issues with your order, please contact our support team for assistance.'),
          SizedBox(height: 10),
          LabelText(text: '4. How can I track my order?'),
          BodyText(
              text:
                  'You can track the status of your order in the Bakery application. We will also send you notifications regarding the progress of your delivery.'),
          SizedBox(height: 10),
          LabelText(text: '5. What is your return policy?'),
          BodyText(
              text:
                  'For information about our return policy, please refer to our [Return Policy](link to return policy) page.'),
          SizedBox(height: 10),
          LabelText(text: '6. How do I contact customer support?'),
          BodyText(
              text:
                  'You can reach our customer support team at [Contact Email] or [Phone Number]. Our support hours are [Support Hours].'),
          SizedBox(height: 10),
          LabelText(text: '7. How can I provide feedback or suggestions?'),
          BodyText(
              text:
                  'We value your feedback and suggestions. You can provide your feedback through the [Your Bakery App Name] application or by contacting our support team.'),
          SizedBox(height: 10),
          LabelText(text: '8. What are your business hours?'),
          BodyText(
              text:
                  'Our business hours are [Business Hours]. We are here to serve you during these hours.'),
          SizedBox(height: 10),
          LabelText(text: '9. Do you offer custom orders or special requests?'),
          BodyText(
              text:
                  'Yes, we offer custom orders and special requests. Please contact our support team to discuss your specific requirements.'),
          SizedBox(height: 10),
          LabelText(text: '10. Is my personal information safe with Bakery?'),
          BodyText(
              text:
                  'We take the security and privacy of your personal information seriously. For more information, please refer to our [Privacy Policy](link to privacy policy).'),
          SizedBox(height: 20),
          LabelText(text: 'Contact Us'),
          PhoneCallText(
            text:
                'If you have any other questions or need further assistance, please contact us at ',
            phoneNumber: '079-71123711',
          ),
          SizedBox(height: 20),
          BodyText(
              text:
                  'We are here to help you enjoy the best bakery products and services.'),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
