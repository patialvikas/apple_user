import 'package:flutter/material.dart';

import '../const/app_asset.dart';



class VitaminModal {
  String? image;
  bool? favorite;
  String title;
  String subtitle;
  String price;

  VitaminModal.vitaminmodel(
      {this.image, required this.title, required this.price, this.favorite,required this.subtitle});
}

// ignore: non_constant_identifier_names
List<VitaminModal> VitaminModalList = [
  VitaminModal.vitaminmodel(
    image: AppAssets.vitamin1,
    subtitle: "25 mg,12 pills",
    title: "Napa extra",
    price: "\$24",
    favorite: false,
  ),
  VitaminModal.vitaminmodel(
    image: AppAssets.vitamin2,
    subtitle: "25 mg,12 pills",
    title: "Napa extra",
    price: "\$24",
    favorite: false,
  ),VitaminModal.vitaminmodel(
    image: AppAssets.vitamin3,
    subtitle: "25 mg,12 pills",
    title: "Napa extra",
    price: "\$24",
    favorite: false,
  ),VitaminModal.vitaminmodel(
    image: AppAssets.vitamin1,
    subtitle: "25 mg,12 pills",
    title: "Napa extra",
    price: "\$24",
    favorite: false,
  ),VitaminModal.vitaminmodel(
    image: AppAssets.vitamin2,
    subtitle: "25 mg,12 pills",
    title: "Napa extra",
    price: "\$24",
    favorite: false,
  ),VitaminModal.vitaminmodel(
    image: AppAssets.vitamin3,
    subtitle: "25 mg,12 pills",
    title: "Napa extra",
    price: "\$24",
    favorite: false,
  ),
];
