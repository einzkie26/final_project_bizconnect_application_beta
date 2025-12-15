import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Bug Report';
  String _selectedPriority = 'Medium';
  bool _isSubmitting = false;
  String? _evidenceUrl;

  final List<String> _reportTypes = [
    'Bug Report',
    'Feature Request',
    'User Report',
    'Chat Report',
    'Company Report',
    'General Inquiry'
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('bizSupport', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2E3192),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E3192), Color(0xFF4285F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.support_agent, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'bizSupport',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We\'re here to help you succeed',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Submit Support Request',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3192),
              ),
            ),
            const SizedBox(height: 24),
            _buildDropdown('Issue Type', _selectedType, _reportTypes, (value) => setState(() => _selectedType = value!)),
            const SizedBox(height: 16),
            _buildDropdown('Priority Level', _selectedPriority, _priorities, (value) => setState(() => _selectedPriority = value!)),
            const SizedBox(height: 16),
            _buildTextField('Title', _titleController, 'Brief description of your issue'),
            const SizedBox(height: 16),
            _buildTextField('Description', _descriptionController, 'Provide detailed information', maxLines: 4),
            const SizedBox(height: 16),
            _buildEvidenceSection(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E3192),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Request',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2E3192))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E3192), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2E3192))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E3192), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) => value?.isEmpty == true ? 'Please enter $label' : null,
        ),
      ],
    );
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Please log in');

      final reportId = 'R${DateTime.now().millisecondsSinceEpoch}';
      
      await FirebaseFirestore.instance.collection('admin_reports').add({
        'id': reportId,
        'type': _selectedType,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'priority': _selectedPriority,
        'status': 'Pending',
        'reportedBy': user.uid,
        'reportedByEmail': user.email ?? 'No email',
        'evidenceUrl': _evidenceUrl,
        'date': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Send system message to user
      await _sendSystemMessage(user.uid, reportId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket submitted successfully!')),
        );
        _titleController.clear();
        _descriptionController.clear();
        setState(() => _evidenceUrl = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _sendSystemMessage(String userId, String reportId) async {
    try {
      // Find existing system chat or create new one
      final existingChats = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: userId)
          .get();
      
      String? chatId;
      for (var doc in existingChats.docs) {
        final participants = List<String>.from(doc.data()['participants']);
        if (participants.contains('system')) {
          chatId = doc.id;
          break;
        }
      }
      
      final message = 'Your support ticket $reportId has been submitted successfully. Our team will review it shortly.';
      
      if (chatId != null) {
        // Update existing chat
        await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
          'lastMessage': message,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'type': 'personal',
        });
      } else {
        // Create new chat
        final newChat = await FirebaseFirestore.instance.collection('chats').add({
          'participants': [userId, 'system'],
          'lastMessage': message,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'type': 'personal',
        });
        chatId = newChat.id;
      }
      
      // Add message
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': 'system',
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
      });
    } catch (e) {
      // Silent fail for system message
    }
  }

  Widget _buildEvidenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Evidence (Optional)', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2E3192))),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Column(
            children: [
              if (_evidenceUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(_evidenceUrl!, height: 150, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _uploadEvidence,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Replace Image'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _evidenceUrl = null),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Remove'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                const Text('Upload screenshot or photo evidence', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _uploadEvidence,
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Image'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E3192)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _uploadEvidence() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload'),
        body: {'key': '493f13fa424a0c9fca4c01f64cdb0b0f', 'image': base64Image},
      );
      
      final data = json.decode(response.body);
      setState(() => _evidenceUrl = data['data']['url']);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image'), backgroundColor: Colors.red),
      );
    }
  }
}