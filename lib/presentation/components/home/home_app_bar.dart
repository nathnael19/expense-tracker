import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../blocs/stats_cubit.dart';
import '../common/streak_indicator.dart';
import '../../screens/debt_screen.dart';
import '../../screens/shopping_lists_screen.dart';
import '../../screens/monthly_report_screen.dart';
import '../../screens/settings_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Dashboard',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const Gap(8),
              BlocSelector<StatsCubit, StatsState, int>(
                selector: (state) => state.streak,
                builder: (context, streak) => StreakIndicator(streak: streak),
              ),
            ],
          ),
          Text(
            DateFormat.yMMMMd().format(DateTime.now()),
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.handshake_outlined,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const DebtScreen()));
          },
        ),
        IconButton(
          icon: Icon(
            Icons.shopping_cart_outlined,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const ShoppingListsScreen()));
          },
        ),
        IconButton(
          icon: Icon(
            Icons.bar_chart,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const MonthlyReportScreen()));
          },
        ),
        IconButton(
          icon: Icon(
            Icons.settings,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const SettingsScreen()));
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
