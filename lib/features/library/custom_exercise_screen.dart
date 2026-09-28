import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/utils/text.dart';
import '../../core/widgets/glass/ambient_background.dart';
import '../../core/widgets/glass/glass.dart';
import '../../core/widgets/glass/glass_controls.dart';
import '../../core/widgets/glass/glass_sheet.dart';
import '../../l10n/app_localizations.dart';
import 'library_providers.dart';

/// Create ([exerciseId] null) or edit a user-made exercise. Pops with the
/// exercise id after saving.
class CustomExerciseScreen extends ConsumerStatefulWidget {
  const CustomExerciseScreen({super.key, this.exerciseId, this.initialBodyPart});

  final String? exerciseId;
  final String? initialBodyPart;

  @override
  ConsumerState<CustomExerciseScreen> createState() => _CustomExerciseScreenState();
}

class _CustomExerciseScreenState extends ConsumerState<CustomExerciseScreen> {
  final _name = TextEditingController();
  final _target = TextEditingController();
  final _instructions = TextEditingController();
  late String _bodyPart = widget.initialBodyPart ?? bodyPartOptions.first;
  String _equipment = 'dumbbell';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.exerciseId;
    if (id != null) {
      final e = (await ref.read(exerciseRepositoryProvider).getByIds([id]))[id];
      if (e != null) {
        _name.text = e.name.titleCase;
        _bodyPart = e.bodyParts.firstOrNull ?? _bodyPart;
        _equipment = e.equipments.firstOrNull ?? _equipment;
        final target = e.targetMuscles.firstOrNull;
        if (target != null && target != _bodyPart) _target.text = target.titleCase;
        _instructions.text = e.instructions.join('\n');
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _instructions.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.customNameRequired)));
      return;
    }
    setState(() => _saving = true);
    final id = await ref.read(exerciseRepositoryProvider).saveCustom(
          id: widget.exerciseId,
          name: _name.text,
          bodyPart: _bodyPart,
          equipment: _equipment,
          targetMuscle: _target.text,
          instructions: _instructions.text.split('\n'),
        );
    if (mounted) context.pop(id);
  }

  Future<void> _pickEquipment() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showGlassSheet<String>(
      context: context,
      scrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(l10n.customEquipment,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final option in equipmentOptions)
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                title: Text(option.titleCase),
                trailing: option == _equipment ? const Icon(Icons.check_rounded) : null,
                onTap: () => Navigator.pop(context, option),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _equipment = picked);
  }

  InputDecoration _field(String hint) => InputDecoration(
        hintText: hint,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final editing = widget.exerciseId != null;

    return AmbientBackdrop(
      child: Scaffold(
        body: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppBar(
              pinned: true,
              toolbarHeight: 64,
              automaticallyImplyLeading: false,
              titleSpacing: 16,
              flexibleSpace: const GlassBar(),
              title: Row(
                children: [
                  GlassIconButton(
                    icon: Icons.close_rounded,
                    tooltip: l10n.cancel,
                    blur: false,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      editing ? l10n.customEditTitle : l10n.customNewTitle,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size(84, 44)),
                    onPressed: _loading || _saving ? null : _save,
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
            if (_loading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                    16, 0, 16, 32 + MediaQuery.paddingOf(context).bottom),
                sliver: SliverList.list(children: [
                  SectionLabel(l10n.customName),
                  Glass(
                    radius: 18,
                    shadow: false,
                    child: TextField(
                      controller: _name,
                      autofocus: !editing,
                      textCapitalization: TextCapitalization.words,
                      style: theme.textTheme.titleMedium,
                      decoration: _field(l10n.customNameHint),
                    ),
                  ),
                  SectionLabel(l10n.customBodyPart),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final part in bodyPartOptions)
                        GlassChip(
                          label: part.titleCase,
                          selected: _bodyPart == part,
                          onTap: () => setState(() => _bodyPart = part),
                        ),
                    ],
                  ),
                  SectionLabel(l10n.customEquipment),
                  Glass(
                    radius: 18,
                    shadow: false,
                    onTap: _pickEquipment,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_equipment.titleCase,
                              style: theme.textTheme.titleMedium),
                        ),
                        const Icon(Icons.expand_more_rounded),
                      ],
                    ),
                  ),
                  SectionLabel(l10n.customTarget),
                  Glass(
                    radius: 18,
                    shadow: false,
                    child: TextField(
                      controller: _target,
                      textCapitalization: TextCapitalization.words,
                      decoration: _field(l10n.customTargetHint),
                    ),
                  ),
                  SectionLabel(l10n.customInstructions),
                  Glass(
                    radius: 18,
                    shadow: false,
                    child: TextField(
                      controller: _instructions,
                      minLines: 4,
                      maxLines: 10,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _field(l10n.customInstructionsHint),
                    ),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}
