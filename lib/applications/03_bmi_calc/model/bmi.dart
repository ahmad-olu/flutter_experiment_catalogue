class Bmi {
  Bmi({
    required this.height,
    required this.weight,
    required this.time,
    this.total,
    this.category,
  });

  factory Bmi.fromMap(String map) {
    final res = map.split(';');
    final height = double.parse(res[0]);
    final weight = double.parse(res[1]);
    final total = double.parse(res[2]);
    final category = res[3];
    final date = DateTime.parse(res[4]);

    return Bmi(
      height: height,
      weight: weight,
      total: total,
      category: category,
      time: date,
    );
  }
  final double height;
  final double weight;
  final DateTime time;
  final double? total;
  final String? category;

  Bmi copyWith({
    double? height,
    double? weight,
    double? total,
    String? category,
    DateTime? time,
  }) {
    return Bmi(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      total: total ?? this.total,
      category: category ?? this.category,
      time: time ?? this.time,
    );
  }

  String toMap() {
    return '$height;$weight;${calculateBMI()};${getCategory()};$time';
  }

  String getCategory() {
    if (total! < 18.5) {
      return 'Underweight';
    } else if (total! < 24.9) {
      return 'Normal weight';
    } else if (total! < 29.9) {
      return 'Overweight';
    } else {
      return 'Obesity';
    }
  }

  double calculateBMI() {
    if (height <= 0) {
      throw ArgumentError('Height must be greater than 0');
    } else if (weight <= 0) {
      throw ArgumentError('Weight must be greater than 0');
    }
    return weight / (height * height);
  }

  @override
  String toString() {
    return 'Bmi(height: $height, weight: $weight, total: $total, category: $category)';
  }
}

String getCategory(double total) {
  if (total < 18.5) {
    return 'Underweight';
  } else if (total < 24.9) {
    return 'Normal weight';
  } else if (total < 29.9) {
    return 'Overweight';
  } else {
    return 'Obesity';
  }
}

double calculateBMI(double height, double weight) {
  if (height <= 0) {
    throw ArgumentError('Height must be greater than 0');
  } else if (weight <= 0) {
    throw ArgumentError('Weight must be greater than 0');
  }
  return weight / (height * height);
}
