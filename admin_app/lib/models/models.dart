class Booking {
  final int id;
  final int? userId;
  final int slotId;
  final String bookingDate;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String poojaName;
  final String? gotra;
  final String? rashi;
  final String status;
  final String? paymentId;
  final String? startTime;
  final String? endTime;
  final double? amount;

  Booking({
    required this.id,
    this.userId,
    required this.slotId,
    required this.bookingDate,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.poojaName,
    this.gotra,
    this.rashi,
    required this.status,
    this.paymentId,
    this.startTime,
    this.endTime,
    this.amount,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'],
      slotId: json['slot_id'],
      bookingDate: json['booking_date'],
      customerName: json['customer_name'],
      customerEmail: json['customer_email'],
      customerPhone: json['customer_phone'],
      poojaName: json['pooja_name'],
      gotra: json['gotra'],
      rashi: json['rashi'],
      status: json['status'] ?? 'pending',
      paymentId: json['payment_id'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) : null,
    );
  }
}

class Slot {
  final int id;
  final String date;
  final String startTime;
  final String endTime;
  final int maxBookings;
  final int currentBookings;
  final bool isAvailable;

  Slot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.maxBookings,
    required this.currentBookings,
    required this.isAvailable,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['id'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      maxBookings: json['max_bookings'] ?? 5,
      currentBookings: json['current_bookings'] ?? 0,
      isAvailable: json['is_available'] ?? true,
    );
  }
}

class DashboardStats {
  final int todayBookings;
  final double todayRevenue;
  final double weeklyRevenue;
  final double monthlyRevenue;

  DashboardStats({
    required this.todayBookings,
    required this.todayRevenue,
    required this.weeklyRevenue,
    required this.monthlyRevenue,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      todayBookings: json['today_bookings'] ?? 0,
      todayRevenue: double.tryParse(json['today_revenue'].toString()) ?? 0.0,
      weeklyRevenue: double.tryParse(json['weekly_revenue'].toString()) ?? 0.0,
      monthlyRevenue: double.tryParse(json['monthly_revenue'].toString()) ?? 0.0,
    );
  }
}
