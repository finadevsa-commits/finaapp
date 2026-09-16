class OperationModel {
  final int id;
  final String date;
  final String description;
  final double montant;
  final String montantFormate;
  final String sens; // CREDIT | DEBIT
  final String type; // entree | sortie

  OperationModel({
    required this.id,
    required this.date,
    required this.description,
    required this.montant,
    required this.montantFormate,
    required this.sens,
    required this.type,
  });

  bool get isCredit => sens == 'CREDIT';

  factory OperationModel.fromJson(Map<String, dynamic> json) {
    return OperationModel(
      id:            json['id'] ?? 0,
      date:          json['date'] ?? '',
      description:   json['description'] ?? '',
      montant:       (json['montant'] ?? 0).toDouble(),
      montantFormate: json['montant_formate'] ?? '0 FCFA',
      sens:          json['sens'] ?? 'DEBIT',
      type:          json['type'] ?? 'sortie',
    );
  }
}