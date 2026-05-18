
if [ -z "$1" ]; then
  echo "Error: Directory path not provided."
  echo "Usage: $0 <directory_path>"
  exit 1
fi

if [ ! -d "$1" ]; then
  echo "Error: Directory '$1' does not exist."
  exit 1
fi

# Check if the directory is a Flutter project
if [ ! -f "$1/pubspec.yaml" ]; then
  echo "Error: '$1' is not a Flutter project (missing pubspec.yaml)."
  exit 1
fi

cd $1
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html