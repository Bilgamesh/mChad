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
      final latest = await this.latest;
      return latest['tag_name'].toString().substring(1);
    } catch (e) {
      logger.error(e.toString());
      return '0.0.0';
    }
  }

  Future<dynamic> get latest async {
    final streamedResponse = await (Client().send(
      Request('GET', Uri.parse(endpoint)),
    ));
    final response = await Response.fromStream(streamedResponse);
    final json = jsonDecode(response.body);
    final latest = json[0];
    return latest;
  }

  Future<bool> isNewVersionAvailable(String currentVersion) async {
    final latest = await latestVersion;
    final [latestMajor, latestMinor, latestPatch] = latest.split('.');
    final [currentMajor, currentMinor, currentPatch] = currentVersion.split('.');

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

  Future<dynamic> get assets async {
    final latest = await this.latest;
    final assetsUrl = latest['assets_url'];
    final streamedResponse = await (Client().send(
      Request('GET', Uri.parse(assetsUrl)),
    ));
    final response = await Response.fromStream(streamedResponse);
    final json = jsonDecode(response.body);
    return json;
  }

  Future<String> getApkUrl(dynamic assets) async {
    for (var asset in assets) {
      if (asset['name'].toString().toLowerCase().endsWith('.apk')) {
        return asset['browser_download_url'].toString();
      }
    }
    throw 'apk not found';
  }

  Future<String?> getSha256checksum(dynamic assets) async {
    for (var asset in assets) {
      if (asset['name'].toString().toLowerCase().endsWith('sha256')) {
        final url = asset['browser_download_url'].toString();
        final streamedResponse = await (Client().send(
          Request('GET', Uri.parse(url)),
        ));
        final response = await Response.fromStream(streamedResponse);
        return response.body.split(' ').first;
      }
    }
    return null;
  }

  Future<void> downloadLatest() async {
    try {
      updateNotifier.value = UpdateStatus.inProgress;
      final assets = await this.assets;
      final apkUrl = await getApkUrl(assets);
      final sha256checksum = await getSha256checksum(assets);
      OtaUpdate()
          .execute(apkUrl, sha256checksum: sha256checksum)
          .listen(
            null,
            cancelOnError: false,
            onDone: () {
              updateNotifier.value = UpdateStatus.available;
            },
            onError: (Object error) {
              logger.error(error.toString());
              ModalUtil.showError(error);
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
