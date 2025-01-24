import 'package:bloc/bloc.dart';
import 'package:experiment_catalogue/applications/03_bmi_calc/model/bmi.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'bmi_state.dart';

const bmiConst = 'bmi';

class BmiCubit extends Cubit<BmiState> {
  BmiCubit() : super(BmiState.initial());

  void weightStr(String val) {
    final weight = double.tryParse(val.trim()) ?? 0.0;
    emit(state.copyWith(weight: weight));
  }

  void heightStr(String val) {
    final height = double.tryParse(val.trim()) ?? 0.0;
    emit(state.copyWith(height: height));
  }

  Future<void> getBmi() async {
    emit(state.copyWith(status: BmiStatus.loading));
    final prefs = await SharedPreferences.getInstance();

    final items = prefs.getStringList(bmiConst);

    final data = items?.map(Bmi.fromMap).toList();
    emit(state.copyWith(status: BmiStatus.loaded, bmi: data));
  }

  Future<void> createBmi() async {
    emit(state.copyWith(statusForm: BmiFormStatus.loading));
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(bmiConst);
    final data = items?.map(Bmi.fromMap).toList() ?? [];

    final bmiTotal = calculateBMI(state.height, state.weight);
    final bmiCategory = getCategory(bmiTotal);
    final bmi = Bmi(
      height: state.height,
      weight: state.weight,
      category: bmiCategory,
      total: bmiTotal,
      time: DateTime.now(),
    );

    final newData = [...data, bmi];
    await prefs.setStringList(
      bmiConst,
      newData.map((e) => e.toMap()).toList(),
    );

    emit(
      state.copyWith(
        statusForm: BmiFormStatus.loaded,
        bmi: newData,
      ),
    );
  }
}
