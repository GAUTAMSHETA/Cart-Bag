import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:super_market2/LogPages/widget.dart';
import 'package:super_market2/SizeConfig.dart';

class ProductSelection extends StatefulWidget {
  String productCatrgoris;
  String uid;

  ProductSelection(this.productCatrgoris, this.uid);

  @override
  _ProductSelectionState createState() => _ProductSelectionState();
}

class _ProductSelectionState extends State<ProductSelection> {
  TextEditingController searchTextEditingController = TextEditingController();

  List productList = [];
  List productListForDisplay = [];

  bool isLoading = true;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  Future _getData() async {
    DocumentReference users = FirebaseFirestore.instance
        .collection('Super Market')
        .doc("Recruiter")
        .collection(widget.uid)
        .doc(widget.productCatrgoris);

    await users.get().then((value) async {
      productList.clear();
      productListForDisplay.clear();
      setState(() {
        print("\n\n\n\n");
        print(value.data()["List"]);
        print("\n\n\n\n");
        productList = List.from(value.data()["List"]);
        productListForDisplay = List.from(value.data()["List"]);
      });
      print(productList);
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productCatrgoris,style: TextStyle(color: Colors.black),),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[200],
      drawer: Drower(recruiter: true),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: SizeConfig.safeBlockHorizontal * 2,
                      right: SizeConfig.safeBlockHorizontal * 2,
                      top: SizeConfig.safeBlockVertical * 1),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20))),
                  child: TextField(
                    controller: searchTextEditingController,
                    decoration: InputDecoration(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: Icon(Icons.search),
                      ),
                      hintText: "Search",
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        productListForDisplay.clear();
                      });

                      for (String i in productList) {
                        if (RegExp(".*${value.toUpperCase()}.*")
                            .hasMatch(i.toUpperCase())) {
                          setState(() {
                            productListForDisplay.add(i);
                          });
                        }
                      }
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.safeBlockVertical * 1,
                        horizontal: SizeConfig.blockSizeHorizontal * 3),
                    margin: EdgeInsets.symmetric(
                        horizontal: SizeConfig.safeBlockHorizontal * 2,
                        vertical: SizeConfig.safeBlockVertical * 1),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(20))),
                    child: ListView.separated(
                      physics: BouncingScrollPhysics(),
                      itemCount: productListForDisplay.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          splashColor: Colors.white70,
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                  builder: (_) => EditProduct(
                                      widget.productCatrgoris,
                                      productListForDisplay[index])),
                            );
                          },
                          onLongPress: () {
                            _showMyDialog(productListForDisplay[index]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: AutoSizeText(productListForDisplay[index]),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _showMyDialog(String dK) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert Dialog'),
          content: Text('Are you sure you want to remove ${dK} ?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                print("\n\nGautam\n\n");
                deleteProduct(dK);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future deleteProduct(String productName) async {
    DocumentReference userStore = FirebaseFirestore.instance
        .collection('Super Market')
        .doc("Recruiter")
        .collection(widget.uid)
        .doc(widget.productCatrgoris);

    userStore.update({productName: FieldValue.delete()}).then((value) {
      userStore.update({
        "List": FieldValue.arrayRemove([productName])
      }).then((value) {
        setState(() {
          productListForDisplay.remove(productName);
          productList.remove(productName);
        });
      });
    });
  }
}

class EditProduct extends StatefulWidget {
  String productType;
  String productName;
  EditProduct(this.productType, this.productName);

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final formKey1 = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController productNameController = TextEditingController();
  TextEditingController productBrandController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();

  bool inStock = true;
  bool veg = true;
  bool uploading = false;

  String uid;

  List<String> imageUrlList = [];
  List<String> imageUrlList1 = [];
  List<Asset> resultList = <Asset>[];
  List<Asset> resultList1 = <Asset>[];
  List productDetails = [];
  List productList = [];

  @override
  void initState() {
    super.initState();
    getProductDetails();
  }

  void getProductDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      uid = prefs.getString("userNiId");

      DocumentReference userStore = FirebaseFirestore.instance
          .collection('Super Market')
          .doc("Recruiter")
          .collection(uid)
          .doc(widget.productType);

      await userStore.get().then((value) async {
        setState(() {
          productNameController.text = value.get(widget.productName)[0];
          productBrandController.text = value.get(widget.productName)[1];
          productPriceController.text =
              value.get(widget.productName)[2].toString();
          productDescriptionController.text = value.get(widget.productName)[3];
          inStock = value.get(widget.productName)[4];

          if (widget.productType == "Grocery" ||
              widget.productType == "Biscuits & Cookies" ||
              widget.productType == "Fruits & Vegetables" ||
              widget.productType == "Dairy & Bakery") {
            veg = value.get(widget.productName)[5];
            imageUrlList =
                List.from(value.get(widget.productName)[6]["Images"]);
          } else {
            imageUrlList =
                List.from(value.get(widget.productName)[5]["Images"]);
          }
        });
      });
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.productType,style: TextStyle(color: Colors.black),),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Form(
          key: formKey1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 26),
            child: Column(
              children: [
                textFieldContainer("Product Name", productNameController),
                textFieldContainer("Brand Name", productBrandController),
                textFieldContainer("Price", productPriceController),
                textFieldContainer("Description", productDescriptionController),
                stockAvailablity(),
                widget.productType == "Grocery" ||
                        widget.productType == "Biscuits & Cookies" ||
                        widget.productType == "Fruits & Vegetables" ||
                        widget.productType == "Dairy & Bakery"
                    ? vegRoNot("Veg")
                    : Container(),
                widget.productType == "Grocery" ||
                        widget.productType == "Biscuits & Cookies" ||
                        widget.productType == "Fruits & Vegetables" ||
                        widget.productType == "Dairy & Bakery"
                    ? vegRoNot("Non - Veg")
                    : Container(),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                AutoSizeText(
                  "Product Images",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 1),
                uploading
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.black,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                      )
                    : Container(
                        height: imageUrlList.length > 3 ? 300 : 150,
                        child: GridView.count(
                          crossAxisCount: 3,
                          children: List.generate(
                            imageUrlList.length,
                            (index) {
                              return Card(
                                child: Image.network(imageUrlList[index]),
                              );
                            },
                          ),
                        ),
                      ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                imageUploader(),
                SizedBox(height: SizeConfig.safeBlockVertical * 5),
                buildRaisedButton(),
                SizedBox(height: SizeConfig.safeBlockVertical * 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DottedBorder imageUploader() {
    return DottedBorder(
      strokeWidth: 3,
      color: Colors.black,
      radius: Radius.circular(24),
      borderType: BorderType.RRect,
      dashPattern: [5, 4],
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.safeBlockHorizontal * 3),
        margin:
            EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 0.5),
        child: Row(
          children: [
            Spacer(),
            Text(imageUrlList.length.toString()),
            Spacer(),
            RaisedButton.icon(
              onPressed: () async {
                await imagePickerAndUploder();
              },
              icon: Icon(
                Icons.upload_outlined,
                color: Colors.black,
              ),
              label: Text(
                "UPLOAD IMAGE",
                style: TextStyle(color: Colors.black),
              ),
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Future imagePickerAndUploder() async {
    if (formKey1.currentState.validate() &&
        !productList.contains(productNameController.text)) {
      setState(() {
        uploading = true;
      });

      resultList1 = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: resultList1,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#FFFFFF",
        ),
      ).then((List<Asset> value) async {
        setState(() {
          resultList = List.from(value);
          resultList1 = List.from(value);
        });

        FirebaseStorage fs = FirebaseStorage.instance;

        var rootReference = fs.ref();

        var image = rootReference
            .child("Recruiter")
            .child(uid)
            .child(widget.productType)
            .child(productNameController.text);

        rootReference
            .child("Recruiter")
            .child(uid)
            .child(widget.productType)
            .child(productNameController.text)
            .delete();

        await {
          for (int v = 0; v < resultList1.length; v++)
            await {
              image
                  .child("Image${v + 1}.png")
                  .putData(
                      (await resultList1[v].getByteData()).buffer.asUint8List())
                  .then((uploadTask) async {
                String _url = await uploadTask.ref.getDownloadURL();
                showSnackbar("Image ${v + 1} Uploded...");
                imageUrlList1.add(_url);

                if (imageUrlList1.length == resultList.length) {
                  imageUrlList.clear();
                  imageUrlList1.sort();
                  setState(() {
                    imageUrlList = List.from(imageUrlList1);
                    uploading = false;
                  });
                }
              }),
            }
        };
      });
    } else if (productList.contains(productNameController.text)) {
      showSnackbar("You already have this product");
    }
  }

  Future deleteProduct() async {
    DocumentReference userStore = FirebaseFirestore.instance
        .collection('Super Market')
        .doc("Recruiter")
        .collection(uid)
        .doc(widget.productType);

    userStore.update({widget.productName: FieldValue.delete()}).then((value) {
      userStore.update({
        "List": FieldValue.arrayRemove([widget.productName])
      }).then((value) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
              builder: (_) => ProductSelection(widget.productType, uid)),
        );
      });
    });
  }

  Future addProduct() async {
    if (formKey1.currentState.validate() &&
        imageUrlList.isNotEmpty &&
        resultList.length == imageUrlList1.length &&
        !productList.contains(productNameController.text)) {
      try {
        print("gautam");

        DocumentReference userStore = FirebaseFirestore.instance
            .collection('Super Market')
            .doc("Recruiter")
            .collection(uid)
            .doc(widget.productType);

        await {
          if (widget.productType == "Grocery" ||
              widget.productType == "Biscuits & Cookies" ||
              widget.productType == "Fruits & Vegetables" ||
              widget.productType == "Dairy & Bakery")
            {
              await productDetails.addAll([
                productNameController.text,
                productBrandController.text,
                productPriceController.text,
                productDescriptionController.text,
                inStock,
                veg
              ]),
            }
          else
            {
              await productDetails.addAll([
                productNameController.text,
                productBrandController.text,
                productPriceController.text,
                productDescriptionController.text,
                inStock
              ]),
            }
        };

        Map<String, List> userInfoMap = await {
          "Images": imageUrlList,
        };

        await productDetails.addAll([userInfoMap]);

        userStore
            .update({widget.productName: FieldValue.delete()}).then((value) {
          userStore.update({
            "List": FieldValue.arrayRemove([widget.productName])
          }).then((value) async {
            await {
              userStore.update({
                await productNameController.text:
                    FieldValue.arrayUnion(productDetails),
                await "List":
                    FieldValue.arrayUnion([productNameController.text]),
              }).then((value) {
                showSnackbar("All Details Uploaded Successfully....");
              }).then((value) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                      builder: (_) =>
                          ProductSelection(widget.productType, uid)),
                );
              }),
            };
          });
        });
      } on Exception catch (e) {
        showSnackbar(e.toString());
      }
    } else if (resultList.length != imageUrlList1.length) {
      showSnackbar("Uploading...");
    } else if (productList.contains(productNameController.text)) {
      showSnackbar("You already have this product");
    }
  }

  Row buildRaisedButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        RaisedButton(
          onPressed: () async {
            await addProduct();
          },
          child: Text(
            "Upgrade",
          ),
          color: Colors.yellow[200],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        RaisedButton(
          onPressed: () async {
            await deleteProduct();
          },
          child: Text(
            "Delete",
          ),
          color: Colors.red[200],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ],
    );
  }

  RadioListTile<bool> vegRoNot(String title) {
    return RadioListTile<bool>(
      title: Text(
        title,
      ),
      value: title == "Veg" ? true : false,
      groupValue: veg,
      onChanged: (value) {
        setState(() {
          veg = value;
        });
      },
      activeColor: Colors.black,
    );
  }

  CheckboxListTile stockAvailablity() {
    return CheckboxListTile(
      value: inStock,
      onChanged: (value) {
        setState(() {
          inStock = !inStock;
        });
      },
      activeColor: Colors.black,
      title: AutoSizeText("In Stock"),
    );
  }

  Padding textFieldContainer(
      String hintText, TextEditingController textEditingController) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 1.5),
      child: TextFormField(
        controller: textEditingController,
        validator: (value) {
          if (hintText == "Product Name") {
            return value.length > 3 ? null : "Please Enter Value";
          } else if (hintText == "Brand Name") {
            return value.length > 2 ? null : "Please Enter Value";
          } else if (hintText == "Price") {
            if (value.isNotEmpty) {
              return double.parse(value) > 0.0 ? null : "Please Enter Value";
            } else {
              return "Please Enter Value";
            }
          }
          return null;
        },
        minLines: hintText == "Description" ? 3 : null,
        maxLines: hintText == "Description" ? 10 : null,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: hintText,
          fillColor: Colors.white60,
          filled: true,
          contentPadding: EdgeInsets.symmetric(
              vertical: SizeConfig.safeBlockVertical * 2.5,
              horizontal: SizeConfig.safeBlockHorizontal * 4),
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(20.0),
          ),
        ),
        keyboardType: hintText == "Price"
            ? TextInputType.number
            : TextInputType.emailAddress,
      ),
    );
  }

  void showSnackbar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}
