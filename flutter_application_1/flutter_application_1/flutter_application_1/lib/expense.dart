class Expense {
  final int id;
  final String name;
  final double amount;
  final DateTime date;
  final String category;

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'], // Add this line
      name: json['name'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']), 
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Add this line
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
  }
}
