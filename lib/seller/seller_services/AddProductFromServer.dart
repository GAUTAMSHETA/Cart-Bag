import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_market2/SizeConfig.dart';
import 'package:super_market2/seller/seller_services/SellerHomePage.dart';

class AddProductFromServer extends StatefulWidget {
  String productType;
  String productName;
  AddProductFromServer(
      {@required this.productType, @required this.productName});
  @override
  _AddProductFromServerState createState() => _AddProductFromServerState();
}

class _AddProductFromServerState extends State<AddProductFromServer> {
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

      DocumentReference users = FirebaseFirestore.instance
          .collection('Super Market')
          .doc("Product Categories")
          .collection("Product Collection")
          .doc(widget.productType);

      DocumentReference userStore = FirebaseFirestore.instance
          .collection('Super Market')
          .doc("Recruiter")
          .collection(uid)
          .doc(widget.productType);

      await users.get().then((value) async {
        setState(() {
          productNameController.text = value.get(widget.productName)[0];
          productBrandController.text = value.get(widget.productName)[1];
          productPriceController.text = value.get(widget.productName)[2].toString();
          productDescriptionController.text = value.get(widget.productName)[3];
          inStock = value.get(widget.productName)[4];

          if (widget.productType == "Grocery" ||
              widget.productType == "Biscuits & Cookies" ||
              widget.productType == "Fruits & Vegetables" ||
              widget.productType == "Dairy & Bakery") {
            veg = value.get(widget.productName)[5];
            imageUrlList = List.from(value.get(widget.productName)[6]["Images"]);
          } else {
            imageUrlList = List.from(value.get(widget.productName)[5]["Images"]);
          }
        });
      });

      await userStore.get().then((value) async {
        setState(() {
          productList = List.from(value.data()["List"]);
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

        await {
          for (int v = 0; v < resultList1.length; v++)
            await {
              image
                  .child("Image${v + 1}.png")
                  .putData(
                      (await resultList1[v].getByteData()).buffer.asUint8List())
                  .then((uploadTask) async {
                String _url = await uploadTask.ref.getDownloadURL();
                showSnackbar("Image ${v + 1} Uploaded...");
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

        if (productList.isNotEmpty) {
          await {
            userStore.update({
              await productNameController.text:
                  FieldValue.arrayUnion(productDetails),
              await "List": FieldValue.arrayUnion([productNameController.text]),
            }).then((value) {
              showSnackbar("All Details Uploaded Successfully....");
            }).then((value) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => SellerHomePage()),
              );
            }),
          };
        }else{
          await {
            userStore.set({
              await productNameController.text:
              FieldValue.arrayUnion(productDetails),
              await "List": FieldValue.arrayUnion([productNameController.text]),
            }).then((value) {
              showSnackbar("All Details Uploaded Successfully....");
            }).then((value) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => SellerHomePage()),
              );
            }),
          };
        }
      } on Exception catch (e) {
        showSnackbar(e.toString());
      }
    } else if (inStock == false) {
      showSnackbar("Check In Stock First...");
    } else if (resultList.length != imageUrlList1.length) {
      showSnackbar("Uploading...");
    } else if (productList.contains(productNameController.text)) {
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
