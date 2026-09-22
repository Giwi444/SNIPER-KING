import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sniper App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0C),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final String currentLogin = "8111175";

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(accountLogin: currentLogin),
      SettingsScreen(accountLogin: currentLogin),
      OrdersScreen(accountLogin: currentLogin),
      HistoryScreen(accountLogin: currentLogin),
      const AlertsScreen(),
    ];

    return Scaffold(
      // เอา SafeArea ออกจาก body เพื่อไม่ให้ดันเนื้อหาผิดเพี้ยน แล้วให้ Scaffold จัดการแทน
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF101014),
            selectedItemColor: const Color(0xFFFFB300),
            unselectedItemColor: Colors.grey.shade600,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Settings'),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_active), label: 'Alerts'),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String accountLogin;
  const HomeScreen({super.key, required this.accountLogin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.home_filled, size: 64, color: Color(0xFFFFB300)),
          const SizedBox(height: 16),
          const Text('หน้าหลัก (Home)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Account Login: $accountLogin', style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final String accountLogin;
  const SettingsScreen({super.key, required this.accountLogin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.tune, size: 64, color: Color(0xFFFFB300)),
          const SizedBox(height: 16),
          const Text('ตั้งค่า (Settings)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Account Login: $accountLogin', style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}

class OrdersScreen extends StatelessWidget {
  final String accountLogin;
  const OrdersScreen({super.key, required this.accountLogin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list_alt, size: 64, color: Color(0xFFFFB300)),
          const SizedBox(height: 16),
          const Text('รายการคำสั่งซื้อ (Orders)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Account Login: $accountLogin', style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final String accountLogin;
  const HistoryScreen({super.key, required this.accountLogin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 64, color: Color(0xFFFFB300)),
          const SizedBox(height: 16),
          const Text('ประวัติ (History)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Account Login: $accountLogin', style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_active, size: 64, color: Color(0xFFFFB300)),
          SizedBox(height: 16),
          Text('การแจ้งเตือน (Alerts)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
