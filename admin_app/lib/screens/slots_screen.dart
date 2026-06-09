import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class SlotsScreen extends StatefulWidget {
  const SlotsScreen({super.key});

  @override
  State<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends State<SlotsScreen> {
  List<Slot> _slots = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _isLoading = true;
    });

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final list = await ApiService().fetchSlots(date: dateStr);

    setState(() {
      _slots = list;
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
      _loadSlots();
    }
  }

  Future<void> _showAddSlotDialog() async {
    final formKey = GlobalKey<FormState>();
    final maxBookingsController = TextEditingController(text: "5");
    DateTime slotDate = _selectedDate;
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 12, minute: 0);

    const goldPrimary = Color(0xFFD4AF37);
    const cardColor = Color(0xFF080415);
    const textStarlight = Colors.white;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
              title: const Text(
                "Create New Pooja Slot",
                style: TextStyle(color: goldPrimary, fontFamily: 'serif'),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Date selector row
                      ListTile(
                        title: Text(
                          "Date: ${DateFormat('dd MMM yyyy').format(slotDate)}",
                          style: const TextStyle(color: textStarlight, fontSize: 14),
                        ),
                        trailing: const Icon(Icons.calendar_today, color: goldPrimary),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: slotDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 90)),
                          );
                          if (picked != null) {
                            setDialogState(() => slotDate = picked);
                          }
                        },
                      ),
                      
                      // Start Time row
                      ListTile(
                        title: Text(
                          "Start Time: ${startTime.format(context)}",
                          style: const TextStyle(color: textStarlight, fontSize: 14),
                        ),
                        trailing: const Icon(Icons.access_time, color: goldPrimary),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );
                          if (picked != null) {
                            setDialogState(() => startTime = picked);
                          }
                        },
                      ),
                      
                      // End Time row
                      ListTile(
                        title: Text(
                          "End Time: ${endTime.format(context)}",
                          style: const TextStyle(color: textStarlight, fontSize: 14),
                        ),
                        trailing: const Icon(Icons.access_time, color: goldPrimary),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );
                          if (picked != null) {
                            setDialogState(() => endTime = picked);
                          }
                        },
                      ),
                      
                      // Max Bookings field
                      TextFormField(
                        controller: maxBookingsController,
                        style: const TextStyle(color: textStarlight),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Max Bookings capacity",
                          labelStyle: TextStyle(color: Colors.white54),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter maximum bookings';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL", style: TextStyle(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    
                    final dateStr = DateFormat('yyyy-MM-dd').format(slotDate);
                    
                    // Format time to HH:MM:SS
                    final sh = startTime.hour.toString().padLeft(2, '0');
                    final sm = startTime.minute.toString().padLeft(2, '0');
                    final startStr = "$sh:$sm:00";
                    
                    final eh = endTime.hour.toString().padLeft(2, '0');
                    final em = endTime.minute.toString().padLeft(2, '0');
                    final endStr = "$eh:$em:00";

                    final newSlot = await ApiService().createSlot(
                      dateStr,
                      startStr,
                      endStr,
                      int.parse(maxBookingsController.text),
                    );

                    if (mounted) {
                      Navigator.pop(context);
                      if (newSlot != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Slot created successfully")),
                        );
                        _loadSlots();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Failed to create slot (Conflict)")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: goldPrimary),
                  child: const Text("CREATE", style: TextStyle(color: Color(0xFF04020E))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditSlotDialog(Slot slot) async {
    final formKey = GlobalKey<FormState>();
    final maxBookingsController = TextEditingController(text: "${slot.maxBookings}");
    bool isAvailable = slot.isAvailable;

    const goldPrimary = Color(0xFFD4AF37);
    const cardColor = Color(0xFF080415);
    const textStarlight = Colors.white;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
              title: const Text(
                "Modify Pooja Slot",
                style: TextStyle(color: goldPrimary, fontFamily: 'serif'),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Time: ${formatTime12Hour(slot.startTime)} - ${formatTime12Hour(slot.endTime)}",
                      style: const TextStyle(color: textStarlight, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: maxBookingsController,
                      style: const TextStyle(color: textStarlight),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Max Bookings capacity",
                        labelStyle: TextStyle(color: Colors.white54),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter maximum bookings';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text("Is Available to Book", style: TextStyle(color: textStarlight, fontSize: 14)),
                      value: isAvailable,
                      activeColor: goldPrimary,
                      onChanged: (val) {
                        setDialogState(() => isAvailable = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL", style: TextStyle(color: Colors.redAccent)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final updated = await ApiService().updateSlot(
                      slot.id,
                      int.parse(maxBookingsController.text),
                      isAvailable,
                    );

                    if (mounted) {
                      Navigator.pop(context);
                      if (updated != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Slot updated successfully")),
                        );
                        _loadSlots();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Failed to update slot")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: goldPrimary),
                  child: const Text("UPDATE", style: TextStyle(color: Color(0xFF04020E))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleDeleteSlot(Slot slot) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF080415),
        title: const Text("Confirm Delete", style: TextStyle(color: Colors.redAccent)),
        content: const Text("Are you sure you want to delete this slot?", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("NO"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("YES"),
          )
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService().deleteSlot(slot.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Slot deleted successfully")),
          );
          _loadSlots();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to delete slot (Active bookings exist)")),
          );
        }
      }
    }
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
          "Slot Management",
          style: TextStyle(
            fontFamily: 'serif',
            color: goldLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cardColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text(
                  "Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}",
                  style: const TextStyle(color: textStarlight, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                OutlinedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today, size: 16, color: goldPrimary),
                  label: const Text("Change Date"),
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
          ),
          
          // Slots List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: goldPrimary))
                : _slots.isEmpty
                    ? const Center(
                        child: Text(
                          "No slots scheduled for this date.",
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _slots.length,
                        itemBuilder: (context, index) {
                          final slot = _slots[index];
                          final isAvailable = slot.isAvailable;
                          final remains = slot.maxBookings - slot.currentBookings;
                          
                          return Card(
                            color: cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: goldPrimary.withOpacity(0.15)),
                            ),
                            margin: const EdgeInsets.bottom(12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              title: Text(
                                "${formatTime12Hour(slot.startTime)} - ${formatTime12Hour(slot.endTime)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text(
                                    "Bookings: ${slot.currentBookings} / ${slot.maxBookings}  (${remains} left)",
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isAvailable && remains > 0
                                              ? Colors.greenAccent.withOpacity(0.1)
                                              : Colors.redAccent.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isAvailable && remains > 0 ? "ACTIVE" : "UNAVAILABLE",
                                          style: TextStyle(
                                            color: isAvailable && remains > 0 ? Colors.greenAccent : Colors.redAccent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: goldPrimary),
                                    onPressed: () => _showEditSlotDialog(slot),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _handleDeleteSlot(slot),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSlotDialog,
        backgroundColor: goldPrimary,
        child: const Icon(Icons.add, color: Color(0xFF04020E)),
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
