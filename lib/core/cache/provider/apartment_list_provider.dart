import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sokon/core/model/apartment.dart';

import '../../../firebase_utils.dart';


class ApartmentListProvider extends ChangeNotifier{
  //data
  List<Apartment> apartmentList=[];
  bool isLoading = false;


  Future<void> getAllApartmentForOwner(String uId) async {
    isLoading = true;
    notifyListeners();
    try {
      //get all events in List
      QuerySnapshot<Apartment> querySnapshot= await FireBaseUtils.getApartmentCollections(uId).get();
      apartmentList= querySnapshot.docs.map((doc) {
        return doc.data();
      }, ).toList();
    } catch (e) {
      debugPrint("Error fetching owner apartments: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAllApartments() async {
    isLoading = true;
    notifyListeners();
    try {
      //get all apartments from all users using collectionGroup
      QuerySnapshot<Apartment> querySnapshot= await FireBaseUtils.getAllApartmentsCollections().get();
      apartmentList= querySnapshot.docs.map((doc) {
        return doc.data();
      }, ).toList();
    } catch (e) {
      debugPrint("Error fetching all apartments: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
