class ConsumptionEntry {
  const ConsumptionEntry({
    required this.id,
    required this.productId,
    required this.amount,
    required this.unit,
    required this.date,
    this.meal,
    this.recipe,
    this.notes,
    this.source = ConsumptionSource.manual,
  });

  final String id;
  final String productId;
  final double amount;
  final String unit;
  final DateTime date;
  final ConsumptionMeal? meal;
  final String? recipe;
  final String? notes;
  final ConsumptionSource source;

  ConsumptionEntry copyWith({
    String? id,
    String? productId,
    double? amount,
    String? unit,
    DateTime? date,
    ConsumptionMeal? meal,
    String? recipe,
    String? notes,
    ConsumptionSource? source,
    bool clearMeal = false,
    bool clearRecipe = false,
    bool clearNotes = false,
  }) {
    return ConsumptionEntry(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      date: date ?? this.date,
      meal: clearMeal ? null : (meal ?? this.meal),
      recipe: clearRecipe ? null : (recipe ?? this.recipe),
      notes: clearNotes ? null : (notes ?? this.notes),
      source: source ?? this.source,
    );
  }
}

enum ConsumptionMeal { breakfast, lunch, dinner, snack, other }

enum ConsumptionSource { manual, scanner, quickAction }
