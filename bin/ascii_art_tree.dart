import 'dart:io';

import 'dart:convert' as dart_convert;
import 'package:ascii_art_tree/ascii_art_tree.dart';
import 'package:path/path.dart' as pack_path;

void main(List<String> args) {
  args = args.toList();

  if (args.isEmpty) {
    print('╔════════════════════════╗');
    print('║  ASCII Art Tree - CLI  ║');
    print('╚════════════════════════╝');
    print('');
    print('» USAGE:\n');
    print('  \$> ascii_art_tree %file %delimiter\n');
    print('» OPTIONS:\n');
    print('  --elegant # Use `elegant` style (default).');
    print('  --dots    # Use `dots` style.');
    print('  --spaces  # Use `spaces` style.');
    print('');
    print('» EXAMPLES:\n');
    print('    # Read a text file with path entries using ":" delimiter:');
    print('    ascii_art_tree /dir/paths.txt :');
    print('');
    print('    # Read a JSON file:');
    print('    ascii_art_tree /dir/tree.json');
    print('');
    exit(0);
  }

  var filePath = args[0];

  var dots = args.remove('--dots');
  var spaces = args.remove('--spaces');
  var elegant = args.remove('--elegant');

  var fromJson = args.remove('--from-json');
  var toJson = args.remove('--to-json');

  var delimiter = args.length > 1 ? args[1] : '/';

  var file = File(filePath).absolute;

  if (!file.existsSync()) {
    stderr.write('** File does NOT exists: ${file.path}\n');
    exit(1);
  }

  var ext = pack_path.extension(file.path);
  if (ext.toLowerCase() == 'json') {
    fromJson = true;
  }

  var content = file.readAsStringSync();

  var asciiArtTree = fromJson
      ? _loadFromJSON(content)
      : _loadFromTextLines(content, delimiter);

  if (toJson) {
    var json = asciiArtTree.toJson();
    var jsonEncoded = dart_convert.JsonEncoder.withIndent('  ').convert(json);
    print(jsonEncoded);
  } else {
    var style = ASCIIArtTreeStyle.elegant;

    if (dots) {
      style = ASCIIArtTreeStyle.dots;
    } else if (spaces) {
      style = ASCIIArtTreeStyle.spaces;
    } else if (elegant) {
      style = ASCIIArtTreeStyle.elegant;
    }

    var tree = asciiArtTree.generate(style: style);
    print(tree);
  }

  exit(0);
}

ASCIIArtTree _loadFromTextLines(String content, String delimiter) {
  var lines = content
      .split(RegExp(r'\r?\n'))
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();

  return ASCIIArtTree.fromStringPaths(lines, delimiter: delimiter);
}

ASCIIArtTree _loadFromJSON(String content) {
  var json = dart_convert.json.decode(content);

  if (json is! Map) {
    print(
        '** Loaded JSON is not a `Map`. Loaded JSON type: ${json.runtimeType}');
    exit(1);
  }

  var map = json.map((k, v) => MapEntry('$k', v));
  return ASCIIArtTree.fromJson(map);
}
