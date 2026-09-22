import 'package:flutter/material.dart';

void main() {
  runApp(const SniperKingApp());
}

class SniperKingApp extends StatelessWidget {
  const SniperKingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNIPER KING Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1416),
        cardColor: const Color(0xFF181F22),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFFFF5252),
          surface: Color(0xFF181F22),
        ),
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

  final List<Widget> _pages = [
    const DashboardTab(),
    const SettingsTab(),
    const LogsTab(),
    const AlertsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF12181B),
        selectedItemColor: const Color(0xFF00E676),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.tune_rounded), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'Logs'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none_rounded), label: 'Alerts'),
        ],
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool isTradingPaused = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart, color: Color(0xFF00E676)),
                SizedBox(width: 8),
                Text('SNIPER KING', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00E676)),
              ),
              child: const Row(
                children: [
                  CircleAvatar(radius: 4, backgroundColor: Color(0xFF00E676)),
                  SizedBox(width: 6),
                  Text('CONNECTED', style: TextStyle(color: Color(0xFF00E676), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: 'RECOVERY',
          icon: Icons.history,
          child: Row(
            children: [
              Expanded(child: _buildValueBox('BUY', '0 / 2', Colors.green, Icons.arrow_upward)),
              const SizedBox(width: 12),
              Expanded(child: _buildValueBox('SELL', '0 / 2', Colors.red, Icons.arrow_downward)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: 'LAST SIGNAL',
          icon: Icons.track_changes,
          child: const Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF233038),
                child: Icon(Icons.blur_on, color: Colors.blueAccent),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NONE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Waiting for SNIPER KING signal...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildCard(
          title: 'BOT CONTROL',
          icon: Icons.smart_toy_outlined,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trading Pause', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('EA สามารถทำงานตามระบบได้', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  Switch(
                    value: isTradingPaused,
                    onChanged: (val) => setState(() => isTradingPaused = val),
                    activeColor: const Color(0xFF00E676),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow, color: Colors.black),
                      label: const Text('START', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676), padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.stop, color: Colors.white),
                      label: const Text('STOP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5252), padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF181F22), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orangeAccent, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildValueBox(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF101416), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 14),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  bool enableDailyTarget = true;
  bool enableDailyLoss = true;
  bool showArrows = true;
  bool mobilePush = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SNIPER KING Settings'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.save, color: Color(0xFF00E676))),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('SIGNAL', 'SNIPER KING signal detection'),
          _buildInputTile('Swing Bars', 'จำนวนแท่งย้อนหลังสำหรับหา Swing High / Swing Low', '15'),
          const SizedBox(height: 16),
          _buildSectionHeader('RISK / SL / TP', 'Stop Loss และ Take Profit'),
          _buildInputTile('Stop Loss', 'SL Points', '5000'),
          _buildInputTile('Take Profit', 'TP Points', '5000'),
          const SizedBox(height: 16),
          _buildSectionHeader('LOT / RECOVERY', 'ระบบเพิ่ม Lot หลังโดน Stop Loss'),
          _buildDropdownTile('Lot Mode', 'รูปแบบการคำนวณ Lot', 'Step'),
          _buildInputTile('Initial Lot', 'Lot เริ่มต้น', '0.01'),
          _buildInputTile('Recovery Multiplier', 'ตัวคูณ Lot Recovery', '2.00'),
          _buildInputTile('Max Lot', 'Lot สูงสุดที่ EA อนุญาต', '0.05'),
          _buildInputTile('Max Recovery Orders', 'จำนวน Recovery สูงสุดต่อฝั่ง', '2'),
          const SizedBox(height: 16),
          _buildSectionHeader('DAILY CONTROL', 'หยุดการเทรดเมื่อถึงกำไร/ขาดทุนประจำวัน'),
          _buildSwitchTile('Enable Daily Target', 'หยุดเมื่อกำไรถึง 500.00', enableDailyTarget, (v) => setState(() => enableDailyTarget = v)),
          _buildSwitchTile('Enable Daily Loss', 'หยุดเมื่อขาดทุนถึง 500.00', enableDailyLoss, (v) => setState(() => enableDailyLoss = v)),
          _buildInputTile('Daily Loss', 'ขาดทุนสูงสุดต่อวัน', '500.00'),
          const SizedBox(height: 16),
          _buildSectionHeader('NOTIFICATIONS', 'การแจ้งเตือนและกราฟ'),
          _buildSwitchTile('Show Arrows', 'แสดงลูกศร Buy / Sell บนกราฟ MT5', showArrows, (v) => setState(() => showArrows = v)),
          _buildSwitchTile('Mobile Push', 'ส่งสัญญาณเข้าโทรศัพท์', mobilePush, (v) => setState(() => mobilePush = v)),
          _buildInputTile('Telegram Poll Seconds', 'ความถี่ในการตรวจคำสั่ง Telegram', '2'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save, color: Colors.black),
            label: const Text('SAVE SNIPER KING SETTINGS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildInputTile(String title, String subtitle, String val) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF181F22), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Chip(
            label: Text(val, style: const TextStyle(color: Color(0xFF00E676))),
            backgroundColor: const Color(0xFF101416),
            avatar: const Icon(Icons.edit, size: 12, color: Color(0xFF00E676)),
          )
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool val, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFF181F22), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          Switch(value: val, onChanged: onChanged, activeColor: const Color(0xFF00E676)),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF181F22), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class LogsTab extends StatelessWidget {
  const LogsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Logs'), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLogItem(Icons.check_circle, Colors.green, 'SNIPER KING parameters updated', '7:24 AM'),
          _buildLogItem(Icons.check_circle, Colors.green, 'SNIPER KING BOT STARTED', '7:24 AM'),
          _buildLogItem(Icons.warning_amber_rounded, Colors.orange, 'Trading PAUSED', '7:24 AM'),
          _buildLogItem(Icons.check_circle, Colors.green, 'SNIPER KING initialized', '18:02:15'),
          _buildLogItem(Icons.check_circle, Colors.green, 'Connected to MT5 Server', '18:00:00'),
          _buildLogItem(Icons.info, Colors.blue, 'EA Magic: 20260915', '17:58:30'),
        ],
      ),
    );
  }

  Widget _buildLogItem(IconData icon, Color color, String message, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF181F22), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: const TextStyle(fontSize: 14)),
                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAlertItem('SNIPER KING', 'Waiting for signal...', 'Now'),
          _buildAlertItem('Connection Stable', 'MT5 connection is active', '1 min ago'),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String subtitle, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF181F22), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.orangeAccent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }
}
