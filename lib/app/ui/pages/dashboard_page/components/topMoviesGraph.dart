import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:provider/provider.dart';

class TopMoviesGraph extends StatefulWidget {
  @override
  _TopMoviesGraphState createState() => _TopMoviesGraphState();
}

class _TopMoviesGraphState extends State<TopMoviesGraph> {
  String selectedFilter = 'Week';
  int? hoveredIndex;
  bool showTitles = false;

  final Map<String, List<Map<String, dynamic>>> movieData = {
    'Week': [
      {'name': 'Pushpa 2: The Rule', 'revenue': 0},
      {'name': 'Jawan', 'revenue': 0},
      {'name': 'Animal', 'revenue': 0},
      {'name': 'Gadar 2', 'revenue': 0},
      {'name': 'KGF: Chapter 2', 'revenue': 0},
    ],
    'Month': [
      {'name': 'Dunki', 'revenue': 0},
      {'name': 'Pathaan', 'revenue': 0},
      {'name': 'RRR', 'revenue': 0},
      {'name': 'Baahubali 2', 'revenue': 0},
      {'name': 'Leo', 'revenue': 0},
    ],
    'Year': [
      {'name': 'Oppenheimer', 'revenue': 0},
      {'name': 'Barbie', 'revenue': 0},
      {'name': 'John Wick 4', 'revenue': 0},
      {'name': 'Mission Impossible 7', 'revenue': 0},
      {'name': 'Fast X', 'revenue': 0},
    ],
    'Lifetime': [
      {'name': 'Avengers: Endgame', 'revenue': 0},
      {'name': 'Avatar', 'revenue': 0},
      {'name': 'Titanic', 'revenue': 0},
      {'name': 'Star Wars: The Force Awakens', 'revenue': 0},
      {'name': 'Jurassic World', 'revenue': 0},
    ],
  };

  final List<Color> sectionColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Card(
      color: selectedThemeData.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => showTitles = !showTitles);
                        },
                        child: PieChart(
                          PieChartData(
                            sections: _generatePieSections(textScaleFactor),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            borderData: FlBorderData(show: false),
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                if (pieTouchResponse?.touchedSection != null) {
                                  setState(() {
                                    hoveredIndex = pieTouchResponse!
                                        .touchedSection!.touchedSectionIndex;
                                    showTitles = true;
                                  });
                                } else {
                                  setState(() => hoveredIndex = null);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                DropdownButton<String>(
                  dropdownColor: selectedThemeData.cardColor,
                  value: selectedFilter,
                  items: ['Week', 'Month', 'Year', 'Lifetime']
                      .map((filter) => DropdownMenuItem(
                            value: filter,
                            child: Text(
                              filter,
                              style: TextStyle(fontSize: 14 * textScaleFactor),
                            ),
                          ))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() => selectedFilter = newValue!);
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      movieData[selectedFilter]!.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color:
                                sectionColors[entry.key % sectionColors.length],
                            margin: const EdgeInsets.only(right: 8.0),
                          ),
                          SizedBox(
                            width: 150,
                            child: Text(
                              entry.value['name'],
                              style: TextStyle(fontSize: 12 * textScaleFactor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(double textScaleFactor) {
    List<Map<String, dynamic>> movies = movieData[selectedFilter]!;
    return movies.take(5).map((movie) {
      int index = movies.indexOf(movie);
      bool isHovered = hoveredIndex == index;
      return PieChartSectionData(
        title: isHovered ? '${movie['name']} \n ${movie['revenue']}' : '',
        value: movie['revenue'].toDouble(),
        color: sectionColors[index % sectionColors.length],
        radius: isHovered ? 75 : 60,
        titleStyle: TextStyle(
          fontSize: isHovered ? 14 * textScaleFactor : 12 * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
