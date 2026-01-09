import 'package:flutter/material.dart';
import 'package:sokon/core/utils/app_colors.dart';
import 'package:sokon/core/utils/app_styles.dart';


class AlertDialogUtils{
  static void  showLoading({required BuildContext context,required String msg}){
    showDialog(barrierDismissible: false,context: context, builder: (context) => AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor,),
          SizedBox(width:20,),
          Text(msg ,style: AppStyles.semiBold14Primary,)
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
    Widget? pos,
    Function? posAction,
    Widget? nav,
    Function? navAction,


  }){
    List<Widget> actions =[];
    if (pos!=null) {
      actions.add(TextButton(onPressed: (){
        //Navigator.pop(context);
        posAction?.call();
      }, child: pos));
    }
    if (nav!=null) {
      actions.add(TextButton(onPressed: (){
        //Navigator.pop(context);
        navAction?.call();
      }, child: nav));
    }
    showDialog(context: context, builder: (context) {
      return AlertDialog(

          content: Text(msg,style:AppStyles.bold20blackIner,),
          title:Text(title ?? "" ,style: AppStyles.semiBold14Primary,) ,
          actions: actions
      );
    },);
  }
}