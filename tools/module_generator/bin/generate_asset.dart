import 'package:args/args.dart';
import 'package:module_generator/generate_asset.dart' as generate_asset;

void main(List<String> args) {
  var parser = ArgParser();
  parser.addOption(
    'path',
    callback: (path) => {generate_asset.generateAsset(args: args)},
  );
  parser.parse(args);
}
