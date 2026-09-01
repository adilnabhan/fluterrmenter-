import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mentor_mobile_app/imports_bindings.dart';
import 'package:mentor_mobile_app/core/network/dio_client.dart';

class SelfClientsScreen extends StatefulWidget {
  const SelfClientsScreen({super.key});

  @override
  State<SelfClientsScreen> createState() => _SelfClientsScreenState();
}

class _SelfClientsScreenState extends State<SelfClientsScreen> {
  List<Map<String, dynamic>> _clients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchSelfClients();
  }

  Future<void> _fetchSelfClients() async {
    setState(() => _isLoading = true);
    try {
      final res = await DioClient().dio.get(
        ApiUris.trainerSelfClients,
        queryParameters: _searchQuery.isNotEmpty ? {'search': _searchQuery} : null,
      );
      if (res.statusCode == 200 && res.data != null) {
        final raw = res.data is Map ? (res.data['results'] ?? res.data['clients'] ?? []) : (res.data is List ? res.data : []);
        setState(() {
          _clients = List<Map<String, dynamic>>.from(raw);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddClientSheet() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime startDate = DateTime.now();
    bool isActive = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Self Client',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Client Name *',
                    hintText: 'e.g. John Doe',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number *',
                    hintText: 'e.g. 9876543210',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address (Optional)',
                    hintText: 'e.g. client@gmail.com',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Training Plan / Notes',
                    hintText: 'e.g. 3x/week hypertrophy, WhatsApp lead',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Active Client Status', style: TextStyle(fontWeight: FontWeight.w600)),
                    Switch(
                      value: isActive,
                      activeColor: const Color(0xFF0D3B2E),
                      onChanged: (val) => setModalState(() => isActive = val),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      final phone = phoneCtrl.text.trim();
                      if (name.isEmpty || phone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter name and phone number.')),
                        );
                        return;
                      }

                      final parts = name.split(' ');
                      final fName = parts.first;
                      final lName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

                      try {
                        final res = await DioClient().dio.post(
                          ApiUris.trainerSelfClients,
                          data: {
                            'first_name': fName,
                            'last_name': lName,
                            'mobile_number': phone,
                            'email': emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                            'notes': notesCtrl.text.trim(),
                            'start_date': DateFormat('yyyy-MM-dd').format(startDate),
                            'is_active': isActive,
                          },
                        );

                        if (res.statusCode == 201 || res.statusCode == 200) {
                          Navigator.pop(ctx);
                          _fetchSelfClients();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Self client added successfully!')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add client: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D3B2E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Save Client', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Self Clients', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddClientSheet,
        backgroundColor: const Color(0xFF0D3B2E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Self Client', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Search & Info Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) {
                    _searchQuery = val;
                    _fetchSelfClients();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search self clients by name, phone...',
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchSelfClients,
                    child: _clients.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _clients.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final client = _clients[index];
                              return _buildClientCard(client);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client) {
    final bool isActive = client['is_active'] == true || client['status'] == 'Active';
    final name = client['name'] ?? 'Client';
    final phone = client['mobile_number'] ?? 'N/A';
    final notes = client['trainer_notes'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF0D3B2E).withOpacity(0.1),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'C',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0D3B2E), fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? 'ACTIVE' : 'INACTIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isActive ? const Color(0xFF166534) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          if (notes != null && notes.toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                notes.toString(),
                style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups_outlined, size: 60, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            const Text(
              'No Self Clients Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add your private/freelance clients here to manage them separately from gym-assigned clients.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showAddClientSheet,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Client'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B2E),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
