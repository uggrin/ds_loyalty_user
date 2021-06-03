class Offer {
  Offer({required this.name, required this.pointCost, required this.id});

  final String id;
  final String? name;
  final int? pointCost;

  factory Offer.fromMap(Map<String, dynamic> data, String documentId) {
    if (data.isEmpty) {
      throw ("No offers");
    }
    final String? name = data['name'];
    final int? pointCost = data['pointCost'];
    return Offer(
      name: name,
      pointCost: pointCost,
      id: documentId,
    );
  }

  Map<String, dynamic> offerToMap() {
    return {
      'name': name,
      'pointCost': pointCost,
    };
  }
}
