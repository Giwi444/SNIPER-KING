/////////////////////////////////////////////////////////////////////// 8. ORDERS SCREEN ////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////

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
  String activeSymbol = 'BTCUSD';
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

  void _listenToOrders() {
    try {
      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://liquidity-b8739-default-rtdb.asia-southeast1.firebasedatabase.app/',
      );

      // ระบบจะเช็กทั้งจากพาสหลัก 'orders' และพาสใต้บัญชี 'accounts/{login}/orders' อัตโนมัติ
      database.ref('accounts/${widget.accountLogin}/orders').onValue.listen((event) {
        final data = event.snapshot.value;
        if (data != null && mounted) {
          _parseOrdersData(data);
        } else {
          // ถ้าไม่มีใน accounts ให้ลองดึงจากพาส 'orders' กลางแทน
          database.ref('orders').onValue.listen((fallbackEvent) {
            final fallbackData = fallbackEvent.snapshot.value;
            if (mounted) {
              _parseOrdersData(fallbackData);
            }
          });
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
                    child: Container(
                      color: const Color(0xFF161619).withOpacity(0.95),
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
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                              child: Text(
                                'ACTIVE ORDERS (${activeOrders.length})',
                                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1, fontFamily: 'monospace'),
                              ),
                            ),
                          ),
                          activeOrders.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40.0),
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
                                    final double priceOpen = double.tryParse(order['price_open']?.toString() ?? '0.0') -> 0.0;
                                    final String symbol = order['symbol']?.toString() ?? activeSymbol;
                                    bool isBuy = type.toUpperCase().contains('BUY');
                                    bool orderProfit = profit >= 0;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0B0B0E),
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
                                                  Text('Lot: $lot', style: const TextStyle(color: Colors.grey, fontSize: 10, fontFamily: 'monospace')),
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
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B0E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.grey, size: 14),
              const SizedBox(width: 4),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'monospace')),
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
