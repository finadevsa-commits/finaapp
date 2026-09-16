class CompteModel {
  final int id;
  final String numeroCompte;
  final double solde;
  final String soldeFormate;
  final String typeCompte;
  final String codeClasse;
  final String codeAgence;
  final bool isDat;
  final bool isCollecte;

  CompteModel({
    required this.id,
    required this.numeroCompte,
    required this.solde,
    required this.soldeFormate,
    required this.typeCompte,
    required this.codeClasse,
    required this.codeAgence,
    required this.isDat,
    required this.isCollecte,
  });

  factory CompteModel.fromJson(Map<String, dynamic> json) {
    return CompteModel(
      id:            json['id'] ?? 0,
      numeroCompte:  json['numero_compte'] ?? '',
      solde:         (json['solde'] ?? 0).toDouble(),
      soldeFormate:  json['solde_formate'] ?? '0 FCFA',
      typeCompte:    json['type_compte'] ?? 'Compte',
      codeClasse:    json['code_classe'] ?? '',
      codeAgence:    json['code_agence'] ?? '',
      isDat:         json['is_dat'] ?? false,
      isCollecte:    json['is_collecte'] ?? false,
    );
  }
}

