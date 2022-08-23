

if [[ $(uname -p) == 'arm' ]]; then
  echo "================================================"
  echo "=              Script runing on M1             ="
  echo "================================================"
  echo "==================== Clean  ===================="
  flutter clean; flutter pub get; cd ios; arch -x86_64 pod install; cd ..; flutter pub run build_runner build --delete-conflicting-outputs
fi

if [[ $(uname -p) != 'arm' ]]; then
  echo "================================================"
  echo "=           Script runing on Intel CPU         ="
  echo "================================================"
  echo "==================== Clean  ===================="
  flutter clean; flutter pub get; cd ios; pod install; cd ..; flutter pub run build_runner build --delete-conflicting-outputs
fi