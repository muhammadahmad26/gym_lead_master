import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_lead_master/services/notification_service.dart';
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/data/models/notification_model.dart';

class CreateNotificationScreen extends StatefulWidget {
  final String gymId;
  const CreateNotificationScreen({super.key, required this.gymId});

  @override
  State<CreateNotificationScreen> createState() =>
      _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends State<CreateNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _msgCtrl = TextEditingController();

  NotificationType _selectedType = NotificationType.general;
  String _sendTo = 'all'; // 'all' or specific userIds
  List<String> _selectedUserIds = [];

  bool _isSending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      List<String> targets = _sendTo == 'all' ? ['all'] : _selectedUserIds;

      await NotificationService().sendNotificationToMembers(
        gymId: widget.gymId,
        title: _titleCtrl.text.trim(),
        message: _msgCtrl.text.trim(),
        type: _selectedType,
        targetUserIds: targets,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Notification Sent!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Back arrow color
        ),
        title: const Text(
          "Create Notification",
          style: TextStyle(color: AppColors.whiteColor),
        ),
        backgroundColor: AppColors.DarkBlueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtrl,
                validator: (v) => v!.isEmpty ? "Required" : null,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _msgCtrl,
                validator: (v) => v!.isEmpty ? "Required" : null,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Message",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              _NotificationTypeDropdown(
                initialType: _selectedType,
                onChanged: (val) => _selectedType = val,
              ),
              const SizedBox(height: 16),

              _SendToSelector(
                gymId: widget.gymId,
                onChanged: (sendTo, selectedUserIds) {
                  _sendTo = sendTo;
                  _selectedUserIds = selectedUserIds;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueColor,
                    padding: const EdgeInsets.all(14),
                  ),
                  child:
                      _isSending
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "SEND NOTIFICATION",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTypeDropdown extends StatefulWidget {
  final NotificationType initialType;
  final ValueChanged<NotificationType> onChanged;

  const _NotificationTypeDropdown({
    required this.initialType,
    required this.onChanged,
  });

  @override
  State<_NotificationTypeDropdown> createState() =>
      _NotificationTypeDropdownState();
}

class _NotificationTypeDropdownState extends State<_NotificationTypeDropdown> {
  late NotificationType _selectedType = widget.initialType;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<NotificationType>(
      value: _selectedType,
      items:
          NotificationType.values
              .map(
                (type) =>
                    DropdownMenuItem(value: type, child: Text(type.label)),
              )
              .toList(),
      onChanged: (val) {
        setState(() => _selectedType = val!);
        widget.onChanged(val!);
      },
      decoration: const InputDecoration(
        labelText: "Notification Type",
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _SendToSelector extends StatefulWidget {
  final String gymId;
  final void Function(String sendTo, List<String> selectedUserIds) onChanged;

  const _SendToSelector({required this.gymId, required this.onChanged});

  @override
  State<_SendToSelector> createState() => _SendToSelectorState();
}

class _SendToSelectorState extends State<_SendToSelector> {
  String _sendTo = 'all';
  final List<String> _selectedUserIds = [];

  void _notifyParent() {
    widget.onChanged(_sendTo, _selectedUserIds);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Send To:", style: TextStyle(fontWeight: FontWeight.bold)),
        RadioListTile<String>(
          value: 'all',
          groupValue: _sendTo,
          onChanged: (val) {
            setState(() => _sendTo = val!);
            _notifyParent();
          },
          title: const Text("All Members"),
        ),
        RadioListTile<String>(
          value: 'selected',
          groupValue: _sendTo,
          onChanged: (val) {
            setState(() => _sendTo = val!);
            _notifyParent();
          },
          title: const Text("Selected Members"),
        ),
        if (_sendTo == 'selected') _buildMemberSelector(),
      ],
    );
  }

  Widget _buildMemberSelector() {
    return SizedBox(
      height: 150,
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('gyms')
                .doc(widget.gymId)
                .collection('members')
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          var members = snapshot.data!.docs;

          return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              var data = members[index].data() as Map<String, dynamic>;
              String uid = data['uid'];
              String name = data['name'];

              return CheckboxListTile(
                value: _selectedUserIds.contains(uid),
                title: Text(name),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedUserIds.add(uid);
                    } else {
                      _selectedUserIds.remove(uid);
                    }
                  });
                  _notifyParent();
                },
              );
            },
          );
        },
      ),
    );
  }
}
