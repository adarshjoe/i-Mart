class CartModel {
  final String productId;
  final String productName;
  final num productPrice;
  final String catgoryName;
  List<dynamic> imageUrl; // Change to mutable
  int quantity; // Make quantity mutable (non-final)
  final String productSize;
  final num discount;
  final String description;
  final String storeId;

  CartModel({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.catgoryName,
    required this.imageUrl,
    required this.quantity,
    required this.productSize,
    required this.discount,
    required this.description,
    required this.storeId,
  });

  factory CartModel.fromFirestore(Map<String, dynamic> data) {
    return CartModel(
      productId: data['productId'],
      productName: data['productName'],
      productPrice: data['productPrice'],
      catgoryName: data['catgoryName'],
      imageUrl: data['imageUrl'],
      quantity: data['quantity'],
      productSize: data['productSize'],
      discount: data['discount'],
      description: data['description'],
      storeId: data['storeId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'catgoryName': catgoryName,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'productSize': productSize,
      'discount': discount,
      'description': description,
      'storeId': storeId,
    };
  }
}
