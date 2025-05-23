import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../feattures/admin/bottom_nav_bar_admin/views/dayscreen_tab_bar/views/Notification/notificationstagsa.dart';
import '../../../../../../feattures/admin/bottom_nav_bar_admin/views/dayscreen_tab_bar/views/Notification/notificationscreena.dart';
import 'package:salary_count_project/url.dart'; // 🔧 Đã thêm
import '../../../../../../Extend/common/widgets/Appbar/appbar.dart'; // <-- already present
import '../../../../../../data/statelessdata/Admin/appbar/appbar.dart';
import '../../../../../../data/statelessdata/Admin/dayscreen/dayscreen_data.dart'; // <-- fixed import path

class DayScreenTabBar extends StatefulWidget {
  const DayScreenTabBar({super.key});

  @override
  State<DayScreenTabBar> createState() => _DayScreenTabBarState();
}

class _DayScreenTabBarState extends State<DayScreenTabBar> {
  DateTime selectedDate = DateTime.now();
  List employees = [];
  Map employeeStatuses = {};
  bool isLoading = false;
  final GlobalKey<NotificationScreenAState> notificationScreenAKey =
      GlobalKey<NotificationScreenAState>();

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString('admin_id') ?? '';
      final url = '$baseUrl/dayscreen?admin_id=$adminId'; // ✅ Đã sửa

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          employees = data;
        });
        updateEmployeeStatuses(selectedDate);
      }
    } catch (e) {
      // TODO: xử lý lỗi nếu cần
    }
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  void updateEmployeeStatuses(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final statuses = <String, dynamic>{};
    for (final employee in employees) {
      final attendance = (employee['attendance'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere(
            (item) => item['date'] == formattedDate,
            orElse: () => {},
          );
      if (attendance.isNotEmpty) {
        statuses[employee['id'].toString()] = {
          'status': attendance['status'],
          'icon': getIconBasedOnStatus(attendance['status']),
          'color': attendance['color'] ?? Colors.grey,
        };
      } else {
        statuses[employee['id'].toString()] = {
          'status': DayScreenData.offlineStatus,
          'icon': Icons.cloud_off,
          'color': Colors.grey,
        };
      }
    }
    if (!mounted) return;
    setState(() {
      employeeStatuses = statuses;
    });
  }

  IconData getIconBasedOnStatus(String? status) {
    switch (status) {
      case 'Đủ':
        return Icons.check_circle;
      case 'Vắng':
        return Icons.cancel;
      case 'Nửa':
        return Icons.access_time;
      default:
        return Icons.cloud_off;
    }
  }

  void handlePrevDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
      updateEmployeeStatuses(selectedDate);
    });
  }

  void handleNextDay() {
    setState(() {
      selectedDate = selectedDate.add(const Duration(days: 1));
      updateEmployeeStatuses(selectedDate);
    });
  }

  Future<void> showDatePickerDialog() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        updateEmployeeStatuses(selectedDate);
      });
    }
  }

  int countEmployeesWithStatus() {
    return employeeStatuses.values
        .where((status) => status['status'] == 'Đủ')
        .length;
  }

  // Add this helper function to convert color names or hex strings to Color
  Color parseColor(dynamic colorValue) {
    if (colorValue is Color) return colorValue;
    if (colorValue is String) {
      // Handle hex color string
      if (colorValue.startsWith('#')) {
        return Color(int.parse(colorValue.replaceFirst('#', '0xff')));
      }
      // Handle some common color names
      switch (colorValue.toLowerCase()) {
        case 'red':
          return Colors.red;
        case 'green':
          return Colors.green;
        case 'blue':
          return Colors.blue;
        case 'yellow':
          return Colors.yellow;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        case 'grey':
        case 'gray':
          return Colors.grey;
        case 'black':
          return Colors.black;
        case 'white':
          return Colors.white;
        default:
          return Colors.grey;
      }
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: AppbarData.dayscreenTitle,
        backgroundColor: const Color(0xFF5e749e),
        titleColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              NotificationScreenA(
                key: notificationScreenAKey,
                onTapNotification: (allNotifications) async {
                  // Khi mở NotificationTagsA, truyền callback để khi thao tác xong sẽ gọi cập nhật lại notification
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => NotificationsTagsA(
                            notifications: allNotifications,
                            onRefreshNotifications: () {
                              notificationScreenAKey.currentState
                                  ?.refreshNotifications();
                            },
                          ),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF5e749e),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: handlePrevDay,
                      child: const Text(
                        '<',
                        style: TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontFamily: 'HP001_4_hang_bold',
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: showDatePickerDialog,
                      child: Text(
                        DateFormat(
                          DayScreenData.dateFormat,
                        ).format(selectedDate),
                        style: const TextStyle(
                          fontFamily: 'HP001',
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: handleNextDay,
                      child: const Text(
                        '>',
                        style: TextStyle(fontSize: 36, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  Text(
                    DayScreenData.totalEmployeesText,
                    style: const TextStyle(fontFamily: 'HP001', fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${countEmployeesWithStatus()}',
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5e749e),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : employees.isEmpty
                        ? Center(
                          child: Text(
                            DayScreenData.noEmployeesText,
                            style: const TextStyle(
                              fontFamily: 'HP001',
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        )
                        : ListView.builder(
                          itemCount: employees.length,
                          itemBuilder: (context, index) {
                            final employee = employees[index];
                            final status =
                                employeeStatuses[employee['id'].toString()];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2, // Tăng flex cho phần tên
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: Text(
                                        employee['name'] ?? '',
                                        style: const TextStyle(
                                          fontFamily: 'HP001',
                                          fontSize: 19,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1, // Giảm flex cho phần status
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          status?['status'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ).copyWith(
                                            color: parseColor(status?['color']),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          status?['icon'] ?? Icons.cloud_off,
                                          size: 20,
                                          color: parseColor(status?['color']),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
