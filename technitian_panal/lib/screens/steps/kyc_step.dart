import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/api_service.dart';
import 'package:flutter/foundation.dart';

class KycStep extends StatefulWidget {
  final VoidCallback onNext;
  const KycStep({super.key, required this.onNext});

  @override
  State<KycStep> createState() => _KycStepState();
}

class _KycStepState extends State<KycStep> {
  String _selectedDocType = 'Aadhaar Card';
  final _docNumberController = TextEditingController();

  XFile? _frontImage;
  XFile? _backImage;

  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> _pickImage(bool isFront) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (isFront) {
        _frontImage = image;
      } else {
        _backImage = image;
      }
    });
  }

  Future<void> _handleNext() async {
    if (_docNumberController.text.isEmpty ||
        _frontImage == null ||
        _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and upload images'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload Images
      String? frontUrl = await _apiService.uploadImage(_frontImage);
      String? backUrl = await _apiService.uploadImage(_backImage);

      if (frontUrl == null || backUrl == null) {
        throw Exception("Image upload failed");
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _apiService.updateTechnicianProfile(
          firebaseUid: user.uid,
          data: {
            'kycType': _selectedDocType,
            'kycNumber': _docNumberController.text.trim(),
            'kycDocumentFront': frontUrl,
            'kycDocumentBack': backUrl,
          },
        );

        // Sync to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'kycType': _selectedDocType,
          // Don't save full number if sensitive, but requirement says "all data"
          'kycNumber': _docNumberController.text.trim(),
          'kycDocumentFront': frontUrl,
          'kycDocumentBack': backUrl,
          'kycStatus': 'submitted', // Or similar
        }, SetOptions(merge: true));

        widget.onNext();
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'KYC Verification',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload government issued ID proof.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Doc Type Dropdown
          DropdownButtonFormField<String>(
            value: _selectedDocType,
            decoration: InputDecoration(
              labelText: 'Document Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: [
              'Aadhaar Card',
              'Driving License',
              'Voter ID',
              'Passport',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedDocType = v!),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _docNumberController,
            decoration: InputDecoration(
              labelText: 'Document Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: _buildImageUpload(
                  'Front Side',
                  _frontImage,
                  () => _pickImage(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildImageUpload(
                  'Back Side',
                  _backImage,
                  () => _pickImage(false),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUpload(String label, XFile? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: file != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FutureBuilder<Uint8List>(
                      future: file.readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.data != null) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  )
                : const Center(
                    child: Icon(LucideIcons.uploadCloud, color: Colors.grey),
                  ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
