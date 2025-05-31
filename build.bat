powershell "rm mChad_v*"

for /f "tokens=2 delims=: " %%a in ('findstr "version:" pubspec.yaml') do (
    set versionName=%%a
)

powershell "flutter build apk --release"

powershell cp ".\build\app\outputs\flutter-apk\app-release.apk" "'.\mChad_v%versionName%.apk'"
powershell wsl "apksigner sign --ks net.przegrywy.keystore --ks-key-alias przegrywy mChad_v%versionName%.apk"
powershell wsl "sha256sum 'mChad_v%versionName%.apk' > 'mChad_v%versionName%.apk.sha256'"