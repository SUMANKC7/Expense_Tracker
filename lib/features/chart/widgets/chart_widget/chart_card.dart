import 'package:expensetrack/features/chart/model/chart_model.dart';
import 'package:expensetrack/features/chart/provider/chart_provider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartCard extends StatelessWidget {
  final ChartProvider provider;
  final ChartType chartType;
  final double height;

  const ChartCard({
    super.key,
    required this.provider,
    required this.chartType,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              Flexible(
                child: Row(
                  children: [
                    Expanded(flex: 3, child: _buildMiniChart()),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _LegendContainer(
                        child: _buildLegend(_getChartData()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER + FULLSCREEN ICON

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _getChartTitle(chartType),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.fullscreen),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(_getChartTitle(chartType))),
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Expanded(child: _buildMiniChart()),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _LegendContainer(
                            child: _buildLegend(
                              _getChartData(),
                              isFullScreen: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  //   GET CHART DATA

  List<ChartDataModel> _getChartData() {
    switch (chartType) {
      case ChartType.expenseIncome:
        return provider.getExpenseIncomeData();
      case ChartType.categoryBreakdown:
        return provider.getCategoryBreakdownData().take(5).toList();
      case ChartType.cashFlow:
        return provider.getCashFlowData();
      case ChartType.monthlyTrends:
        return [
          ChartDataModel(label: 'Net Flow Trend', value: 0, color: Colors.blue),
        ];
      case ChartType.combined:
        return provider.getCombinedData();
    }
  }

  //   LEGEND

  Widget _buildLegend(List<ChartDataModel> data, {bool isFullScreen = false}) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final fontSize = isFullScreen ? 14.0 : 10.0;
    final itemHeight = isFullScreen ? 32.0 : 24.0;
    final dotSize = isFullScreen ? 12.0 : 8.0;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (isFullScreen) ...[
          Text(
            'Legend',
            style: TextStyle(
              fontSize: fontSize + 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ...data.map((item) {
          final percentage = _calculatePercentage(item, data);
          return Container(
            // height: itemHeight,
            margin: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                // const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(width: 10),
                          Text("=>"),
                          SizedBox(width: 10),
                          if (isFullScreen &&
                              chartType != ChartType.monthlyTrends)
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: fontSize - 2,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),

                      // SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  double _calculatePercentage(ChartDataModel item, List<ChartDataModel> data) {
    if (chartType == ChartType.monthlyTrends) return 0;
    final total = data.fold(0.0, (sum, i) => sum + i.value);
    return total == 0 ? 0 : (item.value / total) * 100;
  }

  // BUILD MINI CHART

  Widget _buildMiniChart() {
    switch (chartType) {
      case ChartType.expenseIncome:
        return _buildMiniPieChart(provider.getExpenseIncomeData());
      case ChartType.categoryBreakdown:
        return _buildMiniPieChart(
          provider.getCategoryBreakdownData().take(5).toList(),
        );
      case ChartType.cashFlow:
        return _buildMiniPieChart(provider.getCashFlowData());
      case ChartType.monthlyTrends:
        return _buildMiniLineChart();
      case ChartType.combined:
        return _buildMiniPieChart(provider.getCombinedData());
    }
  }

  // -------------------------
  // PIE CHART
  // -------------------------
  Widget _buildMiniPieChart(List<ChartDataModel> data) {
    if (data.isEmpty || data.every((e) => e.value == 0)) {
      return const Center(
        child: Text('No data', style: TextStyle(color: Colors.grey)),
      );
    }

    final total = data.fold(0.0, (a, b) => a + b.value);

    return PieChart(
      PieChartData(
        centerSpaceRadius: 20,
        sectionsSpace: 1,
        sections: data.map((item) {
          final pct = total == 0 ? 0 : (item.value / total) * 100;
          return PieChartSectionData(
            value: item.value,
            title: pct > 5 ? '${pct.toStringAsFixed(0)}%' : '',
            color: item.color,
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  // LINE CHART (TREND)

  Widget _buildMiniLineChart() {
    final data = provider.getMonthlyTrendsData();

    if (data.isEmpty) {
      return const Center(
        child: Text('No trend data', style: TextStyle(color: Colors.grey)),
      );
    }

    final values = data.map((e) => e.netFlow).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    final paddedMin = minValue - (range * 0.1);
    final paddedMax = maxValue + (range * 0.1);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: paddedMin,
        maxY: paddedMax,
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          horizontalInterval: range > 0 ? range / 4 : 1000,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 0.5),
          getDrawingVerticalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.3), strokeWidth: 0.5),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: range > 0 ? range / 3 : 1000,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatCurrency(value),
                  style: const TextStyle(fontSize: 8, color: Colors.black54),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                if (data.length > 4 && index % 2 != 0) return const SizedBox();
                return Text(
                  data[index].month,
                  style: const TextStyle(fontSize: 8, color: Colors.black54),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.5)),
            left: BorderSide(color: Colors.grey.withOpacity(0.5)),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            barWidth: 2,
            color: Colors.blue,
            spots: data.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.netFlow);
            }).toList(),
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    if (value.abs() >= 1_000_000)
      return '${(value / 1_000_000).toStringAsFixed(1)}M';
    if (value.abs() >= 1_000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toStringAsFixed(0);
  }

  String _getChartTitle(ChartType type) {
    switch (type) {
      case ChartType.expenseIncome:
        return 'Income vs Expense';
      case ChartType.categoryBreakdown:
        return 'Top Categories';
      case ChartType.monthlyTrends:
        return 'Monthly Trends';
      case ChartType.cashFlow:
        return 'Cash Flow';
      case ChartType.combined:
        return 'Overview';
    }
  }
}

// FIX: LEGEND CONTAINER

class _LegendContainer extends StatelessWidget {
  final Widget child;
  const _LegendContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(height: constraints.maxHeight, child: child);
      },
    );
  }
}
