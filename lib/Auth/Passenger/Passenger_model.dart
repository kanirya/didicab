
class PassengerModel {
   String passengerName;
   String passengerGender;
   String passengerCreatedAt;
   String passengerPhoneNumber;
   String uidp;
   String passengerBio;
   String deviceToken;

  PassengerModel(
      {required this.passengerName,
      required this.passengerGender,
      required this.passengerCreatedAt,
      required this.passengerPhoneNumber,
      required this.uidp,
        required this.passengerBio,
         required this.deviceToken
      });
// from map
  factory PassengerModel.fromMap(Map<String, dynamic> map) {
    return PassengerModel(
        passengerName: map['passengerName']??'',
        passengerGender: map['passengerGender']??'',
        passengerCreatedAt: map['passengerCreatedAt']??'',
        passengerPhoneNumber: map['passengerPhoneNumber']??'',
        uidp: map['uidp']??'',
      passengerBio: map['passengerBio']??'',
      deviceToken:map['deviceToken']??''
    );
  }


  // to map
Map<String,dynamic>toMap(){
    return {
      "passengerName":passengerName,
      "passengerGender":passengerGender,
      "passengerCreatedAt":passengerCreatedAt,
      "passengerPhoneNumber":passengerPhoneNumber,
      "uidp":uidp,
      "passengerBio":passengerBio,
      "deviceToken":deviceToken
    };
}
}
