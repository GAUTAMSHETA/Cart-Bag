String panVerification(String pan, String surname) {
  if (pan.length == 10 && pan.isNotEmpty) {
    if (RegExp(r"^[A-Z]{5}[0-9]{4}[A-Z]{1}$").hasMatch(pan)) {
      if (pan[4] == surname.toUpperCase()) {
        return "Yes";
      } else {
        return "Surname error";
      }
    } else {
      return "Number is Invalid";
    }
  } else {
    return "Number is Invalid";
  }
}

List stateCode = [
  "State Code",
  "JAMMU AND KASHMIR",
  "HIMACHAL PRADESH",
  "PUNJAB",
  "CHANDIGARH",
  "UTTARAKHAND",
  "HARYANA",
  "DELHI",
  "RAJASTHAN",
  "UTTAR  PRADESH",
  "BIHAR",
  "SIKKIM",
  "ARUNACHAL PRADESH",
  "NAGALAND",
  "MANIPUR",
  "MIZORAM",
  "TRIPURA",
  "MEGHLAYA",
  "ASSAM",
  "WEST BENGAL",
  "JHARKHAND",
  "ODISHA",
  "CHATTISGARH",
  "MADHYA PRADESH",
  "GUJARAT",
  "DAMAN AND DIU",
  "DADRA AND NAGAR HAVELI",
  "MAHARASHTRA",
  "ANDHRA PRADESH",
  "KARNATAKA",
  "GOA",
  "LAKSHWADEEP",
  "KERALA",
  "TAMIL NADU",
  "PUDUCHERRY",
  "ANDAMAN AND NICOBAR ISLANDS",
  "TELANGANA",
  "ANDHRA PRADESH",
];

String gstVerification(String pan, String gst, String city) {
  if (gst.length == 15 && gst.isNotEmpty) {
    if (stateCode[int.parse(gst.substring(0, 2))] == city.toUpperCase()) {
      if (gst.substring(2, 12) == pan) {
        if (gst.substring(13, 14) == "Z") {
          return checkSum(gst.substring(0, 14), gst.substring(14));
        } else {
          print(gst.substring(13, 14));
          return "Number is Invalid4";
        }
      } else {
        return "Number is Invalid3";
      }
    } else {
      return "Number is Invalid2";
    }
  } else {
    return "Number is Invalide1";
  }
}

String checkSum(String gst, String cSum) {
  List<int> hash = [];
  int sum = 0;
  for (int i = 0; i < 14; i++) {
    if (gst.codeUnitAt(i) < 65) {
      hash.add(int.parse(gst.substring(i, i + 1)));
    } else {
      hash.add((gst.codeUnitAt(i)) - 55);
    }
  }

  for (int i = 1; i < 14; i = i + 2) {
    hash[i] = hash[i] * 2;
  }

  print(hash);

  for (int i = 0; i < 14; i++) {
    hash[i] = (hash[i] ~/ 36) + hash[i].remainder(36);
  }

  for (int i = 0; i < 14; i++) {
    sum += hash[i];
  }

  if (cSum.codeUnitAt(0) < 65) {
    if (String.fromCharCode(36 - sum.remainder(36) + 48) == cSum) {
      return "Yes";
    } else {
      return "Invalid 1";
    }
  } else {
    if (String.fromCharCode(36 - sum.remainder(36) + 55) == cSum) {
      return "Yes";
    } else {
      return "Invalid 2";
    }
  }
}

List productCategories = [
  ["Grocery","https://firebasestorage.googleapis.com/v0/b/super-market-4828b.appspot.com/o/Product%20Categories%2FGrocery.png?alt=media&token=31224de7-fd04-4067-ac77-f9c0aa168206",false],
  ["Biscuits & Cookies","https://firebasestorage.googleapis.com/v0/b/super-market-4828b.appspot.com/o/Product%20Categories%2FBiscuits.png?alt=media&token=e1d46e1d-6e31-4829-af77-e582c56991f6",false],
  ["Fruits & Vegetables","https://firebasestorage.googleapis.com/v0/b/super-market-4828b.appspot.com/o/Product%20Categories%2FFruit.png?alt=media&token=6d371c37-e019-42e9-badb-a4d8eb255d4c",false],
  ["Dairy & Bakery","https://firebasestorage.googleapis.com/v0/b/super-market-4828b.appspot.com/o/Product%20Categories%2FDairy.jpg?alt=media&token=880da578-a64d-4c96-b64a-d21562fc44fd",false],
  ["Stationery","https://firebasestorage.googleapis.com/v0/b/super-market-4828b.appspot.com/o/Product%20Categories%2FStationery.png?alt=media&token=b8a56045-460d-4257-b543-67611c1968dc",false],
  ["Baby Care","https://firebasestorage.googleapis.com/v0/b/super-market-4828b.appspot.com/o/Product%20Categories%2FBaby%20care.png?alt=media&token=b5270afb-9070-45e6-9089-661e46bd5ace",false],
  ["Home Care","https://firebasestorage.googleapis.com/v0/b/super-market-4828b.appspot.com/o/Product%20Categories%2FHome%20care.png?alt=media&token=080e6cc4-66b4-48c6-b956-f6c9e2381275",false],
  ["Personal Care","https://firebasestorage.googleapis.com/v0/b/super-market-4828b.appspot.com/o/Product%20Categories%2FPersonal%20care.png?alt=media&token=98875060-e8c7-4912-a6c5-4ce458340531",false],
  ["Kids","https://firebasestorage.googleapis.com/v0/b/super-market-4828b.appspot.com/o/Product%20Categories%2FKids.png?alt=media&token=8bde368f-06ed-4ee2-bca0-a1e1f3c721e9",false],
  ["Men","https://firebasestorage.googleapis.com/v0/b/super-market-4828b.appspot.com/o/Product%20Categories%2FMen.png?alt=media&token=45906afb-2bf1-48a4-9fbc-39bf7eaa313d",false],
  ["Women","https://firebasestorage.googleapis.com/v0/b/super-market-4828b.appspot.com/o/Product%20Categories%2FWomen.png?alt=media&token=2b20802f-89cb-4650-bc7d-6f39159afa12",false],
  ["Others","https://firebasestorage.googleapis.com/v0/b/super-market-4828b.appspot.com/o/Product%20Categories%2FOthers.png?alt=media&token=249a9c1a-fa21-456e-8ac5-4de2df04a5d5",false],
];