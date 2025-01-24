import 'package:auto_route/auto_route.dart';
import 'package:experiment_catalogue/applications/03_bmi_calc/cubit/bmi_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class BmiCalc03Page extends StatelessWidget {
  const BmiCalc03Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BmiCubit()..getBmi(),
      child: const BmiCalcView(),
    );
  }
}

class BmiCalcView extends StatelessWidget {
  const BmiCalcView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BmiCubit, BmiState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          backgroundColor: Colors.purple[100],
          body: Column(
            children: [
              SizedBox(
                height: 500,
                child: ListView.builder(
                  itemCount: state.bmi.length,
                  itemBuilder: (context, index) {
                    final bmi = state.bmi[index];
                    final formattedTime =
                        DateFormat('MMM dd, yyyy - hh:mm a').format(bmi.time);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListTile(
                        leading: const Icon(
                          Icons.fitness_center,
                          color: Colors.blue,
                          size: 32,
                        ),
                        title: Text(
                          '${bmi.total?.toStringAsFixed(1)} (${bmi.category})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          'Calculated on: $formattedTime',
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                      child: InputTextField(
                    data: 'height in meters (1.75)',
                    onChanged: (v) => context.read<BmiCubit>().heightStr(v),
                  )),
                  Expanded(
                      child: InputTextField(
                    data: 'weight in kg (70)',
                    onChanged: (v) => context.read<BmiCubit>().weightStr(v),
                  )),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              CustomElevatedButton(
                data: 'Submit',
                onPressed: () => context.read<BmiCubit>().createBmi(),
              )
            ],
          ),
        );
      },
    );
  }
}

class InputTextField extends StatelessWidget {
  const InputTextField({required this.data, super.key, this.onChanged});
  final void Function(String)? onChanged;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: data,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({required this.data, super.key, this.onPressed});

  final void Function()? onPressed;
  final String data;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: SizedBox(
        height: 60,
        width: MediaQuery.sizeOf(context).width,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 4,
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            data,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
