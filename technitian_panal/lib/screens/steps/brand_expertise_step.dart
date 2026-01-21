import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BrandExpertiseStep extends StatefulWidget {
  final VoidCallback onNext;
  const BrandExpertiseStep({super.key, required this.onNext});

  @override
  State<BrandExpertiseStep> createState() => _BrandExpertiseStepState();
}

class _BrandExpertiseStepState extends State<BrandExpertiseStep> {
  final ApiService _apiService = ApiService();
  List<dynamic> _brands = [];
  final Set<String> _selectedBrandIds = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchBrands();
  }

  Future<void> _fetchBrands() async {
    try {
      final brands = await _apiService.getBrands();
      if (mounted) {
        setState(() {
          _brands = brands;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('Error loading brands: $e');
    }
  }

  Future<void> _handleNext() async {
    if (_selectedBrandIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one brand')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _apiService.updateTechnicianProfile(
          firebaseUid: user.uid,
          data: {'brandExpertise': _selectedBrandIds.toList()},
        );

        // Sync to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'brandExpertise': _selectedBrandIds.toList(),
        }, SetOptions(merge: true));

        widget.onNext();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Brand Expertise',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select the brands you are authorized or experienced to service.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                if (_brands.isEmpty)
                  const Center(child: Text("No brands found."))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 columns like the design
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: _brands.length,
                    itemBuilder: (context, index) {
                      final brand = _brands[index];
                      final id = brand['_id'] as String;
                      final isSelected = _selectedBrandIds.contains(id);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedBrandIds.remove(id);
                            } else {
                              _selectedBrandIds.add(id);
                            }
                          });
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(
                                            0xFF0F172A,
                                          ) // Dark/Black border
                                        : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1.5,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Image
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Image.network(
                                          brand['imageUrl'] ?? '',
                                          errorBuilder: (c, e, s) => const Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          ),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    // Checkmark
                                    if (isSelected)
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            // color: Colors.black, // Depending on design, icon might be black itself
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            LucideIcons
                                                .checkCircle, // Needs LucideIcons import or use Icons.check_circle_outline
                                            color: Color(0xFF0F172A),
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              brand['title'] ?? 'Unknown',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Continue'),
            ),
          ),
        ),
      ],
    );
  }
}
