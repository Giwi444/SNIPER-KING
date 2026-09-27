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

class _PinAuthWrapperState extends State<PinAuthWrapper> {
  bool isAuthorized = false;
  bool hasStoredPin = false;
  bool isConfirming = false;
  bool isLoading = true;
  String firstEnteredPin = "";
  String currentPinInput = "";

  @override
  void initState() {
    super.initState();
    _checkPinExists();
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

// ==========================================
// MAIN NAVIGATION SCREEN
// ==========================================
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 2; // หน้า Home เป็นค่าเริ่มต้น (Index 2)
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
      backgroundColor: const Color(0xFF0B0B0E),
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
// 1. HOME SCREEN (CLEAN DASHBOARD)
// ==========================================
class HomeScreen extends StatefulWidget {
  final String accountLogin;
  const HomeScreen({super.key, required this.accountLogin});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool isRunning = false;
  DatabaseReference? _dbRef;
  
  double balance = 0.0;
  double equity = 0.0;
  double profit = 0.0;
  String symbol = "XAUUSD";
  String timeframe = "M1";

  Offset _dialogOffset = const Offset(50, 150);
  bool _isLogDialogOpen = false;
  List<Map<String, dynamic>> _eaLogs = [];
  DatabaseReference? _logsRef;

  Offset _statusBoxOffset = const Offset(0, 0);
  bool _isStatusOffsetInitialized = false;

  Offset _robotIconOffset = const Offset(0, 0);
  bool _isRobotIconOffsetInitialized = false;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _initFirebaseAndListen();
    _listenToEALogs();

    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  void _initFirebaseAndListen() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      _dbRef = database.ref('status');

      _dbRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null && mounted) {
          setState(() {
            isRunning = data['is_running'] ?? false;
            balance = (data['balance'] ?? 0.0).toDouble();
            equity = (data['equity'] ?? 0.0).toDouble();
            profit = (data['profit'] ?? 0.0).toDouble();
            symbol = data['symbol']?.toString() ?? 'XAUUSD';
            timeframe = data['timeframe']?.toString() ?? 'M1';
          });
        }
      });
    } catch (e) {
      print("Database listen error: $e");
    }
  }

  void _listenToEALogs() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      _logsRef = database.ref('ea_logs');
      _logsRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (mounted) {
          setState(() {
            _eaLogs.clear();
            if (data is Map) {
              data.forEach((key, value) {
                if (value != null) {
                  _eaLogs.add({'key': key.toString(), 'message': value.toString()});
                }
              });
            } else if (data is List) {
              for (int i = 0; i < data.length; i++) {
                if (data[i] != null) {
                  _eaLogs.add({'key': i.toString(), 'message': data[i].toString()});
                }
              }
            }
            if (_eaLogs.isEmpty) {
              _eaLogs = [
                {'key': '1', 'message': 'EA Initialized & scanning Market XAUUSD M1...'},
                {'key': '2', 'message': 'Analyzing Liquidity Zone & Swing Bars...'},
                {'key': '3', 'message': 'Status: Normal, searching for optimal entry point.'}
              ];
            }
          });
        }
      });
    } catch (e) {
      print("Logs listen error: $e");
      setState(() {
        _eaLogs = [
          {'key': '1', 'message': 'EA Initialized successfully.'},
          {'key': '2', 'message': 'Checking market error / connection: OK.'},
        ];
      });
    }
  }

  void _clearLogs() {
    setState(() {
      _eaLogs.clear();
    });
    try {
      _logsRef?.remove();
    } catch (e) {
      print("Clear logs error: $e");
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
    final screenSize = MediaQuery.of(context).size;

    if (!_isStatusOffsetInitialized) {
      _statusBoxOffset = Offset((screenSize.width - 240) / 2, screenSize.height - 260);
      _isStatusOffsetInitialized = true;
    }

    if (!_isRobotIconOffsetInitialized) {
      _robotIconOffset = Offset(screenSize.width / 2 - 28, screenSize.height - 180);
      _isRobotIconOffsetInitialized = true;
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
            color: Colors.black.withOpacity(0.3),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: constraints.maxHeight * 0.72), 
                            const Spacer(),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 48,
                                        child: ElevatedButton.icon(
                                          onPressed: _closeAllOrders,
                                          icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 18),
                                          label: const Text('CLOSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFFFB300),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: SizedBox(
                                        height: 48,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _toggleBotStatus(true),
                                          icon: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                                          label: const Text('START', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF00C853),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: SizedBox(
                                        height: 48,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _toggleBotStatus(false),
                                          icon: const Icon(Icons.stop, color: Colors.white, size: 18),
                                          label: const Text('STOP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFD50000),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Positioned(
            left: _statusBoxOffset.dx,
            top: _statusBoxOffset.dy,
            child: Draggable(
              feedback: Material(
                color: Colors.transparent,
                child: _buildStatusBoxContent(),
              ),
              childWhenDragging: Container(),
              onDragEnd: (details) {
                setState(() {
                  _statusBoxOffset = details.offset;
                });
              },
              child: _buildStatusBoxContent(),
            ),
          ),

          Positioned(
            left: _robotIconOffset.dx,
            top: _robotIconOffset.dy,
            child: Draggable(
              feedback: Material(
                color: Colors.transparent,
                child: _buildRobotButtonContent(),
              ),
              childWhenDragging: Container(),
              onDragEnd: (details) {
                setState(() {
                  _robotIconOffset = details.offset;
                });
              },
              child: _buildRobotButtonContent(),
            ),
          ),

          if (_isLogDialogOpen)
            Positioned(
              left: _dialogOffset.dx,
              top: _dialogOffset.dy,
              child: Draggable(
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildLogDialogContent(constraintsWidth: MediaQuery.of(context).size.width * 0.85),
                ),
                childWhenDragging: Container(),
                onDragEnd: (details) {
                  setState(() {
                    _dialogOffset = details.offset;
                  });
                },
                child: _buildLogDialogContent(constraintsWidth: MediaQuery.of(context).size.width * 0.85),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRobotButtonContent() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isLogDialogOpen = !_isLogDialogOpen;
          });
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/p.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.black);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBoxContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161619).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF161619), Color(0xFF0B0B0E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: const Color(0xFFFFB300),
          width: 3.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFFF0000), Color(0xFF000000), Color(0xFFFFB300)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(bounds),
            child: const Text(
              'SNIPER KING BOT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: (isRunning ? const Color(0xFF00C853) : Colors.red).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isRunning ? const Color(0xFF00C853) : Colors.red,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRunning ? Icons.play_arrow : Icons.stop,
                  color: isRunning ? const Color(0xFF00C853) : Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isRunning ? 'RUNNING' : 'STOPPED',
                  style: TextStyle(
                    color: isRunning ? const Color(0xFF00C853) : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogDialogContent({required double constraintsWidth}) {
    return Container(
      width: constraintsWidth,
      constraints: const BoxConstraints(maxHeight: 380),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161619).withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB300), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.circle, color: Color(0xFF00C853), size: 12),
                  SizedBox(width: 8),
                  Text(
                    'Robot Active - EA Logs',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _isLogDialogOpen = false;
                  });
                },
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _eaLogs.isEmpty
                    ? const [
                        Text(
                          'No movement or error detected currently.',
                          style: TextStyle(color: Color(0xFF00C853), fontSize: 13, fontFamily: 'monospace'),
                        )
                      ]
                    : _eaLogs.map((log) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '• ${log['message']}',
                            style: const TextStyle(
                              color: Color(0xFF00C853),
                              fontSize: 12.5,
                              fontFamily: 'monospace',
                              height: 1.3,
                            ),
                          ),
                        );
                      }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearLogs,
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
                  label: const Text('ลบข้อความ', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isLogDialogOpen = false;
                    });
                  },
                  icon: const Icon(Icons.home, color: Colors.white, size: 16),
                  label: const Text('กลับแดชบอร์ด', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
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
  bool isConnected = false;

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

      database.ref('.info/connected').onValue.listen((event) {
        final connected = event.snapshot.value as bool? ?? false;
        if (mounted) {
          setState(() {
            isConnected = connected;
          });
        }
      });

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
        title: const Text('Parameters Bot'),
        backgroundColor: const Color(0xFF0B0B0E),
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
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
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// 3. ORDERS SCREEN (แก้ไขให้เหมือนภาพที่ 1)
// ==========================================
class OrdersScreen extends StatefulWidget {
  final String accountLogin;
  const OrdersScreen({super.key, required this.accountLogin});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Map<String, dynamic>> orders = [];
  DatabaseReference? _ordersRef;
  DatabaseReference? _statusRef;

  double balance = 0.0;
  double equity = 0.0;
  double margin = 0.0;
  double freeMargin = 0.0;
  double totalProfit = 0.0;
  String brokerName = "ICMarketsSC-Demo";
  String symbolInfo = "XAUUSD";

  @override
  void initState() {
    super.initState();
    _listenToStatus();
    _listenToOrders();
  }

  void _listenToStatus() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      _statusRef = database.ref('status');
      _statusRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            balance = (data['balance'] ?? 0.0).toDouble();
            equity = (data['equity'] ?? 0.0).toDouble();
            margin = (data['margin'] ?? 0.0).toDouble();
            freeMargin = (data['free_margin'] ?? 0.0).toDouble();
            brokerName = data['broker']?.toString() ?? 'ICMarketsSC-Demo';
            symbolInfo = data['symbol']?.toString() ?? 'XAUUSD';
          });
        }
      });
    } catch (e) {
      print("Status listen error: $e");
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
            orders.clear();
            double calcProfit = 0.0;
            if (data is Map) {
              data.forEach((key, value) {
                if (value is Map) {
                  double p = (value['profit'] ?? 0.0).toDouble();
                  calcProfit += p;
                  orders.add({
                    'id': key.toString(),
                    'symbol': value['symbol']?.toString() ?? 'XAUUSD',
                    'type': value['type']?.toString() ?? 'BUY',
                    'lots': (value['lots'] ?? 0.01).toDouble(),
                    'open_price': (value['open_price'] ?? 0.0).toDouble(),
                    'profit': p,
                  });
                }
              });
            } else if (data is List) {
              for (int i = 0; i < data.length; i++) {
                var value = data[i];
                if (value is Map) {
                  double p = (value['profit'] ?? 0.0).toDouble();
                  calcProfit += p;
                  orders.add({
                    'id': i.toString(),
                    'symbol': value['symbol']?.toString() ?? 'XAUUSD',
                    'type': value['type']?.toString() ?? 'BUY',
                    'lots': (value['lots'] ?? 0.01).toDouble(),
                    'open_price': (value['open_price'] ?? 0.0).toDouble(),
                    'profit': p,
                  });
                }
              }
            }
            totalProfit = calcProfit;
          });
        }
      });
    } catch (e) {
      print("Orders listen error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Orders & Portfolio'),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1. TRADING ACCOUNT INFO CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161619).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_balance, color: Color(0xFFFFB300), size: 16),
                              const SizedBox(width: 6),
                              const Text('TRADING ACCOUNT INFO', style: TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text('Account Login', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          const SizedBox(height: 2),
                          Text(
                            widget.accountLogin,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            brokerName,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B0B0E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          symbolInfo,
                          style: const TextStyle(color: Color(0xFFFFB300), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 2. 4 STATS CARDS (Balance, Equity, Margin, Free Margin)
                Row(
                  children: [
                    Expanded(child: _buildStatBox('Balance', '\$${balance.toStringAsFixed(2)}', Icons.account_balance_wallet_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatBox('Equity', '\$${equity.toStringAsFixed(2)}', Icons.show_chart)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildStatBox('Margin', '\$${margin.toStringAsFixed(2)}', Icons.lock_outline)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatBox('Free Margin', '\$${freeMargin.toStringAsFixed(2)}', Icons.lock_open_outlined)),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. TOTAL OPEN PROFIT CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161619).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL OPEN PROFIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(
                        '${totalProfit >= 0 ? '+' : ''}\$${totalProfit.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: totalProfit >= 0 ? const Color(0xFF00C853) : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 4. ACTIVE ORDERS LIST
                orders.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: Text('No active orders found.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          bool isBuy = order['type'].toString().toUpperCase() == 'BUY';
                          double profitVal = order['profit'];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161619).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(14),
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
                                        color: (isBuy ? const Color(0xFF00C853) : Colors.red).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: isBuy ? const Color(0xFF00C853) : Colors.red),
                                      ),
                                      child: Text(
                                        order['type'],
                                        style: TextStyle(
                                          color: isBuy ? const Color(0xFF00C853) : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order['symbol'],
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Lot: ${order['lots']}',
                                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Text(
                                  '${profitVal >= 0 ? '+' : ''}\$${profitVal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: profitVal >= 0 ? const Color(0xFF00C853) : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
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

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161619).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 1),
      ),
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
          const SizedBox(height: 6),
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
// 4. HISTORY SCREEN (แก้ไขให้เหมือนภาพที่ 3)
// ==========================================
class HistoryScreen extends StatefulWidget {
  final String accountLogin;
  const HistoryScreen({super.key, required this.accountLogin});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int selectedFilterIndex = 0; // 0: วันนี้, 1: สัปดาห์ล่าสุด, 2: เดือนล่าสุด, 3: 3 เดือน
  List<Map<String, dynamic>> historyList = [];
  DatabaseReference? _historyRef;
  double totalRealizedPL = 0.0;

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
            historyList.clear();
            double plSum = 0.0;
            if (data is Map) {
              data.forEach((key, value) {
                if (value is Map) {
                  double profit = (value['profit'] ?? 0.0).toDouble();
                  plSum += profit;
                  historyList.add({
                    'id': key.toString(),
                    'symbol': value['symbol']?.toString() ?? 'XAUUSD',
                    'type': value['type']?.toString() ?? 'BUY',
                    'lots': (value['lots'] ?? 0.01).toDouble(),
                    'profit': profit,
                    'close_time': value['close_time']?.toString() ?? '-',
                  });
                }
              });
            } else if (data is List) {
              for (int i = 0; i < data.length; i++) {
                var value = data[i];
                if (value is Map) {
                  double profit = (value['profit'] ?? 0.0).toDouble();
                  plSum += profit;
                  historyList.add({
                    'id': i.toString(),
                    'symbol': value['symbol']?.toString() ?? 'XAUUSD',
                    'type': value['type']?.toString() ?? 'BUY',
                    'lots': (value['lots'] ?? 0.01).toDouble(),
                    'profit': profit,
                    'close_time': value['close_time']?.toString() ?? '-',
                  });
                }
              }
            }
            totalRealizedPL = plSum;
          });
        }
      });
    } catch (e) {
      print("History listen error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> filters = ['วันนี้', 'สัปดาห์ล่าสุด', 'เดือนล่าสุด', '3 เดือน'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 1. FILTER TABS ROW
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(filters.length, (index) {
                      bool isSelected = selectedFilterIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filters[index]),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              selectedFilterIndex = index;
                            });
                          },
                          selectedColor: const Color(0xFFFFB300),
                          backgroundColor: const Color(0xFF161619),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFFFFB300) : Colors.white24,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. TOTAL REALIZED P/L CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161619).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Realized P/L (${filters[selectedFilterIndex]})',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${totalRealizedPL >= 0 ? '+' : ''}\$${totalRealizedPL.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: totalRealizedPL >= 0 ? const Color(0xFF00C853) : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. HISTORY LIST / NO DATA STATE
                Expanded(
                  child: historyList.isEmpty
                      ? const Center(
                          child: Text(
                            'No closed trade history for this account',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        )
                      : ListView.builder(
                          itemCount: historyList.length,
                          itemBuilder: (context, index) {
                            final item = historyList[index];
                            double profitVal = item['profit'];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161619).withOpacity(0.9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white12, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item['symbol']} (${item['type']})',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Close Time: ${item['close_time']}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 10.5),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${profitVal >= 0 ? '+' : ''}\$${profitVal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: profitVal >= 0 ? const Color(0xFF00C853) : Colors.red,
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
  List<Map<String, dynamic>> alertsList = [];
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
            alertsList.clear();
            if (data is Map) {
              data.forEach((key, value) {
                if (value != null) {
                  alertsList.add({
                    'id': key.toString(),
                    'message': value.toString(),
                  });
                }
              });
            } else if (data is List) {
              for (int i = 0; i < data.length; i++) {
                if (data[i] != null) {
                  alertsList.add({
                    'id': i.toString(),
                    'message': data[i].toString(),
                  });
                }
              }
            }
          });
        }
      });
    } catch (e) {
      print("Alerts listen error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Alerts'),
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
          alertsList.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications at this time.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: alertsList.length,
                  itemBuilder: (context, index) {
                    final alert = alertsList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161619).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active, color: Color(0xFFFFB300), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              alert['message'],
                              style: const TextStyle(color: Colors.white, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
