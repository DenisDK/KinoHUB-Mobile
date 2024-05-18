import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kinohub/components/custom_page_route.dart';
import 'package:kinohub/payment_configurations.dart';
import 'package:kinohub/views/user_profile_view.dart';
import 'package:pay/pay.dart';

class PremiumView extends StatefulWidget {
  const PremiumView({super.key});

  @override
  State<PremiumView> createState() => _PremiumViewState();
}

class _PremiumViewState extends State<PremiumView> {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    var userData;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          userData = snapshot.data!.data() as Map<String, dynamic>;
          bool isPremium = userData['isPremium'] ?? false;

          if (isPremium) {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Преміум план',
                  style: TextStyle(
                    color: Color(0xFFD3D3D3),
                    fontSize: 20,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: const Color(0xFFD3D3D3),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      CustomPageRoute(
                        builder: (context) => const UserProfile(),
                      ),
                    );
                  },
                ),
              ),
              body: const SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Color.fromARGB(255, 233, 156, 88),
                        size: 100,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Ласкаво просимо до нашої елітної спільноти!',
                        style: TextStyle(
                          color: Color(0xFFD3D3D3),
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Дякуємо за вашу підтримку !',
                        style: TextStyle(
                          color: Color(0xFFD3D3D3),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            var googlePayButton = Container(
              width: 200,
              height: 120,
              child: GooglePayButton(
                paymentConfiguration:
                    PaymentConfiguration.fromJsonString(defaultGooglePay),
                paymentItems: const [
                  PaymentItem(
                    label: 'Total',
                    amount: '200.00',
                    status: PaymentItemStatus.final_price,
                  )
                ],
                type: GooglePayButtonType.subscribe,
                margin: const EdgeInsets.only(top: 15.0),
                onPaymentResult: (result) async {
                  debugPrint('Payment Result $result');
                  await _updateUserPremiumStatus();
                },
                loadingIndicator: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );

            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Преміум план',
                  style: TextStyle(
                    color: Color(0xFFD3D3D3),
                    fontSize: 20,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: const Color(0xFFD3D3D3),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      CustomPageRoute(
                        builder: (context) => const UserProfile(),
                      ),
                    );
                  },
                ),
              ),
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFF262626)),
                        child: SizedBox(
                          width: 350,
                          height: 425,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'П',
                                        style: TextStyle(
                                            color: Color(0xFFFF5200),
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: 'реміум план',
                                        style: TextStyle(
                                            color: Color(0xFFDEDEDE),
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const Text(
                                  '200 грн/назавжди',
                                  style: TextStyle(
                                      color: Color(0xFFDEDEDE), fontSize: 18),
                                ),
                                const Text(
                                  '\n- Можливість додавати більше 5 друзів\n\n - Анімоване фото профілю \n\n - Преміум статус в профілі ',
                                  style: TextStyle(
                                      color: Color(0xFFDEDEDE), fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      googlePayButton,
                    ],
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _updateUserPremiumStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({'isPremium': true});
        debugPrint('User isPremium status updated to true');
      } catch (e) {
        debugPrint('Failed to update isPremium status: $e');
      }
    }
  }
}
