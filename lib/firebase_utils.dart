import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sokon/core/model/apartment.dart';
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
    //todo create doc
    var docRef=  collectionRef.doc();
    apartment.id= docRef.id; //auto id
    return
      docRef.set(apartment); //todo save date
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




//todo firebase => json
  //todo [] => json array  , {} => json object
  //todo developers =>object

  // todo json=> object
  // todo object => json
}
