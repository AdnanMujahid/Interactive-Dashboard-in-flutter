import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const InteractiveDashboardApp());
}

class InteractiveDashboardApp extends StatelessWidget {
  const InteractiveDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.indigoAccent,
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      home: const InteractiveDashboardScreen(),
    );
  }
}

class InteractiveDashboardScreen extends StatefulWidget {
  const InteractiveDashboardScreen({super.key});

  @override
  State<InteractiveDashboardScreen> createState() => _InteractiveDashboardScreenState();
}

class _InteractiveDashboardScreenState extends State<InteractiveDashboardScreen>
    with TickerProviderStateMixin {
  late List<DashboardCard> _cards;
  int _nextCardId = 5;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _cards = _initializeCards();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<DashboardCard> _initializeCards() {
    return [
      DashboardCard(
        id: 1,
        title: "Revenue Analytics",
        type: CardType.revenue,
        isExpanded: false,
        position: 0,
      ),
      DashboardCard(
        id: 2,
        title: "User Engagement",
        type: CardType.lineChart,
        isExpanded: false,
        position: 1,
      ),
      DashboardCard(
        id: 3,
        title: "Sales Performance",
        type: CardType.barChart,
        isExpanded: false,
        position: 2,
      ),
      DashboardCard(
        id: 4,
        title: "Market Share",
        type: CardType.pieChart,
        isExpanded: false,
        position: 3,
      ),
    ];
  }




  void _addCard(CardType type) {
    setState(() {
      _cards.add(DashboardCard(
        id: _nextCardId++,
        title: _getCardTitle(type),
        type: type,
        isExpanded: false,
        position: _cards.length,
      ));
    });
  }

  String _getCardTitle(CardType type) {
    switch (type) {
      case CardType.revenue:
        return "Revenue Analytics";
      case CardType.lineChart:
        return "User Engagement";
      case CardType.barChart:
        return "Sales Performance";
      case CardType.pieChart:
        return "Market Share";
    }
  }

  void _removeCard(int id) {
    setState(() {
      _cards.removeWhere((card) => card.id == id);
      // Update positions after removal
      for (int i = 0; i < _cards.length; i++) {
        _cards[i] = _cards[i].copyWith(position: i);
      }
    });
  }

  void _toggleCardExpansion(int id) {
    setState(() {
      final index = _cards.indexWhere((card) => card.id == id);
      if (index != -1) {
        _cards[index] = _cards[index].copyWith(isExpanded: !_cards[index].isExpanded);
      }
    });
  }

  void _reorderCards(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final card = _cards.removeAt(oldIndex);
      _cards.insert(newIndex, card);
      
      // Update positions
      for (int i = 0; i < _cards.length; i++) {
        _cards[i] = _cards[i].copyWith(position: i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E27).withValues(alpha: 0.9),
        elevation: 0,
        title: const Text(
          "Interactive Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: _showAddCardDialog,
            icon: const Icon(Icons.add_chart_rounded, color: Colors.white),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ReorderableListView.builder(
            onReorder: _reorderCards,
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              final card = _cards[index];
              return AnimatedCard(
                key: ValueKey(card.id),
                card: card,
                onTap: () => _toggleCardExpansion(card.id),
                onRemove: () => _removeCard(card.id),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAddCardDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add New Card",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildCardOption(Icons.attach_money, "Revenue", CardType.revenue),
                    _buildCardOption(Icons.show_chart_rounded, "Line Chart", CardType.lineChart),
                    _buildCardOption(Icons.bar_chart_rounded, "Bar Chart", CardType.barChart),
                    _buildCardOption(Icons.pie_chart_rounded, "Pie Chart", CardType.pieChart),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardOption(IconData icon, String label, CardType type) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _addCard(type);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Colors.indigoAccent),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

enum CardType { revenue, lineChart, barChart, pieChart }

class DashboardCard {
  final int id;
  final String title;
  final CardType type;
  final bool isExpanded;
  final int position;

  DashboardCard({
    required this.id,
    required this.title,
    required this.type,
    required this.isExpanded,
    required this.position,
  });

  DashboardCard copyWith({
    int? id,
    String? title,
    CardType? type,
    bool? isExpanded,
    int? position,
  }) {
    return DashboardCard(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      isExpanded: isExpanded ?? this.isExpanded,
      position: position ?? this.position,
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final DashboardCard card;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const AnimatedCard({
    super.key,
    required this.card,
    required this.onTap,
    required this.onRemove,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _swipeController;
  late Animation<double> _expandAnimation;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _expandAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );
    

    if (widget.card.isExpanded) {
      _expandController.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.isExpanded != oldWidget.card.isExpanded) {
      if (widget.card.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _swipeController.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_dragOffset.abs() > 100) {
      // Swipe to remove
      _swipeController.forward().then((_) {
        widget.onRemove();
      });
    } else {
      // Snap back
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _expandAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                elevation: 12,
                color: Colors.white.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                ),
                clipBehavior: Clip.antiAlias,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: widget.card.isExpanded ? 400 : 200,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.card.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    widget.card.isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                                  onPressed: widget.onTap,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white54,
                                    size: 20,
                                  ),
                                  onPressed: widget.onRemove,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ClipRect(
                            child: _buildCardContent(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent() {
    switch (widget.card.type) {
      case CardType.revenue:
        return const RevenueCardContent();
      case CardType.lineChart:
        return const AnimatedLineChartContent();
      case CardType.barChart:
        return const AnimatedBarChartContent();
      case CardType.pieChart:
        return const AnimatedPieChartContent();
    }
  }
}

class RevenueCardContent extends StatelessWidget {
  const RevenueCardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "\$45,231.89",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FFA3),
          ),
        ),
        SizedBox(height: 6),
        Text(
          "+20.1% from last month",
          style: TextStyle(fontSize: 14, color: Colors.greenAccent),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.trending_up, color: Colors.greenAccent, size: 16),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                "Revenue is growing steadily",
                style: TextStyle(color: Colors.white70, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AnimatedLineChartContent extends StatefulWidget {
  const AnimatedLineChartContent({super.key});

  @override
  State<AnimatedLineChartContent> createState() => _AnimatedLineChartContentState();
}

class _AnimatedLineChartContentState extends State<AnimatedLineChartContent>
    with TickerProviderStateMixin {
  late Timer _timer;
  final Random _random = Random();
  List<FlSpot> _spots = [];
  late AnimationController _chartController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeInOut),
    );
    
    _spots = List.generate(12, (i) => FlSpot(i.toDouble(), _random.nextDouble() * 5 + 1));
    _chartController.forward();
    
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        _spots = List.generate(12, (i) => FlSpot(i.toDouble(), _random.nextDouble() * 5 + 1));
      });
      _chartController.reset();
      _chartController.forward();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: _spots,
                isCurved: true,
                color: Colors.cyanAccent,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.cyanAccent.withValues(alpha: 0.3),
                      Colors.cyanAccent.withValues(alpha: 0.0)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      },
    );
  }
}

class AnimatedBarChartContent extends StatefulWidget {
  const AnimatedBarChartContent({super.key});

  @override
  State<AnimatedBarChartContent> createState() => _AnimatedBarChartContentState();
}

class _AnimatedBarChartContentState extends State<AnimatedBarChartContent>
    with TickerProviderStateMixin {
  late Timer _timer;
  final Random _random = Random();
  late List<BarChartGroupData> _groupData;
  late AnimationController _chartController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeInOut),
    );
    
    _updateData();
    _chartController.forward();
    
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _updateData();
      });
      _chartController.reset();
      _chartController.forward();
    });
  }

  void _updateData() {
    _groupData = List.generate(7, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: _random.nextDouble() * 10 + 2,
            gradient: const LinearGradient(
              colors: [Colors.purpleAccent, Colors.indigoAccent],
            ),
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 12,
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: _groupData,
          ),
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        );
      },
    );
  }
}

class AnimatedPieChartContent extends StatefulWidget {
  const AnimatedPieChartContent({super.key});

  @override
  State<AnimatedPieChartContent> createState() => _AnimatedPieChartContentState();
}

class _AnimatedPieChartContentState extends State<AnimatedPieChartContent>
    with TickerProviderStateMixin {
  late Timer _timer;
  int touchedIndex = -1;
  late AnimationController _chartController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeInOut),
    );
    
    _chartController.forward();
    
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      setState(() {});
      _chartController.reset();
      _chartController.forward();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            borderData: FlBorderData(show: false),
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: showingSections(),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> showingSections() {
    final random = Random();
    final sections = List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      final color = [
        Colors.pinkAccent,
        Colors.amberAccent,
        Colors.lightGreenAccent,
        Colors.tealAccent,
      ][i];

      return PieChartSectionData(
        color: color,
        value: random.nextDouble() * 100,
        title: '${(random.nextDouble() * 100).toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 2,
            )
          ],
        ),
      );
    });
    return sections;
  }
}