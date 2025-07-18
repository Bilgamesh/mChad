import 'package:flutter/material.dart';
import 'package:mchad/l10n/generated/app_localizations.dart';

class OnlineUsersModal extends StatelessWidget {
  const OnlineUsersModal({
    Key? key,
    required this.onlineUsers,
    required this.onlineBots,
    required this.hiddenCount,
  }) : super(key: key);
  final List<String> onlineUsers;
  final List<String> onlineBots;
  final int hiddenCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.onlineUsers,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  children: [
                    ...List.generate(
                      onlineUsers.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            Icon(Icons.person_outlined),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(onlineUsers.elementAt(index)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...List.generate(
                      onlineBots.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: [
                            Icon(Icons.smart_toy_outlined),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(onlineBots.elementAt(index)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    hiddenCount > 0
                        ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.public_off_outlined),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '${AppLocalizations.of(context)!.hiddenUsers}: $hiddenCount',
                                ),
                              ),
                            ],
                          ),
                        )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
