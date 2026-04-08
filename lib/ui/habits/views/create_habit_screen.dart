import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/habit.dart';
import '../../../data/providers.dart';

class CreateHabitScreen extends ConsumerStatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController(text: '1');
  
  HabitCategory _selectedCategory = HabitCategory.health;
  FrequencyType _selectedFrequency = FrequencyType.daily;
  bool _remindersEnabled = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final repository = ref.read(habitRepositoryProvider);
      
      final habit = Habit()
        ..uuid = const Uuid().v4()
        ..title = _titleController.text
        ..description = _descriptionController.text.isEmpty ? null : _descriptionController.text
        ..category = _selectedCategory
        ..frequencyType = _selectedFrequency
        ..targetCount = int.tryParse(_targetController.text) ?? 1
        ..unit = 'times'
        ..reminderEnabled = _remindersEnabled
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await repository.saveHabit(habit);
      
      // Invalidate the provider so dashboard refreshes
      ref.invalidate(habitsProvider);
      
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Habit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveHabit,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Habit Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<HabitCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: HabitCategory.values.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<FrequencyType>(
              value: _selectedFrequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: FrequencyType.values.map((freq) {
                return DropdownMenuItem(
                  value: freq,
                  child: Text(freq.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedFrequency = val);
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Reminders'),
              value: _remindersEnabled,
              onChanged: (val) => setState(() => _remindersEnabled = val),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveHabit,
              child: const Text('Save Habit'),
            )
          ],
        ),
      ),
    );
  }
}
