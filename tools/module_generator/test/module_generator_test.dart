import 'package:flutter_test/flutter_test.dart';
import 'package:module_generator/common/common_function.dart';

void main() {
  test('test common function', () async {
    expect(formatClassName('inputName'), 'InputName');
    expect(formatClassName('input_Name'), 'InputName');
    expect(formatClassName('input_name'), 'InputName');
    expect(formatClassName('input_name4'), 'InputName4');

    expect(formatModuleName('inputName'), 'input_name');
    expect(formatModuleName('input_Name'), 'input_name');
    expect(formatModuleName('input_name'), 'input_name');
    expect(formatModuleName('inputName'), 'input_name');
    expect(formatModuleName('inputName4'), 'input_name4');

    expect(camelCase('inputName'), 'inputName');
    expect(camelCase('input_name'), 'inputName');
    expect(camelCase('Input_Name'), 'inputName');
    expect(camelCase('Input Name'), 'inputName');
    expect(camelCase('Input name'), 'inputName');
    expect(camelCase('Input NAME'), 'inputNAME');
    expect(camelCase('Input NAME '), 'inputNAME');
    expect(camelCase('Input NAME 4'), 'inputNAME4');
  });
}
