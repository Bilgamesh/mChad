import 'dart:convert';

import 'package:http/http.dart';
import 'package:mchad/data/constants.dart';
import 'package:mchad/data/notifiers.dart';

import 'package:mchad/utils/logging_util.dart';
import 'package:mchad/utils/modal_util.dart';
import 'package:ota_update/ota_update.dart';

var logger = LoggingUtil(module: 'github_update_service');

class GithubUpdateService {
  GithubUpdateService({required this.endpoint});
  final String endpoint;

  Future<String> get latestVersion async {
    try {
      var latest = await this.latest;
      return latest['tag_name'].toString().substring(1);
    } catch (e) {
      logger.error(e.toString());
      return '0.0.0';
    }
  }

  Future<dynamic> get latest async {
    var streamedResponse = await (Client().send(
      Request('GET', Uri.parse(endpoint)),
    ));
    var response = await Response.fromStream(streamedResponse);
    var json = jsonDecode(response.body);
    var latest = json[0];
    return latest;
  }

  Future<bool> isNewVersionAvailable(String currentVersion) async {
    var latest = await latestVersion;
    var [latestMajor, latestMinor, latestPatch] = latest.split('.');
    var [currentMajor, currentMinor, currentPatch] = currentVersion.split('.');

    if (int.parse(latestMajor) > int.parse(currentMajor)) return true;

    if (int.parse(latestMajor) == int.parse(currentMajor) &&
        int.parse(latestMinor) > int.parse(currentMinor)) {
      return true;
    }

    if (int.parse(latestMajor) == int.parse(currentMajor) &&
        int.parse(latestMinor) == int.parse(currentMinor) &&
        int.parse(latestPatch) > int.parse(currentPatch)) {
      return true;
    }

    return false;
  }

  Future<String> get apkUrl async {
    var latest = await this.latest;
    var assetsUrl = latest['assets_url'].toString();
    var streamedResponse = await (Client().send(
      Request('GET', Uri.parse(assetsUrl)),
    ));
    var response = await Response.fromStream(streamedResponse);
    var json = jsonDecode(response.body);
    for (var element in json) {
      if (element['name'].toString().toLowerCase().endsWith('.apk')) {
        return element['browser_download_url'].toString();
      }
    }
    throw 'apk not found';
  }

  Future<void> downloadLatest() async {
    try {
      updateNotifier.value = UpdateStatus.inProgress;
      var apkUrl = await this.apkUrl;
      OtaUpdate()
          .execute(apkUrl)
          .listen(
            null,
            cancelOnError: true,
            onDone: () {
              updateNotifier.value = UpdateStatus.available;
            },
            onError: (Object error) {
              updateNotifier.value = UpdateStatus.available;
            },
          );
    } catch (e) {
      logger.error(e.toString());
      ModalUtil.showError(e);
      updateNotifier.value = UpdateStatus.available;
    }
  }
}
