import 'package:flutter/material.dart';

class EmergencyContactItem {
  EmergencyContactItem({
    required this.name,
    required this.phone,
    this.enabled = true,
  });

  final String name;
  final String phone;
  bool enabled;
}

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final List<EmergencyContactItem> _contacts = [
    EmergencyContactItem(name: 'Sarah (Sister)', phone: '+251911223344', enabled: true),
  ];

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  void _addContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141418),
        title: const Text('Add Emergency Contact', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name / Relationship',
                labelStyle: TextStyle(color: Colors.white60),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number (+251...)',
                labelStyle: TextStyle(color: Colors.white60),
              ),
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                setState(() {
                  _contacts.add(
                    EmergencyContactItem(
                      name: _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                    ),
                  );
                });
                _nameController.clear();
                _phoneController.clear();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEA580C)),
            child: const Text('Add Contact', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
        title: const Text('Emergency Contacts', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.mark_email_read_outlined, color: Color(0xFFEA580C), size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Contacts saved here receive an automated SMS beacon when your date checks in.',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  const Text('Trusted Contacts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  IconButton(
                    onPressed: _addContact,
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFFEA580C)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _contacts.isEmpty
                    ? const Center(child: Text('No emergency contacts added yet.', style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        itemCount: _contacts.length,
                        itemBuilder: (context, index) {
                          final item = _contacts[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141418),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFEA580C),
                                child: Icon(Icons.person, color: Colors.white, size: 20),
                              ),
                              title: Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text(item.phone, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              trailing: Switch(
                                value: item.enabled,
                                activeColor: const Color(0xFFEA580C),
                                onChanged: (val) {
                                  setState(() => item.enabled = val);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
