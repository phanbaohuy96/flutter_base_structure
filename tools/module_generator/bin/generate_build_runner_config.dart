import 'package:args/args.dart';
import 'package:module_generator/generate_build_runner_config.dart'
    as generate_build_runner_config;

void main(List<String> args) {
  var parser = ArgParser();
  parser.addOption(
    'path',
    callback: (path) =>
        {generate_build_runner_config.generateBuildRunnerConfig(args: args)},
  );
  parser.parse(args);
}
