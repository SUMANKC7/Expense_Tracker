import 'package:expensetrack/core/appcolors.dart';
import 'package:expensetrack/features/transactions/provider/parties_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class _Palette {
  static const primary = Color(0xFF16A34A); // green
  static const danger = Color(0xFFE11D48); // rose
  static const surface = Color(0xFFF6F7F9);
  static const card = Colors.white;
  static const text = Color(0xFF111827);
  static const subtext = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
}

class AddEntity extends StatefulWidget {
  const AddEntity({super.key});

  @override
  State<AddEntity> createState() => _AddEntityState();
}

class _AddEntityState extends State<AddEntity> {
  late final PartiesProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<PartiesProvider>(context, listen: false);
    // Delay the form clearing until after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.clearForm();
    });
  }

  Future<void> _submit() async {
    debugPrint("Submit tapped");
    try {
      final success = await _provider.saveEntity(context);
      debugPrint("SaveEntity result: $success");

      if (success && mounted) {
        // Hide the keyboard
        FocusScope.of(context).unfocus();

        // Clear all form data
        _provider.clearForm();

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Party added successfully')),
        );
      }
    } catch (e, st) {
      debugPrint('Submit error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }

  @override
  void dispose() {
    // Don't dispose the controllers here since they're managed by the provider
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Consumer<PartiesProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: _Palette.surface,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: _Palette.card,
            foregroundColor: _Palette.text,
            centerTitle: true,
            title: const Text(
              'Add New Party',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            // leading: IconButton(
            //   icon: const Icon(Icons.arrow_back),
            //   onPressed: () => Navigator.of(context).maybePop(),
            // ),
          ),

          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _Palette.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Add New Party',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cardWhite,
                  ),
                ),
              ),
            ),
          ),

          body: SafeArea(
            child: Form(
              key: provider.formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: !isKeyboardOpen
                                ? Column(
                                    key: const ValueKey('header'),
                                    children: [
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () {
                                          // pick image
                                        },
                                        child: CircleAvatar(
                                          radius: 40,
                                          backgroundColor: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.camera_alt,
                                            color: _Palette.primary,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey('no-header'),
                                  ),
                          ),

                          // Party name & phone
                          _TextField(
                            controller: provider.nameCtrl,
                            label: 'Party Name',
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _TextField(
                            controller: provider.phoneCtrl,
                            label: 'Phone Number',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (v) => (v == null || v.length < 7)
                                ? 'Enter valid phone'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Switch-style "tab bar"
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _Palette.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: _Palette.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  provider.isCreditInfoSelected
                                      ? 'Credit Info'
                                      : 'Additional Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: provider.isCreditInfoSelected
                                        ? _Palette.primary
                                        : _Palette.danger,
                                  ),
                                ),
                                Switch(
                                  value: provider.isCreditInfoSelected,
                                  onChanged: provider.toggleCreditInfo,
                                  activeColor: _Palette.primary,
                                  inactiveThumbColor: _Palette.danger,
                                  inactiveTrackColor: _Palette.border,
                                  thumbIcon: const WidgetStatePropertyAll(
                                    Icon(Icons.swap_horiz),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: provider.isCreditInfoSelected
                                ? _CreditInfoSection(
                                    openingCtrl: provider.openingCtrl,
                                    dateCtrl: provider.dateCtrl,
                                    toReceive: provider.toReceive,
                                    onToggleReceiveGive:
                                        provider.toggleReceiveGive,
                                    onPickDate: () =>
                                        provider.pickDate(context),
                                  )
                                : _AdditionalDetailsSection(
                                    emailCtrl: provider.emailCtrl,
                                    addressCtrl: provider.addressCtrl,
                                  ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: _Palette.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _Palette.primary, width: 1.4),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class _CreditInfoSection extends StatelessWidget {
  const _CreditInfoSection({
    required this.openingCtrl,
    required this.dateCtrl,
    required this.toReceive,
    required this.onToggleReceiveGive,
    required this.onPickDate,
  });

  final TextEditingController openingCtrl;
  final TextEditingController dateCtrl;
  final bool toReceive;
  final ValueChanged<bool> onToggleReceiveGive;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('credit'),
      children: [
        Row(
          children: [
            Expanded(
              child: _TextField(
                controller: openingCtrl,
                label: 'Opening Balance',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TextField(
                controller: dateCtrl,
                label: 'As of Date',
                readOnly: true,
                onTap: onPickDate,
                suffixIcon: const Icon(Icons.calendar_today, size: 20),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Pick a date' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('To Receive'),
                selected: toReceive,
                onSelected: (_) => onToggleReceiveGive(true),
                selectedColor: _Palette.primary.withOpacity(.12),
                labelStyle: TextStyle(
                  color: toReceive ? _Palette.primary : _Palette.subtext,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: toReceive ? _Palette.primary : _Palette.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              ChoiceChip(
                label: const Text('To Give'),
                selected: !toReceive,
                onSelected: (_) => onToggleReceiveGive(false),
                selectedColor: _Palette.danger.withOpacity(.10),
                labelStyle: TextStyle(
                  color: !toReceive ? _Palette.danger : _Palette.subtext,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: !toReceive ? _Palette.danger : _Palette.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdditionalDetailsSection extends StatelessWidget {
  const _AdditionalDetailsSection({
    required this.emailCtrl,
    required this.addressCtrl,
  });

  final TextEditingController emailCtrl;
  final TextEditingController addressCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('additional'),
      children: [
        _TextField(
          controller: emailCtrl,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (v) {
            if (v == null || v.isEmpty) return null;
            final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v);
            return ok ? null : 'Invalid email';
          },
        ),
        const SizedBox(height: 12),
        _TextField(
          controller: addressCtrl,
          label: 'Address',
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
