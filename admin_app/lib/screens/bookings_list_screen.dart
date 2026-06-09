import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  List<Booking> _bookings = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    String? dateStr;
    if (_selectedDate != null) {
      dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }

    final list = await ApiService().fetchBookings(
      query: _searchController.text.trim(),
      date: dateStr,
    );

    setState(() {
      _bookings = list;
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Color(0xFF04020E),
              surface: Color(0xFF080415),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadBookings();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedDate = null;
      _searchController.clear();
    });
    _loadBookings();
  }

  void _showBookingDetails(Booking booking) {
    const goldPrimary = Color(0xFFD4AF37);
    const goldLight = Color(0xFFF0D060);
    const cardColor = Color(0xFF080415);
    const textStarlight = Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text(
                      "Sacred Pooja Booking",
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: goldLight,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: textStarlight),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12),
                const SizedBox(height: 12),
                
                _buildDetailRow("Pooja / Type", booking.poojaName, isBold: true),
                _buildDetailRow("Customer Name", booking.customerName),
                _buildDetailRow("Phone Number", booking.customerPhone),
                _buildDetailRow("Email Address", booking.customerEmail),
                _buildDetailRow("Date", booking.bookingDate),
                _buildDetailRow("Time Slot", booking.startTime != null && booking.endTime != null
                    ? "${booking.startTime} - ${booking.endTime}"
                    : "No slot details"),
                _buildDetailRow("Gotra", booking.gotra ?? "Not provided"),
                _buildDetailRow("Rashi", booking.rashi ?? "Not provided"),
                
                const SizedBox(height: 12),
                const Divider(color: Colors.white12),
                const SizedBox(height: 12),
                
                _buildDetailRow("Dakshina (Fee)", "₹${booking.amount?.toStringAsFixed(2) ?? '2000.00'}", valueColor: goldPrimary),
                _buildDetailRow("Status", booking.status.toUpperCase(),
                    valueColor: booking.status == 'confirmed' ? Colors.greenAccent : Colors.orangeAccent),
                _buildDetailRow("Razorpay Pay ID", booking.paymentId ?? "Pending payment"),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF04020E);
    const cardColor = Color(0xFF080415);
    const goldPrimary = Color(0xFFD4AF37);
    const goldLight = Color(0xFFF0D060);
    const textStarlight = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Customer Bookings",
          style: TextStyle(
            fontFamily: 'serif',
            color: goldLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        actions: [
          if (_selectedDate != null || _searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.filter_alt_off, color: Colors.redAccent),
              onPressed: _clearFilters,
            )
        ],
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: cardColor,
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: textStarlight),
                  decoration: InputDecoration(
                    hintText: "Search customer, phone, pooja...",
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: goldPrimary),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: goldPrimary),
                      onPressed: _loadBookings,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: goldPrimary.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: goldPrimary),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onSubmitted: (_) => _loadBookings(),
                ),
                const SizedBox(height: 12),
                
                // Date Picker row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? "All Dates"
                          : "Date: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}",
                      style: const TextStyle(color: textStarlight, fontSize: 14),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _selectDate(context),
                      icon: const Icon(Icons.calendar_today, size: 16, color: goldPrimary),
                      label: const Text("Select Date"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: goldLight,
                        side: BorderSide(color: goldPrimary.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Bookings List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: goldPrimary))
                : _bookings.isEmpty
                    ? const Center(
                        child: Text(
                          "No bookings found.",
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];
                          final isConfirmed = booking.status == 'confirmed';
                          
                          return Card(
                            color: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: isConfirmed
                                    ? Colors.greenAccent.withOpacity(0.15)
                                    : goldPrimary.withOpacity(0.15),
                              ),
                            ),
                            margin: const EdgeInsets.bottom(12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking.poojaName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isConfirmed
                                          ? Colors.greenAccent.withOpacity(0.1)
                                          : Colors.orangeAccent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      booking.status.toUpperCase(),
                                      style: TextStyle(
                                        color: isConfirmed ? Colors.greenAccent : Colors.orangeAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 14, color: Colors.white38),
                                      const SizedBox(width: 4),
                                      Text(
                                        booking.customerName,
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.phone, size: 14, color: Colors.white38),
                                      const SizedBox(width: 4),
                                      Text(
                                        booking.customerPhone,
                                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: Colors.white38),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${booking.bookingDate} | ${booking.startTime != null ? formatTime12Hour(booking.startTime!) : 'No slot'}",
                                        style: const TextStyle(color: goldLight, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right, color: goldPrimary),
                              onTap: () => _showBookingDetails(booking),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String formatTime12Hour(String timeStr) {
    try {
      final parts = timeStr.split(':');
      int hours = int.parse(parts[0]);
      final minutes = parts[1];
      final ampm = hours >= 12 ? 'PM' : 'AM';
      hours = hours % 12;
      hours = hours != 0 ? hours : 12;
      return '$hours:$minutes $ampm';
    } catch (_) {
      return timeStr;
    }
  }
}
