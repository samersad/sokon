import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sokon/core/model/apartment.dart';
import 'package:sokon/core/model/booking.dart';
import 'package:sokon/core/model/my_user.dart';


class FireBaseUtils{
  static CollectionReference<Apartment> getApartmentCollections(String uId) {
    return  getUsersCollections().doc(uId).collection(Apartment.collectionName)
      .withConverter<Apartment>(
    fromFirestore: (snapshot, options) => Apartment.fromFireStore(snapshot.data()!),
    toFirestore: (apartment, _) => apartment.toFireStore(),
  );}

  static Query<Apartment> getAllApartmentsCollections() {
    return FirebaseFirestore.instance.collectionGroup(Apartment.collectionName)
        .withConverter<Apartment>(
      fromFirestore: (snapshot, options) => Apartment.fromFireStore(snapshot.data()!),
      toFirestore: (apartment, _) => apartment.toFireStore(),
    );
  }

  static Future<void> addApartmentToFirestore(Apartment apartment,String uId){
    CollectionReference<Apartment> collectionRef=getApartmentCollections( uId);
    var docRef=  collectionRef.doc();
    apartment.id= docRef.id; 
    return docRef.set(apartment);
  }

  static CollectionReference<MyUser> getUsersCollections() {
    return  FirebaseFirestore.instance.collection(MyUser.collectionName)
        .withConverter<MyUser>(
      fromFirestore: (snapshot, _) => MyUser.fromFireStore(snapshot.data()!),
      toFirestore: (myUser, _) => myUser.toFireStore(),
    );}

  static Future<void> addUserToFirestore(MyUser myUser){
   return getUsersCollections().doc(myUser.id).set(myUser);
  }

  static Future<MyUser?> readUserFromFireStore(String id) async {
    var querySnapshot= await getUsersCollections().doc(id).get();
    return querySnapshot.data();
  }

  static CollectionReference<Booking> getBookingCollections() {
    return FirebaseFirestore.instance.collection(Booking.collectionName)
        .withConverter<Booking>(
      fromFirestore: (snapshot, _) => Booking.fromFireStore(snapshot.data()!),
      toFirestore: (booking, _) => booking.toFireStore(),
    );
  }

  static Future<void> addBookingToFirestore(Booking booking) {
    var docRef = getBookingCollections().doc();
    booking.id = docRef.id;
    return docRef.set(booking);
  }

  static Stream<QuerySnapshot<Booking>> getBookingsStream(String userId, bool isOwner) {
    if (isOwner) {
      return getBookingCollections().where('ownerId', isEqualTo: userId).snapshots();
    } else {
      return getBookingCollections().where('clientId', isEqualTo: userId).snapshots();
    }
  }
}
