import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../bloc/results/results_bloc.dart';
import '../../../bloc/results/results_state.dart';
import '../../../bloc/results/results_event.dart';
import '../../../presentation/dashboard/result/result_item.dart';
import '../../../utility/category_detail_list.dart';

class Results extends StatelessWidget {
  Results({Key? key}) : super(key: key);

  final List<String> categories = [for (var e in categoryDetailList) e.title];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResultsBloc()..add(CategoryDataRequested(categories.first)),
      child: ResultsContent(categories: categories),
    );
  }
}

class ResultsContent extends StatefulWidget {
  final List<String> categories;

  const ResultsContent({Key? key, required this.categories}) : super(key: key);

  @override
  _ResultsContentState createState() => _ResultsContentState();
}

class _ResultsContentState extends State<ResultsContent> {
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.categories.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Container(
          margin: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: widget.categories.take(2).map((category) =>
                    FilledButton.tonal(
                      onPressed: () {
                        setState(() {
                          selectedCategory = category;
                        });
                        context.read<ResultsBloc>().add(CategoryDataRequested(category));
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: selectedCategory == category
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: selectedCategory == category
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                ).toList(),
              ),
              const SizedBox(height: 20),
              BlocConsumer<ResultsBloc, ResultsState>(
                listener: (context, state) {
                  if (state is Error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.error)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is Success) {
                    if (state.data == null || state.data.docs.isEmpty) {
                      return const Text(
                        'Нет данных. Пройдите хотя-бы один тест',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      );
                    }

                    // Extract x-values from analysisData
                    List<double>? xValues = state.analysisData?.map((e) => e.x).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1.70,
                          child: LineChart(
                            LineChartData(
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(color: Colors.grey),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      if (xValues!.contains(value)) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(
                                            //color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(
                                          //color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              minX: 1,
                              maxX: (state.data.docs.length * 1.0),
                              minY: 0,
                              maxY: 50,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: state.analysisData?? [],
                                  isCurved: true,
                                  barWidth: 5,
                                  isStrokeCapRound: true,
                                  color: Colors.green,
                                  gradient: LinearGradient(colors: [Colors.grey, Colors.greenAccent]),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [Colors.grey, Colors.greenAccent]
                                          .map((color) => color.withOpacity(0.1))
                                          .toList(),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListView.builder(
                          itemCount: state.data.docs.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ResultItem(index, state.data.docs[index]);
                          },
                        ),
                      ],
                    );
                  }
                  if (state is Error) {
                    return Text(
                      'Error: ${state.error}',
                      style: TextStyle(color: Colors.red),
                    );
                  }
                  return Center(
                    child: LoadingAnimationWidget.discreteCircle(
                      color: Colors.orangeAccent,
                      size: 50,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
