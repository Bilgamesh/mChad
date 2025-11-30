import 'package:flutter/material.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/models/settings_model.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';
import 'package:mchad/services/github/github_update_service.dart';
import 'package:mchad/views/widgets/loading_widget.dart';

class UpdateButtonWidget extends StatelessWidget {
  const UpdateButtonWidget({
    Key? key,
    required this.settings,
    required this.update,
  }) : super(key: key);
  final SettingsModel settings;
  final UpdateStatus update;

  @override
  Widget build(BuildContext context) {
    return Badge(
      label: Text('!'),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          backgroundColor: settings.colorScheme.errorContainer,
        ),
        onPressed: switch (update) {
          UpdateStatus.inProgress => null,
          _ => () async {
            await GithubUpdateService(
              endpoint: KUpdateConfig.endpoint,
            ).downloadLatest();
          },
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            switch (update) {
              UpdateStatus.inProgress => SizedBox(
                height: 20.0,
                child: LoadingWidget(),
              ),
              _ => Icon(Icons.update),
            },
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(AppLocalizations.of(context).updateAvailable),
            ),
          ],
        ),
      ),
    );
  }
}
