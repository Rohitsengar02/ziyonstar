import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RepairExpertiseStep extends StatefulWidget {
  final VoidCallback onNext;
  const RepairExpertiseStep({super.key, required this.onNext});

  @override
  State<RepairExpertiseStep> createState() => _RepairExpertiseStepState();
}

class _RepairExpertiseStepState extends State<RepairExpertiseStep> {
  final ApiService _apiService = ApiService();
  List<dynamic> _issues = [];
  final Set<String> _selectedIssueIds = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchIssues();
  }

  Future<void> _fetchIssues() async {
    try {
      final issues = await _apiService.getIssues();
      if (mounted) {
        setState(() {
          _issues = issues;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('Error loading issues: $e');
    }
  }

  Future<void> _handleNext() async {
    if (_selectedIssueIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one repair issue'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _apiService.updateTechnicianProfile(
          firebaseUid: user.uid,
          data: {'repairExpertise': _selectedIssueIds.toList()},
        );

        // Sync to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'repairExpertise': _selectedIssueIds.toList(),
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
                  'Repair Expertise',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'What kind of repairs can you perform?',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                if (_issues.isEmpty)
                  const Center(child: Text("No issues found."))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600
                          ? 3
                          : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _issues.length,
                    itemBuilder: (context, index) {
                      final issue = _issues[index];
                      final id = issue['_id'] as String;
                      final isSelected = _selectedIssueIds.contains(id);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedIssueIds.remove(id);
                            } else {
                              _selectedIssueIds.add(id);
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
                                        ? const Color(0xFF0F172A)
                                        : Colors.grey.shade200,
                                    width: isSelected ? 2 : 1.5,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child:
                                            issue['imageUrl'] != null &&
                                                issue['imageUrl'].isNotEmpty
                                            ? Image.network(
                                                issue['imageUrl'],
                                                errorBuilder: (c, e, s) =>
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.build,
                                                          color: Colors.grey,
                                                          size: 40,
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          issue['category'] ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                fit: BoxFit.contain,
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.build,
                                                    color: Colors.grey,
                                                    size: 40,
                                                  ),
                                                  if (issue['category'] !=
                                                      null) ...[
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      issue['category'],
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            LucideIcons.checkCircle,
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
                              issue['name'] ?? 'Unknown',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (issue['base_price'] != null)
                              Text(
                                "₹${issue['base_price']}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
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
