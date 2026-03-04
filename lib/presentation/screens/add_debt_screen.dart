import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/debt_model.dart';
import '../../data/models/person_model.dart';
import '../blocs/debt_cubit.dart';
import '../components/debt/debt_type_toggle.dart';

class AddDebtScreen extends StatefulWidget {
  final DebtModel? debt;
  final PersonModel? initialPerson;
  const AddDebtScreen({super.key, this.debt, this.initialPerson});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  late DateTime _selectedDate;
  DateTime? _dueDate;
  late DebtType _selectedType;
  String? _selectedPersonId;

  @override
  void initState() {
    super.initState();
    if (widget.debt != null) {
      _nameController.text = widget.debt!.personName;
      _amountController.text = widget.debt!.amount.toString();
      _reasonController.text = widget.debt!.reason ?? '';
      _selectedDate = widget.debt!.date;
      _dueDate = widget.debt!.dueDate;
      _selectedType = widget.debt!.type;
      _selectedPersonId = widget.debt!.personId;
    } else {
      _selectedDate = DateTime.now();
      _selectedType = DebtType.lent;
      _selectedPersonId = widget.initialPerson?.id;
      if (widget.initialPerson != null) _nameController.text = widget.initialPerson!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _saveDebt() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      String? personId = _selectedPersonId;
      if (personId == null) {
        final state = context.read<DebtCubit>().state;
        final matchedPerson = state.persons.where((p) => p.name.toLowerCase() == _nameController.text.trim().toLowerCase()).firstOrNull;
        if (matchedPerson != null) personId = matchedPerson.id;
      }
      final newDebt = DebtModel(
        id: widget.debt?.id ?? const Uuid().v4(), personName: _nameController.text.trim(), amount: amount,
        date: _selectedDate, dueDate: _dueDate, note: '', reason: _reasonController.text.trim(), type: _selectedType,
        isPaid: widget.debt?.isPaid ?? false, personId: personId,
      );
      if (widget.debt != null) context.read<DebtCubit>().updateDebt(newDebt);
      else context.read<DebtCubit>().addDebt(newDebt);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLent = _selectedType == DebtType.lent;
    final primaryColor = isLent ? Colors.green : Colors.redAccent;

    return Scaffold(
      appBar: AppBar(title: Text(widget.debt != null ? 'Edit Record' : (isLent ? 'Add Lending Record' : 'Add Borrowing Record'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DebtTypeToggle(selectedType: _selectedType, primaryColor: primaryColor, onSelectionChanged: (type) => setState(() => _selectedType = type)),
              const Gap(24),
              _buildTextField(_nameController, isLent ? 'Person Name' : 'Lender Name', Icons.person_outline, readOnly: _selectedPersonId != null),
              const Gap(16),
              _buildTextField(_reasonController, 'Reason', Icons.help_outline, hint: 'e.g., Lunch, Taxi'),
              const Gap(16),
              _buildTextField(_amountController, 'Amount (ETB)', Icons.attach_money, isNumber: true),
              const Gap(16),
              ListTile(
                contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_today), title: const Text('Date'), subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (picked != null) setState(() => _selectedDate = picked);
                }, trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event_available), title: const Text('Due Date (Optional)'), subtitle: Text(_dueDate != null ? DateFormat.yMMMd().format(_dueDate!) : 'Not set'),
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: _dueDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (picked != null) setState(() => _dueDate = picked);
                }, trailing: _dueDate != null ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _dueDate = null)) : const Icon(Icons.chevron_right),
              ),
              const Gap(32),
              FilledButton(
                onPressed: _saveDebt,
                style: FilledButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(widget.debt != null ? 'Update Record' : 'Save Record', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, bool readOnly = false, String? hint}) {
    return TextFormField(
      controller: controller, readOnly: readOnly, keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : null,
      decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: readOnly),
      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : (isNumber && double.tryParse(v) == null ? 'Invalid number' : null),
    );
  }
}
