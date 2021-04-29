class CardData {
  int _id;
  String _date;
  String _superId;
  String _productCategorie;
  String _productName;
  int _quantity;

  CardData(this._date, this._superId, this._productCategorie, this._productName,
      this._quantity);

  CardData.withId(this._id, this._date, this._superId, this._productCategorie,
      this._productName, this._quantity);

  int get id => _id;

  String get date => _date;

  String get superId => _superId;

  String get productCategorie => _productCategorie;

  String get productName => _productName;

  int get quantity => _quantity;

  set date(String newdate) {
    this._date = newdate;
  }

  set superId(String newSuperId) {
    this._superId = newSuperId;
  }

  set productCategorie(String newProductCategorie) {
    this._productCategorie = newProductCategorie;
  }

  set productName(String newProductName) {
    this._productName = newProductName;
  }

  set quantity(int newquantity) {
    if (newquantity > 0) {
      this._quantity = newquantity;
    }
  }

  // Convert a CardData object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();

    if (id != null) {
      map['Id'] = _id;
    }

    map['Date'] = _date;
    map['Super_Id'] = _superId;
    map['Product_Categorie'] = _productCategorie;
    map['Product_Name'] = _productName;
    map['Quantity'] = _quantity;

    return map;
  }

  // Extract a Card object from a Map object
  CardData.fromMapObject(Map<String, dynamic> map) {
    this._id = map['Id'];
    this._date = map['Date'];
    this._superId = map['Super_Id'];
    this._productCategorie = map['Product_Categorie'];
    this._productName = map['Product_Name'];
    this._quantity = map['Quantity'];
  }
}
