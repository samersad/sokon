import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sokon/core/cache/provider/user_provider.dart';
import 'package:sokon/core/model/apartment.dart';
import 'package:sokon/core/model/booking.dart';
import 'package:sokon/core/utils/app_assets.dart';
import 'package:sokon/firebase_utils.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../widgets/custom_elevated_buttom.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? cardNumber;
  String? cardHolder;
  String? expiryDate;

  DateTimeRange? selectedDate;
  late Apartment apartment;
  bool isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInitialized) {
      apartment = ModalRoute.of(context)!.settings.arguments as Apartment;
      isInitialized = true;
    }
  }

  Future<void> pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String getFormattedDate() {
    if (selectedDate == null) return "Select Date";
    final format = DateFormat('dd MMM');
    return "${format.format(selectedDate!.start)} - ${format.format(selectedDate!.end)}";
  }

  Future<void> goToAddCard() async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.addCardRoute,
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        cardNumber = result["cardNumber"];
        cardHolder = result["cardHolder"];
        expiryDate = result["expiryDate"];
      });
    }
  }

  void confirmBooking() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date range")),
      );
      return;
    }

    var userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to book")),
      );
      return;
    }

    Booking booking = Booking(
      apartmentId: apartment.id,
      apartmentName: apartment.name,
      apartmentAddress: apartment.address,
      apartmentImage: (apartment.images != null && apartment.images!.isNotEmpty)
          ? apartment.images![0]
          : null,
      clientId: userProvider.user!.id,
      clientName: userProvider.user!.name,
      ownerId: apartment.ownerId,
      ownerName: apartment.ownerName,
      startDate: selectedDate!.start,
      endDate: selectedDate!.end,
      totalPrice: apartment.price, // Simplified
      status: 'pending',
    );

    try {
      await FireBaseUtils.addBookingToFirestore(booking);
      showSuccessDialog(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text("Booking", style: AppStyles.bold20blackIner),
        centerTitle: true,
      ),
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(minHeight: 110.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.sp),
                    border: Border.all(color: AppColors.grayColor, width: 2),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: (apartment.images != null &&
                                  apartment.images!.isNotEmpty)
                              ? Image.network(
                                  apartment.images![0],
                                  width: 80.w,
                                  height: 80.h,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(AppAssets.image,
                                  width: 80.w, height: 80.h),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AutoSizeText(
                                apartment.name ?? "Apartment",
                                style: AppStyles.semiBold14DarkPrimary,
                                maxLines: 2,
                              ),
                              SizedBox(height: 5.h),
                              Row(
                                children: [
                                  Image.asset(AppAssets.locationIcon,
                                      width: 14.w),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: AutoSizeText(
                                      apartment.address ?? "No Address",
                                      style: AppStyles.medium12gray,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5.h),
                              Row(
                                children: [
                                  Text("${apartment.price ?? 0}/month",
                                      style: AppStyles.regular14black),
                                  Spacer(),
                                  Image.asset(AppAssets.star, width: 14.w),
                                  SizedBox(width: 4.w),
                                  Text("4.8", style: AppStyles.regular14black),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                Text("Period", style: AppStyles.bold20black),

                InkWell(
                  onTap: pickDateRange,
                  child: Row(
                    children: [
                      Image.asset(AppAssets.dateIcon),
                      SizedBox(width: 10.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date", style: AppStyles.regular14gray),
                          Text(getFormattedDate(),
                              style: AppStyles.medium16black),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10.h),
                Divider(color: AppColors.grayColor),

                SizedBox(height: 10.h),

                Text(
                  "Make sure to check your date before making any sort of payments",
                  style: AppStyles.regular14gray,
                ),

                SizedBox(height: 20.h),

                Text("Payments", style: AppStyles.bold20black),

                Row(
                  children: [
                    if (cardNumber != null)
                      Image.asset(AppAssets.mastercardIcon),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        cardNumber == null
                            ? "No Card Added"
                            : "**** **** **** ${cardNumber!.substring(cardNumber!.length - 4)}",
                        style: AppStyles.bold20black,
                      ),
                    ),
                    TextButton(
                      onPressed: goToAddCard,
                      child: Text(
                        cardNumber == null ? "Add Card" : "Edit",
                        style: AppStyles.bold20black,
                      ),
                    ),
                  ],
                ),

                Divider(color: AppColors.grayColor),

                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Enter a Voucher",
                    style: AppStyles.bold20black.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                Text("Price Details", style: AppStyles.bold20black),

                buildRow("Period time",
                    selectedDate == null ? "-" : "${selectedDate!.duration.inDays} Days"),
                buildRow("Monthly payment", "${apartment.price ?? 0} EG"),
                buildRow("Tax", "10 EG"),
                buildRow("Total", "${(apartment.price ?? 0) + 10} EG",
                    isTotal: true),

                SizedBox(height: 40.h),

                CustomElevatedButtom(
                  onPressed: confirmBooking,
                  text: "Confirm and Pay",
                  customPadding: 20,
                  borderRadius: 10.r,
                  backgroundColorElevated: AppColors.darkBlueColor,
                  textStyle: AppStyles.semiBold20White,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(String t1, String t2, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Text(
            t1,
            style: isTotal ? AppStyles.medium16black : AppStyles.regular14gray,
          ),
          Spacer(),
          Text(
            t2,
            style: isTotal
                ? AppStyles.bold18PrimaryColor
                : AppStyles.medium16black,
          ),
        ],
      ),
    );
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppAssets.successBg),
                  SizedBox(height: 20),
                  Text(
                    "Yey, your booking success",
                    textAlign: TextAlign.center,
                    style: AppStyles.bold20black,
                  ),
                  const SizedBox(height: 10),
                  Text(
                      "you have successfully booked a property, enjoy your property",
                      textAlign: TextAlign.center,
                      style: AppStyles.regular14gray),
                  SizedBox(height: 25),
                  CustomElevatedButtom(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    text: "successfully",
                    customPadding: 15,
                    borderRadius: 10.r,
                    backgroundColorElevated: AppColors.darkBlueColor,
                    textStyle: AppStyles.semiBold20White,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
