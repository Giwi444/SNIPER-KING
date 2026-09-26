import 'package:flutter/material.dart';

void main() {
  runApp(const BlackNovaApp());
}

class BlackNovaApp extends StatelessWidget {
  const BlackNovaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 2; // เริ่มต้นที่หน้า HOME (ตรงกลาง)

  // รายการหน้าจอทั้งหมดครบถ้วนทุกเมนู
  final List<Widget> _screens = [
    const SmartScreen(),
    const MetatraderScreen(),
    const HomeScreen(),
    const ScannerScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'SMART'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'METATRADER'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.graphic_eq), label: 'SCANNER'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'SETTINGS'),
        ],
      ),
    );
  }
}

// 1. หน้า HOME (ตามโครงสร้างรูปภาพของคุณ)
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Create your own Forex\nMobile Robot Today',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 260,
                width: double.infinity,
                child: Image.network(
                  'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1000&auto=format&fit=crop',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your Trading With',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'BLACK NOVA\nSCAPER',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Powered By Algohost',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Link in bio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(Icons.delete_outline, 'DELETE'),
                    _buildActionButton(Icons.play_arrow, 'START'),
                    _buildActionButton(Icons.show_chart, 'SYMBOLS'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Connected Robots:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// 2. หน้า SMART (จัดการระบบสมองกลและเงื่อนไขอัตโนมัติ)
class SmartScreen extends StatelessWidget {
  const SmartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Smart Robot Control', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.bolt, color: Colors.redAccent),
            title: Text('AI Auto-Trading Mode'),
            subtitle: Text('เปิดใช้งานระบบวิเคราะห์กราฟอัตโนมัติ'),
            trailing: Switch(value: true, onChanged: null),
          ),
          Divider(color: Colors.grey),
          ListTile(
            leading: Icon(Icons.security, color: Colors.redAccent),
            title: Text('Risk Management (Stop Loss)'),
            subtitle: Text('ตั้งค่าจำกัดความเสี่ยงอัตโนมัติ 2% ต่อไม้'),
          ),
          Divider(color: Colors.grey),
          ListTile(
            leading: Icon(Icons.speed, color: Colors.redAccent),
            title: Text('Execution Speed'),
            subtitle: Text('Ultra-Fast (Low Latency Server)'),
          ),
        ],
      ),
    );
  }
}

// 3. หน้า METATRADER (เชื่อมต่อพอร์ตและบัญชีเทรด)
class MetatraderScreen extends StatelessWidget {
  const MetatraderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('MetaTrader Accounts', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: Colors.grey[900],
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Colors.red),
                title: const Text('MT5 Live Account #892311'),
                subtitle: const Text('Server: Exness-Real\nBalance: \$891.82'),
                isThreeLine: true,
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add MT4 / MT5 Account'),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. หน้า SCANNER (สแกนหาคู่เงินและโอกาสทำกำไร)
class ScannerScreen extends StatelessWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Market Scanner', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text('EURUSD (M15)'),
            subtitle: Text('Signal: Strong Buy (Bullish Engulfing)'),
            trailing: Text('+45 pips', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
          Divider(color: Colors.grey),
          ListTile(
            title: Text('XAUUSD (H1)'),
            subtitle: Text('Signal: Breakout Resistance'),
            trailing: Text('+120 pips', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
          Divider(color: Colors.grey),
          ListTile(
            title: Text('GBPUSD (M5)'),
            subtitle: Text('Signal: Waiting for Setup'),
            trailing: Text('Scanning...', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }
}

// 5. หน้า SETTINGS (ตั้งค่าระบบและบัญชีผู้ใช้งาน)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('App Settings', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.person, color: Colors.white70),
            title: Text('Account Profile'),
            subtitle: Text('blacknova_user@algohost.com'),
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.white70),
            title: Text('Push Notifications'),
            subtitle: Text('แจ้งเตือนสถานะคำสั่งซื้อขาย'),
            trailing: Switch(value: true, onChanged: null),
          ),
          ListTile(
            leading: Icon(Icons.language, color: Colors.white70),
            title: Text('Language'),
            subtitle: Text('English / Thai'),
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.white70),
            title: Text('About Algohost'),
            subtitle: Text('Version 2.4.0 (Stable)'),
          ),
        ],
      ),
    );
  }
}
