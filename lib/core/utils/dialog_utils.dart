
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_styles.dart';

class DialogUtils{
  static void  showLoading({required BuildContext context,required String msg}){
showDialog(barrierDismissible: false,context: context, builder: (context) => AlertDialog(
  content: Row(
    children: [
      CircularProgressIndicator(color: AppColors.primaryColor,),
      SizedBox(width:20,),
      Text(msg ,style: AppStyles.bold20black,)
    ],
  ),
)
);
  }
static void hideLoading({required BuildContext context}){
    Navigator.pop(context);
  }

 static void showMessage({required BuildContext context,
   required String msg,
    String? title,
    String? pos,
   Function? posAction,
    String? nav,
   Function? navAction,


 }){
   List<Widget> actions =[];
   if (pos!=null) {
     actions.add(TextButton(onPressed: (){
       //Navigator.pop(context);
       posAction?.call();
     }, child: Text(pos,style: AppStyles.bold20black,)));
   }
   if (nav!=null) {
     actions.add(TextButton(onPressed: (){
       //Navigator.pop(context);
       navAction?.call();
     }, child: Text(nav,style: AppStyles.bold20black,)));
   }
   showDialog(context: context, builder: (context) {
      return AlertDialog(
        content: Text(msg,style: AppStyles.bold20black,),
        title:Text(title ?? "" ,style: AppStyles.bold20black,) ,
        actions: actions
        );
    },);
 }
}