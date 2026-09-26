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
      home: const PinAuthWrapper(),
    );
  }
}

// ==========================================
// PIN AUTH WRAPPER
// ==========================================
class PinAuthWrapper extends StatefulWidget {
  const PinAuthWrapper({super.key});

  @override
  State<PinAuthWrapper> createState() => _PinAuthWrapperState();
}

class _PinAuthWrapperState extends State<PinAuthWrapper> with WidgetsBindingObserver {
  bool isAuthorized = false;
  bool hasStoredPin = false;
  bool isConfirming = false;
  bool isLoading = true;
  String firstEnteredPin = "";
  String currentPinInput = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPinExists();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      if (mounted && hasStoredPin) {
        setState(() {
          isAuthorized = false;
          currentPinInput = "";
        });
      }
    }
  }

  Future<void> _checkPinExists() async {
    final prefs = await SharedPreferences.getInstance();
    final pin = prefs.getString('user_pin');
    setState(() {
      hasStoredPin = pin != null && pin.isNotEmpty;
      isLoading = false;
    });
  }

  Future<void> _saveNewPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', pin);
  }

  Future<void> _verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('user_pin');
    if (storedPin == pin) {
      setState(() {
        isAuthorized = true;
      });
    } else {
      setState(() {
        currentPinInput = "";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัส PIN ไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง'), backgroundColor: Colors.red),
      );
    }
  }

  void _onNumberTap(String number) {
    if (currentPinInput.length < 6) {
      setState(() {
        currentPinInput += number;
      });

      if (currentPinInput.length == 6) {
        if (!hasStoredPin) {
          if (!isConfirming) {
            firstEnteredPin = currentPinInput;
            currentPinInput = "";
            isConfirming = true;
          } else {
            if (firstEnteredPin == currentPinInput) {
              _saveNewPin(currentPinInput);
              setState(() {
                hasStoredPin = true;
                isAuthorized = true;
              });
            } else {
              setState(() {
                currentPinInput = "";
                isConfirming = false;
                firstEnteredPin = "";
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('รหัส PIN ไม่ตรงกัน กรุณาตั้งค่าใหม่อีกครั้ง'), backgroundColor: Colors.red),
              );
            }
          }
        } else {
          _verifyPin(currentPinInput);
        }
      }
    }
  }

  void _onDeleteTap() {
    if (currentPinInput.isNotEmpty) {
      setState(() {
        currentPinInput = currentPinInput.substring(0, currentPinInput.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (isAuthorized) {
      return const MainNavigationScreen();
    }

    String titleText = "กรุณากรอก PIN เพื่อเข้าใช้งาน";
    if (!hasStoredPin) {
      titleText = isConfirming ? "ยืนยันรหัส PIN 6 หลักอีกครั้ง" : "ตั้งค่ารหัส PIN 6 หลักใหม่";
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/p.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF0B0B0E));
            },
          ),
          Container(
            color: Colors.black.withOpacity(0.8),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, color: Color(0xFFFFB300), size: 48),
                const SizedBox(height: 16),
                Text(
                  titleText,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    bool isFilled = index < currentPinInput.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled ? const Color(0xFFFFB300) : Colors.transparent,
                        border: Border.all(color: const Color(0xFFFFB300), width: 2),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ['1', '2', '3'].map((val) => _buildPinButton(val)).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ['4', '5', '6'].map((val) => _buildPinButton(val)).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ['7', '8', '9'].map((val) => _buildPinButton(val)).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 96),
                      _buildPinButton('0'),
                      _buildPinButton('del'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinButton(String val) {
    return Container(
      width: 72,
      height: 72,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFD50000), Color(0xFF7A0000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (val == 'del') {
              _onDeleteTap();
            } else {
              _onNumberTap(val);
            }
          },
          customBorder: const CircleBorder(),
          splashColor: const Color(0xFFFFB300).withOpacity(0.6),
          highlightColor: const Color(0xFFFFB300).withOpacity(0.4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/p.jpg',
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.25),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.transparent);
                  },
                ),
              ),
              Center(
                child: val == 'del'
                    ? const Icon(Icons.backspace_outlined, color: Colors.white)
                    : Text(
                        val,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 2;
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
      const SettingsScreen(),
      OrdersScreen(accountLogin: currentLogin),
      HomeScreen(accountLogin: currentLogin),
      HistoryScreen(accountLogin: currentLogin),
      AlertsScreen(onAlertsRead: () {
        setState(() {
          unreadAlertsCount = 0;
        });
      }),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD50000), Color(0xFF7A0000), Color(0xFF101014)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFFFFB300),
          unselectedItemColor: Colors.white70,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Settings'),
            const BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
            const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadAlertsCount',
                          style: const TextStyle(
                            color: Colors.red,
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
            isRunning = data['is_running'] ?? false;
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
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/p.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: const Color(0xFF0B0B0E));
          },
        ),
        Container(
          color: Colors.black.withOpacity(0.2),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD50000), Color(0xFF101014), Color(0xFFFFB300)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFFB300),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.smart_toy, color: Color(0xFFFFB300), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Sniper King Bot',
                              style: TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.settings_suggest, color: Color(0xFFFFB300), size: 16),
                          SizedBox(width: 6),
                          Text(
                            'BOT & ORDER CONTROL',
                            style: TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('EA Execution Status', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isRunning ? const Color(0xFF00C853).withOpacity(0.25) : Colors.red.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isRunning ? 'RUNNING' : 'STOPPED',
                              style: TextStyle(
                                color: isRunning ? const Color(0xFF00C853) : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // ย้ายปุ่ม Connected มาไว้ในกล่องตรงนี้ ต่อจากบรรทัด Running
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Connection Status', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isConnected ? const Color(0xFF00C853) : Colors.red).withOpacity(0.25),
                              borderRadius: BorderRadius.circular(8),
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
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isConnected ? 'CONNECTED' : 'DISCONNECTED',
                                  style: TextStyle(
                                    color: isConnected ? const Color(0xFF00C853) : Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _toggleBotStatus(true),
                              icon: const Icon(Icons.play_arrow, color: Colors.white),
                              label: const Text('START', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00C853),
                                padding: const EdgeInsets.symmetric(vertical: 12),
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
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _closeAllOrders,
                          icon: const Icon(Icons.delete_sweep, color: Colors.white),
                          label: const Text('CLOSE ALL ORDERS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
        ),
      ],
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/p.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF0B0B0E));
            },
          ),
          Container(
            color: Colors.black.withOpacity(0.8),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SNIPER KING PARAMETERS',
                  style: TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161619).withOpacity(0.9),
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
        ],
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
  DatabaseReference? _dbRef;
  String activeSymbol = 'XAUUSD';
  String activeTimeframe = 'M1';
  String accountServer = 'Exness-MT5Server';

  double balance = 0.0;
  double equity = 0.0;
  double margin = 0.0;
  double freeMargin = 0.0;
  double profitLoss = 0.0;

  @override
  void initState() {
    super.initState();
    _listenToOrders();
    _listenToStatusForSymbol();
    _listenToFinancialStatus();
  }

  void _listenToStatusForSymbol() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      _dbRef = database.ref('status');
      _dbRef?.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            activeSymbol = data['symbol']?.toString() ?? 'XAUUSD';
            activeTimeframe = data['timeframe']?.toString() ?? 'M1';
            accountServer = data['server']?.toString() ?? 'Exness-MT5Server';
            
            balance = (data['balance'] ?? 0.0).toDouble();
            equity = (data['equity'] ?? 0.0).toDouble();
            margin = (data['margin'] ?? 0.0).toDouble();
            freeMargin = (data['free_margin'] ?? 0.0).toDouble();
            profitLoss = (data['profit'] ?? 0.0).toDouble();
          });
        }
      });
    } catch (e) {
      print("Status symbol listen error: $e");
    }
  }

  void _listenToFinancialStatus() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      database.ref('status').onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            balance = (data['balance'] ?? 0.0).toDouble();
            equity = (data['equity'] ?? 0.0).toDouble();
            margin = (data['margin'] ?? 0.0).toDouble();
            freeMargin = (data['free_margin'] ?? 0.0).toDouble();
            profitLoss = (data['profit'] ?? 0.0).toDouble();
            if (data['server'] != null) {
              accountServer = data['server'].toString();
            }
          });
        }
      });
    } catch (e) {
      print("Financial listen error: $e");
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
        title: const Text('Active Orders & Portfolio'),
        backgroundColor: const Color(0xFF0B0B0E),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/p.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF0B0B0E));
            },
          ),
          Container(
            color: Colors.black.withOpacity(0.8),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD50000), Color(0xFF101014), Color(0xFFFFB300)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFFB300),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.account_balance, color: Color(0xFFFFB300), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'TRADING ACCOUNT INFO',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber, width: 1),
                            ),
                            child: Text(
                              activeSymbol,
                              style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Account Login', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                widget.accountLogin,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Server', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                accountServer,
                                style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

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
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isTotalProfit
                          ? [const Color(0xFF00C853).withOpacity(0.3), const Color(0xFF161619)]
                          : [const Color(0xFFD50000).withOpacity(0.3), const Color(0xFF161619)],
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
                const SizedBox(height: 12),

                activeOrders.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Center(
                          child: Text('No active orders currently', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                              color: const Color(0xFF161619).withOpacity(0.9),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161619).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.grey, size: 15),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
            textAlign: TextAlign.center,
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
        title: const Text('History'),
        backgroundColor: const Color(0xFF0B0B0E),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/p.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF0B0B0E));
            },
          ),
          Container(
            color: Colors.black.withOpacity(0.8),
          ),
          Column(
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
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD50000), Color(0xFF101014), Color(0xFFFFB300)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFFB300),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Realized P/L ($selectedFilter)', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
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
                              color: const Color(0xFF161619).withOpacity(0.9),
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/p.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF0B0B0E));
            },
          ),
          Container(
            color: Colors.black.withOpacity(0.8),
          ),
          alertItems.isEmpty
              ? const Center(child: Text('No active alerts...', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: alertItems.length,
                  itemBuilder: (context, index) {
                    final alert = alertItems[index];
                    return Card(
                      color: const Color(0xFF161619).withOpacity(0.9),
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
        ],
      ),
    );
  }
}
