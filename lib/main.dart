// 📌 ไฟล์ Flutter รวมโค้ดทั้งหมด (รวมโครงสร้าง MainNavigationScreen, OverlayBallonWidget และหน้าจอประกอบครบถ้วน)

/////////////////////////////////////////////////////////////////////// 1. IMPORTS & OVERLAY CONFIG ////////
////////////////////////////////////////////////////////////////////////////////////////////////----------

import 'dart:async';  
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';


/////////////////////////////////////////////////////////////////////// 2. OVERLAY BALLOON WIDGET //////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////

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
  try {
    // 1. ขอสิทธิ์แจ้งเตือน (สำหรับ Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // 2. ตรวจสอบสิทธิ์แสดงผลทับแอปอื่น (Overlay Permission)
    bool? isGranted = await FlutterOverlayWindow.isPermissionGranted();
    if (isGranted == null || !isGranted) {
      bool? requested = await FlutterOverlayWindow.requestPermission();
      if (requested != true) return;
    }

    // 3. สั่งแสดงบอลลูนเมื่อได้รับสิทธิ์เรียบร้อย
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
  } catch (e) {
    print("Show floating balloon error: $e");
  }
}


/////////////////////////////////////////////////////////////////////// 3. MAIN FUNCTION & TYPEWRITER TEXT ////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////--

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


/////////////////////////////////////////////////////////////////////// 4. MT5 LOGIN WRAPPER SCREEN //////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////

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
      } else {
        Firebase.app(); 
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

          await _showFloatingBalloon();

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


/////////////////////////////////////////////////////////////////////// 5. PIN AUTH WRAPPER SCREEN //////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////

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
      await _showFloatingBalloon();
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
              _showFloatingBalloon();
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


/////////////////////////////////////////////////////////////////////// 6. MAIN NAVIGATION SCREEN //////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////

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

    // 📌 เรียกคำสั่งเปิด Overlay บอลลูนเมื่อหน้าจอ MainNavigationScreen ถูกสร้างขึ้น
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFloatingBalloon();
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
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                          shadows: [
                                                            Shadow(color: Colors.red, blurRadius: 8),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: TypewriterText(
                                                          text: "${log['message']}",
                                                          style: const TextStyle(
                                                            color: Colors.redAccent,
                                                            fontFamily: 'monospace',
                                                            fontSize: 14,
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
                                                      color: Colors.white,
                                                      fontFamily: 'monospace',
                                                      fontSize: 14,
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


/////////////////////////////////////////////////////////////////////// 7. OTHER SCREENS PLACEHOLDERS (Settings, Orders, History, Alerts) ////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////--

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Settings Screen', style: TextStyle(color: Colors.white))));
  }
}

class OrdersScreen extends StatelessWidget {
  final String accountLogin;
  const OrdersScreen({super.key, required this.accountLogin});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Orders Screen', style: TextStyle(color: Colors.white))));
  }
}

class HistoryScreen extends StatelessWidget {
  final String accountLogin;
  const HistoryScreen({super.key, required this.accountLogin});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('History Screen', style: TextStyle(color: Colors.white))));
  }
}

class AlertsScreen extends StatelessWidget {
  final VoidCallback onAlertsRead;
  const AlertsScreen({super.key, required this.onAlertsRead});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Alerts Screen', style: TextStyle(color: Colors.white))));
  }
}

class HomeScreen extends StatelessWidget {
  final String accountLogin;
  const HomeScreen({super.key, required this.accountLogin});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Home Screen', style: TextStyle(color: Colors.white))));
  }
}
