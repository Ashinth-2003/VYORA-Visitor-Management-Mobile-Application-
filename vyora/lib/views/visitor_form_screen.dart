import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controllers/visitor_controller.dart';
import '../models/visitor_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/snack_bar.dart';
import '../utils/validators.dart';
import 'visitor_details_screen.dart';
import 'widgets/app_card.dart';
import 'widgets/gold_button.dart';
import 'widgets/qr_box.dart';
import 'widgets/screen_background.dart';
import 'widgets/section_title.dart';

/// Used for both registering and editing. Pass a visitor to edit it.
class VisitorFormScreen extends StatefulWidget {
  const VisitorFormScreen({super.key, this.visitor});

  final Visitor? visitor;

  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.visitor?.name);
  late final _mobileController = TextEditingController(
    text: widget.visitor?.mobile,
  );
  late final _emailController = TextEditingController(
    text: widget.visitor?.email,
  );
  late final _purposeController = TextEditingController(
    text: widget.visitor?.purpose,
  );

  late VisitorType _type = widget.visitor?.visitorType ?? VisitorType.customer;
  late String _project = widget.visitor?.project ?? visitorProjects.first;
  bool _isSaving = false;
  int _resetCount = 0; // changes the dropdown keys so they pick up the cleared values

  bool get _isEditing => widget.visitor != null;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final old = widget.visitor;
    final email = _emailController.text.trim();
    final visitor = Visitor(
      id: old?.id ?? '',
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      email: email.isEmpty ? null : email,
      visitorType: _type,
      project: _project,
      purpose: _purposeController.text.trim(),
      status: old?.status ?? VisitorStatus.registered,
      createdAt: old?.createdAt ?? DateTime.now(),
      checkInTime: old?.checkInTime,
      checkOutTime: old?.checkOutTime,
    );

    final controller = context.read<VisitorController>();
    try {
      if (_isEditing) {
        await controller.updateVisitor(visitor);
        if (!mounted) return;
        showMessage(context, 'Visitor updated');
        Navigator.pop(context);
      } else {
        // The QR code uses the id the server gave this visitor.
        final saved = await controller.addVisitor(visitor);
        if (!mounted) return;
        await _showSuccessSheet(saved);
      }
    } on AppException catch (e) {
      if (mounted) showMessage(context, e.message, isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _showSuccessSheet(Visitor saved) async {
    final viewPass = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_rounded,
                size: 36,
                color: AppColors.success,
              ),
              const SizedBox(height: 8),
              Text(
                'Visitor registered',
                style: sheetContext.textStyles.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                saved.name,
                style: TextStyle(color: sheetContext.colors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              QrBox(data: saved.id, size: 150),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: GoldButton(
                      label: 'Add another',
                      outlined: true,
                      onPressed: () => Navigator.pop(sheetContext, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GoldButton(
                      label: 'View pass',
                      onPressed: () => Navigator.pop(sheetContext, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;

    if (viewPass == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VisitorDetailsScreen(visitorId: saved.id),
        ),
      );
    } else {
      // Clear the form so the same person is not registered twice by accident.
      _formKey.currentState!.reset();
      _nameController.clear();
      _mobileController.clear();
      _emailController.clear();
      _purposeController.clear();
      setState(() {
        _type = VisitorType.customer;
        _project = visitorProjects.first;
        _resetCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit visitor' : 'Register visitor'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const SectionTitle('Contact details'),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Visitor name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) => Validators.required(v, 'Name'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Mobile number',
                        counterText: '',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: Validators.mobile,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email (optional)',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                      validator: Validators.email,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const SectionTitle('Visit details'),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: [
                    DropdownButtonFormField<VisitorType>(
                      key: ValueKey('type$_resetCount'),
                      initialValue: _type,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Visitor type',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      items: [
                        for (final type in VisitorType.values)
                          DropdownMenuItem(value: type, child: Text(type.label)),
                      ],
                      onChanged: (value) => setState(() => _type = value!),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      key: ValueKey('project$_resetCount'),
                      initialValue: _project,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Project',
                        prefixIcon: Icon(Icons.apartment_outlined),
                      ),
                      items: [
                        // Keeps an old project selectable if the server has one we don't list.
                        for (final project in {...visitorProjects, _project})
                          DropdownMenuItem(value: project, child: Text(project)),
                      ],
                      onChanged: (value) => setState(() => _project = value!),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _purposeController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Purpose of visit',
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 44),
                          child: Icon(Icons.notes_rounded),
                        ),
                      ),
                      validator: (v) => Validators.required(v, 'Purpose'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: GoldButton(
                      label: 'Cancel',
                      outlined: true,
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GoldButton(
                      label: _isEditing ? 'Save changes' : 'Create pass',
                      icon: Icons.check_rounded,
                      isLoading: _isSaving,
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
