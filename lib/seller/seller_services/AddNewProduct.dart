import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_market2/SizeConfig.dart';
import 'package:super_market2/seller/seller_services/SellerHomePage.dart';

class AddNewProduct extends StatefulWidget {
  String productType;
  AddNewProduct({@required this.productType});

  @override
  _AddNewProductState createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {
  final formKey1 = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool inStock = true;
  bool veg = true;
  bool uploading = false;

  List<String> imageURL = <String>[];
  List<String> imageURLP = <String>[];
  List<Asset> resultList = <Asset>[];
  List<Asset> resultList1 = <Asset>[];
  List<Asset> resultListP = <Asset>[];
  List productDetails = [];
  List productList = [];

  String productName, brandName, price, uid, description = "Not Available";

  @override
  void initState() {
    super.initState();
    getProductList();
  }

  void getProductList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("userNiId");

    DocumentReference userStore = FirebaseFirestore.instance
        .collection('Super Market')
        .doc("Recruiter")
        .collection(uid)
        .doc(widget.productType);

    await userStore.get().then((value) async {
      setState(() {
        productList = List.from(value.data()["List"]);
        print("\n\n\n\n\n");
        print(productList);
        print("\n\n\n");
      });
    });
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
        child: Container(
          child: Form(
            key: formKey1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 26),
              child: Column(
                children: [
                  textFieldContainer("Product Name"),
                  textFieldContainer("Brand Name"),
                  textFieldContainer("Price"),
                  textFieldContainer("Description"),
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
                  uploading
                      ? CircularProgressIndicator(
                          backgroundColor: Colors.black,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.grey),
                        )
                      : Container(
                          height: imageURL.length == 0
                              ? 1
                              : imageURL.length > 3
                                  ? 300
                                  : 150,
                          child: GridView.count(
                            crossAxisCount: 3,
                            children: List.generate(
                              imageURL.length,
                              (index) {
                                return Card(
                                  child: Image.network(imageURL[index]),
                                );
                              },
                            ),
                          ),
                        ),
                  SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  imageUploader(),
                  SizedBox(height: SizeConfig.safeBlockVertical * 8),
                  buildRaisedButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  RaisedButton buildRaisedButton() {
    return RaisedButton(
      onPressed: () async {
        await addProduct();
      },
      child: Text(
        "Publish Product",
      ),
      color: Color(0xffa9e1eb),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Future addProduct() async {
    if (formKey1.currentState.validate() &&
        inStock == true &&
        resultList.isNotEmpty &&
        imageURL.isNotEmpty &&
        imageURLP.isNotEmpty &&
        resultList.length == imageURL.length &&
        resultList.length == imageURLP.length &&
        !productList.contains(productName)) {
      try {
        print("gautam");

        DocumentReference userStore = FirebaseFirestore.instance
            .collection('Super Market')
            .doc("Recruiter")
            .collection(uid)
            .doc(widget.productType);

        DocumentReference userStoreP = FirebaseFirestore.instance
            .collection('Super Market')
            .doc("Product Categories")
            .collection("Product Collection")
            .doc(widget.productType);

        await {
          if (widget.productType == "Grocery" ||
              widget.productType == "Biscuits & Cookies" ||
              widget.productType == "Fruits & Vegetables" ||
              widget.productType == "Dairy & Bakery")
            {
              await productDetails.addAll(
                  [productName, brandName, price, description, inStock, veg]),
            }
          else
            {
              await productDetails.addAll(
                  [productName, brandName, price, description, inStock]),
            }
        };

        Map<String, List> userInfoMap = await {
          "Images": imageURL,
        };

        Map<String, List> userInfoMapP = await {
          "Images": imageURLP,
        };

        await productDetails.addAll([userInfoMap]);

        if (productList.isNotEmpty) {
          await {
            userStore.update({
              await productName: FieldValue.arrayUnion(productDetails),
              await "List": FieldValue.arrayUnion([productName]),
            }).then((value) async {
              productDetails.removeLast();
              await productDetails.addAll([userInfoMapP]);
              userStoreP.update({
                await productName: FieldValue.arrayUnion(productDetails),
                await "List": FieldValue.arrayUnion([productName]),
              }).then((value) {
                showSnackbar("All Details Uploaded Successfully....");
              }).then((value) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => SellerHomePage()),
                );
              });
            })
          };
        }else{
          await {
            userStore.set({
              await productName: FieldValue.arrayUnion(productDetails),
              await "List": FieldValue.arrayUnion([productName]),
            }).then((value) async {
              productDetails.removeLast();
              await productDetails.addAll([userInfoMapP]);
              userStoreP.update({
                await productName: FieldValue.arrayUnion(productDetails),
                await "List": FieldValue.arrayUnion([productName]),
              }).then((value) {
                showSnackbar("All Details Uploaded Successfully....");
              }).then((value) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => SellerHomePage()),
                );
              });
            })
          };
        }
      } on Exception catch (e) {
        showSnackbar(e.toString());
      }
    } else if (inStock == false) {
      showSnackbar("Check In Stock First...");
    } else if (resultList.length != imageURL.length) {
      showSnackbar("Uploading...");
    } else if (resultList.length == 0) {
      showSnackbar("Upload Image First..");
    } else if (resultList.length != imageURLP.length) {
      showSnackbar("Uploading...");
    } else if (productList.contains(productName)) {
      showSnackbar("You already have this product");
    }
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
            Text(resultList.length.toString()),
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
        !productList.contains(productName)) {
      try {
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
            resultListP = List.from(value);
            uploading = true;
          });

          FirebaseStorage fs = FirebaseStorage.instance;

          var rootReference = fs.ref();

          var image = rootReference
              .child("Recruiter")
              .child(uid)
              .child(widget.productType)
              .child(productName);

          var imageP = rootReference
              .child("Provider")
              .child("Baby Care")
              .child(productName);
          await {
            for (int v = 0; v < resultList1.length; v++)
              await {
                image
                    .child("Image${v + 1}.png")
                    .putData((await resultList1[v].getByteData())
                        .buffer
                        .asUint8List())
                    .then((uploadTask) async {
                  imageP
                      .child("Image${v + 1}.png")
                      .putData((await resultListP[v].getByteData())
                          .buffer
                          .asUint8List())
                      .then((value) async {
                    String _url = await value.ref.getDownloadURL();
                    imageURLP.add(_url);
                  });

                  String _url = await uploadTask.ref.getDownloadURL();
                  showSnackbar("Image ${v + 1} Uploded...");
                  imageURL.add(_url);
                  if (imageURL.length == resultList.length) {
                    setState(() {
                      imageURL.sort();
                      imageURLP.sort();
                      uploading = false;
                    });
                  }
                }),
              }
          };
        });
      } on Exception catch (e) {
        showSnackbar("Error.....");
        setState(() {
          uploading = false;
        });
      }
    } else if (productList.contains(productName)) {
      showSnackbar("You already have this product");
    }
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

  Padding textFieldContainer(String hintText) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: SizeConfig.safeBlockVertical * 1.5),
      child: TextFormField(
        onChanged: (value) {
          if (hintText == "Product Name") {
            productName = value;
          } else if (hintText == "Brand Name") {
            brandName = value;
          } else if (hintText == "Price") {
            price = value;
          } else if (hintText == "Description") {
            description = value;
          }
        },
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
          fillColor: Colors.white60,
          filled: true,
          contentPadding: EdgeInsets.symmetric(
              vertical: SizeConfig.safeBlockVertical * 2.5,
              horizontal: SizeConfig.safeBlockHorizontal * 4),
          border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(20.0),
              borderSide: BorderSide.none),
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
