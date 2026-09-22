import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      home: const PinCheckOrSetupScreen(),
    );
  }
}

// ==========================================
// PIN CHECK OR SETUP SCREEN (ตรวจสอบหรือสร้าง PIN ใหม่)
// ==========================================
class PinCheckOrSetupScreen extends StatefulWidget {
  const PinCheckOrSetupScreen({super.key});

  @override
  State<PinCheckOrSetupScreen> createState() => _PinCheckOrSetupScreenState();
}

class _PinCheckOrSetupScreenState extends State<PinCheckOrSetupScreen> {
  String enteredPin = "";
  String? savedPin;
  bool isSetupMode = false;
  bool isConfirmStep = false;
  String tempPin = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSavedPin();
  }

  Future<void> _checkSavedPin() async {
    final prefs = await SharedPreferences.getInstance();
    String? pin = prefs.getString('user_app_pin');
    setState(() {
      savedPin = pin;
      isSetupMode = (pin == null || pin.isEmpty);
      isLoading = false;
    });
  }

  Future<void> _savePinToDevice(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_app_pin', pin);
  }

  void _onNumberTap(String number) async {
    if (enteredPin.length < 6) {
      setState(() {
        enteredPin += number;
      });

      if (enteredPin.length == 6) {
        if (isSetupMode) {
          if (!isConfirmStep) {
            // ขั้นตอนที่ 1: บันทึก PIN ชั่วคราว แล้วให้ยืนยันอีกครั้ง
            setState(() {
              tempPin = enteredPin;
              isConfirmStep = true;
              enteredPin = "";
            });
          } else {
            // ขั้นตอนที่ 2: ยืนยัน PIN ว่าตรงกันไหม
            if (enteredPin == tempPin) {
              await _savePinToDevice(enteredPin);
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('รหัส PIN ไม่ตรงกัน กรุณาตั้งใหม่อีกครั้ง'), backgroundColor: Colors.redAccent),
              );
              setState(() {
                isConfirmStep = false;
                tempPin = "";
                enteredPin = "";
              });
            }
          }
        } else {
          // โหมดกรอกรหัสผ่านเข้าใช้งานปกติ
          if (enteredPin == savedPin) {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PIN ไม่ถูกต้อง'), backgroundColor: Colors.redAccent, duration: Duration(seconds: 1)),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                enteredPin = "";
              });
            });
          }
        }
      }
    }
  }

  void _onDeleteTap() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFFFB300))));
    }

    String titleText = "กรุณากรอก PIN ของคุณ";
    if (isSetupMode) {
      titleText = isConfirmStep ? "ยืนยันรหัส PIN 6 หลักอีกครั้ง" : "สร้างรหัส PIN 6 หลักใหม่";
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0B0E), Color(0xFF002A12)], // พื้นหลังไล่สี ดำ ไป เขียวเข้ม
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const IronManLogo(size: 80),
              const SizedBox(height: 20),
              Text(
                titleText,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 30),

              // จุดแสดงสถานะรหัส 6 ช่อง
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  bool isFilled = index < enteredPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled ? const Color(0xFFFFB300) : Colors.transparent,
                      border: Border.all(color: const Color(0xFFFFB300), width: 2),
                      boxShadow: isFilled ? [const BoxShadow(color: Color(0xFFFFB300), blurRadius: 8, spreadRadius: 1)] : [],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              // แผงปุ่มกดตัวเลข (โทนเหลือง-แดง)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    _buildRow(['1', '2', '3']),
                    const SizedBox(height: 16),
                    _buildRow(['4', '5', '6']),
                    const SizedBox(height: 16),
                    _buildRow(['7', '8', '9']),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 80, height: 80),
                        const SizedBox(width: 24),
                        _buildPinButton('0'),
                        const SizedBox(width: 24),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: ElevatedButton(
                            onPressed: _onDeleteTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF161619),
                              shape: const CircleBorder(),
                              side: const BorderSide(color: Color(0xFFFF5252), width: 2),
                            ),
                            child: const Icon(Icons.backspace_outlined, color: Color(0xFFFF5252), size: 24),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: numbers.map((num) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _buildPinButton(num),
        );
      }).toList(),
    );
  }

  Widget _buildPinButton(String number) {
    return SizedBox(
      width: 80,
      height: 80,
      child: ElevatedButton(
        onPressed: () => _onNumberTap(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF161619),
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          side: const BorderSide(color: Color(0xFFFFB300), width: 2),
          shadowColor: const Color(0xFFFF5252).withOpacity(0.5),
          elevation: 6,
        ),
        child: Text(
          number,
          style: const TextStyle(color: Color(0xFFFFB300), fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ==========================================
// MAIN NAVIGATION SCREEN (แดชบอร์ดหลัก)
// ==========================================
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
            if (_currentIndex != 4) {
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0E),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline, color: Color(0xFFFFB300)),
            tooltip: 'ล็อกหน้าจอ',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PinCheckOrSetupScreen()),
              );
            },
          ),
        ],
      ),
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
              if (index == 4) {
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
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$unreadAlertsCount',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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
                        style: const TextStyle(fontSize: 11, color: Colors.amberAccent, fontWeight: FontWeight.w500),
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
                          style: TextStyle(color: isRunning ? const Color(0xFF00C853) : Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
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
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
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
        const SnackBar(content: Text('Parameters Synced & Saved to EA Successfully!'), backgroundColor: Color(0xFFFFB300)),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      Expanded(child: _buildControllerInputField('Initial Lot', initialLotController)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildControllerInputField('Max Recovery', maxRecoveryController)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildControllerInputField('Swing Bars', swingBarsController)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildControllerInputField('SL Points', slPointsController)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildControllerInputField('Risk Reward', riskRewardController)),
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
                              Text('${calculatedTP.toStringAsFixed(1)} Points', style: const TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildControllerInputField(String label, TextEditingController controller) {
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
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 10)),
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

  @override
  void initState() {
    super.initState();
    _listenToOrders();
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
                if (value is Map) activeOrders.add(Map<dynamic, dynamic>.from(value));
              });
            } else if (data is List) {
              for (var e in data) {
                if (e is Map) activeOrders.add(Map<dynamic, dynamic>.from(e));
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
      appBar: AppBar(title: Text('Active Orders (${widget.accountLogin})'), backgroundColor: const Color(0xFF0B0B0E)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF161619),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isTotalProfit ? const Color(0xFF00C853) : Colors.redAccent, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TOTAL OPEN PROFIT', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(
                  '${isTotalProfit ? "+" : ""}\$${totalOrdersProfit.toStringAsFixed(2)}',
                  style: TextStyle(color: isTotalProfit ? const Color(0xFF00C853) : Colors.redAccent, fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          Expanded(
            child: activeOrders.isEmpty
                ? const Center(child: Text('No active orders currently', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: activeOrders.length,
                    itemBuilder: (context, index) {
                      final order = activeOrders[index];
                      final String type = order['type']?.toString() ?? 'BUY';
                      final double profit = double.tryParse(order['profit']?.toString() ?? '0.0') ?? 0.0;
                      bool isBuy = type.toUpperCase().contains('BUY');

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
                            Text(type, style: TextStyle(color: isBuy ? const Color(0xFF00C853) : Colors.redAccent, fontWeight: FontWeight.bold)),
                            Text('${profit >= 0 ? "+" : ""}\$${profit.toStringAsFixed(2)}', style: TextStyle(color: profit >= 0 ? const Color(0xFF00C853) : Colors.redAccent, fontWeight: FontWeight.bold)),
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

  @override
  void initState() {
    super.initState();
    _listenToHistory();
  }

  void _listenToHistory() {
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
                if (value is Map) allTradeHistory.add(Map<dynamic, dynamic>.from(value));
              });
            }
          });
        }
      });
    } catch (e) {
      print("History error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('History (${widget.accountLogin})'), backgroundColor: const Color(0xFF0B0B0E)),
      body: allTradeHistory.isEmpty
          ? const Center(child: Text('No closed trade history', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allTradeHistory.length,
              itemBuilder: (context, index) {
                final trade = allTradeHistory[index];
                return ListTile(
                  title: Text(trade['symbol']?.toString() ?? 'XAUUSD', style: const TextStyle(color: Colors.white)),
                  trailing: Text('\$${trade['profit'] ?? '0.00'}', style: const TextStyle(color: Color(0xFF00C853))),
                );
              },
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
                if (value != null) alertItems.add({'key': key.toString(), 'message': value.toString()});
              });
            }
          });
        }
      });
    } catch (e) {
      print("Alerts error: $e");
    }
  }

  void _deleteAlert(String key) {
    try {
      _alertsRef?.child(key).remove();
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
