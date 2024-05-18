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
                  'Преміум-підписка',
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
                      Text(
                        'Ви вже маєте преміум-підписку!',
                        style: TextStyle(color: Color(0xFFD3D3D3), fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            // Якщо преміум-статус відсутній, відображаємо кнопку купівлі
            var googlePayButton = GooglePayButton(
              paymentConfiguration: PaymentConfiguration.fromJsonString(defaultGooglePay),
              paymentItems: const [
                PaymentItem(
                  label: 'Total',
                  amount: '0.01',
                  status: PaymentItemStatus.final_price,
                )
              ],
              type: GooglePayButtonType.buy,
              margin: const EdgeInsets.only(top: 15.0),
              onPaymentResult: (result) async {
                debugPrint('Payment Result $result');
                await _updateUserPremiumStatus();
              },
              loadingIndicator: const Center(
                child: CircularProgressIndicator(),
              ),
            );

            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Преміум-підписка',
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
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 150)),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFDEDEDE))
                        ),
                        child: const SizedBox(
                          width: 350,
                          height: 150,
                          child:  Text(
                          'Отримайте преміум підписку та насолоджуйтесь наступними перевагами:\n\n'
                          '- Без реклами\n'
                          '- Додавання більше п\'яти друзів\n',
                          style: TextStyle(color: Color(0xFFDEDEDE),fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        ),
                      ),
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
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({'isPremium': true});
        debugPrint('User isPremium status updated to true');
      } catch (e) {
        debugPrint('Failed to update isPremium status: $e');
      }
    }
  }
}
