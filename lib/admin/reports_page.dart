import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_analytics_page.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('admin_reports')
          .orderBy('createdAt', descending: true)
          .get();
      
      setState(() {
        _reports = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'docId': doc.id,
            'id': data['id'] ?? doc.id,
            'type': data['type'] ?? 'General',
            'title': data['title'] ?? '',
            'description': data['description'] ?? '',
            'reportedBy': data['reportedByEmail'] ?? 'Unknown',
            'status': data['status'] ?? 'Pending',
            'date': data['date']?.substring(0, 10) ?? DateTime.now().toIso8601String().substring(0, 10),
            'priority': data['priority'] ?? 'Medium',
            'evidenceUrl': data['evidenceUrl'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: const Color(0xFF2E3192),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Reports', icon: Icon(Icons.report)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportsTab(),
          const AdminAnalyticsPage(),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredReports = _getFilteredReports();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButton<String>(
            value: _selectedFilter,
            items: ['All', 'Pending', 'In Progress', 'Resolved']
                .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (value) => setState(() => _selectedFilter = value!),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredReports.length,
            itemBuilder: (context, index) {
              final report = filteredReports[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text(report['type']),
                  subtitle: Text('${report['reportedBy']} • ${report['date']}'),
                  trailing: Chip(
                    label: Text(report['status']),
                    backgroundColor: _getStatusColor(report['status']),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Title: ${report['title']}'),
                          const SizedBox(height: 8),
                          Text('Description: ${report['description']}'),
                          const SizedBox(height: 8),
                          if (report['evidenceUrl'] != null) ...[
                            const Text('Evidence:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _showImageDialog(report['evidenceUrl']),
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    report['evidenceUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Text('Failed to load image'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Tap image to zoom', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => _updateStatus(report['id'], 'Resolved'),
                                child: const Text('Resolve'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _updateStatus(report['id'], 'In Progress'),
                                child: const Text('In Progress'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredReports() {
    return _reports.where((report) {
      return _selectedFilter == 'All' || report['status'] == _selectedFilter;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'In Progress': return Colors.blue;
      case 'Resolved': return Colors.green;
      default: return Colors.grey;
    }
  }

  Future<void> _updateStatus(String reportId, String newStatus) async {
    try {
      final reportIndex = _reports.indexWhere((report) => report['id'] == reportId);
      if (reportIndex != -1) {
        final docId = _reports[reportIndex]['docId'];
        final userId = _reports[reportIndex]['reportedBy'];
        
        await FirebaseFirestore.instance
            .collection('admin_reports')
            .doc(docId)
            .update({'status': newStatus});
        
        // Send message to user if resolved
        if (newStatus == 'Resolved') {
          await _sendResolvedMessage(userId, reportId);
        }
        
        setState(() {
          _reports[reportIndex]['status'] = newStatus;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Report updated to $newStatus')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _sendResolvedMessage(String userId, String reportId) async {
    try {
      // Find existing system chat
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
      
      final message = 'Your support ticket $reportId has been resolved. Thank you for using bizSupport!';
      
      if (chatId != null) {
        // Update existing chat
        await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
          'lastMessage': message,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'type': 'personal',
        });
        
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
      }
    } catch (e) {
      // Silent fail for system message
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('Failed to load image', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}