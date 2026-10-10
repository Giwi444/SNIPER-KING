import 'dart:async';  
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';


////////////////////////////////////////////
////////////////////////////////////////////

// ฟังก์ชันสำหรับหน้าตาของบอลลูนที่จะลอยทับหน้าจออื่น (พร้อมจุดสถานะออนไลน์)
@pragma("vm:entry-point")
void overlayMain() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        color: Colors.transparent,
        child: OverlayBallonWidget(),
      ),
    ),
  );
}

// ดีไซน์ตัวบอลลูน (แสดงภาพ assets/images/1.jpg ทรงกลม พร้อมจุดเช็คสถานะการเชื่อมต่อ)
class OverlayBallonWidget extends StatefulWidget {
  const OverlayBallonWidget({super.key});

  @override
  State<OverlayBallonWidget> createState() => _OverlayBallonWidgetState();
}

class _OverlayBallonWidgetState extends State<OverlayBallonWidget> {
  bool isConnected = false;
  StreamSubscription? _connectionSub;

  @override
  void initState() {
    super.initState();
    _initFirebaseAndListenConnection();
  }

  Future<void> _initFirebaseAndListenConnection() async {
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

      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      _connectionSub = database.ref('.info/connected').onValue.listen((event) {
        final connected = event.snapshot.value as bool? ?? false;
        if (mounted) {
          setState(() {
            isConnected = connected;
          });
        }
      });
    } catch (e) {
      print("Overlay connection listen error: $e");
    }
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await FlutterOverlayWindow.closeOverlay();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD50000), width: 2),
          boxShadow: [
            BoxShadow(
              color: (isConnected ? const Color(0xFF00C853) : const Color(0xFFD50000)).withOpacity(0.6),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/1.jpg',
                fit: BoxFit.cover,
                width: 56,
                height: 56,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFD50000),
                    child: const Icon(Icons.show_chart, color: Colors.white, size: 30),
                  );
                },
              ),
            ),
            // จุดสถานะออนไลน์สีเขียว (หรือสีแดงถ้าหลุดการเชื่อมต่อ) มุมขวาบน
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isConnected ? const Color(0xFF00C853) : const Color(0xFFD50000),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: (isConnected ? const Color(0xFF00C853) : const Color(0xFFD50000)).withOpacity(0.8),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showFloatingBalloon() async {
  bool? isGranted = await FlutterOverlayWindow.isPermissionGranted();
  if (isGranted == null || !isGranted) {
    bool? requested = await FlutterOverlayWindow.requestPermission();
    if (requested != true) return;
  }

  bool isActive = await FlutterOverlayWindow.isActive();
  if (!isActive) {
    await FlutterOverlayWindow.showOverlay(
      height: 80,
      width: 80,
      alignment: OverlayAlignment.centerRight,
      flag: OverlayFlag.defaultFlag,
      positionGravity: PositionGravity.auto,
    );
  }
}

////////////////////////////////////////////
////////////////////////////////////////////

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


class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 50),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = "";
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  @override
  void didUpdateWidget(covariant TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      _currentIndex = 0;
      _displayedText = "";
      _startTypewriter();
    }
  }

  void _startTypewriter() {
    if (widget.text.isEmpty) return;
    _timer = Timer.periodic(widget.duration, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
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
    return Text(_displayedText, style: widget.style);
  }
}

class LiquiditySweepApp extends StatelessWidget {
  const LiquiditySweepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROSE_CYBER ROBOT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B0E),
        cardColor: const Color(0xFF161619),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD50000),
          secondary: Color(0xFFFF1744),
        ),
      ),
      home: const MT5LoginWrapper(),
    );
  }
}



class MT5LoginWrapper extends StatefulWidget {
  const MT5LoginWrapper({super.key});

  @override
  State<MT5LoginWrapper> createState() => _MT5LoginWrapperState();
}

class _MT5LoginWrapperState extends State<MT5LoginWrapper> {
  final TextEditingController _loginController = TextEditingController(text: '');
  final TextEditingController _passwordController = TextEditingController(text: '');
  final TextEditingController _serverController = TextEditingController(text: ''); 
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isLoggedInMT5 = false;
  StreamSubscription<DatabaseEvent>? _loginStatusSubscription;

  @override
  void initState() {
    super.initState();
    _checkExistingMT5Login();
  }

  @override
  void dispose() {
    _loginStatusSubscription?.cancel();
    _loginController.dispose();
    _passwordController.dispose();
    _serverController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingMT5Login() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogin = prefs.getString('mt5_login');
    if (savedLogin != null && savedLogin.isNotEmpty) {
      setState(() {
        _isLoggedInMT5 = true;
      });
    }
  }

  void _submitMT5Login() async {
    String login = _loginController.text.trim();
    String password = _passwordController.text.trim();
    String server = _serverController.text.trim().isEmpty ? 'ICMarketsSC-Demo' : _serverController.text.trim();

    if (login.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลพอร์ต MT5 ให้ครบถ้วน'), backgroundColor: Color(0xFFD50000)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ เพิ่มการเช็คและ Initialize Firebase ตรงนี้ให้ปลอดภัยก่อนใช้งาน
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

      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      await _loginStatusSubscription?.cancel();

      await database.ref('status').update({
        'login': login,
        'password': password,
        'server': server,
        'request_login': true,
        'login_status': 'pending', 
      });

      _loginStatusSubscription = database.ref('status').onValue.listen((event) async {
        final data = event.snapshot.value;
        if (data == null || data is! Map) return;

        final status = data['login_status']?.toString();
        final firebaseLogin = data['login']?.toString() ?? '';
        final firebasePassword = data['password']?.toString() ?? '';
        final firebaseServer = data['server']?.toString() ?? '';

        bool isAllMatched = (firebaseLogin == login && 
                             firebasePassword == password && 
                             firebaseServer == server);

        if (status == 'success') {
          if (!isAllMatched) {
            await _loginStatusSubscription?.cancel();
            if (!mounted) return;
            _passwordController.clear();
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ข้อมูลบัญชี, รหัสผ่าน หรือ Server ไม่ถูกต้องตามความเป็นจริง'),
                backgroundColor: Color(0xFFD50000),
              ),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }

          await _loginStatusSubscription?.cancel();
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('mt5_login', login);
          await prefs.setString('mt5_server', server);

          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _isLoggedInMT5 = true;
          });
        } else if (status == 'failed' || status == 'error') {
          await _loginStatusSubscription?.cancel();

          if (!mounted) return;
          _passwordController.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('บัญชีเทรด, รหัสผ่าน หรือ Server ไม่ถูกต้อง กรุณากรอกใหม่อีกครั้ง'),
              backgroundColor: Color(0xFFD50000),
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      });

      Future.delayed(const Duration(seconds: 10), () {
        if (_isLoading && mounted) {
          _loginStatusSubscription?.cancel();
          _passwordController.clear();

          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('หมดเวลาเชื่อมต่อ: กรุณาตรวจสอบสถานะ Server หรือ EA'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      });

    } catch (e) {
      if (!mounted) return;
      _passwordController.clear();

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อระบบ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedInMT5) {
      return const PinAuthWrapper();
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/ppp.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF0B0B0E)),
          ),
          Container(color: Colors.black.withOpacity(0.88)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.9),
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
                                'assets/images/ppp.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(color: Colors.black);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161619).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFF0000), width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.8),
                              blurRadius: 12.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: const [
                            Text(
                              '🌹 R   O   S   E 🌹',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 3.0,
                                shadows: [
                                  Shadow(color: Colors.red, blurRadius: 12, offset: Offset(0, 0)),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'C Y B E R   B O T',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2.5,
                                shadows: [
                                  Shadow(color: Colors.red, blurRadius: 10, offset: Offset(0, 0)),
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
                          border: Border.all(color: const Color(0xFFD50000), width: 1.5),
                          color: Colors.black.withOpacity(0.6),
                          boxShadow: [
                            BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 6),
                          ],
                        ),
                        child: const Text(
                          'Powered By Algohost',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextField(
                        controller: _loginController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Account Login',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontStyle: FontStyle.italic),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF1744), width: 2.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Investor Password',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontStyle: FontStyle.italic),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF1744), width: 2.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _serverController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'ตัวอย่าง: ICMarketsSC-Demo',
                          hintStyle: TextStyle(color: Colors.redAccent.withOpacity(0.6), fontStyle: FontStyle.italic),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF1744), width: 2.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitMT5Login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD50000),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('VERIFY & CONNECT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    if (_isLoggedInMT5) {
      return const PinAuthWrapper();
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/ppp.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF0B0B0E)),
          ),
          Container(color: Colors.black.withOpacity(0.88)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.9),
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
                                'assets/images/ppp.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(color: Colors.black);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161619).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFF0000), width: 2.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.8),
                              blurRadius: 12.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: const [
                            Text(
                              '🌹 R   O   S   E 🌹',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 3.0,
                                shadows: [
                                  Shadow(color: Colors.red, blurRadius: 12, offset: Offset(0, 0)),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'C Y B E R   B O T',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2.5,
                                shadows: [
                                  Shadow(color: Colors.red, blurRadius: 10, offset: Offset(0, 0)),
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
                          border: Border.all(color: const Color(0xFFD50000), width: 1.5),
                          color: Colors.black.withOpacity(0.6),
                          boxShadow: [
                            BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 6),
                          ],
                        ),
                        child: const Text(
                          'Powered By Algohost',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextField(
                        controller: _loginController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Account Login',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontStyle: FontStyle.italic),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF1744), width: 2.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Investor Password',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35), fontStyle: FontStyle.italic),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF1744), width: 2.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _serverController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'ตัวอย่าง: ICMarketsSC-Demo',
                          hintStyle: TextStyle(color: Colors.redAccent.withOpacity(0.6), fontStyle: FontStyle.italic),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF1744), width: 2.0)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitMT5Login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD50000),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('VERIFY & CONNECT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    if (!mounted) return;
    final pin = prefs.getString('user_pin');
    setState(() {
      hasStoredPin = pin != null && pin.isNotEmpty;
      isLoading = false;
    });
  }

  Future<void> _saveNewPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    await prefs.setString('user_pin', pin);
  }

  Future<void> _verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
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

    String titleText = "กรุณากรอก PIN เพื่อเข้าใช้งานระบบ";
    if (!hasStoredPin) {
      titleText = isConfirming ? "ยืนยันรหัส PIN 6 หลักอีกครั้ง" : "ตั้งค่ารหัส PIN 6 หลักความปลอดภัย";
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/ppp.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF0B0B0E)),
          ),
          Container(color: Colors.black.withOpacity(0.85)),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, color: Color(0xFFFF1744), size: 48),
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
                        color: isFilled ? const Color(0xFFFF1744) : Colors.transparent,
                        border: Border.all(color: const Color(0xFFFF1744), width: 2),
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
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFD50000), Color(0xFF7A0000)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
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
          child: Center(
            child: val == 'del'
                ? const Icon(Icons.backspace_outlined, color: Colors.white)
                : Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
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

class _MainNavigationScreenState extends State<MainNavigationScreen> with TickerProviderStateMixin {
  int _currentIndex = 2;
  String currentLogin = "8111175";
  int unreadAlertsCount = 0;
  DatabaseReference? _alertsRef;
  DatabaseReference? _dbRef;
  DatabaseReference? _logsRef;
  DatabaseReference? _ordersRef;

  Offset _orderBubbleOffset = const Offset(20, 100);
  bool _isOrderBubblePressed = false;
  bool _isLargeLogsModalOpen = false;
  bool isRunning = false;
  bool isConnected = false;
  
  String symbol = "XAUUSD";
  String timeframe = "M1";
  double profit = 0.0;
  List<Map<String, dynamic>> _botLogs = [];
  List<Map<dynamic, dynamic>> activeOrders = [];

  final String _imageA = 'assets/images/ppp.jpg';
  final String _imageB = 'assets/images/1791591138980.jpg';
  bool _showMorphImage = false; 

  late final AnimationController _bounceController = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> _bounceAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(
    CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
  );

  late final AnimationController _scannerController = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> _scannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
  );

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();
    _listenToActiveAccount();
    _listenToAlertsCount();
    _initFirebaseAndListen();
    _listenToLogs();
    _listenToConnectionStatus();
    _listenToOrdersForDialog();

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
    _bounceController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('mt5_login');
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() {
        currentLogin = saved;
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
      _logsRef = database.ref('logs');
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
      _ordersRef = database.ref('orders');
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

  void _clearLogItem(String key) {
    try {
      _logsRef?.child(key).remove();
    } catch (e) {
      print("Clear log item error: $e");
    }
  }

  void _clearAllLogs() {
    try {
      _logsRef?.remove();
      setState(() {
        _botLogs.clear();
      });
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
      AlertsScreen(onAlertsRead: () {
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
      backgroundColor: const Color(0xFF0B0B0E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          Positioned(
            left: _orderBubbleOffset.dx,
            top: _orderBubbleOffset.dy,
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _bounceAnimation.value),
                  child: child,
                );
              },
              child: Draggable(
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildSymbolBubbleWidget(),
                ),
                childWhenDragging: Container(),
                onDragEnd: (details) {
                  setState(() {
                    _orderBubbleOffset = details.offset;
                  });
                },
                child: GestureDetector(
                  onTapDown: (_) {
                    setState(() {
                      _isOrderBubblePressed = true;
                    });
                  },
                  onTapUp: (_) {
                    setState(() {
                      _isOrderBubblePressed = false;
                      _isLargeLogsModalOpen = !_isLargeLogsModalOpen;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      _isOrderBubblePressed = false;
                    });
                  },
                  child: AnimatedScale(
                    scale: _isOrderBubblePressed ? 0.85 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: _buildSymbolBubbleWidget(),
                  ),
                ),
              ),
            ),
          ),
          if (_isLargeLogsModalOpen)
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLargeLogsModalOpen = false;
                    });
                  },
                  child: Container(color: Colors.black54),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.94,
                    height: MediaQuery.of(context).size.height * 0.78,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFF0000), width: 4.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.9),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                      color: const Color(0xFF121215),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.terminal, color: Color(0xFFFF1744), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'EA STATUS & BOT LOGS',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  if (_botLogs.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                                      onPressed: _clearAllLogs,
                                      tooltip: 'Clear All Logs',
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () {
                                      setState(() {
                                        _isLargeLogsModalOpen = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Color(0xFFFF0000), height: 2, thickness: 2),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStatusReportBox(symbol, timeframe, totalOrdersProfit, activeOrders.length, totalLots, isTotalProfit),
                                  const SizedBox(height: 16),
                                  const Row(
                                    children: [
                                      Icon(Icons.show_chart, color: Color(0xFFFF1744), size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        'ACTIVITY LOGS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (_botLogs.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 20.0),
                                      child: Center(
                                        child: Text('No log records...', style: TextStyle(color: Colors.grey, fontFamily: 'monospace')),
                                      ),
                                    ),
                                  ..._botLogs.asMap().entries.map((entry) {
                                    var log = entry.value;
                                    bool isLatest = (entry.key == 0);

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
                                                          color: Colors.redAccent,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          shadows: [
                                                            Shadow(color: Colors.red, blurRadius: 8),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: TypewriterText(
                                                          text: "> ${log['message']}",
                                                          style: const TextStyle(
                                                            color: Colors.redAccent,
                                                            fontFamily: 'monospace',
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            height: 1.4,
                                                            shadows: [
                                                              Shadow(color: Colors.red, blurRadius: 10, offset: Offset(0, 0)),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    "> ${log['message']}",
                                                    style: const TextStyle(
                                                      color: Colors.greenAccent,
                                                      fontFamily: 'monospace',
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                          ),
                                          GestureDetector(
                                            onTap: () => _clearLogItem(log['key']),
                                            child: const Padding(
                                              padding: EdgeInsets.only(left: 8.0),
                                              child: Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
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
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0B0B0E),
            border: Border(
              top: BorderSide(color: const Color(0xFFD50000).withOpacity(0.6), width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.8),
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
    );
  }

  Widget _buildSymbolBubbleWidget() {
    bool isServerActive = isConnected && isRunning;
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF222222), Color(0xFF8A0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFD50000), width: 2.0),
        boxShadow: [
          BoxShadow(
            color: (isServerActive ? const Color(0xFF00C853) : const Color(0xFFD50000)).withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              _showMorphImage ? _imageB : _imageA,
              fit: BoxFit.cover,
              width: 54,
              height: 54,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.black);
              },
            ),
          ),
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isServerActive ? const Color(0xFF00C853) : const Color(0xFFD50000),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
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
        color: const Color(0xFF161619),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF0000),
          width: 2.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Container(
              height: 200,
              width: double.infinity,
              color: Colors.black,
              child: AnimatedBuilder(
                animation: _scannerAnimation,
                builder: (context, child) {
                  double scanValue = _scannerAnimation.value * 200;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        baseImage,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: 200,
                      ),
                      ClipRect(
                        clipper: ScannerClipper(scanValue),
                        child: Image.asset(
                          morphImage,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: 200,
                        ),
                      ),
                      Positioned(
                        top: scanValue - 2,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF1744),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent,
                                blurRadius: 10,
                                spreadRadius: 3,
                              ),
                              BoxShadow(
                                color: Colors.white,
                                blurRadius: 3,
                                spreadRadius: 1,
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
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🌹 ROSE CYBER BOT LIVE STATUS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: isServerActive ? const Color(0xFF00C853) : const Color(0xFFD50000),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isServerActive ? const Color(0xFF00C853) : const Color(0xFFD50000)).withOpacity(0.8),
                            blurRadius: 6,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isServerActive ? 'EA SERVER ONLINE & RUNNING' : 'EA SERVER OFFLINE / STOPPED',
                      style: TextStyle(
                        color: isServerActive ? const Color(0xFF00C853) : Colors.redAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.white24, height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Orders: $orderCount', style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('Lots: ${totalLots.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    Text(
                      'P/L: ${isTotalProfit ? "+" : ""}\$${totalOrdersProfit.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isTotalProfit ? const Color(0xFF00C853) : Colors.redAccent,
                        fontSize: 11,
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
          color: isSelected ? const Color(0xFFFF1744) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: isSelected ? 1.5 : 0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.8),
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
  DatabaseReference? _marketRef;

  bool _isChartModalOpen = false;

  @override
  void initState() {
    super.initState();
    _initFirebaseAndListen();
    _listenToOrdersForDialog();
    _listenToConnectionStatus();
    _listenToMarketPrices();
    _listenToHistoryForStats();
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

  void _listenToMarketPrices() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      
      _marketRef = database.ref('market');
      _marketRef?.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (data != null && mounted) {
          if (data is Map) {
            setState(() {
              if (data['bid'] != null) {
                realTimeBid = double.tryParse(data['bid'].toString()) ?? realTimeBid;
              }
              if (data['ask'] != null) {
                realTimeAsk = double.tryParse(data['ask'].toString()) ?? realTimeAsk;
              }
            });
          }
        }
      });

      database.ref('status').onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value;
        if (data != null && mounted && data is Map) {
          setState(() {
            if (data['bid'] != null) {
              realTimeBid = double.tryParse(data['bid'].toString()) ?? realTimeBid;
            }
            if (data['ask'] != null) {
              realTimeAsk = double.tryParse(data['ask'].toString()) ?? realTimeAsk;
            }
          });
        }
      });
    } catch (e) {
      print("Market prices listen error: $e");
    }
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
            
            if (data['bid'] != null) {
              realTimeBid = double.tryParse(data['bid'].toString()) ?? realTimeBid;
            }
            if (data['ask'] != null) {
              realTimeAsk = double.tryParse(data['ask'].toString()) ?? realTimeAsk;
            }
          });
        }
      });
    } catch (e) {
      print("Database listen error: $e");
    }
  }

  void _listenToHistoryForStats() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      _historyRef = database.ref('history');
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

  void _listenToOrdersForDialog() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );
      _ordersRef = database.ref('orders');
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
        const SnackBar(content: Text('Sent Close All Command to EA!'), backgroundColor: Color(0xFFD50000)),
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
          Container(color: const Color(0xFF0B0B0E)),
          Image.asset(
            'assets/images/ppp.jpg',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.3),
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF0B0B0E));
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.9), const Color(0xFF3A0000).withOpacity(0.5), Colors.black.withOpacity(0.95)],
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
                              color: Colors.red.withOpacity(0.9),
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
                                'assets/images/ppp.jpg',
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161619).withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFF0000), width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.8),
                            blurRadius: 12.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: const [
                          Text(
                            '🌹 R   O   S   E 🌹',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 3.0,
                              shadows: [
                                Shadow(color: Colors.red, blurRadius: 12, offset: Offset(0, 0)),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'C Y B E R   B O T',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2.5,
                              shadows: [
                                Shadow(color: Colors.red, blurRadius: 10, offset: Offset(0, 0)),
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
                        border: Border.all(color: const Color(0xFFD50000), width: 1.5),
                        color: Colors.black.withOpacity(0.6),
                        boxShadow: [
                          BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 6),
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
                          colors: const [Color(0xFF8A0000), Color(0xFF3A0000)],
                          onPressed: _closeAllOrders,
                        ),
                        const SizedBox(width: 20),
                        _buildCircularButton(
                          label: isRunning ? 'STOP' : 'START',
                          icon: isRunning ? Icons.stop : Icons.play_arrow,
                          colors: isRunning 
                              ? const [Color(0xFFD50000), Color(0xFF5A0000)] 
                              : const [Color(0xFFB71C1C), Color(0xFF7A0000)], 
                          onPressed: () => _toggleBotStatus(!isRunning),
                          isLarge: true,
                        ),
                        const SizedBox(width: 18),
                        _buildCircularButton(
                          label: 'STATS', 
                          icon: Icons.bar_chart,
                          colors: const [Color(0xFF8A0000), Color(0xFF3A0000)],
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
                    width: MediaQuery.of(context).size.width * 0.94,
                    height: MediaQuery.of(context).size.height * 0.78,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFF0000), width: 4.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.9),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                      color: const Color(0xFF121215),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.dashboard_outlined, color: Color(0xFFFF1744), size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'DASHBOARD STATS & OVERVIEW',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _isChartModalOpen = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Color(0xFFFF0000), height: 2, thickness: 2),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
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
    int totalTrades = _historyTrades.length;
    int winTrades = 0;
    int lossTrades = 0;
    double totalProfitLoss = 0.0;
    double maxProfit = 0.0;
    double maxLoss = 0.0;

    for (var trade in _historyTrades) {
      double p = double.tryParse(trade['profit']?.toString() ?? '0.0') ?? 0.0;
      totalProfitLoss += p;
      if (p > 0) {
        winTrades++;
        if (p > maxProfit) maxProfit = p;
      } else if (p < 0) {
        lossTrades++;
        if (p < maxLoss) maxLoss = p;
      }
    }

    double winRate = totalTrades > 0 ? (winTrades / totalTrades) * 100 : 0.0;
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
    if (maxDDAmount == 0 && lossTrades > 0) {
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
                  value: '${winRate.toStringAsFixed(1)}%',
                  subText: '$winTrades Win / $lossTrades Loss',
                  color: const Color(0xFF00C853),
                  icon: Icons.pie_chart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'MAX DRAWDOWN',
                  value: '${maxDDAmount.toStringAsFixed(2)}%',
                  subText: 'Max Loss: \$${maxLoss.toStringAsFixed(2)}',
                  color: Colors.redAccent,
                  icon: Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'TOTAL TRADES',
                  value: '$totalTrades',
                  subText: 'Active Orders: ${activeOrders.length}',
                  color: const Color(0xFFFF1744),
                  icon: Icons.receipt_long,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'NET PROFIT',
                  value: '${totalProfitLoss >= 0 ? "+" : ""}\$${totalProfitLoss.toStringAsFixed(2)}',
                  subText: 'Balance: \$${balance.toStringAsFixed(2)}',
                  color: totalProfitLoss >= 0 ? const Color(0xFF00C853) : Colors.redAccent,
                  icon: Icons.account_balance_wallet,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'SYSTEM PERFORMANCE SUMMARY',
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Bot Engine Status', isRunning ? 'Running' : 'Stopped', isRunning ? const Color(0xFF00C853) : Colors.redAccent),
                const Divider(color: Colors.white12, height: 16),
                _buildSummaryRow('Current Symbol / TF', '$symbol ($timeframe)', Colors.redAccent),
                const Divider(color: Colors.white12, height: 16),
                _buildSummaryRow('Active Profit (P/L)', '${profit >= 0 ? "+" : ""}\$${profit.toStringAsFixed(2)}', profit >= 0 ? const Color(0xFF00C853) : Colors.redAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required String subText, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
          const SizedBox(height: 4),
          Text(subText, style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val, Color valColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace')),
        Text(val, style: TextStyle(color: valColor, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace')),
      ],
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
          colors: [Color(0xFFFF1744), Color(0xFFD50000), Color(0xFF5A0000), Color(0xFF161619)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.5),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF161619),
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
                    const Icon(Icons.show_chart, color: Color(0xFFFF1744), size: 16),
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
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: Text(
                    'Spread: ${spreadVal > 0 ? spreadVal.toStringAsFixed(1) : "0.0"}',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
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
                    const Text('BID', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
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
    required List<Color> colors,
    required VoidCallback onPressed,
    bool isLarge = false,
  }) {
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
                colors: colors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(color: const Color(0xFFD50000), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
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
            accountServer = data['server']?.toString() ?? 'ICMarkets SC-MT5-Demo';
            
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
        title: const Text('Portfolio', style: TextStyle(fontFamily: 'monospace')),
        backgroundColor: const Color(0xFF0B0B0E),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/ppp.jpg',
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
                      colors: [Color(0xFFD50000), Color(0xFF101014), Color(0xFF5A0000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFFF0000),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.8),
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
                              Icon(Icons.account_balance, color: Color(0xFFFF1744), size: 18),
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
                              border: Border.all(color: Colors.redAccent, width: 1),
                            ),
                            child: Text(
                              activeSymbol,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
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
                              const Text('Account Login', style: TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace')),
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
                              const Text('Server', style: TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace')),
                              const SizedBox(height: 2),
                              Text(
                                accountServer,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
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
                      color: Colors.redAccent,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.7),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
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
                                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, fontFamily: 'monospace'),
                                ),
                                Text(
                                  '${isTotalProfit ? "+" : ""}\$${totalOrdersProfit.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: isTotalProfit ? const Color(0xFF00C853) : const Color(0xFFD50000),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
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
                                    child: Text('No active orders currently', style: TextStyle(color: Colors.grey, fontSize: 13, fontFamily: 'monospace')),
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
                                                  style: TextStyle(color: isBuy ? const Color(0xFF00C853) : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
                                                  const SizedBox(height: 2),
                                                  Text('Lot: $lot', style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace')),
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
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 19,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

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
      appBar: AppBar(
        title: const Text('History', style: TextStyle(fontFamily: 'monospace')),
        backgroundColor: const Color(0xFF0B0B0E),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/ppp.jpg',
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
                        label: Text(filter, style: const TextStyle(fontFamily: 'monospace')),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFF1744),
                        backgroundColor: const Color(0xFF161619),
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
                    colors: [Color(0xFFD50000), Color(0xFF101014), Color(0xFF5A0000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFF0000),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.8),
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
                            color: totalProfit >= 0 ? const Color(0xFF00C853) : Colors.redAccent,
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
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.redAccent,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.7),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: filteredHistory.isEmpty
                        ? const Center(
                            child: Text('No closed trade history for this account', style: TextStyle(color: Colors.grey, fontFamily: 'monospace')),
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
                                            style: TextStyle(color: isBuy ? const Color(0xFF00C853) : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'),
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
                                              style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontFamily: 'monospace'),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(closeTime, style: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'monospace')),
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
            List<Map<String, dynamic>> tempList = [];
            if (data is Map) {
              data.forEach((key, value) {
                if (value != null) {
                  String rawMsg = value.toString();
                  String cleanMsg = rawMsg.replaceAll(RegExp(r'command\s*', caseSensitive: false), '');
                  
                  String upperMsg = cleanMsg.toUpperCase();
                  if (upperMsg.contains('ORDER') || 
                      upperMsg.contains('BUY') || 
                      upperMsg.contains('SELL') || 
                      upperMsg.contains('POSITION') ||
                      upperMsg.contains('PROFIT') || 
                      upperMsg.contains('LOSS') ||
                      upperMsg.contains('OPEN') ||
                      upperMsg.contains('CLOSE') ||
                      upperMsg.contains('TP') ||
                      upperMsg.contains('SL')) {
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
                  if (upperMsg.contains('ORDER') || 
                      upperMsg.contains('BUY') || 
                      upperMsg.contains('SELL') || 
                      upperMsg.contains('POSITION') ||
                      upperMsg.contains('PROFIT') || 
                      upperMsg.contains('LOSS') ||
                      upperMsg.contains('OPEN') ||
                      upperMsg.contains('CLOSE') ||
                      upperMsg.contains('TP') ||
                      upperMsg.contains('SL')) {
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

  void _clearAlertItem(String key) {
    try {
      _alertsRef?.child(key).remove();
    } catch (e) {
      print("Clear alert error: $e");
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
        title: const Text('Alerts & Notifications', style: TextStyle(fontFamily: 'monospace')),
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
            'assets/images/ppp.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF0B0B0E));
            },
          ),
          Container(
            color: Colors.black.withOpacity(0.8),
          ),
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.redAccent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.6),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: alertItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No trading alerts available',
                        style: TextStyle(color: Colors.grey, fontFamily: 'monospace', fontSize: 13),
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
                            color: const Color(0xFF161619).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.4), width: 1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.notifications_active, color: Color(0xFFFF1744), size: 20),
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
                                  child: Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
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

  final List<String> symbolOptions = ['XAUUSD', 'BTCUSD', 'EURUSD'];
  final List<String> tradingModeOptions = ['All Mode', 'Liquidity', 'Breakout', 'Enqulfing'];
  final List<String> lotModeOptions = ['Fixed', 'Step', 'Double'];
  
  final TextEditingController initialLotController = TextEditingController();
  final TextEditingController maxRecoveryController = TextEditingController();
  final TextEditingController maxOrdersController = TextEditingController(); 
  final TextEditingController swingBarsController = TextEditingController();
  final TextEditingController slPointsController = TextEditingController();
  final TextEditingController riskRewardController = TextEditingController();

  final TextEditingController startTimeController = TextEditingController(text: "08:00");
  final TextEditingController endTimeController = TextEditingController(text: "22:00");

  bool enableDailyTarget = true;
  final TextEditingController dailyTargetController = TextEditingController();
  
  bool enableDailyLoss = false;
  final TextEditingController dailyLossController = TextEditingController();

  bool isSoundEnabled = true;
  bool isPushEnabled = true;
  bool isAutoLotEnabled = false;
  double riskPercent = 1.0;
  final String currentPinStateStatus = "ตั้งค่ารหัส PIN แล้ว";

  DatabaseReference? _statusRef;

  bool _isEditing = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadAllSettingsFromFirebase();
    _loadLocalPreferences();
  }

  @override
  void dispose() {
    initialLotController.dispose();
    maxRecoveryController.dispose();
    maxOrdersController.dispose();
    swingBarsController.dispose();
    slPointsController.dispose();
    riskRewardController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    dailyTargetController.dispose();
    dailyLossController.dispose();
    super.dispose();
  }

  void _loadAllSettingsFromFirebase() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      _statusRef = database.ref('status');
      _statusRef?.onValue.listen((DatabaseEvent event) {
        if (_isEditing) return;

        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            selectedSymbol = data['symbol']?.toString() ?? 'XAUUSD';
            tradingMode = data['trading_mode']?.toString() ?? 'Sniper';
            lotMode = data['lot_mode']?.toString() ?? 'Double';
            selectedTf = data['timeframe']?.toString() ?? 'M1';
            
            startTimeController.text = data['start_time_th']?.toString() ?? '08:00';
            endTimeController.text = data['end_time_th']?.toString() ?? '22:00';

            initialLotController.text = data['initial_lot']?.toString() ?? '0.01';
            maxRecoveryController.text = data['max_recovery']?.toString() ?? '10';
            maxOrdersController.text = data['max_orders']?.toString() ?? '10'; 
            swingBarsController.text = data['swing_bars']?.toString() ?? '30';
            slPointsController.text = data['sl_points']?.toString() ?? '500';
            riskRewardController.text = data['risk_reward']?.toString() ?? '2.0';

            enableDailyTarget = data['enable_daily_target'] ?? true;
            dailyTargetController.text = data['daily_target']?.toString() ?? '100.0';

            enableDailyLoss = data['enable_daily_loss'] ?? false;
            dailyLossController.text = data['daily_loss']?.toString() ?? '50.0';

            _isInitialized = true;
          });
        }
      });
    } catch (e) {
      print("Load settings error: $e");
    }
  }

  Future<void> _loadLocalPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      isSoundEnabled = prefs.getBool('pref_sound') ?? true;
      isPushEnabled = prefs.getBool('pref_push') ?? true;
      isAutoLotEnabled = prefs.getBool('pref_autolot') ?? false;
      riskPercent = prefs.getDouble('pref_risk') ?? 1.0;
    });
  }

  void _saveBotParametersToFirebase() {
    try {
      _statusRef?.update({
        'symbol': selectedSymbol,
        'trading_mode': tradingMode,
        'lot_mode': lotMode,
        'timeframe': selectedTf,
        'start_time_th': startTimeController.text,
        'end_time_th': endTimeController.text,
        'initial_lot': double.tryParse(initialLotController.text) ?? 0.01,
        'max_recovery': int.tryParse(maxRecoveryController.text) ?? 10,
        'max_orders': int.tryParse(maxOrdersController.text) ?? 10, 
        'swing_bars': int.tryParse(swingBarsController.text) ?? 30,
        'sl_points': double.tryParse(slPointsController.text) ?? 500.0,
        'risk_reward': double.tryParse(riskRewardController.text) ?? 2.0,
        'enable_daily_target': enableDailyTarget,
        'daily_target': double.tryParse(dailyTargetController.text) ?? 100.0,
        'enable_daily_loss': enableDailyLoss,
        'daily_loss': double.tryParse(dailyLossController.text) ?? 50.0,
      });

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parameters & Time Config Synced & Saved to EA Successfully!'),
          backgroundColor: Color(0xFFFF1744),
        ),
      );
    } catch (e) {
      print("Save bot parameters error: $e");
    }
  }

  Future<void> _resetPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_pin');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PinAuthWrapper()),
      (route) => false,
    );
  }

  Future<void> _logoutToLoginScreen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_pin');
    await prefs.remove('mt5_login');
    await prefs.remove('mt5_server');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MT5LoginWrapper()),
      (route) => false,
    );
  }

  Color buttonColorForLot(String mode) {
    if (mode == 'Fixed') return const Color(0xFF00E5FF);
    if (mode == 'Step') return const Color(0xFF9C27B0);
    return const Color(0xFFFF9100);
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
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 13),
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
        backgroundColor: const Color(0xFF0B0B0E),
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/ppp.jpg',
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161619).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.redAccent,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.7),
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
                        style: TextStyle(color: Color(0xFFFF1744), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8, fontFamily: 'monospace'),
                      ),
                      const SizedBox(height: 12),
                      const Text('Trading Symbol', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 8),
                      Row(
                        children: symbolOptions.map((sym) {
                          bool isSelected = selectedSymbol == sym;
                          Color buttonColor = sym == 'XAUUSD'
                              ? const Color(0xFFFF1744)
                              : sym == 'BTCUSD'
                                  ? const Color(0xFF00C853)
                                  : const Color(0xFFD50000);

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
                                    backgroundColor: isSelected ? buttonColor : const Color(0xFF0B0B0E),
                                    foregroundColor: isSelected ? Colors.white : Colors.white70,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    side: BorderSide(color: buttonColor, width: isSelected ? 2.5 : 1),
                                    elevation: isSelected ? 6 : 0,
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
                      const Text('Trading Mode', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      const SizedBox(height: 8),
                      Row(
                        children: tradingModeOptions.map((mode) {
                          bool isSelected = tradingMode == mode;
                          Color modeColor = mode == 'All Mode'
                              ? const Color(0xFFFF1744)
                              : mode == 'Liquidity'
                                  ? const Color(0xFFE91E63)
                                  : mode == 'Breakout'
                                      ? const Color(0xFF00BCD4)
                                      : const Color(0xFFFF5722);

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
                                    backgroundColor: isSelected ? modeColor : const Color(0xFF0B0B0E),
                                    foregroundColor: isSelected ? Colors.white : Colors.white70,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    side: BorderSide(color: modeColor, width: isSelected ? 2.5 : 1),
                                    elevation: isSelected ? 6 : 0,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Text(
                                    mode,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('Lot Mode', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
                                    backgroundColor: isSelected ? modeColor : const Color(0xFF0B0B0E),
                                    foregroundColor: isSelected ? Colors.white : Colors.white70,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    side: BorderSide(color: modeColor, width: isSelected ? 2.5 : 1),
                                    elevation: isSelected ? 6 : 0,
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
                      const Text('Timeframe', style: TextStyle(color: Colors.grey, fontSize: 11)),
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
                          return ElevatedButton(
                            onPressed: () => setState(() {
                              _isEditing = true;
                              selectedTf = tf;
                            }),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? const Color(0xFFFF1744) : const Color(0xFF0B0B0E),
                              foregroundColor: isSelected ? Colors.white : Colors.white70,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFFFF1744) : Colors.white24,
                                width: isSelected ? 2 : 1,
                              ),
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
                          Expanded(child: _buildControllerInputField('Swing Bars', swingBarsController, TextInputType.number)),
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
                      Row(
                        children: [
                          Expanded(child: _buildControllerInputField('Start Time (เวลาไทย)', startTimeController, TextInputType.text)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildControllerInputField('End Time (เวลาไทย)', endTimeController, TextInputType.text)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Calculated TP', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          const SizedBox(height: 4),
                          Container(
                            height: 46,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B0B0E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white12, width: 1),
                            ),
                            child: Text(
                              '${calculatedTP.toStringAsFixed(1)} Pts',
                              style: const TextStyle(color: Color(0xFFFF1744), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 8),
                      const Text(
                        'DAILY TARGET & LOSS CONTROL', 
                        style: TextStyle(color: Color(0xFFFF1744), fontSize: 11, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B0B0E),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF00C853).withOpacity(0.5), width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Daily Target', style: TextStyle(color: Color(0xFF00C853), fontSize: 11, fontWeight: FontWeight.bold)),
                                      Switch(
                                        value: enableDailyTarget,
                                        activeColor: const Color(0xFF00C853),
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
                                color: const Color(0xFF0B0B0E),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Daily Loss', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                      Switch(
                                        value: enableDailyLoss,
                                        activeColor: Colors.redAccent,
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
                            backgroundColor: const Color(0xFFFF1744),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24, height: 24),
                      const SizedBox(height: 8),
                      const Text(
                        'SECURITY & PRIVACY', 
                        style: TextStyle(color: Color(0xFFFF1744), fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace')
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
                                Text(currentPinStateStatus, style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace')),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD50000),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            onPressed: _resetPin,
                            child: const Text('Reset', style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Log Out (เปลี่ยนบัญชี MT5)', style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace')),
                                SizedBox(height: 2),
                                Text('ออกจากระบบเพื่อกลับไปหน้าล็อกอิน', style: TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace')),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[850],
                              side: const BorderSide(color: Color(0xFFFF1744), width: 1.5),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            onPressed: _logoutToLoginScreen,
                            child: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
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
}.
