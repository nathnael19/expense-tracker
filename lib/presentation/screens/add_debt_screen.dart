import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/debt_model.dart';
import '../blocs/debt_cubit.dart';

class AddDebtScreen extends StatefulWidget {
  final DebtModel? debt;
  const AddDebtScreen({super.key, this.debt});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _selectedDate;
  DateTime? _dueDate;
  late DebtType _selectedType;

  @override
  void initState() {
    super.initState();
    if (widget.debt != null) {
      _nameController.text = widget.debt!.personName;
      _amountController.text = widget.debt!.amount.toString();
      _noteController.text = widget.debt!.note;
      _selectedDate = widget.debt!.date;
      _dueDate = widget.debt!.dueDate;
      _selectedType = widget.debt!.type;
    } else {
      _selectedDate = DateTime.now();
      _selectedType = DebtType.lent;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveDebt() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final newDebt = DebtModel(
        id: widget.debt?.id ?? const Uuid().v4(),
        personName: _nameController.text.trim(),
        amount: amount,
        date: _selectedDate,
        dueDate: _dueDate,
        note: _noteController.text.trim(),
        type: _selectedType,
        isPaid: widget.debt?.isPaid ?? false,
      );

      context.read<DebtCubit>().addDebt(newDebt);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLent = _selectedType == DebtType.lent;
    final primaryColor = isLent ? Colors.green : Colors.redAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.debt != null
              ? 'Edit Record'
              : (isLent ? 'Add Lending Record' : 'Add Borrowing Record'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type Toggle
              SegmentedButton<DebtType>(
                segments: const [
                  ButtonSegment(
                    value: DebtType.lent,
                    label: Text('I Lent'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: DebtType.borrowed,
                    label: Text('I Borrowed'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  side: MaterialStateProperty.all(
                    BorderSide(color: primaryColor),
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.white;
                    }
                    return primaryColor;
                  }),
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return primaryColor;
                    }
                    return null;
                  }),
                ),
              ),
              const Gap(24),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: isLent ? 'Person Name' : 'Lender Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const Gap(16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: isLent
                      ? 'Amount Lent (ETB)'
                      : 'Amount Borrowed (ETB)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const Gap(16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(isLent ? 'Date Lent' : 'Date Borrowed'),
                subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                onTap: _pickDate,
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available),
                title: const Text('Due Date (Optional)'),
                subtitle: Text(
                  _dueDate != null
                      ? DateFormat.yMMMd().format(_dueDate!)
                      : 'Not set',
                ),
                onTap: _pickDueDate,
                trailing: _dueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _dueDate = null;
                          });
                        },
                      )
                    : const Icon(Icons.chevron_right),
              ),
              const Gap(8),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  prefixIcon: const Icon(Icons.notes),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const Gap(32),
              FilledButton(
                onPressed: _saveDebt,
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.debt != null ? 'Update Record' : 'Save Record',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
