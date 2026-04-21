import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/roster_controller.dart';
import 'package:ez_trainz/models/roster_api_models.dart';

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF4DA6E8);
  static const _accent = Color(0xFFFFE000);

  late TabController _tabs;
  final _rosterNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    final c = RosterController.to;
    c.loadRosters();
    c.loadInstructorRoster();
    c.loadMyInstructorSlots();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _rosterNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = RosterController.to;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: const Text(
          'Roster & meetings',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ctrl.loadRosters();
              ctrl.loadInstructorRoster();
              ctrl.loadMyInstructorSlots();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: _accent,
          labelColor: _accent,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Rosters'),
            Tab(text: 'Slots'),
            Tab(text: 'Mine'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _RostersTab(nameCtrl: _rosterNameCtrl),
          _SlotsTab(
            title: 'Open meeting slots',
            slots: ctrl.meetingSlots,
            showActions: true,
          ),
          _SlotsTab(
            title: 'My meeting slots',
            slots: ctrl.myMeetingSlots,
            showActions: false,
          ),
        ],
      ),
    );
  }
}

class _RostersTab extends StatelessWidget {
  const _RostersTab({required this.nameCtrl});
  final TextEditingController nameCtrl;

  @override
  Widget build(BuildContext context) {
    final ctrl = RosterController.to;
    return Obx(() {
      final loading = ctrl.isLoading.value;
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (ctrl.error.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(ctrl.error.value, style: const TextStyle(color: Colors.white)),
            ),
          _Glass(
            title: 'Create roster',
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'name',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () => ctrl.createRoster({'name': nameCtrl.text.trim()}),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE000),
                      foregroundColor: const Color(0xFF1A1A2E),
                    ),
                    child: const Text('Create'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your rosters',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (ctrl.rosterSummaries.isEmpty)
            Text(
              'No rosters yet.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
            )
          else
            ...ctrl.rosterSummaries.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: ListTile(
                    title: Text(
                      r.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    subtitle: Text(
                      'id: ${r.id}',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                    trailing: IconButton(
                      onPressed: loading
                          ? null
                          : () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Delete roster?'),
                                  content: Text(r.name),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Get.back();
                                        await ctrl.deleteRoster(r.id);
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _SlotsTab extends StatelessWidget {
  const _SlotsTab({
    required this.title,
    required this.slots,
    required this.showActions,
  });

  final String title;
  final RxList<InstructorMeetingSlot> slots;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final ctrl = RosterController.to;
    return Obx(() {
      if (ctrl.isLoading.value && slots.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFFFFE000)));
      }
      return RefreshIndicator(
        color: const Color(0xFFFFE000),
        onRefresh: () async {
          if (showActions) {
            await ctrl.loadInstructorRoster();
          } else {
            await ctrl.loadMyInstructorSlots();
          }
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            if (slots.isEmpty)
              Text(
                'No slots.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
              )
            else
              ...slots.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SlotCard(
                    slot: s,
                    showActions: showActions,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot, required this.showActions});
  final InstructorMeetingSlot slot;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    final ctrl = RosterController.to;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${slot.date}  ${slot.timeSlot}'.trim(),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'id: ${slot.id}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.black54),
            ),
            if (slot.postId != null && slot.postId!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'post: ${slot.postId}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
            if (showActions) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: ctrl.isLoading.value || slot.id.isEmpty
                          ? null
                          : () => ctrl.joinSlot(slot.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Join'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: ctrl.isLoading.value || slot.id.isEmpty
                          ? null
                          : () => ctrl.leaveSlot(slot.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Leave'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  const _Glass({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
