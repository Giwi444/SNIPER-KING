// ==========================================
// #1 โหมดการเชื่อมต่อเซิร์ฟเวอร์
// ==========================================

import 'dart:async';  
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ตัวแปรส่วนกลางสำหรับเก็บสถานะ
String globalSavedLogin = '';
String globalSavedServer = '';
String globalUserPin = '';

// ==========================================
// #2 โหมดเมนหลัก (Theme Stainless Steel Setup)
// ==========================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBnKyMazopUyD1k-kcIXo3bFedWfHXN0JA",
          appId: "1:155532929563:android:49d8a1e0040dc87ce766be",
          messagingSenderId: "155532929563",
          projectId: "liquidity-b8739",
          storageBucket: "liquidity-b8739-firebasestorage.app",
          databaseURL: "https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app",
        ),
      );
    }
  } catch (e) {
    print("Firebase init error: $e");
  }

  runApp(const LiquiditySweepApp());
}


// Widget ช่วยทำเอฟเฟกต์พิมพ์ดีดข้อความ
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration speed;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.speed = const Duration(milliseconds: 65),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = "";
  int _currentIndex = 0;
  bool _completed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      _displayedText = "";
      _currentIndex = 0;
      _completed = false;
      _startTyping();
    }
  }

  void _startTyping() {
    if (widget.text.isEmpty) return;
    _timer = Timer.periodic(widget.speed, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        setState(() {
          _completed = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
}


// ==========================================
// #3 โหมดเริ่มต้นแอพ (พร้อมโหลดเซสชันถาวรและป้องกันจอดำ)
// ==========================================

class LiquiditySweepApp extends StatelessWidget {
  const LiquiditySweepApp({super.key});

  Future<bool> _loadStoredSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      globalSavedLogin = prefs.getString('saved_mt5_login') ?? '';
      globalSavedServer = prefs.getString('saved_mt5_server') ?? '';
      globalUserPin = prefs.getString('saved_user_pin') ?? '';
    } catch (e) {
      print("Shared Preferences read error: $e");
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🎯SNIPER HYBRID🎯',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF37474F),
        cardColor: const Color(0xFF455A64),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFECEFF1),
          secondary: Color(0xFFCFD8DC),
        ),
      ),
      home: FutureBuilder<bool>(
        future: _loadStoredSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return globalSavedLogin.isNotEmpty ? const PinAuthWrapper() : const MT5LoginWrapper();
          }
          return Scaffold(
            body: Container(
              color: const Color(0xFF37474F),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFCFD8DC)),
              ),
            ),
          );
        },
      ),
    );
  }
}


// ==========================================
// #4 MT5 LOGIN WRAPPER
// ==========================================

class MT5LoginWrapper extends StatefulWidget {
  const MT5LoginWrapper({super.key});

  @override
  State<MT5LoginWrapper> createState() => _MT5LoginWrapperState();
}

class _MT5LoginWrapperState extends State<MT5LoginWrapper> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _serverController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _serverController.dispose();
    super.dispose();
  }

  Future<void> _submitMT5Login() async {
    if (_isLoading) return;

    final login = _loginController.text.trim();
    final server = _serverController.text.trim().isEmpty
        ? 'ICMarketsSC-Demo'
        : _serverController.text.trim();

    if (login.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกเลขพอร์ต MT5 ให้ครบถ้วน'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final FirebaseApp app;

      if (Firebase.apps.isEmpty) {
        app = await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyBnKyMazopUyD1k-kcIXo3bFedWfHXN0JA',
            appId: '1:155532929563:android:49d8a1e0040dc87ce766be',
            messagingSenderId: '155532929563',
            projectId: 'liquidity-b8739',
            storageBucket: 'liquidity-b8739.firebasestorage.app',
            databaseURL:
                'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app',
          ),
        );
      } else {
        app = Firebase.app();
      }

      final database = FirebaseDatabase.instanceFor(
        app: app,
        databaseURL:
            'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app',
      );

      final snapshot = await database.ref('accounts/$login').get();

      if (!mounted) return;

      if (!snapshot.exists) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('ไม่พบบัญชีนี้ในระบบ กรุณาติดต่อผู้ดูแลระบบ'),
            ),
          );
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_mt5_login', login);
      await prefs.setString('saved_mt5_server', server);

      globalSavedLogin = login;
      globalSavedServer = server;

      if (!mounted) return;

      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PinAuthWrapper(),
        ),
      );
    } catch (e, stackTrace) {
  debugPrint('LOGIN ERROR: $e');
  debugPrintStack(stackTrace: stackTrace);

  if (!mounted) return;

  setState(() => _isLoading = false);

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('เข้าสู่ระบบไม่สำเร็จ: $e'),
        duration: const Duration(seconds: 8),
      ),
    );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/1792250396366.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF37474F)),
          ),
          Container(color: const Color(0xFF263238).withOpacity(0.70)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/1792250396366.jpg',
                        width: 160,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.smart_toy,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SNIPER HYBRID',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'ROBOT',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFECEFF1),
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _loginController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Account Login'),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Investor Password').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _serverController,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          _inputDecoration('Server (เช่น ICMarketsSC-Demo)'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitMT5Login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF546E7A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('VERIFY & CONNECT'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Powered By Algohost',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.white60),
      filled: true,
      fillColor: const Color(0xFF263238).withOpacity(0.75),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF90A4AE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFCFD8DC),
          width: 2,
        ),
      ),
    );
  }
}

// ==========================================
// #5 PIN AUTH WRAPPER
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
  bool isSaving = false;

  String firstEnteredPin = '';
  String currentPinInput = '';

  @override
  void initState() {
    super.initState();
    _checkPinExists();
  }

  Future<void> _checkPinExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPin = prefs.getString('saved_user_pin') ?? '';

      if (!mounted) return;

      setState(() {
        globalUserPin = savedPin;
        hasStoredPin = savedPin.isNotEmpty;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('PIN initialization error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('โหลดข้อมูล PIN ไม่สำเร็จ กรุณาลองเปิดแอปใหม่'),
        ),
      );
    }
  }

  Future<void> _saveNewPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString('saved_user_pin', pin);

    if (!saved) {
      throw Exception('Unable to save PIN');
    }

    globalUserPin = pin;
  }

  Future<void> _verifyPin(String pin) async {
    if (globalUserPin == pin) {
      if (!mounted) return;

      setState(() {
        isAuthorized = true;
        currentPinInput = '';
      });
    } else {
      if (!mounted) return;

      setState(() => currentPinInput = '');

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('รหัส PIN ไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง'),
          ),
        );
    }
  }

  Future<void> _onNumberTap(String number) async {
    if (isSaving || currentPinInput.length >= 6) return;

    final nextPin = currentPinInput + number;

    setState(() => currentPinInput = nextPin);

    if (nextPin.length < 6) return;

    if (hasStoredPin) {
      await _verifyPin(nextPin);
      return;
    }

    if (!isConfirming) {
      setState(() {
        firstEnteredPin = nextPin;
        currentPinInput = '';
        isConfirming = true;
      });
      return;
    }

    if (firstEnteredPin != nextPin) {
      setState(() {
        currentPinInput = '';
        firstEnteredPin = '';
        isConfirming = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('PIN ไม่ตรงกัน กรุณาตั้งค่าใหม่อีกครั้ง'),
          ),
        );
      return;
    }

    setState(() => isSaving = true);

    try {
      await _saveNewPin(nextPin);

      if (!mounted) return;

      setState(() {
        hasStoredPin = true;
        isAuthorized = true;
        currentPinInput = '';
        isSaving = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Save PIN error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        currentPinInput = '';
        firstEnteredPin = '';
        isConfirming = false;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึก PIN ไม่สำเร็จ กรุณาลองใหม่'),
        ),
      );
    }
  }

  void _onDeleteTap() {
    if (isSaving || currentPinInput.isEmpty) return;

    setState(() {
      currentPinInput =
          currentPinInput.substring(0, currentPinInput.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFCFD8DC),
          ),
        ),
      );
    }

    if (isAuthorized) {
      return const MainNavigationScreen();
    }

    final titleText = hasStoredPin
        ? 'กรุณากรอก PIN เพื่อเข้าใช้งานระบบ'
        : isConfirming
            ? 'ยืนยันรหัส PIN 6 หลักอีกครั้ง'
            : 'ตั้งค่ารหัส PIN 6 หลักความปลอดภัย';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/1792250396366.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF37474F)),
          ),
          Container(color: const Color(0xFF263238).withOpacity(0.70)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      color: Color(0xFFCFD8DC),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      titleText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        final filled = index < currentPinInput.length;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: filled
                                ? const Color(0xFFCFD8DC)
                                : Colors.transparent,
                            border: Border.all(
                              color: const Color(0xFFB0BEC5),
                              width: 2,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 30),
                    for (final row in [
                      ['1', '2', '3'],
                      ['4', '5', '6'],
                      ['7', '8', '9'],
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: row.map(_buildPinButton).toList(),
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
                    if (isSaving)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
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
          colors: [Color(0xFF90A4AE), Color(0xFF455A64)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: const Color(0xFFCFD8DC),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSaving
              ? null
              : () {
                  if (val == 'del') {
                    _onDeleteTap();
                  } else {
                    _onNumberTap(val);
                  }
                },
          customBorder: const CircleBorder(),
          child: Center(
            child: val == 'del'
                ? const Icon(
                    Icons.backspace_outlined,
                    color: Colors.white,
                  )
                : Text(
                    val,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}



// ==========================================
// #6 โหมดควบคุมแดชบอร์ด (MainNavigationScreen)
// ==========================================

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with TickerProviderStateMixin {
  int _currentIndex = 2;
  String currentLogin = "235305975"; 
  int unreadAlertsCount = 0;
  DatabaseReference? _alertsRef;
  DatabaseReference? _dbRef;
  DatabaseReference? _logsRef;
  DatabaseReference? _ordersRef;

  Offset _modalOffset = const Offset(16, 80);
  Offset _floatingBubbleOffset = const Offset(20, 250); 
  bool _isLiveStatusVisible = true;
  bool _isLargeLogsModalOpen = false;
  
  bool isRunning = false;
  bool isConnected = false;
  
  String symbol = "XAUUSD";
  String timeframe = "M1";
  double profit = 0.0;
  List<Map<String, dynamic>> _botLogs = [];
  List<Map<dynamic, dynamic>> activeOrders = [];

  final String _imageA = 'assets/images/1792250396366.jpg';
  final String _imageB = 'assets/images/1792250578954.jpg';
  bool _showMorphImage = false; 

  late final AnimationController _scannerController = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
  );

  late final AnimationController _bubbleBounceController = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> _bubbleBounceAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
    CurvedAnimation(parent: _bubbleBounceController, curve: Curves.easeInOut),
  );

  @override
  void initState() {
    super.initState();
    _loadSavedLogin().then((_) {
      _listenToActiveAccount();
      _listenToAlertsCount();
      _initFirebaseAndListen();
      _listenToLogs();
      _listenToConnectionStatus();
      _listenToOrdersForDialog();
    });

    _scannerController.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        if (mounted) {
          setState(() {
            _showMorphImage = !_showMorphImage;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _bubbleBounceController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLogin() async {
    if (globalSavedLogin.isNotEmpty && mounted) {
      setState(() {
        currentLogin = globalSavedLogin;
      });
    }
  }

  void _listenToActiveAccount() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      database.ref('status/login').onValue.listen((event) {
        final val = event.snapshot.value?.toString();
        if (val != null && val.isNotEmpty && mounted && val != currentLogin) {
          setState(() {
            currentLogin = val;
          });
          _listenToAlertsCount();
          _initFirebaseAndListen();
          _listenToLogs();
          _listenToOrdersForDialog();
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
      
      _alertsRef = database.ref('accounts/$currentLogin/alerts');
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

  void _initFirebaseAndListen() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      _dbRef = database.ref('accounts/$currentLogin/status');
      _dbRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            isRunning = data['is_running'] ?? false;
            profit = (data['profit'] ?? 0.0).toDouble();
            symbol = data['symbol']?.toString() ?? 'BTCUSD';
            timeframe = data['timeframe']?.toString() ?? 'M1';
          });
        }
      });
    } catch (e) {
      print("Database listen error: $e");
    }
  }

  void _listenToConnectionStatus() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      database.ref('.info/connected').onValue.listen((event) {
        final connected = event.snapshot.value as bool? ?? false;
        if (mounted) {
          setState(() {
            isConnected = connected;
          });
        }
      });
    } catch (e) {
      print("Connection listen error: $e");
    }
  }

  void _listenToLogs() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      _logsRef = database.ref('accounts/$currentLogin/logs');
      _logsRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (mounted) {
          List<Map<String, dynamic>> tempLogs = [];
          if (data is Map) {
            var sortedEntries = data.entries.toList()
              ..sort((a, b) => b.key.toString().compareTo(a.key.toString()));
            for (var entry in sortedEntries) {
              if (entry.value != null) {
                String rawMsg = entry.value.toString();
                String cleanMsg = rawMsg.replaceAll(RegExp(r'command\s*', caseSensitive: false), '');
                tempLogs.add({
                  'key': entry.key.toString(),
                  'message': cleanMsg,
                });
              }
            }
          } else if (data is List) {
            for (int i = data.length - 1; i >= 0; i--) {
              if (data[i] != null) {
                String rawMsg = data[i].toString();
                String cleanMsg = rawMsg.replaceAll(RegExp(r'command\s*', caseSensitive: false), '');
                tempLogs.add({
                  'key': i.toString(),
                  'message': cleanMsg,
                });
              }
            }
          }
          setState(() {
            _botLogs = tempLogs;
          });
        }
      });
    } catch (e) {
      print("Logs listen error: $e");
    }
  }

  void _listenToOrdersForDialog() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      _ordersRef = database.ref('accounts/$currentLogin/orders');
      _ordersRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (mounted) {
          List<Map<dynamic, dynamic>> newOrders = [];
          if (data is Map) {
            data.forEach((key, value) {
              if (value is Map) {
                newOrders.add(Map<dynamic, dynamic>.from(value));
              }
            });
          } else if (data is List) {
            for (var e in data) {
              if (e is Map) {
                newOrders.add(Map<dynamic, dynamic>.from(e));
              }
            }
          }
          setState(() {
            activeOrders = newOrders;
          });
        }
      });
    } catch (e) {
      print("Orders listen error: $e");
    }
  }

  void _clearLogItem(String key) async {
    try {
      if (_logsRef != null) {
        await _logsRef!.child(key).remove();
      }
    } catch (e) {
      print("Clear log item error: $e");
    }
  }

  void _clearAllLogs() async {
    try {
      if (_logsRef != null) {
        await _logsRef!.remove();
        if (mounted) {
          setState(() {
            _botLogs.clear();
          });
        }
      }
    } catch (e) {
      print("Clear all logs error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const SettingsScreen(),
      OrdersScreen(accountLogin: currentLogin),
      HomeScreen(accountLogin: currentLogin),
      HistoryScreen(accountLogin: currentLogin),
      AlertsScreen(accountLogin: currentLogin, onAlertsRead: () {
        setState(() {
          unreadAlertsCount = 0;
        });
      }),
    ];

    double totalOrdersProfit = activeOrders.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item['profit']?.toString() ?? '0.0') ?? 0.0);
    });
    double totalLots = activeOrders.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item['lot']?.toString() ?? '0.0') ?? 0.0);
    });
    bool isTotalProfit = totalOrdersProfit >= 0;

    return Scaffold(
      backgroundColor: const Color(0xFF37474F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 65.0),
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
          
          if (_isLargeLogsModalOpen)
            Positioned(
              left: _modalOffset.dx,
              top: _modalOffset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _modalOffset += details.delta;
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.92,
                  height: MediaQuery.of(context).size.height * 0.72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFCFD8DC), width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCFD8DC).withOpacity(0.7),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                    color: const Color(0xFF37474F),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.terminal, color: Color(0xFFCFD8DC), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'STATUS & LOGS',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _isLiveStatusVisible ? Icons.visibility : Icons.visibility_off,
                                    color: _isLiveStatusVisible ? const Color(0xFF00E676) : Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isLiveStatusVisible = !_isLiveStatusVisible;
                                    });
                                  },
                                  tooltip: _isLiveStatusVisible ? 'Hide Live Status' : 'Show Live Status',
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                ),
                                if (_botLogs.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.delete_sweep, color: Color(0xFFCFD8DC), size: 20),
                                    onPressed: _clearAllLogs,
                                    tooltip: 'Clear All Logs',
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _isLargeLogsModalOpen = false;
                                    });
                                  },
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFFCFD8DC), height: 1, thickness: 1.5),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isLiveStatusVisible) ...[
                                _buildStatusReportBox(symbol, timeframe, totalOrdersProfit, activeOrders.length, totalLots, isTotalProfit),
                                const SizedBox(height: 12),
                              ],
                              const Row(
                                children: [
                                  Icon(Icons.show_chart, color: Color(0xFFCFD8DC), size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'ACTIVITY LOGS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_botLogs.isEmpty)
                                const Expanded(
                                  child: Center(
                                    child: Text('No log records...', style: TextStyle(color: Color(0xFFB0BEC5), fontFamily: 'monospace')),
                                  ),
                                )
                              else
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _botLogs.length,
                                    itemBuilder: (context, index) {
                                      var log = _botLogs[index];
                                      bool isLatest = (index == 0);

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: isLatest
                                                  ? Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const Text(
                                                          '➔ ',
                                                          style: TextStyle(
                                                            color: Color(0xFF00E676),
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                            shadows: [
                                                              Shadow(color: Color(0xFF00E676), blurRadius: 8),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: TypewriterText(
                                                            text: "${log['message']}",
                                                            speed: const Duration(milliseconds: 65),
                                                            style: const TextStyle(
                                                              color: Color(0xFF00E676),
                                                              fontFamily: 'monospace',
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.bold,
                                                              height: 1.4,
                                                              shadows: [
                                                                Shadow(color: Color(0xFF00E676), blurRadius: 10, offset: Offset(0, 0)),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Text(
                                                      "> ${log['message']}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: 'monospace',
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                            ),
                                            GestureDetector(
                                              onTap: () => _clearLogItem(log['key']),
                                              child: const Padding(
                                                padding: EdgeInsets.only(left: 8.0),
                                                child: Icon(Icons.delete_outline, color: Color(0xFFCFD8DC), size: 15),
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
                    ],
                  ),
                ),
              ),
            ),

          AnimatedBuilder(
            animation: _bubbleBounceAnimation,
            builder: (context, child) {
              return Positioned(
                left: _floatingBubbleOffset.dx,
                top: _floatingBubbleOffset.dy + _bubbleBounceAnimation.value,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      _floatingBubbleOffset += details.delta;
                    });
                  },
                  onTap: () {
                    setState(() {
                      _isLargeLogsModalOpen = !_isLargeLogsModalOpen;
                    });
                  },
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFCFD8DC), Color(0xFF78909C)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFCFD8DC).withOpacity(0.8),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Image.asset(
                              _imageA,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.smart_toy, color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isConnected ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: (isConnected ? const Color(0xFF00E676) : const Color(0xFFFF5252)).withOpacity(0.8),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF455A64),
                  border: Border(
                    top: BorderSide(color: const Color(0xFFCFD8DC).withOpacity(0.8), width: 1.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCustomNavItem(0, Icons.tune, 'Settings'),
                    _buildCustomNavItem(1, Icons.list_alt, 'Orders'),
                    _buildCustomNavItem(2, Icons.home_filled, 'Home'),
                    _buildCustomNavItem(3, Icons.history, 'History'),
                    _buildCustomNavItem(
                      4, 
                      Icons.notifications_active, 
                      'Alerts', 
                      badgeCount: unreadAlertsCount,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusReportBox(String symbol, String tf, double totalOrdersProfit, int orderCount, double totalLots, bool isTotalProfit) {
    bool isServerActive = isConnected && isRunning;
    String baseImage = _showMorphImage ? _imageA : _imageB;
    String morphImage = _showMorphImage ? _imageB : _imageA;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF455A64),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFCFD8DC),
          width: 2.0,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Colors.black,
                  child: AnimatedBuilder(
                    animation: _scannerAnimation,
                    builder: (context, child) {
                      double scanValue = _scannerAnimation.value * 150;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            baseImage,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: 150,
                          ),
                          ClipRect(
                            clipper: ScannerClipper(scanValue),
                            child: Image.asset(
                              morphImage,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              width: double.infinity,
                              height: 150,
                            ),
                          ),
                          Positioned(
                            top: scanValue - 2,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              decoration: const BoxDecoration(
                                color: Color(0xFFCFD8DC),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LIVE STATUS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isServerActive ? const Color(0xFF00C853) : const Color(0xFF90A4AE),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isServerActive ? const Color(0xFF00C853) : const Color(0xFF90A4AE)).withOpacity(0.8),
                                blurRadius: 4,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isServerActive ? 'EA SERVER ONLINE & RUNNING' : 'EA SERVER OFFLINE / STOPPED',
                          style: TextStyle(
                            color: isServerActive ? const Color(0xFF00C853) : const Color(0xFFCFD8DC),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.white24, height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Active Orders: $orderCount', style: const TextStyle(color: Color(0xFFCFD8DC), fontSize: 10, fontWeight: FontWeight.bold)),
                        Text('Lots: ${totalLots.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        Text(
                          'P/L: ${isTotalProfit ? "+" : ""}\$${totalOrdersProfit.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: isTotalProfit ? const Color(0xFF00C853) : const Color(0xFFFF5252),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isLiveStatusVisible = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCFD8DC), width: 1.5),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomNavItem(int index, IconData icon, String label, {int badgeCount = 0}) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          if (index == 4) {
            unreadAlertsCount = 0;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF607D8B) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFFCFD8DC) : Colors.transparent,
            width: isSelected ? 1.5 : 0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFCFD8DC).withOpacity(0.8),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white70,
                  size: 22,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
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
                        '$badgeCount',
                        style: const TextStyle(
                          color: Color(0xFF37474F),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerClipper extends CustomClipper<Rect> {
  final double scanValue;
  ScannerClipper(this.scanValue);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width, scanValue);
  }

  @override
  bool shouldReclip(covariant ScannerClipper oldClipper) {
    return oldClipper.scanValue != scanValue;
  }
}


// ==========================================
// #7 โหมด HomeScreen
// ==========================================

class HomeScreen extends StatefulWidget {
  final String accountLogin;
  const HomeScreen({super.key, required this.accountLogin});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isRunning = false;
  DatabaseReference? _dbRef;
  
  double balance = 0.0;
  double equity = 0.0;
  double profit = 0.0;
  String symbol = "XAUUSD";
  String timeframe = "M1";

  int cycleWins = 0;
  int cycleLosses = 0;
  double cycleWinRate = 0.0;

  List<Map<dynamic, dynamic>> activeOrders = [];
  DatabaseReference? _ordersRef;

  List<Map<dynamic, dynamic>> _historyTrades = [];
  DatabaseReference? _historyRef;

  bool isConnected = false;

  late final AnimationController _scannerController = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);

  double realTimeBid = 0.0;
  double realTimeAsk = 0.0;

  bool _isChartModalOpen = false;

  @override
  void initState() {
    super.initState();
    _initFirebaseAndListen(widget.accountLogin);
    _listenToOrdersForDialog(widget.accountLogin);
    _listenToConnectionStatus();
    _listenToHistoryForStats(widget.accountLogin);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountLogin != widget.accountLogin) {
      _initFirebaseAndListen(widget.accountLogin);
      _listenToOrdersForDialog(widget.accountLogin);
      _listenToHistoryForStats(widget.accountLogin);
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _listenToConnectionStatus() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      database.ref('.info/connected').onValue.listen((event) {
        final connected = event.snapshot.value as bool? ?? false;
        if (mounted) {
          setState(() {
            isConnected = connected;
          });
        }
      });
    } catch (e) {
      print("Connection listen error: $e");
    }
  }

  void _initFirebaseAndListen(String login) {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      _dbRef = database.ref('accounts/$login/status');
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
            
            if (data['bid'] != null) {
              realTimeBid = double.tryParse(data['bid'].toString()) ?? realTimeBid;
            }
            if (data['ask'] != null) {
              realTimeAsk = double.tryParse(data['ask'].toString()) ?? realTimeAsk;
            }

            cycleWins = int.tryParse(data['cycle_wins']?.toString() ?? '0') ?? 0;
            cycleLosses = int.tryParse(data['cycle_losses']?.toString() ?? '0') ?? 0;
            cycleWinRate = (data['cycle_win_rate'] ?? 0.0).toDouble();
          });
        }
      });
    } catch (e) {
      print("Database listen error: $e");
    }
  }

  void _listenToHistoryForStats(String login) {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      _historyRef = database.ref('accounts/$login/history');
      _historyRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (mounted) {
          List<Map<dynamic, dynamic>> tempHistory = [];
          if (data is Map) {
            data.forEach((key, value) {
              if (value is Map) {
                tempHistory.add(Map<dynamic, dynamic>.from(value));
              } else if (value is List) {
                for (var item in value) {
                  if (item is Map) {
                    tempHistory.add(Map<dynamic, dynamic>.from(item));
                  }
                }
              }
            });
          } else if (data is List) {
            for (var e in data) {
              if (e is Map) {
                tempHistory.add(Map<dynamic, dynamic>.from(e));
              }
            }
          }
          setState(() {
            _historyTrades = tempHistory;
          });
        }
      });
    } catch (e) {
      print("History stats listen error: $e");
    }
  }

  void _listenToOrdersForDialog(String login) {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      _ordersRef = database.ref('accounts/$login/orders');
      _ordersRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (mounted) {
          List<Map<dynamic, dynamic>> newOrders = [];
          if (data is Map) {
            data.forEach((key, value) {
              if (value is Map) {
                newOrders.add(Map<dynamic, dynamic>.from(value));
              }
            });
          } else if (data is List) {
            for (var e in data) {
              if (e is Map) {
                newOrders.add(Map<dynamic, dynamic>.from(e));
              }
            }
          }
          setState(() {
            activeOrders = newOrders;
          });
        }
      });
    } catch (e) {
      print("Orders listen error: $e");
    }
  }

  void _toggleBotStatus(bool status) {
    try {
      _dbRef?.update({
        'is_running': status,
        'command_timestamp': DateTime.now().millisecondsSinceEpoch,
      });
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
        const SnackBar(content: Text('Sent Close All Command to EA!'), backgroundColor: Color(0xFF78909C)),
      );
    } catch (e) {
      print("Close all error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: const Color(0xFF37474F)),
          Image.asset(
            'assets/images/1792250396366.jpg',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.28),
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF37474F));
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF263238).withOpacity(0.8), const Color(0xFF455A64).withOpacity(0.4), const Color(0xFF37474F).withOpacity(0.85)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFCFD8DC).withOpacity(0.8),
                              blurRadius: 22,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/1792250396366.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(color: const Color(0xFF37474F));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF455A64).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFCFD8DC), width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFCFD8DC).withOpacity(0.8),
                            blurRadius: 12.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: const [
                          FlashingSniperText(),
                          SizedBox(height: 4),
                          Text(
                            'HYBRID ROBOT',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2.5,
                              shadows: [
                                Shadow(color: Color(0xFFCFD8DC), blurRadius: 10, offset: Offset(0, 0)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFCFD8DC), width: 1.5),
                        color: const Color(0xFF37474F).withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(color: Colors.white.withOpacity(0.25), blurRadius: 6),
                        ],
                      ),
                      child: const Text(
                        'Powered By Algohost',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircularButton(
                          label: 'CLOSE',
                          icon: Icons.delete_outline,
                          colors: const [Color(0xFF78909C), Color(0xFF37474F)],
                          borderColor: const Color(0xFFCFD8DC),
                          onPressed: _closeAllOrders,
                        ),
                        const SizedBox(width: 20),                        
                        _buildCircularButton(
                          label: isRunning ? 'STOP' : 'START',
                          icon: isRunning ? Icons.stop : Icons.play_arrow,
                          colors: isRunning 
                              ? const [Color(0xFF00E676), Color(0xFF00C853), Color(0xFF2E7D32)] 
                              : const [Color(0xFFB0BEC5), Color(0xFF607D8B), Color(0xFF37474F)], 
                          borderColor: isRunning ? const Color(0xFF00E676) : const Color(0xFFCFD8DC),
                          glowColor: isRunning ? const Color(0xFF00E676) : const Color(0xFFCFD8DC),
                          onPressed: () => _toggleBotStatus(!isRunning),
                          isLarge: true,
                        ),

                        const SizedBox(width: 18),
                        _buildCircularButton(
                          label: 'STATS', 
                          icon: Icons.bar_chart,
                          colors: const [Color(0xFF78909C), Color(0xFF37474F)],
                          borderColor: const Color(0xFFCFD8DC),
                          onPressed: () {
                            setState(() {
                              _isChartModalOpen = true;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildBidAskBoxContent(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          if (_isChartModalOpen)
            Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isChartModalOpen = false;
                    });
                  },
                  child: Container(color: Colors.black54),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.92,
                    height: MediaQuery.of(context).size.height * 0.62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCFD8DC), width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCFD8DC).withOpacity(0.9),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                      color: const Color(0xFF37474F),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.dashboard_outlined, color: Color(0xFFCFD8DC), size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'DASHBOARD STATS',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _isChartModalOpen = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Color(0xFFCFD8DC), height: 1, thickness: 2),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: _buildDashboardStatsContent(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDashboardStatsContent() {
    double totalProfitLoss = 0.0;
    double maxProfit = 0.0;
    double maxLoss = 0.0;

    for (var trade in _historyTrades) {
      double p = double.tryParse(trade['profit']?.toString() ?? '0.0') ?? 0.0;
      totalProfitLoss += p;
      if (p > 0) {
        if (p > maxProfit) maxProfit = p;
      } else if (p < 0) {
        if (p < maxLoss) maxLoss = p;
      }
    }

    int displayWins = cycleWins;
    int displayLosses = cycleLosses;
    int totalCycles = displayWins + displayLosses;
    double displayWinRate = totalCycles > 0 ? (displayWins / totalCycles) * 100 : cycleWinRate;
    double lossRate = 100.0 - displayWinRate;

    double peak = balance > 0 ? balance : 1000.0;
    double maxDDAmount = 0.0;
    for (var trade in _historyTrades) {
      double p = double.tryParse(trade['profit']?.toString() ?? '0.0') ?? 0.0;
      peak += p;
      double currentDD = peak > 0 ? (maxLoss.abs() / peak) * 100 : 0.0;
      if (currentDD > maxDDAmount) {
        maxDDAmount = currentDD;
      }
    }
    if (maxDDAmount == 0 && displayLosses > 0) {
      maxDDAmount = (maxLoss.abs() / (balance > 0 ? balance : 1000.0)) * 100;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'WIN RATE',
                  value: '${displayWinRate.toStringAsFixed(1)}%',
                  subText: '$displayWins Win / $displayLosses Loss',
                  color: const Color(0xFF00C853),
                  icon: Icons.pie_chart,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: 'MAX DRAWDOWN',
                  value: '${maxDDAmount.toStringAsFixed(2)}%',
                  subText: 'Max Loss: \$${maxLoss.toStringAsFixed(2)}',
                  color: const Color(0xFFFF5252),
                  icon: Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'TOTAL CYCLES',
                  value: '$totalCycles',
                  subText: '',
                  color: const Color(0xFFCFD8DC),
                  icon: Icons.receipt_long,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: 'NET PROFIT',
                  value: '${totalProfitLoss >= 0 ? "+" : ""}\$${totalProfitLoss.toStringAsFixed(2)}',
                  subText: 'Balance: \$${balance.toStringAsFixed(2)}',
                  color: totalProfitLoss >= 0 ? const Color(0xFF00C853) : const Color(0xFFFF5252),
                  icon: Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF455A64),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCFD8DC), width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCFD8DC).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'WIN RATE & CYCLES',
                  style: TextStyle(
                    color: const Color(0xFFCFD8DC),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(color: Colors.white.withOpacity(0.8), blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF263238),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCFD8DC).withOpacity(0.5), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'WIN RATE PERCENT',
                          style: TextStyle(
                            color: Color(0xFFCFD8DC),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GREEN NEON',
                                style: TextStyle(color: Color(0xFF00C853), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                              ),
                              Text(
                                'WIN RATE: ${displayWinRate.toStringAsFixed(1)}%',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'SILVER METALLIC',
                                style: TextStyle(color: Color(0xFFCFD8DC), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                              ),
                              Text(
                                'LOSS RATE: ${lossRate.toStringAsFixed(1)}%',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 14,
                          width: double.infinity,
                          color: const Color(0xFF90A4AE).withOpacity(0.4),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (displayWinRate / 100).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF00C853),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00C853).withOpacity(0.9),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFCFD8DC).withOpacity(0.6), width: 1.2),
                          color: const Color(0xFF37474F).withOpacity(0.7),
                        ),
                        child: Center(
                          child: Text(
                            'Based on $displayWins Win / $displayLosses Loss Cycles',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildStatCard({required String title, required String value, required String subText, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF455A64),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFFCFD8DC), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              value, 
              style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 2),
          Text(subText, style: const TextStyle(color: Colors.white70, fontSize: 9, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildBidAskBoxContent(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double boxWidth = screenWidth - 32;
    double spreadVal = (realTimeAsk > 0 && realTimeBid > 0) ? (realTimeAsk - realTimeBid) * 100 : 0.0;

    return Container(
      width: boxWidth,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFECEFF1), Color(0xFFCFD8DC), Color(0xFF78909C), Color(0xFF455A64)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCFD8DC).withOpacity(0.6),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF37474F),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.show_chart, color: Color(0xFFCFD8DC), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      symbol,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF263238),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCFD8DC).withOpacity(0.5)),
                  ),
                  child: Text(
                    'Spread: ${spreadVal > 0 ? spreadVal.toStringAsFixed(1) : "0.0"}',
                    style: const TextStyle(color: Color(0xFFCFD8DC), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('BID', style: TextStyle(color: Color(0xFFCFD8DC), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    const SizedBox(height: 6),
                    Text(
                      realTimeBid > 0 ? realTimeBid.toStringAsFixed(2) : 'Loading...',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'monospace', fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                Container(height: 35, width: 1, color: Colors.white24),
                Column(
                  children: [
                    const Text('ASK', style: TextStyle(color: Color(0xFF00C853), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    const SizedBox(height: 6),
                    Text(
                      realTimeAsk > 0 ? realTimeAsk.toStringAsFixed(2) : 'Loading...',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'monospace', fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required String label,
    required IconData icon,
    required Object colors,
    required Color borderColor,
    Color? glowColor,
    required VoidCallback onPressed,
    bool isLarge = false,
  }) {
    List<Color> colorList = colors is List<Color> ? colors : [const Color(0xFF78909C), const Color(0xFF37474F)];
    double size = isLarge ? 82 : 70;
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: colorList,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: borderColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: (glowColor ?? borderColor).withOpacity(0.8),
                  blurRadius: 14,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: isLarge ? 34 : 28),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class FlashingSniperText extends StatefulWidget {
  const FlashingSniperText({super.key});

  @override
  State<FlashingSniperText> createState() => _FlashingSniperTextState();
}

class _FlashingSniperTextState extends State<FlashingSniperText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double val = _animation.value;
        return Opacity(
          opacity: val,
          child: Text(
            '🎯 S N I P E R 🎯',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3.0,
              shadows: [
                Shadow(
                  color: const Color(0xFFCFD8DC).withOpacity(val),
                  blurRadius: 20 * val,
                  offset: const Offset(0, 0),
                ),
                Shadow(
                  color: const Color(0xFFB0BEC5).withOpacity(val),
                  blurRadius: 10 * val,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


// ==========================================
// #8 โหมดรายงานออเดอร์ (OrdersScreen)
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
  String accountServer = 'ICMarketsSC-Demo';

  double balance = 0.0;
  double equity = 0.0;
  double margin = 0.0;
  double freeMargin = 0.0;
  double profitLoss = 0.0;

  @override
  void initState() {
    super.initState();
    _listenToOrders(widget.accountLogin);
    _listenToStatusForSymbol(widget.accountLogin);
  }

  @override
  void didUpdateWidget(covariant OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountLogin != widget.accountLogin) {
      _listenToOrders(widget.accountLogin);
      _listenToStatusForSymbol(widget.accountLogin);
    }
  }

  void _listenToStatusForSymbol(String login) {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      _dbRef = database.ref('accounts/$login/status');
      _dbRef?.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            activeSymbol = data['symbol']?.toString() ?? 'BTCUSD';
            activeTimeframe = data['timeframe']?.toString() ?? 'M1';
            accountServer = data['server']?.toString() ?? 'ICMarketsSC-Demo';
            
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

  void _listenToOrders(String login) {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      _ordersRef = database.ref('accounts/$login/orders');
      _ordersRef?.onValue.listen((event) {
        final data = event.snapshot.value;
        if (mounted) {
          _parseOrdersData(data);
        }
      });
    } catch (e) {
      print("Orders listen error: $e");
    }
  }

  void _parseOrdersData(Object? data) {
    List<Map<dynamic, dynamic>> newOrders = [];
    if (data is Map) {
      data.forEach((key, value) {
        if (value is Map) {
          newOrders.add(Map<dynamic, dynamic>.from(value));
        }
      });
    } else if (data is List) {
      for (var e in data) {
        if (e is Map) {
          newOrders.add(Map<dynamic, dynamic>.from(e));
        }
      }
    }
    setState(() {
      activeOrders = newOrders;
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalOrdersProfit = activeOrders.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item['profit']?.toString() ?? '0.0') ?? 0.0);
    });
    bool isTotalProfit = totalOrdersProfit >= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders & Portfolio', style: TextStyle(fontFamily: 'monospace')),
        backgroundColor: const Color(0xFF37474F),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/1792250396366.jpg',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.25),
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF37474F));
            },
          ),
          Container(
            color: const Color(0xFF263238).withOpacity(0.75),
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
                      colors: [Color(0xFF90A4AE), Color(0xFF455A64), Color(0xFF37474F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFCFD8DC),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCFD8DC).withOpacity(0.8),
                        blurRadius: 15,
                        spreadRadius: 2,
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
                              Icon(Icons.account_balance, color: Color(0xFFCFD8DC), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'TRADING ACCOUNT INFO',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFCFD8DC), width: 1),
                            ),
                            child: Text(
                              activeSymbol,
                              style: const TextStyle(color: Color(0xFFCFD8DC), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
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
                              const Text('Account Login', style: TextStyle(color: Color(0xFFCFD8DC), fontSize: 11, fontFamily: 'monospace')),
                              const SizedBox(height: 2),
                              Text(
                                widget.accountLogin,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Server', style: TextStyle(color: Color(0xFFCFD8DC), fontSize: 11, fontFamily: 'monospace')),
                              const SizedBox(height: 2),
                              Text(
                                accountServer,
                                style: const TextStyle(color: Color(0xFFCFD8DC), fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFCFD8DC),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCFD8DC).withOpacity(0.7),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: const Color(0xFF37474F).withOpacity(0.95),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
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
                                    ? [const Color(0xFF00C853).withOpacity(0.3), const Color(0xFF455A64)]
                                    : [const Color(0xFF78909C).withOpacity(0.4), const Color(0xFF455A64)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isTotalProfit ? const Color(0xFF00C853).withOpacity(0.8) : const Color(0xFFCFD8DC).withOpacity(0.8),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TOTAL OPEN PROFIT',
                                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, fontFamily: 'monospace'),
                                ),
                                Text(
                                  '${isTotalProfit ? "+" : ""}\$${totalOrdersProfit.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: isTotalProfit ? const Color(0xFF00C853) : const Color(0xFFFF5252),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                              child: Text(
                                'ACTIVE ORDERS (${activeOrders.length})',
                                style: const TextStyle(color: Color(0xFFCFD8DC), fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1, fontFamily: 'monospace'),
                              ),
                            ),
                          ),
                          activeOrders.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40.0),
                                  child: Center(
                                    child: Text('No active orders currently', style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 13, fontFamily: 'monospace')),
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
                                    final double priceOpen = double.tryParse(order['price']?.toString() ?? '0.0') ?? 0.0;
                                    final String symbol = order['symbol']?.toString() ?? activeSymbol;
                                    bool isBuy = type.toUpperCase().contains('BUY');
                                    bool orderProfit = profit >= 0;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF455A64),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isBuy ? const Color(0xFF00C853).withOpacity(0.6) : const Color(0xFFCFD8DC).withOpacity(0.6),
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
                                                  color: isBuy ? const Color(0xFF00C853).withOpacity(0.2) : const Color(0xFF78909C).withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  type,
                                                  style: TextStyle(color: isBuy ? const Color(0xFF00C853) : const Color(0xFFCFD8DC), fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
                                                  const SizedBox(height: 2),
                                                  Text('Lot: $lot | Open: ${priceOpen.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFCFD8DC), fontSize: 10, fontFamily: 'monospace')),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${orderProfit ? "+" : ""}\$${profit.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: orderProfit ? const Color(0xFF00C853) : const Color(0xFFFF5252),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              fontFamily: 'monospace',
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
                  ),
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF455A64),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCFD8DC).withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFCFD8DC), size: 14),
              const SizedBox(width: 4),
              Text(title, style: const TextStyle(color: Color(0xFFCFD8DC), fontSize: 11, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


// ==========================================
// #9 โหมดการบันทึกประจำวัน (HistoryScreen)
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

      _historyRef = database.ref('accounts/$login/history');

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
      if (timeStr.isEmpty) return false;

      String formattedTime = timeStr.replaceAll('.', '-').replaceAll('/', '-');
      DateTime? tradeDate;

      try {
        List<String> parts = formattedTime.split(' ')[0].split('-');
        if (parts.length == 3) {
          int? p1 = int.tryParse(parts[0]);
          int? p2 = int.tryParse(parts[1]);
          int? p3 = int.tryParse(parts[2]);

          if (p1 != null && p2 != null && p3 != null) {
            if (p1 > 1000) {
              tradeDate = DateTime(p1, p2, p3);
            } else {
              int year = p3;
              if (year < 100) year += 2000;
              tradeDate = DateTime(year, p2, p1);
            }
          }
        }
      } catch (e) {
        tradeDate = null;
      }

      tradeDate ??= DateTime.tryParse(formattedTime);
      if (tradeDate == null && formattedTime.length >= 10) {
        tradeDate = DateTime.tryParse(formattedTime.substring(0, 10));
      }

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

  String _formatDisplayDate(String rawDate) {
    if (rawDate.isEmpty) return '';
    try {
      List<String> spaceSplit = rawDate.split(' ');
      String datePart = spaceSplit[0];
      String timePart = spaceSplit.length > 1 ? ' ${spaceSplit[1]}' : '';

      String cleanDate = datePart.replaceAll('.', '-').replaceAll('/', '-');
      List<String> parts = cleanDate.split('-');
      
      if (parts.length == 3) {
        int? p1 = int.tryParse(parts[0]);
        int? p2 = int.tryParse(parts[1]);
        int? p3 = int.tryParse(parts[2]);

        if (p1 != null && p2 != null && p3 != null) {
          String day, month, year;
          if (p1 > 1000) {
            year = p1.toString();
            month = p2.toString().padLeft(2, '0');
            day = p3.toString();
          } else {
            day = p1.toString();
            month = p2.toString().padLeft(2, '0');
            year = p3 < 100 ? '${2000 + p3}' : p3.toString();
          }
          return '$day.$month.$year$timePart';
        }
      }
    } catch (e) {}
    return rawDate;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<dynamic, dynamic>> filteredHistory = _getFilteredHistory();

    double totalProfit = filteredHistory.fold(0.0, (sum, item) {
      return sum + (double.tryParse(item['profit']?.toString() ?? '0.0') ?? 0.0);
    });

    return Scaffold(
      backgroundColor: const Color(0xFF37474F),
      appBar: AppBar(
        title: const Text('History', style: TextStyle(fontFamily: 'monospace')),
        backgroundColor: const Color(0xFF37474F),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/1792250396366.jpg',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.2),
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF37474F));
            },
          ),
          Container(
            color: const Color(0xFF263238).withOpacity(0.8),
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
                        label: Text(filter, style: const TextStyle(fontFamily: 'monospace')),
                        selected: isSelected,
                        selectedColor: const Color(0xFF78909C),
                        backgroundColor: const Color(0xFF455A64),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: 'monospace',
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF90A4AE), Color(0xFF455A64), Color(0xFF37474F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFCFD8DC),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFCFD8DC).withOpacity(0.8),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Realized P/L ($selectedFilter)',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${totalProfit >= 0 ? "+" : ""}\$${totalProfit.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: totalProfit >= 0 ? const Color(0xFF00C853) : const Color(0xFFFF5252),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF37474F),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFCFD8DC),
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCFD8DC).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: filteredHistory.isEmpty
                        ? const Center(
                            child: Text('No closed trade history for this account', style: TextStyle(color: Color(0xFFB0BEC5), fontFamily: 'monospace')),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: filteredHistory.length,
                            itemBuilder: (context, index) {
                              final trade = filteredHistory[index];
                              final String type = trade['type']?.toString() ?? 'BUY';
                              final String symbol = trade['symbol']?.toString() ?? 'BTCUSD';
                              final double lot = double.tryParse(trade['lot']?.toString() ?? '0.01') ?? 0.01;
                              final double priceOpen = double.tryParse(trade['price_open']?.toString() ?? '0.0') ?? 0.0;
                              final double priceClose = double.tryParse(trade['price_close']?.toString() ?? '0.0') ?? 0.0;
                              final double profit = double.tryParse(trade['profit']?.toString() ?? '0.0') ?? 0.0;
                              
                              final String rawCloseTime = trade['close_time']?.toString() ?? trade['time']?.toString() ?? '';
                              final String closeTime = _formatDisplayDate(rawCloseTime);

                              bool isBuy = type.toUpperCase().contains('BUY');
                              bool isProfit = profit >= 0;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF455A64),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFCFD8DC).withOpacity(0.5),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isBuy ? const Color(0xFF00C853).withOpacity(0.2) : const Color(0xFF78909C).withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            type,
                                            style: TextStyle(color: isBuy ? const Color(0xFF00C853) : const Color(0xFFCFD8DC), fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('$symbol, lot: $lot', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
                                            const SizedBox(height: 3),
                                            Text(
                                              '${priceOpen.toStringAsFixed(2)} -> ${priceClose.toStringAsFixed(2)}',
                                              style: const TextStyle(color: Color(0xFFCFD8DC), fontSize: 11, fontFamily: 'monospace'),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(closeTime, style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 10, fontFamily: 'monospace')),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${isProfit ? "+" : ""}\$${profit.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: isProfit ? const Color(0xFF00C853) : const Color(0xFFFF5252),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
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
// #10 โหมดการแจ้งเตือนข้อความ (AlertsScreen)
// ==========================================

class AlertsScreen extends StatefulWidget {
  final String accountLogin;
  final VoidCallback onAlertsRead;
  const AlertsScreen({super.key, required this.accountLogin, required this.onAlertsRead});

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
    _listenToAlerts(widget.accountLogin);
  }

  @override
  void didUpdateWidget(covariant AlertsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountLogin != widget.accountLogin) {
      _listenToAlerts(widget.accountLogin);
    }
  }

  DateTime? _extractDateTime(String message) {
    try {
      final regExp = RegExp(r'\[(\d{2})\.(\d{2})\.(\d{4})\s+(\d{2}):(\d{2}):(\d{2})\]');
      final match = regExp.firstMatch(message);
      if (match != null) {
        int day = int.parse(match.group(1)!);
        int month = int.parse(match.group(2)!);
        int year = int.parse(match.group(3)!);
        int hour = int.parse(match.group(4)!);
        int minute = int.parse(match.group(5)!);
        int second = int.parse(match.group(6)!);
        return DateTime(year, month, day, hour, minute, second);
      }
    } catch (e) {}
    return null;
  }

  bool _isAllowedAlert(String upperMsg) {
    bool isFirstOrder = upperMsg.contains('SMART BUY') || upperMsg.contains('SMART SELL') || upperMsg.contains('FIRST') || (upperMsg.contains('OPEN') && !upperMsg.contains('RECOVERY'));
    bool isRecovery = upperMsg.contains('RECOVERY');
    bool isProfitClose = upperMsg.contains('PROFIT') || upperMsg.contains('TP') || upperMsg.contains('CLOSE WIN');
    bool isLossClose = upperMsg.contains('LOSS') && !upperMsg.contains('DAILY LOSS');
    bool isDailyTarget = upperMsg.contains('DAILY TARGET') || upperMsg.contains('TARGET REACHED');
    bool isDailyLoss = upperMsg.contains('DAILY LOSS') || upperMsg.contains('MAX LOSS');
    bool isCloseTime = upperMsg.contains('TIME') || upperMsg.contains('EXCEED') || upperMsg.contains('SESSION');

    return isFirstOrder || isRecovery || isProfitClose || isLossClose || isDailyTarget || isDailyLoss || isCloseTime;
  }

  void _listenToAlerts(String login) {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      _alertsRef = database.ref('accounts/$login/alerts');

      _alertsRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (mounted) {
          setState(() {
            List<Map<String, dynamic>> tempList = [];
            if (data is Map) {
              data.forEach((key, value) {
                if (value != null) {
                  String rawMsg = value.toString();
                  String cleanMsg = rawMsg.replaceAll(RegExp(r'command\s*', caseSensitive: false), '');
                  String upperMsg = cleanMsg.toUpperCase();
                  
                  if (_isAllowedAlert(upperMsg)) {
                    tempList.add({
                      'key': key.toString(),
                      'message': cleanMsg,
                      'time': _extractDateTime(cleanMsg),
                    });
                  }
                }
              });
            } else if (data is List) {
              for (int i = 0; i < data.length; i++) {
                if (data[i] != null) {
                  String rawMsg = data[i].toString();
                  String cleanMsg = rawMsg.replaceAll(RegExp(r'command\s*', caseSensitive: false), '');
                  String upperMsg = cleanMsg.toUpperCase();
                  
                  if (_isAllowedAlert(upperMsg)) {
                    tempList.add({
                      'key': i.toString(),
                      'message': cleanMsg,
                      'time': _extractDateTime(cleanMsg),
                    });
                  }
                }
              }
            }

            tempList.sort((a, b) {
              DateTime? timeA = a['time'];
              DateTime? timeB = b['time'];
              if (timeA == null && timeB == null) return 0;
              if (timeA == null) return 1;
              if (timeB == null) return -1;
              return timeB.compareTo(timeA);
            });

            alertItems = tempList;
          });
        }
      });
    } catch (e) {
      print("Alerts listen error: $e");
    }
  }

  void _clearAlertItem(String key) async {
    try {
      if (_alertsRef != null) {
        await _alertsRef!.child(key).remove();
      }
    } catch (e) {
      print("Clear alert error: $e");
    }
  }

  void _clearAllAlerts() async {
    try {
      if (_alertsRef != null) {
        await _alertsRef!.remove();
        if (mounted) {
          setState(() {
            alertItems.clear();
          });
        }
      }
    } catch (e) {
      print("Clear all alerts error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF37474F),
      appBar: AppBar(
        title: const Text('Alerts & Notifications', style: TextStyle(fontFamily: 'monospace')),
        backgroundColor: const Color(0xFF37474F),
        actions: [
          if (alertItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Color(0xFFCFD8DC)),
              onPressed: _clearAllAlerts,
              tooltip: 'Clear All Alerts',
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/1792250396366.jpg',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.2),
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF37474F));
            },
          ),
          Container(
            color: const Color(0xFF263238).withOpacity(0.8),
          ),
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF37474F),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFCFD8DC),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCFD8DC).withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: alertItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No trading alerts available',
                        style: TextStyle(color: Color(0xFFB0BEC5), fontFamily: 'monospace', fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: alertItems.length,
                      itemBuilder: (context, index) {
                        var alert = alertItems[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF455A64),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFCFD8DC).withOpacity(0.6),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.notifications_active, color: Color(0xFFCFD8DC), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  alert['message'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _clearAlertItem(alert['key']),
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.delete_outline, color: Color(0xFFCFD8DC), size: 18),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}


// ==========================================
// #11 โหมดการตั้งค่าพารามิเตอร์ (SettingsScreen)
// ==========================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedSymbol = 'XAUUSD';
  String tradingMode = 'Sniper';
  String lotMode = 'Fixed';
  
  final List<String> timeframes = ["M1", "M2", "M3", "M4", "M5", "M15", "M30", "H1"];
  String selectedTf = "M1";

  bool enableTrendFilter = true;

  final List<String> symbolOptions = ['XAUUSD', 'BTCUSD', 'EURUSD'];
  final List<String> tradingModeOptions = ['All Mode', 'Liquidity', 'Breakout', 'Enqulfing'];
  final List<String> lotModeOptions = ['Fixed', 'Step', 'Double'];
  
  final TextEditingController initialLotController = TextEditingController();
  final TextEditingController maxRecoveryController = TextEditingController();
  final TextEditingController maxOrdersController = TextEditingController(); 
  final TextEditingController slPointsController = TextEditingController();
  final TextEditingController riskRewardController = TextEditingController();
  
  final TextEditingController recoveryStepController = TextEditingController(text: "200");

  final TextEditingController startTimeController = TextEditingController(text: "08:00");
  final TextEditingController endTimeController = TextEditingController(text: "22:00");

  bool enableDailyTarget = true;
  final TextEditingController dailyTargetController = TextEditingController();
  
  bool enableDailyLoss = false;
  final TextEditingController dailyLossController = TextEditingController();

  bool enableBasketControl = true;
  bool enableBasketTp = true;
  final TextEditingController basketTpController = TextEditingController(text: "1.50");
  
  bool enableBasketSl = false;
  final TextEditingController basketSlController = TextEditingController(text: "5.00");

  bool isSoundEnabled = true;
  bool isPushEnabled = true;
  bool isAutoLotEnabled = false;
  double riskPercent = 1.0;
  final String currentPinStateStatus = "ตั้งค่ารหัส PIN แล้ว";

  DatabaseReference? _statusRef;
  String currentLogin = "235305975";

  bool _isEditing = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLoginAndSettings();
  }

  @override
  void dispose() {
    initialLotController.dispose();
    maxRecoveryController.dispose();
    maxOrdersController.dispose();
    slPointsController.dispose();
    riskRewardController.dispose();
    recoveryStepController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    dailyTargetController.dispose();
    dailyLossController.dispose();
    basketTpController.dispose();
    basketSlController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLoginAndSettings() async {
    if (globalSavedLogin.isNotEmpty) {
      setState(() {
        currentLogin = globalSavedLogin;
      });
    }
    _loadAllSettingsFromFirebase();
  }

  void _loadAllSettingsFromFirebase() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      _statusRef = database.ref('accounts/$currentLogin/status');
      _statusRef?.onValue.listen((DatabaseEvent event) {
        if (_isEditing) return;

        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            selectedSymbol = data['symbol']?.toString() ?? 'BTCUSD';
            tradingMode = data['trading_mode']?.toString() ?? 'Sniper';
            lotMode = data['lot_mode']?.toString() ?? 'Double';
            selectedTf = data['timeframe']?.toString() ?? 'M1';
            
            enableTrendFilter = data['enable_trend_filter'] ?? true;

            startTimeController.text = data['start_time_th']?.toString() ?? '08:00';
            endTimeController.text = data['end_time_th']?.toString() ?? '22:00';

            initialLotController.text = data['initial_lot']?.toString() ?? '0.01';
            maxRecoveryController.text = data['max_recovery']?.toString() ?? '10';
            maxOrdersController.text = data['max_orders']?.toString() ?? '10'; 
            slPointsController.text = data['sl_points']?.toString() ?? '500';
            riskRewardController.text = data['risk_reward']?.toString() ?? '2.0';
            recoveryStepController.text = data['recovery_step_pts']?.toString() ?? '200';

            enableDailyTarget = data['enable_daily_target'] ?? true;
            dailyTargetController.text = data['daily_target']?.toString() ?? '100.0';

            enableDailyLoss = data['enable_daily_loss'] ?? false;
            dailyLossController.text = data['daily_loss']?.toString() ?? '50.0';

            enableBasketControl = data['enable_basket_control'] ?? true;
            enableBasketTp = data['enable_basket_tp'] ?? true;
            basketTpController.text = data['basket_tp']?.toString() ?? '1.50';

            enableBasketSl = data['enable_basket_sl'] ?? false;
            basketSlController.text = data['basket_sl']?.toString() ?? '5.00';

            _isInitialized = true;
          });
        }
      });
    } catch (e) {
      print("Load settings error: $e");
    }
  }

  void _saveBotParametersToFirebase() {
    try {
      final payload = {
        'symbol': selectedSymbol,
        'trading_mode': tradingMode,
        'lot_mode': lotMode,
        'timeframe': selectedTf,
        'enable_trend_filter': enableTrendFilter,
        'start_time_th': startTimeController.text,
        'end_time_th': endTimeController.text,
        'initial_lot': double.tryParse(initialLotController.text) ?? 0.01,
        'max_recovery': int.tryParse(maxRecoveryController.text) ?? 10,
        'max_orders': int.tryParse(maxOrdersController.text) ?? 10, 
        'sl_points': double.tryParse(slPointsController.text) ?? 500.0,
        'risk_reward': double.tryParse(riskRewardController.text) ?? 2.0,
        'recovery_step_pts': double.tryParse(recoveryStepController.text) ?? 200.0,
        'enable_daily_target': enableDailyTarget,
        'daily_target': double.tryParse(dailyTargetController.text) ?? 100.0,
        'enable_daily_loss': enableDailyLoss,
        'daily_loss': double.tryParse(dailyLossController.text) ?? 50.0,
        'enable_basket_control': enableBasketControl,
        'use_individual_sl_tp': !enableBasketControl,
        'enable_basket_tp': enableBasketTp,
        'basket_tp': double.tryParse(basketTpController.text) ?? 1.50,
        'enable_basket_sl': enableBasketSl,
        'basket_sl': double.tryParse(basketSlController.text) ?? 5.00,
      };

      _statusRef?.update(payload);

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parameters & Time Config Synced & Saved to EA Successfully!'),
          backgroundColor: Color(0xFF00E676),
        ),
      );
    } catch (e) {
      print("Save bot parameters error: $e");
    }
  }

  Future<void> _resetPin() async {
    globalUserPin = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_user_pin');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PinAuthWrapper()),
      (route) => false,
    );
  }

  Future<void> _logoutToLoginScreen() async {
    // เคลียร์ค่าที่ล็อกอินทั้งหมดทั้ง SharedPreferences และ Global เพื่อให้กลับไปหน้ากรอก MT5 ใหม่
    globalUserPin = '';
    globalSavedLogin = '';
    globalSavedServer = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ล้างข้อมูลเซสชันทั้งหมดในเครื่อง

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MT5LoginWrapper()),
      (route) => false,
    );
  }

  Color buttonColorForLot(String mode) {
    if (mode == 'Fixed') return const Color(0xFFFF5252);
    if (mode == 'Step') return const Color(0xFF00E5FF);
    return const Color(0xFFE040FB);
  }

  Widget _buildControllerInputField(String label, TextEditingController controller, TextInputType keyboardType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFCFD8DC), fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF37474F),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.6), width: 1.2),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            onChanged: (val) => setState(() {
              _isEditing = true;
            }),
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

  @override
  Widget build(BuildContext context) {
    double sl = double.tryParse(slPointsController.text) ?? 500;
    double rr = double.tryParse(riskRewardController.text) ?? 2.0;
    double calculatedTP = sl * rr;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Bot Parameters', style: TextStyle(fontFamily: 'monospace')),
        backgroundColor: const Color(0xFF37474F),
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/1792250396366.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF37474F));
            },
          ),
          Container(
            color: const Color(0xFF263238).withOpacity(0.75),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF455A64).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFCFD8DC),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCFD8DC).withOpacity(0.7),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PARAMETERS BOT',
                        style: TextStyle(color: Color(0xFFCFD8DC), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 12),
                      const Text('Trading Symbol', style: TextStyle(color: Color(0xFFCFD8DC), fontSize: 11)),
                      const SizedBox(height: 8),
                      Row(
                        children: symbolOptions.map((sym) {
                          bool isSelected = selectedSymbol == sym;
                          Color buttonColor = sym == 'XAUUSD'
                              ? const Color(0xFFFF5252)
                              : sym == 'BTCUSD'
                                  ? const Color(0xFF00E676)
                                  : const Color(0xFF00E5FF);

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: SizedBox(
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () => setState(() {
                                    _isEditing = true;
                                    selectedSymbol = sym;
                                  }),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected ? buttonColor : const Color(0xFF37474F),
                                    foregroundColor: isSelected ? Colors.white : Colors.white70,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    side: BorderSide(color: buttonColor, width: isSelected ? 2.5 : 1),
                                    elevation: isSelected ? 8 : 0,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Text(
                                    sym,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Trading Mode', style: TextStyle(color: Color(0xFFCFD8DC), fontSize: 11)),
                      const SizedBox(height: 8),
                      Row(
                        children: tradingModeOptions.map((mode) {
                          bool isSelected = tradingMode == mode;
                          Color modeColor = mode == 'All Mode'
                              ? const Color(0xFFFF9100)
                              : mode == 'Liquidity'
                                  ? const Color(0xFFE040FB)
                                  : mode == 'Breakout'
                                      ? const Color(0xFF00E5FF)
                                      : const Color(0xFF00E676);

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3.0),
                              child: SizedBox(
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () => setState(() {
                                    _isEditing = true;
                                    tradingMode = mode;
                                  }),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected ? modeColor : const Color(0xFF37474F),
                                    foregroundColor: isSelected ? Colors.white : Colors.white70,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    side: BorderSide(color: modeColor, width: isSelected ? 2.5 : 1),
                                    elevation: isSelected ? 8 : 0,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Text(
                                    mode,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Lot Mode', style: TextStyle(color: Color(0xFFCFD8DC), fontSize: 11)),
                      const SizedBox(height: 8),
                      Row(
                        children: lotModeOptions.map((mode) {
                          bool isSelected = lotMode == mode;
                          Color modeColor = buttonColorForLot(mode);

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: SizedBox(
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () => setState(() {
                                    _isEditing = true;
                                    lotMode = mode;
                                  }),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected ? modeColor : const Color(0xFF37474F),
                                    foregroundColor: isSelected ? Colors.white : Colors.white70,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    side: BorderSide(color: modeColor, width: isSelected ? 2.5 : 1),
                                    elevation: isSelected ? 8 : 0,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Text(
                                    mode,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF37474F),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFCFD8DC), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Daily Trend Filter (D1)', style: TextStyle(color: Color(0xFFCFD8DC), fontSize: 12, fontWeight: FontWeight.bold)),
                                Switch(
                                  value: enableTrendFilter,
                                  activeColor: const Color(0xFF00E676),
                                  onChanged: (val) => setState(() {
                                    _isEditing = true;
                                    enableTrendFilter = val;
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text('Trading Timeframe', style: TextStyle(color: Color(0xFFCFD8DC), fontSize: 11)),
                            const SizedBox(height: 8),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 2.2,
                              ),
                              itemCount: timeframes.length,
                              itemBuilder: (context, index) {
                                String tf = timeframes[index];
                                bool isSelected = selectedTf == tf;
                                
                                List<Color> tfColors = [
                                  const Color(0xFFFF5252),
                                  const Color(0xFFFF9100),
                                  const Color(0xFFFFEA00),
                                  const Color(0xFF00E676),
                                  const Color(0xFF00E5FF),
                                  const Color(0xFF2979FF),
                                  const Color(0xFFE040FB),
                                  const Color(0xFFFF4081),
                                ];
                                Color tfColor = tfColors[index % tfColors.length];

                                return ElevatedButton(
                                  onPressed: () => setState(() {
                                    _isEditing = true;
                                    selectedTf = tf;
                                  }),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected ? tfColor : const Color(0xFF37474F),
                                    foregroundColor: isSelected ? Colors.white : Colors.white70,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    side: BorderSide(
                                      color: tfColor,
                                      width: isSelected ? 2.5 : 1,
                                    ),
                                    elevation: isSelected ? 6 : 0,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Text(
                                    tf,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
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
                          Expanded(child: _buildControllerInputField('Max Orders', maxOrdersController, TextInputType.number)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildControllerInputField('Recovery Step (Pts)', recoveryStepController, TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildControllerInputField('SL Points', slPointsController, TextInputType.number)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildControllerInputField('Risk Reward', riskRewardController, TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Calculated TP', style: TextStyle(color: Color(0xFFCFD8DC), fontSize: 11)),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            height: 46,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF37474F),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF00E676).withOpacity(0.6), width: 1.2),
                            ),
                            child: Text(
                              '${calculatedTP.toStringAsFixed(1)} Pts',
                              style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Start Time (เวลาไทย)', style: TextStyle(color: Color(0xFFCFD8DC), fontSize: 11)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF37474F),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4), width: 1),
                                  ),
                                  child: TextField(
                                    controller: startTimeController,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                    onChanged: (val) => setState(() { _isEditing = true; }),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('End Time (เวลาไทย)', style: TextStyle(color: Color(0xFFCFD8DC), fontSize: 11)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF37474F),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.4), width: 1),
                                  ),
                                  child: TextField(
                                    controller: endTimeController,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                    onChanged: (val) => setState(() { _isEditing = true; }),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 8),

                      // BASKET CONTROL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'BASKET CONTROL', 
                            style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold)
                          ),
                          Row(
                            children: [
                              const Text('Enable Basket', style: TextStyle(color: Color(0xFFCFD8DC), fontSize: 10)),
                              const SizedBox(width: 6),
                              Switch(
                                value: enableBasketControl,
                                activeColor: const Color(0xFF00E5FF),
                                onChanged: (val) => setState(() {
                                  _isEditing = true;
                                  enableBasketControl = val;
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF37474F),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.8), width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Basket TP', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 11, fontWeight: FontWeight.bold)),
                                      Switch(
                                        value: enableBasketTp,
                                        activeColor: const Color(0xFF00E5FF),
                                        onChanged: (val) => setState(() {
                                          _isEditing = true;
                                          enableBasketTp = val;
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  _buildControllerInputField('Target (\$)', basketTpController, TextInputType.number),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF37474F),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFF9100).withOpacity(0.8), width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Basket SL', style: TextStyle(color: Color(0xFFFF9100), fontSize: 11, fontWeight: FontWeight.bold)),
                                      Switch(
                                        value: enableBasketSl,
                                        activeColor: const Color(0xFFFF9100),
                                        onChanged: (val) => setState(() {
                                          _isEditing = true;
                                          enableBasketSl = val;
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  _buildControllerInputField('Limit (\$)', basketSlController, TextInputType.number),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // DAILY TARGET & LOSS CONTROL
                      const Text(
                        'DAILY TARGET & LOSS CONTROL', 
                        style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF37474F),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF00E676).withOpacity(0.8), width: 1.2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Daily Target', style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.bold)),
                                      Switch(
                                        value: enableDailyTarget,
                                        activeColor: const Color(0xFF00E676),
                                        onChanged: (val) => setState(() {
                                          _isEditing = true;
                                          enableDailyTarget = val;
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  _buildControllerInputField('Target (\$)', dailyTargetController, TextInputType.number),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF37474F),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.8), width: 1.2),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Daily Loss', style: TextStyle(color: Color(0xFFFF5252), fontSize: 11, fontWeight: FontWeight.bold)),
                                      Switch(
                                        value: enableDailyLoss,
                                        activeColor: const Color(0xFFFF5252),
                                        onChanged: (val) => setState(() {
                                          _isEditing = true;
                                          enableDailyLoss = val;
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  _buildControllerInputField('Limit (\$)', dailyLossController, TextInputType.number),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveBotParametersToFirebase,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text('SYNC & SAVE TO EA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFCFD8DC), width: 1.5),
                            ),
                            elevation: 6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24, height: 24),
                      const SizedBox(height: 8),
                      const Text(
                        'SECURITY & PRIVACY', 
                        style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace')
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Reset Security PIN / Login', style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace')),
                                const SizedBox(height: 2),
                                Text(currentPinStateStatus, style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 11, fontFamily: 'monospace')),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9100),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _resetPin,
                            child: const Text('Reset', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Log Out (เปลี่ยนบัญชี MT5)', style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace')),
                                SizedBox(height: 2),
                                Text('ออกจากระบบเพื่อกลับไปหน้าล็อกอิน', style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 11, fontFamily: 'monospace')),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF5252),
                              side: const BorderSide(color: Color(0xFFCFD8DC), width: 1.5),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _logoutToLoginScreen,
                            child: const Text('Log Out', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
