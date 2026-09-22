import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBnKyMazopUyD1k-kcIXo3bFedWfHXN0JA",
        appId: "1:155532929563:android:49d8a1e0040dc87ce766be",
        messagingSenderId: "155532929563",
        projectId: "liquidity-b8739",
        storageBucket: "liquidity-b8739.firebasestorage.app",
        databaseURL: "https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app",
      ),
    );
  } catch (e) {
    print("Firebase init error: $e");
  }

  runApp(const LiquiditySweepApp());
}

class LiquiditySweepApp extends StatelessWidget {
  const LiquiditySweepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sniper King',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B0E),
        cardColor: const Color(0xFF161619),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00C853),
          secondary: Color(0xFFFFB300),
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
  String currentLogin = "8111175";
  int unreadAlertsCount = 0;
  DatabaseReference? _alertsRef;

  @override
  void initState() {
    super.initState();
    _listenToActiveAccount();
    _listenToAlertsCount();
  }

  void _listenToActiveAccount() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      database.ref('status/login').onValue.listen((event) {
        final val = event.snapshot.value?.toString();
        if (val != null && val.isNotEmpty && mounted) {
          setState(() {
            currentLogin = val;
          });
        }
      });
    } catch (e) {
      print("Account listen error: $e");
    }
  }

  void _listenToAlertsCount() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      _alertsRef = database.ref('alerts');
      _alertsRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (data != null && mounted) {
          int total = 0;
          if (data is Map) {
            total = data.length;
          } else if (data is List) {
            total = data.where((e) => e != null).length;
          }
          setState(() {
            if (_currentIndex != 5) { // ปรับ index เป็น 5 เนื่องจากเพิ่มหน้า Trade เข้ามา
              unreadAlertsCount = total;
            }
          });
        } else if (data == null && mounted) {
          setState(() {
            unreadAlertsCount = 0;
          });
        }
      });
    } catch (e) {
      print("Alerts count error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(accountLogin: currentLogin),
      const TradeChartScreen(), // <--- หน้าเทรดใหม่ที่เพิ่มเข้ามาตามรีเควส
      const SettingsScreen(),
      OrdersScreen(accountLogin: currentLogin),
      HistoryScreen(accountLogin: currentLogin),
      AlertsScreen(onAlertsRead: () {
        setState(() {
          unreadAlertsCount = 0;
        });
      }),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: Container(
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
              if (index == 5) {
                unreadAlertsCount = 0;
              }
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF101014),
          selectedItemColor: const Color(0xFFFFB300),
          unselectedItemColor: Colors.grey.shade600,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.candlestick_chart), label: 'Trade'), // <--- ปุ่มเมนู Trade
            const BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Settings'),
            const BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
            const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_active),
                  if (unreadAlertsCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadAlertsCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Alerts',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// IRON MAN ROBOT LOGO WIDGET
// ==========================================
class IronManLogo extends StatelessWidget {
  final double size;
  const IronManLogo({super.key, this.size = 60.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFB71C1C), Color(0xFF161619)],
          radius: 0.8,
        ),
        border: Border.all(color: const Color(0xFFFFB300), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.65,
            height: size * 0.75,
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F),
              borderRadius: BorderRadius.circular(size * 0.2),
              border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
            ),
          ),
          Positioned(
            top: size * 0.18,
            child: Container(
              width: size * 0.35,
              height: size * 0.45,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300),
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            ),
          ),
          Positioned(
            top: size * 0.35,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size * 0.1,
                  height: size * 0.05,
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: const [BoxShadow(color: Colors.cyan, blurRadius: 6, spreadRadius: 1)],
                  ),
                ),
                SizedBox(width: size * 0.08),
                Container(
                  width: size * 0.1,
                  height: size * 0.05,
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: const [BoxShadow(color: Colors.cyan, blurRadius: 6, spreadRadius: 1)],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: size * 0.12,
            child: Container(
              width: size * 0.12,
              height: size * 0.12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyanAccent,
                boxShadow: const [BoxShadow(color: Colors.cyan, blurRadius: 8, spreadRadius: 2)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 1. HOME SCREEN
// ==========================================
class HomeScreen extends StatefulWidget {
  final String accountLogin;
  const HomeScreen({super.key, required this.accountLogin});

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
        const SnackBar(content: Text('Sent Close All Command to EA!'), backgroundColor: Color(0xFFFFB300)),
      );
    } catch (e) {
      print("Close all error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isProfit = profitLoss >= 0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1E24), Color(0xFF121215)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFFFB300).withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withOpacity(0.12),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: 0.12,
                        child: const IronManLogo(size: 130),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.circle, color: Color(0xFFFFB300), size: 10),
                          SizedBox(width: 8),
                          Text(
                            'SNIPER KING ROBOT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFB300),
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.workspace_premium, color: Color(0xFFFFB300), size: 18),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: (isConnected ? const Color(0xFF00C853) : Colors.red).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isConnected ? const Color(0xFF00C853) : Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isConnected ? Icons.bolt : Icons.wifi_off,
                                color: isConnected ? const Color(0xFF00C853) : Colors.red,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isConnected ? 'CONNECTED' : 'NO CONNECTED',
                                style: TextStyle(
                                  color: isConnected ? const Color(0xFF00C853) : Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        broker.isNotEmpty ? '$broker ($loginAccount) | $server' : 'Liquidity Sweep v.3 (${widget.accountLogin})',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isProfit
                      ? [const Color(0xFF00C853).withOpacity(0.15), const Color(0xFF161619)]
                      : [const Color(0xFFD50000).withOpacity(0.15), const Color(0xFF161619)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isProfit ? const Color(0xFF00C853).withOpacity(0.5) : const Color(0xFFD50000).withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'FLOATING PROFIT / LOSS',
                    style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${isProfit ? "+" : ""}\$${profitLoss.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isProfit ? const Color(0xFF00C853) : const Color(0xFFD50000),
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildMetricCard('Balance', '\$${balance.toStringAsFixed(2)}', Icons.account_balance_wallet)),
                const SizedBox(width: 10),
                Expanded(child: _buildMetricCard('Equity', '\$${equity.toStringAsFixed(2)}', Icons.show_chart)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Margin', '\$${margin.toStringAsFixed(2)}', Icons.lock_outline)),
                const SizedBox(width: 10),
                Expanded(child: _buildMetricCard('Free Margin', '\$${freeMargin.toStringAsFixed(2)}', Icons.lock_open)),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: const [
                Icon(Icons.smart_toy_outlined, color: Color(0xFFFFB300), size: 18),
                SizedBox(width: 6),
                Text(
                  'BOT & ORDER CONTROL',
                  style: TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161619),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12, width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('EA Execution Status', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isRunning ? const Color(0xFF00C853).withOpacity(0.15) : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isRunning ? 'RUNNING' : 'STOPPED',
                          style: TextStyle(
                            color: isRunning ? const Color(0xFF00C853) : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleBotStatus(true),
                          icon: const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text('START', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleBotStatus(false),
                          icon: const Icon(Icons.stop, color: Colors.white),
                          label: const Text('STOP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD50000),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _closeAllOrders,
                      icon: const Icon(Icons.delete_sweep, color: Colors.white),
                      label: const Text('CLOSE ALL ORDERS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB300),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161619),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 15),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. TRADE CHART & QUICK TRADE SCREEN (เพิ่มใหม่ตามภาพอ้างอิง)
// ==========================================
class TradeChartScreen extends StatefulWidget {
  const TradeChartScreen({super.key});

  @override
  State<TradeChartScreen> createState() => _TradeChartScreenState();
}

class _TradeChartScreenState extends State<TradeChartScreen> {
  String symbol = "XAUUSD";
  String selectedTimeframe = "1m";
  final List<String> timeframes = ["Tick", "1m", "15m", "1h", "1D"];
  
  double currentPrice = 4330.70;
  double changeAmount = -12.83;
  double changePercent = -0.30;
  double highPrice = 4376.03;
  double lowPrice = 4291.58;
  double openPrice = 4344.70;

  double lotSize = 0.01;
  DatabaseReference? _statusRef;
  DatabaseReference? _tradeRef;

  @override
  void initState() {
    super.initState();
    _initFirebaseConnection();
  }

  void _initFirebaseConnection() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      _statusRef = database.ref('status');
      _tradeRef = database.ref('trade_actions');

      _statusRef?.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            symbol = data['symbol']?.toString() ?? 'XAUUSD';
            selectedTimeframe = data['timeframe']?.toString() ?? '1m';
            currentPrice = (data['bid'] ?? data['price'] ?? 4330.70).toDouble();
            highPrice = (data['high'] ?? 4376.03).toDouble();
            lowPrice = (data['low'] ?? 4291.58).toDouble();
            openPrice = (data['open'] ?? 4344.70).toDouble();
            changePercent = (data['change_pct'] ?? -0.30).toDouble();
            changeAmount = (data['change_amt'] ?? -12.83).toDouble();
          });
        }
      });
    } catch (e) {
      print("Trade screen firebase error: $e");
    }
  }

  void _updateTimeframe(String tf) {
    setState(() {
      selectedTimeframe = tf;
    });
    try {
      _statusRef?.update({'timeframe': tf});
    } catch (e) {
      print("Update timeframe error: $e");
    }
  }

  void _executeManualTrade(String actionType) {
    try {
      _tradeRef?.push().set({
        'action': actionType, // 'BUY' หรือ 'SELL'
        'symbol': symbol,
        'lot': lotSize,
        'price': currentPrice,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$actionType Executed Successfully (Lot: $lotSize)!'),
          backgroundColor: actionType == 'BUY' ? const Color(0xFF00C853) : Colors.redAccent,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print("Execute manual trade error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNeg = changePercent < 0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
        backgroundColor: const Color(0xFF0B0B0E),
        actions: [
          IconButton(icon: const Icon(Icons.star_border, color: Colors.amber), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.open_in_new, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub Header: ราคาปัจจุบัน และ High/Low
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPrice.toStringAsFixed(2),
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${isNeg ? "" : "+"}$changeAmount (${isNeg ? "" : "+"}${changePercent.toStringAsFixed(2)}%)',
                      style: TextStyle(color: isNeg ? Colors.redAccent : const Color(0xFF00C853), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    const Text('09/22 12:00:11 GMT+3', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Text('เปิด  ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(openPrice.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text('สูง  ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(highPrice.toStringAsFixed(2), style: const TextStyle(color: const Color(0xFF00C853), fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text('ปิด  ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(currentPrice.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text('ต่ำ  ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        Text(lowPrice.toStringAsFixed(2), style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // แถบ Timeframe
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: timeframes.map((tf) {
                    bool isSelected = selectedTimeframe == tf;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () => _updateTimeframe(tf),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white24 : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tf,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Row(
                  children: const [
                    Icon(Icons.fullscreen, color: Colors.grey, size: 20),
                    SizedBox(width: 12),
                    Icon(Icons.bar_chart, color: Colors.grey, size: 20),
                    SizedBox(width: 12),
                    Icon(Icons.settings_outlined, color: Colors.grey, size: 20),
                  ],
                ),
              ],
            ),
          ),

          // พื้นที่จำลองกราฟ Candlestick ชาร์ต
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFF0B0B0E),
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Text(
                      '$symbol · 1 · Exchange',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  Positioned(
                    top: 36,
                    left: 16,
                    child: Text(
                      currentPrice.toStringAsFixed(2),
                      style: const TextStyle(color: const Color(0xFF00C853), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // เส้นกราฟจำลองแนวโน้มขาขึ้น (Candlestick UI Simulation)
                  Center(
                    child: CustomPaint(
                      size: const Size(double.infinity, 220),
                      painter: ChartPainter(),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 16,
                    child: const Text('15:40                  15:50                  16:00', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ),
                ],
              ),
            ),
          ),

          // แผงควบคุมการซื้อขายด่วน (Quick Trade Panel ด้านล่างสุด)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF161619),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              border: Border(top: BorderSide(color: Colors.white12, width: 1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Text('แตะครั้งเดียว', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Icon(Icons.arrow_drop_down, color: Colors.grey, size: 16),
                      ],
                    ),
                    Row(
                      children: const [
                        Text('ต่ำ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        SizedBox(width: 8),
                        Icon(Icons.swap_vert, color: Colors.grey, size: 16),
                        SizedBox(width: 8),
                        Text('สูง', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // กล่องปรับเพิ่ม/ลด Lot Size
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0B0E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white70, size: 18),
                        onPressed: () {
                          setState(() {
                            if (lotSize > 0.01) lotSize = double.parse((lotSize - 0.01).toStringAsFixed(2));
                          });
                        },
                      ),
                      Column(
                        children: [
                          const Text('ล็อต', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          Text(
                            lotSize.toStringAsFixed(2),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white70, size: 18),
                        onPressed: () {
                          setState(() {
                            lotSize = double.parse((lotSize + 0.01).toStringAsFixed(2));
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('ค่าต่ำสุด:0.01 ล็อต', style: TextStyle(color: Colors.grey, fontSize: 10)),
                ),
                const SizedBox(height: 10),

                // ปุ่ม SELL / BUY ขนาดใหญ่
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _executeManualTrade('SELL'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD50000),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Column(
                          children: [
                            const Text('ขาย', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              (currentPrice - 0.11).toStringAsFixed(2),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _executeManualTrade('BUY'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Column(
                          children: [
                            const Text('ซื้อ', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              (currentPrice + 0.11).toStringAsFixed(2),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// คลาสวาดเส้นกราฟแท่งเทียนจำลองในหน้า Trade
class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGreen = Paint()
      ..color = const Color(0xFF00C853)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintRed = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillGreen = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.fill;

    final fillRed = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    // ข้อมูลจำลองพิกัดแท่งเทียน
    final candles = [
      {'x': 30.0, 'open': 100.0, 'close': 80.0, 'high': 110.0, 'low': 70.0, 'isGreen': false},
      {'x': 60.0, 'open': 80.0, 'close': 95.0, 'high': 100.0, 'low': 75.0, 'isGreen': true},
      {'x': 90.0, 'open': 95.0, 'close': 90.0, 'high': 105.0, 'low': 85.0, 'isGreen': false},
      {'x': 120.0, 'open': 90.0, 'close': 110.0, 'high': 115.0, 'loc': 88.0, 'isGreen': true},
      {'x': 150.0, 'open': 110.0, 'close': 105.0, 'high': 120.0, 'low': 100.0, 'isGreen': false},
      {'x': 180.0, 'open': 105.0, 'close': 130.0, 'high': 135.0, 'low': 102.0, 'isGreen': true},
      {'x': 210.0, 'open': 130.0, 'close': 150.0, 'high': 155.0, 'low': 125.0, 'isGreen': true},
      {'x': 240.0, 'open': 150.0, 'close': 140.0, 'high': 160.0, 'low': 135.0, 'isGreen': false},
      {'x': 270.0, 'open': 140.0, 'close': 165.0, 'high': 170.0, 'low': 138.0, 'isGreen': true},
    ];

    for (var c in candles) {
      double x = c['x'] as double;
      double open = c['open'] as double;
      double close = c['close'] as double;
      double high = c['high'] as double;
      double low = c['low'] as double;
      bool isGreen = c['isGreen'] as bool;

      Paint paint = isGreen ? paintGreen : paintRed;
      Paint fill = isGreen ? fillGreen : fillRed;

      // วาดไส้เทียน
      canvas.drawLine(Offset(x, size.height - high), Offset(x, size.height - low), paint);

      // วาดตัวแท่งเทียน
      double top = size.height - (open > close ? open : close);
      double height = (open - close).abs();
      if (height < 2) height = 2;

      canvas.drawRect(Rect.fromLTWH(x - 4, top, 8, height), fill);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==========================================
// 2. SETTINGS SCREEN
// ==========================================
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String lotMode = 'Double';
  final TextEditingController initialLotController = TextEditingController();
  final TextEditingController maxRecoveryController = TextEditingController();
  final TextEditingController swingBarsController = TextEditingController();
  final TextEditingController slPointsController = TextEditingController();
  final TextEditingController riskRewardController = TextEditingController();

  bool enableDailyTarget = true;
  final TextEditingController dailyTargetController = TextEditingController();
  
  bool enableDailyLoss = false;
  final TextEditingController dailyLossController = TextEditingController();

  DatabaseReference? _settingsRef;

  @override
  void initState() {
    super.initState();
    _loadSettingsFromFirebase();
  }

  void _loadSettingsFromFirebase() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      _settingsRef = database.ref('status');

      _settingsRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            lotMode = data['lot_mode']?.toString() ?? 'Double';
            initialLotController.text = data['initial_lot']?.toString() ?? '0.01';
            maxRecoveryController.text = data['max_recovery']?.toString() ?? '10';
            swingBarsController.text = data['swing_bars']?.toString() ?? '30';
            slPointsController.text = data['sl_points']?.toString() ?? '500';
            riskRewardController.text = data['risk_reward']?.toString() ?? '2.0';

            enableDailyTarget = data['enable_daily_target'] ?? true;
            dailyTargetController.text = data['daily_target']?.toString() ?? '100.0';

            enableDailyLoss = data['enable_daily_loss'] ?? false;
            dailyLossController.text = data['daily_loss']?.toString() ?? '50.0';
          });
        }
      });
    } catch (e) {
      print("Load settings error: $e");
    }
  }

  void _saveSettingsToFirebase() {
    try {
      _settingsRef?.update({
        'lot_mode': lotMode,
        'initial_lot': double.tryParse(initialLotController.text) ?? 0.01,
        'max_recovery': int.tryParse(maxRecoveryController.text) ?? 10,
        'swing_bars': int.tryParse(swingBarsController.text) ?? 30,
        'sl_points': double.tryParse(slPointsController.text) ?? 500.0,
        'risk_reward': double.tryParse(riskRewardController.text) ?? 2.0,
        'enable_daily_target': enableDailyTarget,
        'daily_target': double.tryParse(dailyTargetController.text) ?? 100.0,
        'enable_daily_loss': enableDailyLoss,
        'daily_loss': double.tryParse(dailyLossController.text) ?? 50.0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parameters Synced & Saved to EA Successfully!'),
          backgroundColor: Color(0xFFFFB300),
        ),
      );
    } catch (e) {
      print("Save settings error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double sl = double.tryParse(slPointsController.text) ?? 500;
    double rr = double.tryParse(riskRewardController.text) ?? 2.0;
    double calculatedTP = sl * rr;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EA Parameters Settings'),
        backgroundColor: const Color(0xFF0B0B0E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LIQUIDITY SWEEP PARAMETERS',
              style: TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161619),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lot Mode', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B0B0E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: lotMode,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF161619),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        items: ['Fixed', 'Step', 'Double'].map((String item) {
                          return DropdownMenuItem<String>(value: item, child: Text(item));
                        }).toList(),
                        onChanged: (val) => setState(() => lotMode = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: _buildControllerInputField('Initial Lot', initialLotController, TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildControllerInputField('Max Recovery', maxRecoveryController, TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: _buildControllerInputField('Swing Bars', swingBarsController, TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildControllerInputField('SL Points', slPointsController, TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: _buildControllerInputField('Risk Reward', riskRewardController, TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B0B0E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Calculated TP', style: TextStyle(color: Colors.grey, fontSize: 10)),
                              const SizedBox(height: 2),
                              Text(
                                '${calculatedTP.toStringAsFixed(1)} Points',
                                style: const TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Enable Daily Target', style: TextStyle(color: Colors.white, fontSize: 13)),
                      Switch(
                        value: enableDailyTarget,
                        activeColor: const Color(0xFF00C853),
                        onChanged: (val) => setState(() => enableDailyTarget = val),
                      ),
                    ],
                  ),
                  if (enableDailyTarget) ...[
                    const SizedBox(height: 6),
                    _buildControllerInputField('Daily Target (\$)', dailyTargetController, TextInputType.number),
                  ],
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Enable Daily Loss', style: TextStyle(color: Colors.white, fontSize: 13)),
                      Switch(
                        value: enableDailyLoss,
                        activeColor: Colors.redAccent,
                        onChanged: (val) => setState(() => enableDailyLoss = val),
                      ),
                    ],
                  ),
                  if (enableDailyLoss) ...[
                    const SizedBox(height: 6),
                    _buildControllerInputField('Daily Loss Limit (\$)', dailyLossController, TextInputType.number),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSettingsToFirebase,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('SYNC & SAVE TO EA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControllerInputField(String label, TextEditingController controller, TextInputType keyboardType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0B0E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12, width: 1),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            onChanged: (val) => setState(() {}),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 3. ORDERS SCREEN
// ==========================================
class OrdersScreen extends StatefulWidget {
  final String accountLogin;
  const OrdersScreen({super.key, required this.accountLogin});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<dynamic, dynamic>> activeOrders = [];
  DatabaseReference? _ordersRef;
  String activeSymbol = 'XAUUSD';
  String activeTimeframe = 'M1';

  @override
  void initState() {
    super.initState();
    _listenToOrders();
    _listenToStatusForSymbol();
  }

  void _listenToStatusForSymbol() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      database.ref('status').onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            activeSymbol = data['symbol']?.toString() ?? 'XAUUSD';
            activeTimeframe = data['timeframe']?.toString() ?? 'M1';
          });
        }
      });
    } catch (e) {
      print("Status symbol listen error: $e");
    }
  }

  void _listenToOrders() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      _ordersRef = database.ref('orders');

      _ordersRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (mounted) {
          setState(() {
            activeOrders.clear();
            if (data is Map) {
              data.forEach((key, value) {
                if (value is Map) {
                  activeOrders.add(Map<dynamic, dynamic>.from(value));
                }
              });
            } else if (data is List) {
              for (var e in data) {
                if (e is Map) {
                  activeOrders.add(Map<dynamic, dynamic>.from(e));
                }
              }
            }
          });
        }
      });
    } catch (e) {
      print("Orders listen error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalOrdersProfit = activeOrders.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item['profit']?.toString() ?? '0.0') ?? 0.0);
    });
    bool isTotalProfit = totalOrdersProfit >= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Active Orders (${widget.accountLogin})'),
        backgroundColor: const Color(0xFF0B0B0E),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF161619),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.4), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B0B0E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.3)),
                        ),
                        child: Text(
                          activeSymbol,
                          style: const TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B0B0E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                        ),
                        child: Text(
                          activeTimeframe,
                          style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const Text('Active Symbol', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isTotalProfit
                    ? [const Color(0xFF00C853).withOpacity(0.2), const Color(0xFF161619)]
                    : [const Color(0xFFD50000).withOpacity(0.2), const Color(0xFF161619)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isTotalProfit ? const Color(0xFF00C853).withOpacity(0.8) : const Color(0xFFD50000).withOpacity(0.8),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL OPEN PROFIT',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                Text(
                  '${isTotalProfit ? "+" : ""}\$${totalOrdersProfit.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isTotalProfit ? const Color(0xFF00C853) : const Color(0xFFD50000),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: activeOrders.isEmpty
                ? const Center(
                    child: Text('No active orders currently', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: activeOrders.length,
                    itemBuilder: (context, index) {
                      final order = activeOrders[index];
                      final String type = order['type']?.toString() ?? 'BUY';
                      final double lot = double.tryParse(order['lot']?.toString() ?? '0.01') ?? 0.01;
                      final double profit = double.tryParse(order['profit']?.toString() ?? '0.0') ?? 0.0;
                      final String symbol = order['symbol']?.toString() ?? activeSymbol;
                      bool isBuy = type.toUpperCase().contains('BUY');
                      bool orderProfit = profit >= 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161619),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isBuy ? const Color(0xFF00C853).withOpacity(0.5) : Colors.redAccent.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isBuy ? const Color(0xFF00C853).withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(color: isBuy ? const Color(0xFF00C853) : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text('Lot: $lot', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              '${orderProfit ? "+" : ""}\$${profit.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: orderProfit ? const Color(0xFF00C853) : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
    );
  }
}

// ==========================================
// 4. TRADE HISTORY SCREEN
// ==========================================
class HistoryScreen extends StatefulWidget {
  final String accountLogin;
  const HistoryScreen({super.key, required this.accountLogin});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<dynamic, dynamic>> allTradeHistory = [];
  DatabaseReference? _historyRef;
  
  String selectedFilter = 'วันนี้';
  final List<String> filterOptions = ['วันนี้', 'สัปดาห์ล่าสุด', 'เดือนล่าสุด', '3 เดือนล่าสุด', 'ทั้งหมด'];

  @override
  void initState() {
    super.initState();
    _listenToHistory(widget.accountLogin);
  }

  @override
  void didUpdateWidget(covariant HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountLogin != widget.accountLogin) {
      _listenToHistory(widget.accountLogin);
    }
  }

  void _listenToHistory(String login) {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      _historyRef = database.ref('history');

      _historyRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (mounted) {
          setState(() {
            allTradeHistory.clear();
            if (data is Map) {
              data.forEach((key, value) {
                if (value is Map) {
                  allTradeHistory.add(Map<dynamic, dynamic>.from(value));
                } else if (value is List) {
                  for (var item in value) {
                    if (item is Map) {
                      allTradeHistory.add(Map<dynamic, dynamic>.from(item));
                    }
                  }
                }
              });
            } else if (data is List) {
              for (var e in data) {
                if (e is Map) {
                  allTradeHistory.add(Map<dynamic, dynamic>.from(e));
                }
              }
            }

            allTradeHistory.sort((a, b) {
              String timeA = a['close_time']?.toString() ?? a['time']?.toString() ?? '';
              String timeB = b['close_time']?.toString() ?? b['time']?.toString() ?? '';
              return timeB.compareTo(timeA);
            });
          });
        }
      });
    } catch (e) {
      print("History listen error: $e");
    }
  }

  List<Map<dynamic, dynamic>> _getFilteredHistory() {
    if (selectedFilter == 'ทั้งหมด') return allTradeHistory;

    DateTime now = DateTime.now();
    return allTradeHistory.where((trade) {
      String timeStr = trade['close_time']?.toString() ?? trade['time']?.toString() ?? '';
      DateTime? tradeDate = DateTime.tryParse(timeStr.replaceAll('.', '-'));
      if (tradeDate == null) return false;

      if (selectedFilter == 'วันนี้') {
        return tradeDate.year == now.year && tradeDate.month == now.month && tradeDate.day == now.day;
      } else if (selectedFilter == 'สัปดาห์ล่าสุด') {
        DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        DateTime startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return tradeDate.isAfter(startDate) || tradeDate.isAtSameMomentAs(startDate);
      } else if (selectedFilter == 'เดือนล่าสุด') {
        return tradeDate.year == now.year && tradeDate.month == now.month;
      } else if (selectedFilter == '3 เดือนล่าสุด') {
        DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return tradeDate.isAfter(threeMonthsAgo);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<dynamic, dynamic>> filteredHistory = _getFilteredHistory();

    double totalProfit = filteredHistory.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item['profit']?.toString() ?? '0.0') ?? 0.0);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('History (${widget.accountLogin})'),
        backgroundColor: const Color(0xFF0B0B0E),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: filterOptions.length,
              itemBuilder: (context, index) {
                String filter = filterOptions[index];
                bool isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFB300),
                    backgroundColor: const Color(0xFF161619),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF161619),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.5), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Realized P/L ($selectedFilter)', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  '${totalProfit >= 0 ? "+" : ""}\$${totalProfit.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: totalProfit >= 0 ? const Color(0xFF00C853) : Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredHistory.isEmpty
                ? const Center(
                    child: Text('No closed trade history for this account', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final trade = filteredHistory[index];
                      final String type = trade['type']?.toString() ?? 'BUY';
                      final String symbol = trade['symbol']?.toString() ?? 'BTCUSD';
                      final double lot = double.tryParse(trade['lot']?.toString() ?? '0.01') ?? 0.01;
                      final double priceOpen = double.tryParse(trade['price_open']?.toString() ?? '0.0') ?? 0.0;
                      final double priceClose = double.tryParse(trade['price_close']?.toString() ?? '0.0') ?? 0.0;
                      final double profit = double.tryParse(trade['profit']?.toString() ?? '0.0') ?? 0.0;
                      final String closeTime = trade['close_time']?.toString() ?? trade['time']?.toString() ?? '';
                      bool isBuy = type.toUpperCase().contains('BUY');
                      bool isProfit = profit >= 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161619),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isBuy ? const Color(0xFF00C853).withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(color: isBuy ? const Color(0xFF00C853) : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$symbol, lot: $lot', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${priceOpen.toStringAsFixed(2)} -> ${priceClose.toStringAsFixed(2)}',
                                      style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontFamily: 'monospace'),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(closeTime, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              '${isProfit ? "+" : ""}\$${profit.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isProfit ? const Color(0xFF00C853) : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
    );
  }
}

// ==========================================
// 5. ALERTS SCREEN
// ==========================================
class AlertsScreen extends StatefulWidget {
  final VoidCallback onAlertsRead;
  const AlertsScreen({super.key, required this.onAlertsRead});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<Map<String, dynamic>> alertItems = [];
  DatabaseReference? _alertsRef;

  @override
  void initState() {
    super.initState();
    widget.onAlertsRead();
    _listenToAlerts();
  }

  void _listenToAlerts() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      _alertsRef = database.ref('alerts');

      _alertsRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (mounted) {
          setState(() {
            alertItems.clear();
            if (data is Map) {
              data.forEach((key, value) {
                if (value != null) {
                  alertItems.add({
                    'key': key.toString(),
                    'message': value.toString(),
                  });
                }
              });
            } else if (data is List) {
              for (int i = 0; i < data.length; i++) {
                if (data[i] != null) {
                  alertItems.add({
                    'key': i.toString(),
                    'message': data[i].toString(),
                  });
                }
              }
            }

            alertItems.sort((a, b) => b['message'].compareTo(a['message']));
          });
        }
      });
    } catch (e) {
      print("Alerts listen error: $e");
    }
  }

  void _deleteAlert(String key) {
    try {
      _alertsRef?.child(key).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleted alert successfully'), duration: Duration(seconds: 1)),
      );
    } catch (e) {
      print("Delete alert error: $e");
    }
  }

  void _clearAllAlerts() {
    try {
      _alertsRef?.remove();
      setState(() {
        alertItems.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cleared all alerts successfully'), duration: Duration(seconds: 1)),
      );
    } catch (e) {
      print("Clear all alerts error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Push Alerts'),
        backgroundColor: const Color(0xFF0B0B0E),
        actions: [
          if (alertItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              onPressed: _clearAllAlerts,
              tooltip: 'Clear All Alerts',
            ),
        ],
      ),
      body: alertItems.isEmpty
          ? const Center(child: Text('No active alerts...', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alertItems.length,
              itemBuilder: (context, index) {
                final alert = alertItems[index];
                return Card(
                  color: const Color(0xFF161619),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active, color: Color(0xFFFFB300)),
                    title: Text(alert['message'], style: const TextStyle(color: Colors.white, fontSize: 13)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                      onPressed: () => _deleteAlert(alert['key']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
