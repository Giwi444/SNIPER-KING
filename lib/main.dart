import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class RobotBackground extends StatelessWidget {
  final Widget child;
  const RobotBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/1000056738_2.jpg', // เปลี่ยนเป็นชื่อไฟล์รูปของคุณ
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: const Color(0xFF0B0B0E));
          },
        ),
        Container(
          color: Colors.black.withOpacity(0.35),
        ),
        child,
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String accountLogin;
  final VoidCallback onLogout;
  const HomeScreen({super.key, required this.accountLogin, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isRunning = false;
  bool isConnected = false; 
  double balance = 0.0;
  double equity = 0.0;
  double margin = 0.0;
  double freeMargin = 0.0;
  double profitLoss = 0.0;
  String broker = "";
  String server = "";
  int loginAccount = 0;
  int _currentIndex = 2; // หน้า Home อยู่ตรงกลาง (index 2)

  DatabaseReference? _dbRef;

  @override
  void initState() {
    super.initState();
    _initFirebaseAndListen(widget.accountLogin);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountLogin != widget.accountLogin) {
      _initFirebaseAndListen(widget.accountLogin);
    }
  }

  void _initFirebaseAndListen(String login) {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      _dbRef = database.ref('status');

      database.ref('.info/connected').onValue.listen((event) {
        final connected = event.snapshot.value as bool? ?? false;
        if (mounted) {
          setState(() {
            isConnected = connected;
          });
        }
      });

      _dbRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null && mounted) {
          setState(() {
            balance = (data['balance'] ?? 0.0).toDouble();
            equity = (data['equity'] ?? 0.0).toDouble();
            margin = (data['margin'] ?? 0.0).toDouble();
            freeMargin = (data['free_margin'] ?? 0.0).toDouble();
            profitLoss = (data['profit'] ?? 0.0).toDouble();
            isRunning = data['is_running'] ?? false;
            broker = data['broker']?.toString() ?? '';
            server = data['server']?.toString() ?? '';
            loginAccount = int.tryParse(data['login']?.toString() ?? login) ?? 0;
          });
        }
      });
    } catch (e) {
      print("Database listen error: $e");
    }
  }

  void _toggleBotStatus(bool status) {
    try {
      _dbRef?.update({'is_running': status});
    } catch (e) {
      print("Toggle bot error: $e");
    }
  }

  void _closeAllOrders() {
    try {
      _dbRef?.update({
        'close_all': true,
        'command_timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sent Close All Command to EA!'), backgroundColor: Color(0xFFD50000)),
      );
    } catch (e) {
      print("Close all error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isProfit = profitLoss >= 0;

    return Scaffold(
      body: RobotBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                // 1. แถบ Connect และปุ่ม Logout ด้านบน
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isConnected ? const Color(0xFF00C853) : const Color(0xFFD50000),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isConnected ? const Color(0xFF00C853) : const Color(0xFFD50000),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isConnected ? 'Connect' : 'No Connection',
                            style: TextStyle(
                              color: isConnected ? const Color(0xFF00C853) : const Color(0xFFD50000),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.lock_outline, color: Color(0xFFD50000), size: 22),
                      onPressed: widget.onLogout,
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // 2. หัวข้อ "Create your own Forex Mobile Robot Today"
                const Text(
                  'Create your own Forex\nMobile Robot Today',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 15),

                // 3. ชื่อแอป (Your Trading With / BLACK NOVA SCAPER)
                const Text(
                  'Your Trading With',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'BLACK NOVA\nSCAPER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    height: 1.1,
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 2)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD50000).withOpacity(0.5), width: 1),
                  ),
                  child: const Text(
                    'Powered By Algohost',
                    style: TextStyle(
                      color: Color(0xFFD50000),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // 4. แผงควบคุมแคปซูลทรงรี (DELETE, START, SYMBOLS)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _closeAllOrders,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD50000),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text('DELETE', style: TextStyle(color: Colors.black87, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _toggleBotStatus(true),
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                color: isRunning ? const Color(0xFF00C853) : const Color(0xFFD50000),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow, color: Colors.white, size: 26),
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text('START', style: TextStyle(color: Colors.black87, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD50000),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.show_chart, color: Colors.white, size: 22),
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text('SYMBOLS', style: TextStyle(color: Colors.black87, fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 5. ข้อความ Link in bio
                const Text(
                  'Link in bio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 8),

                // 6. Connected Robots:
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Connected Robots:',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 7. กล่อง Floating Profit / Loss
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isProfit
                          ? [const Color(0xFF00C853).withOpacity(0.35), const Color(0xFF161619).withOpacity(0.9)]
                          : [const Color(0xFFB71C1C).withOpacity(0.65), const Color(0xFF161619).withOpacity(0.9)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isProfit ? const Color(0xFF00C853).withOpacity(0.8) : const Color(0xFFD50000).withOpacity(0.8),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'FLOATING PROFIT / LOSS',
                        style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '\$${profitLoss.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isProfit ? const Color(0xFF00C853) : const Color(0xFFFF5252),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 8. กล่อง Account Overview (4 ช่อง Balance, Equity, Margin, Free Margin)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161619).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white12, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.account_balance, color: Color(0xFFD50000), size: 15),
                          SizedBox(width: 6),
                          Text(
                            'ACCOUNT OVERVIEW',
                            style: TextStyle(
                              color: Color(0xFFD50000),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard('Balance', '\$${balance.toStringAsFixed(2)}', Icons.account_balance_wallet, const Color(0xFF00695C).withOpacity(0.45))),
                          const SizedBox(width: 8),
                          Expanded(child: _buildMetricCard('Equity', '\$${equity.toStringAsFixed(2)}', Icons.show_chart, const Color(0xFF0D47A1).withOpacity(0.45))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard('Margin', '\$${margin.toStringAsFixed(2)}', Icons.lock_outline, const Color(0xFFE65100).withOpacity(0.45))),
                          const SizedBox(width: 8),
                          Expanded(child: _buildMetricCard('Free Margin', '\$${freeMargin.toStringAsFixed(2)}', Icons.lock_open, const Color(0xFF4A148C).withOpacity(0.45))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      // 9. แถบเมนูด้านล่างสุดโทนสีแดงเข้ม
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF8B0000),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 15,
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
          backgroundColor: const Color(0xFF8B0000),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.bolt, size: 20), label: 'SMART'),
            const BottomNavigationBarItem(icon: Icon(Icons.show_chart, size: 20), label: 'METATRADER'),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home_filled, color: Color(0xFFD50000), size: 20),
              ),
              label: 'HOME',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.graphic_eq, size: 20), label: 'SCANNER'),
            const BottomNavigationBarItem(icon: Icon(Icons.settings, size: 20), label: 'SETTINGS'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.redAccent, size: 13),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
