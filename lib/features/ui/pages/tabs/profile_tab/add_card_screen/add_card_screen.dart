import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/app_styles.dart';
import '../../../../widgets/custom_elevated_buttom.dart';


class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String cardNumber = "";
  String expiryDate = "";
  String cardHolderName = "";
  String cvvCode = "";
  bool isCvvFocused = false;

  void onCreditCardModelChange(CreditCardModel data) {
    setState(() {
      cardNumber = data.cardNumber;
      expiryDate = data.expiryDate;
      cardHolderName = data.cardHolderName;
      cvvCode = data.cvvCode;
      isCvvFocused = data.isCvvFocused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,

        title: Text("Add Card", style: AppStyles.bold20blackIner),
        centerTitle: true,
      ),
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CreditCardWidget(
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                showBackView: isCvvFocused,
                onCreditCardWidgetChange: (CreditCardBrand brand) {},
                bankName: 'My Bank',
                cardBgColor: AppColors.primaryColor,
                enableFloatingCard: true,
                height: 220.h,
                width: MediaQuery.of(context).size.width,
                obscureCardNumber: true,
                obscureCardCvv: true,
                labelCardHolder: 'CARD HOLDER',
                labelValidThru: 'VALID THRU',
                cardType: CardType.mastercard,
                isHolderNameVisible: true,
                animationDuration: const Duration(milliseconds: 1000),
                frontCardBorder: Border.all(color: Colors.grey),
                backCardBorder: Border.all(color: Colors.grey),
                padding: 16,
              ),

              SizedBox(height: 20.h),

              CreditCardForm(
                formKey: formKey,
                cardNumber: cardNumber,
                expiryDate: expiryDate,
                cardHolderName: cardHolderName,
                cvvCode: cvvCode,
                onCreditCardModelChange: onCreditCardModelChange,
                obscureNumber: false,
                isHolderNameVisible: true,
                isCardNumberVisible: true,
                isExpiryDateVisible: true,
                enableCvv: true,

                inputConfiguration: const InputConfiguration(
                  cardNumberDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Card Number',
                    hintText: 'XXXX XXXX XXXX XXXX',
                  ),
                  expiryDateDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Expiry Date',
                    hintText: 'MM/YY',
                  ),
                  cvvCodeDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'CVV',
                    hintText: 'XXX',
                  ),
                  cardHolderDecoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Card Holder',
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 20.w),
                child: CustomElevatedButtom(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        Navigator.pop(context, {
                          "cardNumber": cardNumber,
                          "cardHolder": cardHolderName,
                          "expiryDate": expiryDate,
                        });

                      }


                  }
                  ,
                  text: "Add Card",
                  customPadding: 15,
                  borderRadius: 20.r,
                  backgroundColorElevated: AppColors.darkBlueColor,
                  textStyle: AppStyles.semiBold20White,
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}