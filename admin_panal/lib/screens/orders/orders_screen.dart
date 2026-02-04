import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'order_detail_screen.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedTechnician = 'All';
  String _selectedBrand = 'All';
  String _selectedPayment = 'All';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final orders = await ApiService().getBookings();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      setState(() => _isLoading = false);
    }
  }

  List<String> get _allTechnicians {
    final techs = _orders
        .map((o) => o['technicianId']?['name']?.toString())
        .where((name) => name != null)
        .cast<String>()
        .toSet()
        .toList();
    techs.sort();
    return ['All', ...techs];
  }

  List<String> get _allBrands {
    final brands = _orders
        .map((o) => o['deviceBrand']?.toString())
        .where((brand) => brand != null && brand.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    brands.sort();
    return ['All', ...brands];
  }

  List<dynamic> get _filteredOrders {
    return _orders.where((order) {
      // Search Filter
      final id = order['_id'].toString().toUpperCase();
      final userName = (order['userId']?['name'] ?? '')
          .toString()
          .toLowerCase();
      final device =
          '${order['deviceBrand'] ?? ''} ${order['deviceModel'] ?? ''}'
              .toLowerCase();
      final query = _searchQuery.toLowerCase();

      bool matchesSearch =
          id.contains(query.toUpperCase()) ||
          userName.contains(query) ||
          device.contains(query);

      // Status Filter
      bool matchesStatus = true;
      if (_selectedStatus != 'All') {
        if (_selectedStatus == 'Active') {
          matchesStatus =
              order['status'] == 'In_Progress' || order['status'] == 'Accepted';
        } else if (_selectedStatus == 'Pending') {
          matchesStatus =
              order['status'] == 'Pending_Assignment' ||
              order['status'] == 'Pending_Acceptance';
        } else {
          matchesStatus = order['status'] == _selectedStatus;
        }
      }

      // Technician Filter
      bool matchesTech = true;
      if (_selectedTechnician != 'All') {
        matchesTech = order['technicianId']?['name'] == _selectedTechnician;
      }

      // Brand Filter
      bool matchesBrand = true;
      if (_selectedBrand != 'All') {
        matchesBrand = order['deviceBrand'] == _selectedBrand;
      }

      // Payment Filter
      bool matchesPayment = true;
      if (_selectedPayment != 'All') {
        matchesPayment = order['paymentStatus'] == _selectedPayment;
      }

      return matchesSearch &&
          matchesStatus &&
          matchesTech &&
          matchesBrand &&
          matchesPayment;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          'Order Management',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchOrders();
            },
            icon: const Icon(LucideIcons.refreshCw, size: 20),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildOrderStats(),
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.searchX,
                          size: 48,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matches found for your criteria',
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(_filteredOrders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search by ID, Customer or Device...',
              hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
              prefixIcon: const Icon(LucideIcons.search, size: 18),
              filled: true,
              fillColor: const Color(0xFFF6F8FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 12),
          // Status Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Active'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Completed'),
                const SizedBox(width: 8),
                _buildFilterChip('Cancelled'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Dropdowns Row
          Row(
            children: [
              // Technician
              Expanded(
                child: _buildDropdown(
                  value: _selectedTechnician,
                  hint: 'Technician',
                  items: _allTechnicians,
                  onChanged: (val) =>
                      setState(() => _selectedTechnician = val!),
                ),
              ),
              const SizedBox(width: 12),
              // Brand
              Expanded(
                child: _buildDropdown(
                  value: _selectedBrand,
                  hint: 'Brand',
                  items: _allBrands,
                  onChanged: (val) => setState(() => _selectedBrand = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Payment Filter
          Row(
            children: [
              Text(
                'Payment Status:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              _buildSmallChip(
                'All',
                isSelected: _selectedPayment == 'All',
                onTap: () => setState(() => _selectedPayment = 'All'),
              ),
              const SizedBox(width: 8),
              _buildSmallChip(
                'Pending',
                isSelected: _selectedPayment == 'Pending',
                onTap: () => setState(() => _selectedPayment = 'Pending'),
              ),
              const SizedBox(width: 8),
              _buildSmallChip(
                'Paid',
                isSelected: _selectedPayment == 'Paid',
                onTap: () => setState(() => _selectedPayment = 'Paid'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: GoogleFonts.inter(fontSize: 12)),
          icon: const Icon(LucideIcons.chevronDown, size: 14),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(
                val,
                style: GoogleFonts.inter(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedStatus == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallChip(
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primary : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderStats() {
    int active = _orders
        .where((o) => o['status'] == 'In_Progress' || o['status'] == 'Accepted')
        .length;
    int pending = _orders
        .where(
          (o) =>
              o['status'] == 'Pending_Assignment' ||
              o['status'] == 'Pending_Acceptance',
        )
        .length;
    int completed = _orders.where((o) => o['status'] == 'Completed').length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniStat(
            'Active',
            active.toString().padLeft(2, '0'),
            Colors.blue,
          ),
          _buildMiniStat(
            'Pending',
            pending.toString().padLeft(2, '0'),
            Colors.orange,
          ),
          _buildMiniStat(
            'Completed',
            completed.toString().padLeft(2, '0'),
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String val, Color color) {
    return Column(
      children: [
        Text(
          val,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildOrderCard(dynamic order) {
    String status = order['status'] ?? 'Pending';
    Color statusColor = status == 'In_Progress'
        ? Colors.blue
        : (status.contains('Pending'))
        ? Colors.orange
        : status == 'Cancelled'
        ? Colors.red
        : Colors.green;

    String id = order['_id']
        .toString()
        .substring(order['_id'].toString().length - 8)
        .toUpperCase();
    String userName = order['userId']?['name'] ?? 'Unknown User';
    String techName = order['technicianId']?['name'] ?? 'Unassigned';
    String device =
        '${order['deviceBrand'] ?? ''} ${order['deviceModel'] ?? 'Device'}'
            .trim();

    List<dynamic> issues = order['issues'] ?? [];
    String issueStr = issues.isNotEmpty
        ? (issues[0] is Map ? issues[0]['issueName'] : issues[0].toString())
        : 'Repair Service';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          ),
        );
        _fetchOrders();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#ORD-$id',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.replaceAll('_', ' '),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.smartphone, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        issueStr,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${order['totalPrice']}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.user, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      userName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.hardHat,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      techName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
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
}
