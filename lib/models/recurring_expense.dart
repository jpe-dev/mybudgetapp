class RecurringExpense {
  final String category;
  final double amount;
  final int dayOfMonth;
  final String description;

  RecurringExpense({
    required this.category,
    required this.amount,
    required this.dayOfMonth,
    required this.description,
  });

  // Convertir l'objet en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'dayOfMonth': dayOfMonth,
      'description': description,
    };
  }

  // Créer un objet à partir d'un Map
  factory RecurringExpense.fromJson(Map<String, dynamic> json) {
    return RecurringExpense(
      category: json['category'],
      amount: json['amount'].toDouble(),
      dayOfMonth: json['dayOfMonth'],
      description: json['description'],
    );
  }
}