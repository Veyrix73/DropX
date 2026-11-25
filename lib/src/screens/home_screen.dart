import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../settings/app_settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.settings});
  final AppSettings settings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<PlatformFile> _files = [];
  bool _picking = false;

  Future<void> _pickFiles() async {
    setState(() => _picking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: false,
      );
      if (!mounted || result == null) return;
      setState(() {
        for (final file in result.files) {
          final exists = _files.any(
            (item) => item.name == file.name && item.size == file.size,
          );
          if (!exists) _files.add(file);
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open files: $error')),
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _showPairingPreview() async {
    if (_files.isEmpty) return;
    final code = List.generate(6, (_) => Random.secure().nextInt(10)).join();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 410),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: QrImageView(
                    data: 'dropx-preview://pair?code=$code',
                    version: QrVersions.auto,
                    size: 184,
                    foregroundColor: const Color(0xFF172016),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Pairing preview',
                  style: Theme.of(dialogContext)
                      .textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your share code',
                  style: TextStyle(
                    color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  code,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Code copied')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy code'),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Preview only. Pairing and file transfer are not connected yet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                        color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReceiveInfo() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Receive files'),
        content: const Text(
          'The receiver flow is being prepared. Device pairing and incoming transfers will be enabled when the transfer service is connected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 42),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (MediaQuery.sizeOf(context).width < 900) ...[
                    Icon(Icons.bubble_chart_rounded,
                        color: theme.colorScheme.primary, size: 25),
                    const SizedBox(width: 8),
                    const Text('DropX',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900)),
                  ] else
                    Text(
                      'YOUR WORKSPACE',
                      style: theme.textTheme.labelMedium?.copyWith(
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'EARLY PREVIEW',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              Text(
                'Move files.\nNot obstacles.',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.04,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A simpler way to share between all your devices.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              _HeroPanel(
                settings: widget.settings,
                picking: _picking,
                onPick: _picking ? null : _pickFiles,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, box) {
                  final send = _ActionCard(
                    icon: Icons.upload_rounded,
                    title: 'Send files',
                    description: 'Choose files and prepare a share code.',
                    buttonText: 'Choose files',
                    onPressed: _picking ? null : _pickFiles,
                  );
                  final receive = _ActionCard(
                    icon: Icons.download_rounded,
                    title: 'Receive files',
                    description: 'Join a transfer from another device.',
                    buttonText: 'Enter a code',
                    onPressed: _showReceiveInfo,
                  );
                  if (box.maxWidth < 610) {
                    return Column(children: [
                      send,
                      const SizedBox(height: 14),
                      receive,
                    ]);
                  }
                  return Row(children: [
                    Expanded(child: send),
                    const SizedBox(width: 14),
                    Expanded(child: receive),
                  ]);
                },
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    'Selected files',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 9),
                  _CountPill(count: _files.length),
                ],
              ),
              const SizedBox(height: 13),
              _FileList(
                files: _files,
                onRemove: (file) => setState(() => _files.remove(file)),
                onAdd: _pickFiles,
                onCreatePreview: _showPairingPreview,
              ),
              const SizedBox(height: 30),
              Text(
                'Built for every screen',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _PlatformChip(Icons.phone_iphone_rounded, 'iOS'),
                  _PlatformChip(Icons.android_rounded, 'Android'),
                  _PlatformChip(Icons.desktop_windows_rounded, 'Windows'),
                  _PlatformChip(Icons.language_rounded, 'Web'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.settings,
    required this.picking,
    required this.onPick,
  });

  final AppSettings settings;
  final bool picking;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final dark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF20271B) : const Color(0xFFE9F0DC),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: accent.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ONE APP. ALL YOUR DEVICES.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sharing should\nfeel this easy.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  'Pick what you need. Connect your devices. Let DropX handle the rest.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onPick,
                  icon: picking
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_rounded),
                  label: Text(picking ? 'Opening files…' : 'Select files'),
                ),
              ],
            ),
          ),
          if (MediaQuery.sizeOf(context).width >= 630) ...[
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 175,
                      height: 175,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: accent.withOpacity(0.2), width: 1.5),
                      ),
                    ),
                    Container(
                      width: 125,
                      height: 125,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withOpacity(0.13),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(-42, 8),
                      child: _DeviceIcon(
                          icon: Icons.laptop_mac_rounded, accent: accent),
                    ),
                    Transform.translate(
                      offset: const Offset(47, -20),
                      child: _DeviceIcon(
                          icon: Icons.phone_iphone_rounded, accent: accent),
                    ),
                    Icon(Icons.bolt_rounded, size: 38, color: accent),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeviceIcon extends StatelessWidget {
  const _DeviceIcon({required this.icon, required this.accent});
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 76,
      height: 88,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF11150F) : Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: accent.withOpacity(0.32), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Icon(icon, size: 34, color: accent),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 26),
          const SizedBox(height: 14),
          Text(title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(description,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onPressed,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(buttonText),
                const SizedBox(width: 7),
                const Icon(Icons.arrow_forward_rounded, size: 17),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FileList extends StatelessWidget {
  const _FileList({
    required this.files,
    required this.onRemove,
    required this.onAdd,
    required this.onCreatePreview,
  });

  final List<PlatformFile> files;
  final ValueChanged<PlatformFile> onRemove;
  final VoidCallback onAdd;
  final VoidCallback onCreatePreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: files.isEmpty
          ? Row(
              children: [
                Icon(Icons.folder_open_rounded,
                    size: 30, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nothing here yet',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(
                        'Choose files to prepare your first transfer.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.add_circle_outline_rounded,
                    color: theme.colorScheme.primary),
              ],
            )
          : Column(
              children: [
                for (var i = 0; i < files.length; i++) ...[
                  if (i > 0) const Divider(height: 17),
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(_fileIcon(files[i].extension),
                            color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              files[i].name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _sizeLabel(files[i].size),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove file',
                        onPressed: () => onRemove(files[i]),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 15),
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  alignment: WrapAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add more'),
                    ),
                    FilledButton.icon(
                      onPressed: onCreatePreview,
                      icon: const Icon(Icons.qr_code_2_rounded),
                      label: const Text('Create pairing preview'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text('$count',
          style: TextStyle(color: color, fontWeight: FontWeight.w900)),
    );
  }
}

class _PlatformChip extends StatelessWidget {
  const _PlatformChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

IconData _fileIcon(String? extension) => switch (extension?.toLowerCase()) {
      'png' || 'jpg' || 'jpeg' || 'gif' || 'webp' => Icons.image_rounded,
      'mp4' || 'mov' || 'mkv' => Icons.movie_rounded,
      'mp3' || 'wav' || 'flac' => Icons.audio_file_rounded,
      'pdf' => Icons.picture_as_pdf_rounded,
      'zip' || 'rar' || '7z' => Icons.archive_rounded,
      _ => Icons.insert_drive_file_rounded,
    };

String _sizeLabel(int size) {
  if (size < 1024) return '$size B';
  if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
  if (size < 1024 * 1024 * 1024) {
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}
