// import 'package:cloud_firestore/cloud_firestore.dart';

// class BannerModel {
//   final String id;
//   final String imageUrl;
//   final String link;
//   final bool isActive;
//   final Timestamp? createdAt;
//   final Timestamp? updatedAt;

//   BannerModel({
//     required this.id,
//     required this.imageUrl,
//     required this.link,
//     required this.isActive,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory BannerModel.fromJson(Map<String, dynamic> json, {String? docId}) {
//     return BannerModel(
//       id: docId ?? json['id'] ?? '',
//       imageUrl: json['imageUrl'] ?? '',
//       link: json['link'] ?? '',
//       isActive: json['isActive'] ?? false,
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//     );
//   }

//   factory BannerModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return BannerModel.fromJson(data, docId: doc.id);
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'imageUrl': imageUrl,
//       'link': link,
//       'isActive': isActive,
//     };
//   }

//   BannerModel copyWith({
//     String? id,
//     String? imageUrl,
//     String? link,
//     bool? isActive,
//     Timestamp? createdAt,
//     Timestamp? updatedAt,
//   }) {
//     return BannerModel(
//       id: id ?? this.id,
//       imageUrl: imageUrl ?? this.imageUrl,
//       link: link ?? this.link,
//       isActive: isActive ?? this.isActive,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class PromoBannersModel {
  final String title;
  final String image;
  final String category;
  final String id;

  PromoBannersModel(
      {required this.title,
      required this.id,
      required this.image,
      required this.category});

  // convert to json to object model
  factory PromoBannersModel.fromJson(Map<String, dynamic> json, String id) {
    return PromoBannersModel(
        title: json["title"] ?? "",
        image: json["image"] ?? "",
        category: json["category"] ?? "",
        id: id);
  }

  // Convert List<QueryDocumentSnapshot> to List<ProductModel>
  static List<PromoBannersModel> fromJsonList(
      List<QueryDocumentSnapshot> list) {
    return list
        .map((e) =>
            PromoBannersModel.fromJson(e.data() as Map<String, dynamic>, e.id))
        .toList();
  }
}