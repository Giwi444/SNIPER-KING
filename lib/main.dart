import 'package:flutter/material.dart';

void main() {
  runApp(const SniperKingApp());
}

class SniperKingApp extends StatelessWidget {
  const SniperKingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sniper King',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const DashboardScreen(),
    );
  }
}

// -------------------------------------------------------------------------
// 1. หน้าจอแดชบอร์ดหลัก (Dashboard) พร้อมปุ่มบอลลอยลากได้
// -------------------------------------------------------------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ตำแหน่งเริ่มต้นของปุ่มลูกบอลลอย AI บนหน้าจอ
  double _floatX = 300.0;
  double _floatY = 500.0;

  bool _isBotRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // โทนสีมืดพรีเมียม
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('SNIPER KING DASHBOARD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // --- เนื้อหาแดชบอร์ดหลัก (Balance, Margin, Bot Control) ---
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ส่วนแสดงยอดเงินรวมด้านบน (แก้ไขปัญหาเครื่องหมาย $)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                    ),
                    child: const Text(
                      '+\$0.00',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. ข้อมูล Balance & Equity
                Row(
                  children: [
                    Expanded(child: _buildInfoCard('Balance', '\$1581.00', Icons.account_balance_wallet)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInfoCard('Equity', '\$1581.00', Icons.trending_up)),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. ข้อมูล Margin & Free Margin
                Row(
                  children: [
                    Expanded(child: _buildInfoCard('Margin', '\$0.00', Icons.lock_outline)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInfoCard('Free Margin', '\$1581.00', Icons.lock_open)),
                  ],
                ),
                const SizedBox(height: 30),

                // 4. ส่วนควบคุม Bot & Order Control
                const Text(
                  'BOT & ORDER CONTROL',
                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('EA Execution Status', style: TextStyle(color: Colors.white70)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isBotRunning ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _isBotRunning ? 'RUNNING' : 'STOPPED',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isBotRunning = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('START', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isBotRunning = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('STOP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Close All Orders Triggered!')),
                            );
                          },
                          icon: const Icon(Icons.delete_sweep, color: Colors.black),
                          label: const Text('CLOSE ALL ORDERS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- ปุ่มลูกบอลลอย AI (ลากเลื่อนได้อิสระบนหน้าจอ) ---
          Positioned(
            left: _floatX,
            top: _floatY,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _floatX += details.delta.dx;
                  _floatY += details.delta.dy;
                });
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AiChatScreen()),
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Colors.purpleAccent, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.white60),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------------
// 2. หน้าจอแชทสนทนากับ AI (สไตล์ WhatsApp / Gemini)
// -------------------------------------------------------------------------
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      "sender": "ai",
      "message": "สวัสดีตอนเช้า Ironman! ฉันคือผู้ช่วย AI ส่วนตัวของคุณ พร้อมวิเคราะห์พอร์ตและตลาดให้แล้ว มีอะไรให้ช่วยเหลือไหมครับ?"
    }
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    String userText = _messageController.text;
    setState(() {
      _messages.add({"sender": "user", "message": userText});
      _messageController.clear();

      _messages.add({
        "sender": "ai",
        "message": "รับทราบคำถาม: \"$userText\" ระบบบริหารความเสี่ยงทำงานปกติ พอร์ตอยู่ในสถานะทรงตัวปลอดภัยดีครับ"
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111B21), // โทนสีมืดสไตล์ WhatsApp
      appBar: AppBar(
        backgroundColor: const Color(0xFF202C33),
        title: Row(
          children: const [
            CircleAvatar(
              backgroundColor: Colors.purpleAccent,
              radius: 18,
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Meta AI / Sniper AI", style: TextStyle(color: Colors.white, fontSize: 15)),
                Text("ออนไลน์", style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
              ],
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg["sender"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF005C4B) : const Color(0xFF202C33),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["message"]!,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFF202C33),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A3942),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "ถาม Meta AI หรือค้นหา...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF00A884),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
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
