import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/habit.dart';
import '../../../data/providers.dart';

class CreateHabitScreen extends ConsumerStatefulWidget {
  final String? habitUuid;

  const CreateHabitScreen({super.key, this.habitUuid});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController(text: '1');
  final _unitController = TextEditingController(text: 'times');

  HabitCategory _selectedCategory = HabitCategory.health;
  FrequencyType _selectedFrequency = FrequencyType.daily;
  bool _remindersEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;
  DateTime? _originalCreatedAt;

  @override
  void initState() {
    super.initState();
    // If editing, load the existing habit data
    if (widget.habitUuid != null) {
      _loadHabitData();
    }
  }

  Future<void> _loadHabitData() async {
    if (widget.habitUuid == null) return;

    try {
      final repository = ref.read(habitRepositoryProvider);
      final habits = await repository.getAllHabits();
      final habit = habits.firstWhere((h) => h.uuid == widget.habitUuid,
          orElse: () => Habit());

      if (habit.uuid != null && habit.uuid!.isNotEmpty) {
        setState(() {
          _originalCreatedAt = habit.createdAt;
          _titleController.text = habit.title;
          _descriptionController.text = habit.description ?? '';
          _selectedCategory = habit.category;
          _selectedFrequency = habit.frequencyType;
          _targetController.text = habit.targetCount.toString();
          _unitController.text = habit.unit;
          _remindersEnabled = habit.reminderEnabled;
          if (habit.reminderTime != null) {
            _reminderTime = TimeOfDay(
              hour: habit.reminderTime!.hour,
              minute: habit.reminderTime!.minute,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading habit: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final repository = ref.read(habitRepositoryProvider);

        final habit = Habit()
          ..uuid = widget.habitUuid ?? const Uuid().v4()
          ..title = _titleController.text.trim()
          ..description = _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text.trim()
          ..category = _selectedCategory
          ..frequencyType = _selectedFrequency
          ..targetCount = int.tryParse(_targetController.text) ?? 1
          ..unit = _unitController.text.trim().isEmpty
              ? 'times'
              : _unitController.text.trim()
          ..reminderEnabled = _remindersEnabled
          ..reminderTime = _remindersEnabled
              ? DateTime.now().copyWith(
                  hour: _reminderTime.hour, minute: _reminderTime.minute)
              : null
          ..createdAt = _originalCreatedAt ?? DateTime.now()
          ..updatedAt = DateTime.now();

        await repository.saveHabit(habit);

        // Invalidate the provider so dashboard refreshes
        ref.invalidate(habitsProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.habitUuid == null
                  ? 'Habit created successfully!'
                  : 'Habit updated successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving habit: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _pickReminderTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (pickedTime != null) {
      setState(() => _reminderTime = pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habitUuid == null ? 'Create Habit' : 'Edit Habit'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Form content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Habit Title
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Habit Title *',
                        hintText: 'e.g., Morning Exercise, Read 30 minutes',
                        prefixIcon: const Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a habit title';
                        }
                        if (value.length < 2) {
                          return 'Title must be at least 2 characters';
                        }
                        if (value.length > 50) {
                          return 'Title cannot exceed 50 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Optional details about this habit',
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Frequency Section
                    _buildSectionTitle('Frequency & Target'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<HabitCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: HabitCategory.values.map((cat) {
                        final catName = cat.toString().split('.').last;
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(
                              catName[0].toUpperCase() + catName.substring(1)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null)
                          setState(() => _selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<FrequencyType>(
                      value: _selectedFrequency,
                      decoration: const InputDecoration(
                        labelText: 'Frequency *',
                        prefixIcon: Icon(Icons.repeat),
                      ),
                      items: FrequencyType.values.map((freq) {
                        final freqName = freq.toString().split('.').last;
                        return DropdownMenuItem(
                          value: freq,
                          child: Text(freqName[0].toUpperCase() +
                              freqName.substring(1)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null)
                          setState(() => _selectedFrequency = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _targetController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Target Count *',
                              hintText: '1',
                              prefixIcon: Icon(Icons.functions),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final num = int.tryParse(value);
                              if (num == null || num <= 0) {
                                return 'Must be > 0';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _unitController,
                            decoration: const InputDecoration(
                              labelText: 'Unit *',
                              hintText: 'times, minutes, km',
                              prefixIcon: Icon(Icons.straighten),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Reminder Section
                    _buildSectionTitle('Reminders'),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Enable Reminders'),
                              subtitle: const Text(
                                  'Get notified when it\'s time to complete this habit'),
                              value: _remindersEnabled,
                              onChanged: (val) =>
                                  setState(() => _remindersEnabled = val),
                            ),
                            if (_remindersEnabled)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reminder Time',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _reminderTime.format(context),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                    FilledButton.tonal(
                                      onPressed:
                                          _isLoading ? null : _pickReminderTime,
                                      child: const Text('Change Time'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _saveHabit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(widget.habitUuid == null
                                ? 'Create Habit'
                                : 'Save Changes'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}
