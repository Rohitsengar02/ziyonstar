import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import '../../responsive.dart';

class NotificationsPrefsScreen extends StatefulWidget {
  const NotificationsPrefsScreen({super.key});

  @override
  State<NotificationsPrefsScreen> createState() =>
      _NotificationsPrefsScreenState();
}

class _NotificationsPrefsScreenState extends State<NotificationsPrefsScreen> {
  bool _newOrders = true;
  bool _orderUpdates = true;
  bool _payoutAlerts = true;
  bool _systemAlerts = false;
  bool _marketing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Responsive(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Order Alerts'),
              const SizedBox(height: 16),
              _buildSwitchTile(
                'New Service Requests',
                'Get notified when a new customer request matches your skills',
                _newOrders,
                (val) => setState(() => _newOrders = val),
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                'Order Status Updates',
                'Updates regarding ongoing repairs and customer messages',
                _orderUpdates,
                (val) => setState(() => _orderUpdates = val),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Financial & System'),
              const SizedBox(height: 16),
              _buildSwitchTile(
                'Payout Notifications',
                'Alerts when a payout is processed to your bank account',
                _payoutAlerts,
                (val) => setState(() => _payoutAlerts = val),
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                'System Maintenance',
                'Critical updates about platform availability',
                _systemAlerts,
                (val) => setState(() => _systemAlerts = val),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Other'),
              const SizedBox(height: 16),
              _buildSwitchTile(
                'Promotions & News',
                'Periodic updates about new features and partner offers',
                _marketing,
                (val) => setState(() => _marketing = val),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryButton,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Preferences',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String sub,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryButton,
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          sub,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
        ),
      ),
    );
  }
}
