import 'package:flutter/material.dart';

class SettingsForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onSave;

  const SettingsForm({
    super.key,
    required this.initialData,
    required this.onSave,
  });

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  late TextEditingController _titleController;
  late TextEditingController _itemsPerPageController;
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialData['title']);
    _itemsPerPageController = TextEditingController(
      text: widget.initialData['itemsPerPage'].toString(),
    );
    _darkMode = widget.initialData['darkMode'];
    _notificationsEnabled = widget.initialData['notificationsEnabled'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _itemsPerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Admin Panel Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _itemsPerPageController,
            decoration: const InputDecoration(
              labelText: 'Items Per Page',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a number';
              }
              if (int.tryParse(value) == null) {
                return 'Enter valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: widget.initialData['themeColor'],
            decoration: const InputDecoration(
              labelText: 'Theme Color',
              border: OutlineInputBorder(),
            ),
            items: ['Blue', 'Green', 'Purple', 'Orange']
                .map(
                  (color) => DropdownMenuItem(value: color, child: Text(color)),
                )
                .toList(),
            onChanged: (value) {},
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave({
                      'title': _titleController.text,
                      'itemsPerPage': int.parse(_itemsPerPageController.text),
                      'darkMode': _darkMode,
                      'notificationsEnabled': _notificationsEnabled,
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Save Settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
