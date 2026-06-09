import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'login_screen.dart';
import 'bookings_list_screen.dart';
import 'slots_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
    });

    final stats = await ApiService().fetchDashboardStats();
    
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    await ApiService().logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF04020E);
    const cardColor = Color(0xFF080415);
    const goldPrimary = Color(0xFFD4AF37);
    const goldLight = Color(0xFFF0D060);
    const textStarlight = Colors.white;
    const textMuted = Colors.white70;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: TextStyle(
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: goldLight,
          ),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: goldPrimary),
            onPressed: _loadStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: goldPrimary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Sacred Analytics",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: textStarlight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Grid of stats
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      _buildStatCard(
                        title: "Today's Bookings",
                        value: "${_stats?.todayBookings ?? 0}",
                        icon: Icons.calendar_today,
                        color: goldPrimary,
                        cardColor: cardColor,
                        textStarlight: textStarlight,
                      ),
                      _buildStatCard(
                        title: "Today's Revenue",
                        value: "₹${_stats?.todayRevenue.toStringAsFixed(0) ?? '0'}",
                        icon: Icons.currency_rupee,
                        color: Colors.greenAccent,
                        cardColor: cardColor,
                        textStarlight: textStarlight,
                      ),
                      _buildStatCard(
                        title: "Weekly Revenue",
                        value: "₹${_stats?.weeklyRevenue.toStringAsFixed(0) ?? '0'}",
                        icon: Icons.trending_up,
                        color: goldLight,
                        cardColor: cardColor,
                        textStarlight: textStarlight,
                      ),
                      _buildStatCard(
                        title: "Monthly Revenue",
                        value: "₹${_stats?.monthlyRevenue.toStringAsFixed(0) ?? '0'}",
                        icon: Icons.account_balance,
                        color: Colors.cyanAccent,
                        cardColor: cardColor,
                        textStarlight: textStarlight,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    "Quick Controls",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: textStarlight,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Control cards
                  _buildControlCard(
                    title: "Booking Management",
                    subtitle: "View, search and verify customer bookings",
                    icon: Icons.book_online,
                    color: goldPrimary,
                    cardColor: cardColor,
                    textColor: textStarlight,
                    subColor: textMuted,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BookingsListScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildControlCard(
                    title: "Slot Scheduling",
                    subtitle: "Add, modify or delete available pooja slots",
                    icon: Icons.schedule,
                    color: goldLight,
                    cardColor: cardColor,
                    textColor: textStarlight,
                    subColor: textMuted,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SlotsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required Color textStarlight,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Icon(icon, color: color, size: 24),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textStarlight,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required Color textColor,
    required Color subColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: subColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
