class DriverModel {
   String name;
   String phoneNumber;
   String CNIC;
   String make;
   String model;
   String carYear;
   String seats;
   String numberPlate;
   String carColor;
   String profilePic;
   String createdAt;
   String uid;
   String deviceToken;

  DriverModel({
     required this.name,
     required this.phoneNumber,
     required this.CNIC,
     required this.make,
     required this.model,
     required this.carYear,
     required this.seats,
     required this.numberPlate,
     required this.carColor,
     required this.profilePic,
     required this.createdAt,
     required this.uid,
    required this.deviceToken
  });
  //from map

  factory DriverModel.fromMap(Map<String,dynamic>map){
    return DriverModel(
        name: map['name']??'',
        phoneNumber: map['phoneNumber']??'',
        CNIC: map['CNIC']??'',
        make: map['make']??'',
        model: map['model']??'',
        carYear: map['carYear']??'',
        seats: map['seats']??'',
        numberPlate: map['numberPlate']??'',
        carColor: map['carColor']??'',
        profilePic: map['profilePic']??'',
        createdAt: map['createdAt']??'',
        uid: map['uid']??'',
        deviceToken:map['deviceToken']??'',
    );
  }

  //to map
Map<String,dynamic>toMap(){
    return{
      "name":name,
      "phoneNumber":phoneNumber,
      "CNIC":CNIC,
      "make":make,
      "model":model,
      "carYear":carYear,
      "seats":seats,
      "numberPlate":numberPlate,
      "carColor":carColor,
      "profilePic":profilePic,
      "createdAt":createdAt,
      "uid":uid,
      "deviceToken":deviceToken
    };
}

}



