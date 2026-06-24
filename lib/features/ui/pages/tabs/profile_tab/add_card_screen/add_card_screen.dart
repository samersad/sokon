import 'package:flutter/material.dart';
import 'package:sokon/l10n/app_localizations.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,

        title: Text(l10n.addCard, style: theme.textTheme.titleLarge),
        centerTitle: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
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
                bankName: l10n.myBank,
                cardBgColor: theme.primaryColor,
                enableFloatingCard: true,
                height: 220.h,
                width: MediaQuery.of(context).size.width,
                obscureCardNumber: true,
                obscureCardCvv: true,
                labelCardHolder: 'CARD HOLDER',
                labelValidThru: l10n.validThru,
                cardType: CardType.mastercard,
                isHolderNameVisible: true,
                animationDuration: const Duration(milliseconds: 1000),
                frontCardBorder: Border.all(color: theme.highlightColor),
                backCardBorder: Border.all(color: theme.highlightColor),
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

                inputConfiguration: InputConfiguration(
                  cardNumberDecoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: l10n.cardNumber,
                    hintText: l10n.cardNumberPlaceholder,
                  ),
                  expiryDateDecoration:  InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: l10n.expiryDate,
                    hintText: l10n.expiryDatePlaceholder,
                  ),
                  cvvCodeDecoration:  InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: l10n.cvvLabel,
                    hintText: l10n.cvvPlaceholder,
                  ),
                  cardHolderDecoration:  InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: l10n.cardHolder,
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
                  text: l10n.addCard,
                  customPadding: 15,
                  borderRadius: 20.r,
                  backgroundColorElevated: theme.primaryColor,
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
