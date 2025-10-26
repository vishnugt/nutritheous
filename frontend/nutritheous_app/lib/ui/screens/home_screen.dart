import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/providers.dart';
import '../../models/meal.dart';
import '../../models/user_profile.dart';
import '../widgets/meal_card.dart';
import 'meal_upload_screen.dart';
import 'meal_detail_screen.dart';
import 'meal_edit_screen.dart';
import 'analytics_screen.dart';
import 'trends_screen.dart';
import 'habits_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  // Cache tab titles to avoid recreating on every build
  static const List<String> _tabTitles = [
    'Meals',
    'Calendar',
    'Record',
    'Trends',
    'Analytics',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                user?.email[0].toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 18,
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ),
        title: Text(
          _tabTitles[_selectedIndex],
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          _buildMealsTab(),
          const HabitsScreen(),
          MealUploadScreen(
            onUploadComplete: () => _onItemTapped(0), // Navigate to meals tab
          ),
          const TrendsScreen(),
          const AnalyticsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        elevation: _selectedIndex == 2 ? 8 : 4,
        backgroundColor: theme.colorScheme.primary,
        shape: const CircleBorder(),
        child: Icon(
          _selectedIndex == 2 ? Icons.add_a_photo : Icons.add_a_photo_outlined,
          color: theme.colorScheme.onPrimary,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 65,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Left side buttons
            _buildNavButton(
              context,
              icon: Icons.restaurant_menu_outlined,
              selectedIcon: Icons.restaurant_menu,
              label: 'Meals',
              index: 0,
            ),
            _buildNavButton(
              context,
              icon: Icons.calendar_month_outlined,
              selectedIcon: Icons.calendar_month,
              label: 'Calendar',
              index: 1,
            ),
            // Spacer for FAB
            const SizedBox(width: 56),
            // Right side buttons
            _buildNavButton(
              context,
              icon: Icons.show_chart_outlined,
              selectedIcon: Icons.show_chart,
              label: 'Trends',
              index: 3,
            ),
            _buildNavButton(
              context,
              icon: Icons.analytics_outlined,
              selectedIcon: Icons.analytics,
              label: 'Analytics',
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                size: 24,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealsTab() {
    final mealsAsync = ref.watch(mealsListProvider);
    final todayMealsAsync = ref.watch(todayMealsProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(mealsListProvider.notifier).refresh();
        ref.invalidate(todayMealsProvider);
        ref.invalidate(userProfileProvider);
      },
      child: mealsAsync.when(
        data: (meals) {
          return todayMealsAsync.when(
            data: (todayMeals) => profileAsync.when(
              data: (profile) => meals.isEmpty
                  ? CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildTodaySummary(todayMeals, profile),
                        ),
                        SliverFillRemaining(
                          child: _buildEmptyMealsMessage(),
                        ),
                      ],
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildTodaySummary(todayMeals, profile),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final meal = meals[index];
                                return RepaintBoundary(
                                  child: MealCard(
                                    meal: meal,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MealDetailScreen(
                                            mealId: meal.id,
                                            meal: meal,
                                          ),
                                        ),
                                      );
                                    },
                                    onEdit: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MealEditScreen(meal: meal),
                                        ),
                                      );

                                      if (result == true) {
                                        ref.invalidate(mealsListProvider);
                                        ref.invalidate(todayMealsProvider);
                                      }
                                    },
                                  ),
                                );
                              },
                              childCount: meals.length,
                            ),
                          ),
                        ),
                      ],
                    ),
              loading: () => meals.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildMealsList(meals),
              error: (_, __) => meals.isEmpty
                  ? const Center(child: Text('Error loading profile'))
                  : _buildMealsList(meals),
            ),
            loading: () => meals.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _buildMealsList(meals),
            error: (_, __) => meals.isEmpty
                ? const Center(child: Text('Error loading today\'s meals'))
                : _buildMealsList(meals),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildTodaySummary(List<Meal> meals, UserProfile profile) {
    final completedMeals = meals.where((m) => m.isAnalysisComplete).toList();

    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;
    double totalCarbs = 0;

    for (final meal in completedMeals) {
      if (meal.nutrition != null) {
        totalCalories += meal.nutrition!.calories;
        totalProtein += meal.nutrition!.protein;
        totalFat += meal.nutrition!.fat;
        totalCarbs += meal.nutrition!.carbs;
      }
    }

    // Calculate remaining calories
    final suggestedCalories = profile.estimatedCaloriesBurntPerDay ?? 0;
    final remainingCalories = suggestedCalories - totalCalories.toInt();
    final remainingColor = remainingCalories >= 0 ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (suggestedCalories > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: remainingColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: remainingColor, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          remainingCalories >= 0 ? Icons.check_circle : Icons.warning,
                          size: 16,
                          color: remainingColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${remainingCalories.abs()} kcal ${remainingCalories >= 0 ? 'left' : 'over'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: remainingColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Calorie Progress Bar
            if (suggestedCalories > 0) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Calorie Goal',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        '${totalCalories.toInt()} / $suggestedCalories kcal',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: remainingColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (totalCalories / suggestedCalories).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(remainingColor),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutritionSummaryItem(
                  'Calories',
                  totalCalories.toStringAsFixed(0),
                  'kcal',
                  Colors.orange,
                ),
                _buildNutritionSummaryItem(
                  'Protein',
                  totalProtein.toStringAsFixed(1),
                  'g',
                  Colors.blue,
                ),
                _buildNutritionSummaryItem(
                  'Carbs',
                  totalCarbs.toStringAsFixed(1),
                  'g',
                  Colors.purple,
                ),
                _buildNutritionSummaryItem(
                  'Fat',
                  totalFat.toStringAsFixed(1),
                  'g',
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSummaryItem(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMealsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No meals yet.\nStart tracking your nutrition!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList(List<Meal> meals) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return RepaintBoundary(
          child: MealCard(
            meal: meal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealDetailScreen(
                    mealId: meal.id,
                    meal: meal, // Pass the meal object to reuse cached data
                  ),
                ),
              );
            },
            onEdit: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealEditScreen(meal: meal),
                ),
              );

              // If edit was successful, refresh the meal lists
              if (result == true) {
                ref.invalidate(mealsListProvider);
                ref.invalidate(todayMealsProvider);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({String? message}) {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  message ?? 'No meals yet.\nStart tracking your nutrition!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading meals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(mealsListProvider.notifier).refresh();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
