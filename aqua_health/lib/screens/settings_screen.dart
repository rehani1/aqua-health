import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/info_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          _SettingsHeader(),
          SizedBox(height: 12),
          _SectionTitle('Goals'),
          _SettingsGroup(
            rows: <_SettingsRowData>[
              _SettingsRowData(label: 'Step Goal', value: '8,000 steps'),
              _SettingsRowData(label: 'Sleep Goal', value: '8 hrs'),
            ],
          ),
          SizedBox(height: 12),
          _SectionTitle('Permissions'),
          _SettingsGroup(
            rows: <_SettingsRowData>[
              _SettingsRowData(label: 'Health Connect', value: 'Connected'),
            ],
          ),
          SizedBox(height: 12),
          _SectionTitle('Optional'),
          _SettingsGroup(
            rows: <_SettingsRowData>[
              _SettingsRowData(label: 'Reminders', value: 'Off'),
              _SettingsRowData(label: 'Theme', value: 'Ocean Blue'),
            ],
          ),
          SizedBox(height: 12),
          _SimpleLink(title: 'Privacy & Data'),
          SizedBox(height: 8),
          _SimpleLink(title: 'About'),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Text('Settings', style: Theme.of(context).textTheme.headlineMedium);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.rows});

  final List<_SettingsRowData> rows;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            _SettingsRow(data: rows[i]),
            if (i != rows.length - 1)
              Divider(
                color: AppColors.divider.withValues(alpha: 0.5),
                height: 1,
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.data});

  final _SettingsRowData data;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        data.label,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        data.value,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFADC0E4),
      ),
      onTap: () {},
    );
  }
}

class _SimpleLink extends StatelessWidget {
  const _SimpleLink({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFADC0E4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsRowData {
  const _SettingsRowData({required this.label, required this.value});

  final String label;
  final String value;
}
