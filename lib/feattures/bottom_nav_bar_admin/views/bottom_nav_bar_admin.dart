import 'package:flutter/material.dart';
import 'dayscreen_tab_bar/views/dayscreen_tab_bar.dart';
import 'employee_tab_bar/views/employee_tab_bar.dart';
import 'monthscreen_tab_bar/views/monthscreen_tab_bar.dart';
import 'options_tab_bar/views/options_tab_bar.dart';
import '../../../data/statelessdata/Admin/bottom_nav_bar/bottomnav.dart';

class BottomNavBarAdmin extends StatefulWidget {
  const BottomNavBarAdmin({super.key});

  @override
  State<BottomNavBarAdmin> createState() => _BottomNavBarAdminState();
}

class _BottomNavBarAdminState extends State<BottomNavBarAdmin> {
  int _currentIndex = 0;

  // Style riêng cho chữ label của BottomNavigationBar
  final TextStyle _labelTextStyle = const TextStyle(
    fontFamily: 'HP001_4_hang_bold',
    fontSize: 14,
    color: Colors.red, // Có thể chỉnh màu nếu muốn
  );

  final List<Widget> _pages = const [
    DayScreenTabBar(),
    EmployeeTabBar(),
    MonthScreenTabBar(),
    OptionsTabBar(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Đổi màu nền navbar thành trắng
        selectedItemColor: Colors.blue, // Màu icon/label khi được chọn
        unselectedItemColor: Colors.grey, // Màu icon/label khi không chọn
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedLabelStyle: _labelTextStyle,
        unselectedLabelStyle: _labelTextStyle,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: BottomnavData.day,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: BottomnavData.employee,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: BottomnavData.month,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: BottomnavData.options,
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
