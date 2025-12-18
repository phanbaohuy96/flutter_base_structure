import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../common_widget/export.dart';

enum SampleOption { option1, option2, option3, option4 }

extension SampleOptionExt on SampleOption {
  String get label {
    switch (this) {
      case SampleOption.option1:
        return 'Option 1';
      case SampleOption.option2:
        return 'Option 2';
      case SampleOption.option3:
        return 'Option 3';
      case SampleOption.option4:
        return 'Option 4';
    }
  }
}

class InputsPage extends StatefulWidget {
  const InputsPage({super.key});

  @override
  State<InputsPage> createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  final _textController = TextEditingController();
  final _passwordController = TextEditingController();
  final _multilineController = TextEditingController();
  bool _obscurePassword = true;
  String? _dropdownValue;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // For custom widgets
  final _inputContainerCtrl = InputContainerController();
  final _inputContainerErrorCtrl = InputContainerController();
  final _inputContainerPasswordCtrl = InputContainerController();
  final _dropdownController =
      DropdownController<SampleOption, DropdownData<SampleOption>>(
    value: DropdownData<SampleOption>(),
  );
  final _multipleChoiceController = MultipleChoiceDropdownController<
      SampleOption, MultipleChoiceDropdownData<SampleOption>>(
    value: MultipleChoiceDropdownData<SampleOption>(),
  );
  SampleOption? _dropdownMenuButtonValue;

  @override
  void dispose() {
    _textController.dispose();
    _passwordController.dispose();
    _multilineController.dispose();
    _inputContainerCtrl.dispose();
    _inputContainerErrorCtrl.dispose();
    _inputContainerPasswordCtrl.dispose();
    _dropdownController.dispose();
    _multipleChoiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      children: [
        // Custom Widget: InputContainer
        Text(
          'InputContainer Widget',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        InputContainer(
          controller: _inputContainerCtrl,
          title: 'InputContainer',
          hint: 'Custom input widget',
          prefixIcon: const Icon(Icons.person),
        ),
        const SizedBox(height: 16),
        InputContainer(
          controller: _inputContainerPasswordCtrl,
          title: 'Password',
          hint: 'Enter password',
          isPassword: true,
          prefixIcon: const Icon(Icons.lock),
        ),
        const SizedBox(height: 16),
        InputContainer(
          controller: _inputContainerErrorCtrl,
          title: 'With Validation',
          hint: 'Enter text',
          validation: 'This field has an error',
          prefixIcon: const Icon(Icons.error_outline),
        ),
        const SizedBox(height: 16),
        const InputContainer(
          title: 'Disabled',
          hint: 'Cannot edit',
          enable: false,
          text: 'Disabled text',
        ),
        const SizedBox(height: 16),
        const InputContainer(
          title: 'Multiline',
          hint: 'Enter multiple lines',
          maxLines: 4,
        ),
        const SizedBox(height: 32),

        // Custom Widget: DropdownWidget
        Text(
          'DropdownWidget',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        DropdownWidget<SampleOption>(
          controller: _dropdownController,
          title: 'Select Option',
          hint: 'Choose an option',
          items: SampleOption.values,
          itemBuilder: (option) => Text(option.label),
          prefixIcon: const Icon(Icons.list),
          onChanged: (value) {
            // Handle change
          },
        ),
        const SizedBox(height: 16),
        DropdownWidget<SampleOption>(
          title: 'Disabled Dropdown',
          hint: 'Cannot select',
          items: SampleOption.values,
          itemBuilder: (option) => Text(option.label),
          enable: false,
        ),
        const SizedBox(height: 32),

        // Custom Widget: MultipleChoiceDropdownWidget
        Text(
          'MultipleChoiceDropdownWidget',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        MultipleChoiceDropdownWidget<SampleOption>(
          controller: _multipleChoiceController,
          title: 'Select Multiple Options',
          hint: 'Choose options',
          items: SampleOption.values,
          itemBuilder: (option, selected) => Row(
            children: [
              Icon(
                selected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(option.label),
            ],
          ),
          valueBuilder: (selected) {
            if (selected.isEmpty) {
              return const Text('');
            }
            return Text(
              selected.map((e) => e.label).join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
          onChanged: (values) {
            // Handle change
          },
        ),
        const SizedBox(height: 32),

        // Custom Widget: DropdownMenuButton
        Text(
          'DropdownMenuButton',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        DropdownMenuButton<SampleOption>(
          customButton: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dropdownMenuButtonValue?.label ?? 'Select Option',
                  style: textTheme.bodyMedium,
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          items: SampleOption.values,
          value: _dropdownMenuButtonValue,
          itemBuilder: (option) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(option.label),
          ),
          onChanged: (value) {
            setState(() {
              _dropdownMenuButtonValue = value;
            });
          },
        ),
        const SizedBox(height: 32),

        // Basic Text Fields
        Text(
          'Basic Text Fields',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Label',
            hintText: 'Enter text',
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'With Helper Text',
            hintText: 'Enter text',
            helperText: 'This is helper text',
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Disabled',
            hintText: 'Cannot edit',
          ),
          enabled: false,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: 'With Clear Button',
            hintText: 'Enter text',
            suffixIcon: Icon(Icons.clear),
          ),
        ),
        const SizedBox(height: 24),

        // Text Fields with Icons
        Text(
          'Text Fields with Icons',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter email',
            prefixIcon: Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Phone',
            hintText: 'Enter phone number',
            prefixIcon: Icon(Icons.phone),
            suffixIcon: Icon(Icons.contact_phone),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Search',
            hintText: 'Search...',
            prefixIcon: Icon(Icons.search),
            suffixIcon: Icon(Icons.filter_list),
          ),
        ),
        const SizedBox(height: 24),

        // Password Field
        Text(
          'Password Field',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Error States
        Text(
          'Error States',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter email',
            errorText: 'Invalid email address',
            prefixIcon: Icon(Icons.email),
          ),
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Required Field',
            hintText: 'This field is required',
            errorText: 'This field cannot be empty',
            errorMaxLines: 2,
          ),
        ),
        const SizedBox(height: 24),

        // Multiline Text Field
        Text(
          'Multiline Text Field',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _multilineController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Enter description',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 24),

        // Input with Counter
        Text(
          'Input with Counter',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const TextField(
          maxLength: 100,
          decoration: InputDecoration(
            labelText: 'Bio',
            hintText: 'Tell us about yourself',
            helperText: 'Max 100 characters',
          ),
        ),
        const SizedBox(height: 24),

        // Input with Formatters
        Text(
          'Input with Formatters',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Numbers only',
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Letters only',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 24),

        // Dropdown Field
        Text(
          'Dropdown Field',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _dropdownValue,
          decoration: const InputDecoration(
            labelText: 'Select Option',
            prefixIcon: Icon(Icons.list),
          ),
          items: ['Option 1', 'Option 2', 'Option 3', 'Option 4']
              .map(
                (option) => DropdownMenuItem(
                  value: option,
                  child: Text(option),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() => _dropdownValue = value);
          },
        ),
        const SizedBox(height: 24),

        // Date Picker Field
        Text(
          'Date & Time Picker Fields',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Date',
            hintText: 'Select date',
            prefixIcon: const Icon(Icons.calendar_today),
            suffixText: _selectedDate != null
                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                : null,
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
        ),
        const SizedBox(height: 16),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Time',
            hintText: 'Select time',
            prefixIcon: const Icon(Icons.access_time),
            suffixText: _selectedTime != null
                ? '''${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'''
                : null,
          ),
          onTap: () {
            showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
          },
        ),
        const SizedBox(height: 24),

        // Custom Styled Inputs
        Text(
          'Custom Styled Inputs',
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'Filled Style',
            hintText: 'Enter text',
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Rounded Style',
            hintText: 'Enter text',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Dense Style',
            hintText: 'Enter text',
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
