part of 'bmi_cubit.dart';

enum BmiStatus { initial, loading, loaded, failure }

enum BmiFormStatus { loading, loaded, failure }

@immutable
class BmiState {
  const BmiState({
    required this.height,
    required this.weight,
    required this.bmi,
    required this.status,
    required this.statusForm,
  });

  factory BmiState.initial() => const BmiState(
        height: 0,
        weight: 0,
        bmi: [],
        status: BmiStatus.initial,
        statusForm: BmiFormStatus.loaded,
      );

  final double height;
  final double weight;
  final List<Bmi> bmi;
  final BmiStatus status;
  final BmiFormStatus statusForm;

  BmiState copyWith({
    double? height,
    double? weight,
    List<Bmi>? bmi,
    BmiStatus? status,
    BmiFormStatus? statusForm,
  }) {
    return BmiState(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      status: status ?? this.status,
      statusForm: statusForm ?? this.statusForm,
    );
  }

  @override
  String toString() {
    return 'BmiState(height: $height, weight: $weight, bmi: $bmi, status: $status, statusForm: $statusForm)';
  }

  @override
  bool operator ==(covariant BmiState other) {
    if (identical(this, other)) return true;

    return other.height == height &&
        other.weight == weight &&
        listEquals(other.bmi, bmi) &&
        other.status == status &&
        other.statusForm == statusForm;
  }

  @override
  int get hashCode {
    return height.hashCode ^
        weight.hashCode ^
        bmi.hashCode ^
        status.hashCode ^
        statusForm.hashCode;
  }
}
