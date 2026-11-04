@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

/// End-to-end tests of `bin/ascii_art_tree.dart`, run as a real process.
void main() {
  late Directory dir;
  late String cliKernel;

  setUpAll(() async {
    dir = Directory.systemTemp.createTempSync('ascii_art_tree_cli');
    cliKernel = '${dir.path}/ascii_art_tree.dill';

    // Compiled once, so each run does not compile the CLI again:
    var r = await Process.run(Platform.resolvedExecutable, [
      'compile',
      'kernel',
      'bin/ascii_art_tree.dart',
      '-o',
      cliKernel,
    ]);
    expect(r.exitCode, equals(0), reason: '${r.stdout}${r.stderr}');
  });

  tearDownAll(() => dir.deleteSync(recursive: true));

  Future<ProcessResult> cli(List<String> args) => Process.run(
    Platform.resolvedExecutable,
    [cliKernel, ...args],
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );

  String file(String name, String content) {
    var f = File('${dir.path}/$name')..writeAsStringSync(content);
    return f.path;
  }

  /// Expects a successful run printing exactly [stdout].
  Future<void> expectOutput(List<String> args, String stdout) async {
    var r = await cli(args);
    expect(r.stderr, isEmpty);
    expect(r.exitCode, equals(0));
    expect(r.stdout, equals(stdout));
  }

  /// Expects a failed run with [exitCode] and [stderr] in the error output.
  Future<void> expectError(
    List<String> args,
    int exitCode,
    Pattern stderr,
  ) async {
    var r = await cli(args);
    expect(r.exitCode, equals(exitCode));
    expect(r.stdout, isEmpty);
    expect(r.stderr, contains(stderr));
  }

  test('usage', () async {
    await expectOutput([], '''
╔════════════════════════╗
║  ASCII Art Tree - CLI  ║
╚════════════════════════╝

» USAGE:

  \$> ascii_art_tree %file %delimiter

» OPTIONS:

  --elegant # Use `elegant` style (default).
  --dots    # Use `dots` style.
  --spaces  # Use `spaces` style.
  --from-json # Parse the file as JSON (implied by `.json` files).
  --to-json   # Output the tree as JSON.

» EXAMPLES:

    # Read a text file with path entries using ":" delimiter:
    ascii_art_tree /dir/paths.txt :

    # Read a JSON file:
    ascii_art_tree /dir/tree.json

''');
  });

  group('text file', () {
    late String paths;

    setUpAll(
      () => paths = file(
        'paths.txt',
        'lib/src/a.dart\nlib/main.dart\r\n\n   test/a_test.dart   \n',
      ),
    );

    test('default style', () async {
      await expectOutput(
        [paths],
        '''
lib
  ├─┬─ src
  │ └──> a.dart
  └──> main.dart
test
  └──> a_test.dart

''',
      );
    });

    test('every style flag', () async {
      await expectOutput(
        ['--elegant', paths],
        '''
lib
  ├─┬─ src
  │ └──> a.dart
  └──> main.dart
test
  └──> a_test.dart

''',
      );
      await expectOutput(
        ['--dots', paths],
        '''
lib
..src
....a.dart
..main.dart
test
..a_test.dart

''',
      );
      await expectOutput(
        [paths, '--spaces'],
        '''
lib
  src
    a.dart
  main.dart
test
  a_test.dart

''',
      );
    });

    test('conflicting style flags: dots, then spaces, then elegant', () async {
      await expectOutput([
        '--spaces',
        '--dots',
        '--elegant',
        paths,
      ], 'lib\n..src\n....a.dart\n..main.dart\ntest\n..a_test.dart\n\n');
      await expectOutput([
        '--elegant',
        '--spaces',
        paths,
      ], 'lib\n  src\n    a.dart\n  main.dart\ntest\n  a_test.dart\n\n');
    });

    test('--to-json (style flags are ignored)', () async {
      var r = await cli([paths, '--to-json', '--dots']);
      expect(r.exitCode, equals(0));
      expect(
        r.stdout,
        equals('''
{
  "lib": {
    "src": {
      "a.dart": null
    },
    "main.dart": null
  },
  "test": {
    "a_test.dart": null
  }
}
'''),
      );
    });

    test('delimiters', () async {
      await expectOutput([
        file('colon.txt', 'a:b:c\na:d\n'),
        ':',
      ], 'a\n├─┬─ b\n│ └──> c\n└──> d\n\n');

      await expectOutput([
        file('multi.txt', 'a::b\na::c:d\n'),
        '::',
      ], 'a\n├──> b\n└──> c:d\n\n');

      await expectOutput([
        file('windows.txt', 'C:\\Users\\me\nC:\\Windows\n'),
        '\\',
      ], 'C:\n ├─┬─ Users\n │ └──> me\n └──> Windows\n\n');

      // Without the delimiter, a line is a single node:
      await expectOutput([file('nodelim.txt', 'a:b\n')], 'a:b\n\n');

      // Extra arguments after the delimiter are ignored:
      await expectOutput([
        file('extra.txt', 'a.b\n'),
        '.',
        'ignored',
      ], 'a\n└──> b\n\n');
    });

    test('absolute paths: blank root', () async {
      await expectOutput([
        file('abs.txt', '/usr/bin\n/usr/lib\n/etc\n'),
      ], '/\n├─┬─ usr\n│ ├──> bin\n│ └──> lib\n└──> etc\n\n');
    });

    test('unicode labels', () async {
      await expectOutput([
        file('unicode.txt', '根/日本語/😀\n根/한국어\n'),
      ], '根\n├─┬─ 日本語\n│ └──> 😀\n└──> 한국어\n\n');
    });

    test('empty file', () async {
      await expectOutput([file('empty.txt', '')], '\n');
      await expectOutput([file('blank.txt', '\n  \n\r\n')], '\n');
    });
  });

  group('JSON file', () {
    test('detected by extension (case-insensitive)', () async {
      var json = '{"a": {"b": null, "c": {"d": null}}}';
      var expected = 'a\n├──> b\n└─┬─ c\n  └──> d\n\n';

      await expectOutput([file('tree.json', json)], expected);
      await expectOutput([file('TREE.JSON', json)], expected);
      await expectOutput([file('tree.json.txt', json)], '$json\n\n');
    });

    test('--from-json with every style', () async {
      var path = file('tree.data', '{"a": {"b": {"c": null}}, "x": null}');

      await expectOutput([path, '--from-json'], 'a\n└─┬─ b\n  └──> c\nx\n\n');
      await expectOutput(['--from-json', '--dots', path], 'a\n.b\n...c\nx\n\n');
      await expectOutput([
        path,
        '--spaces',
        '--from-json',
      ], 'a\n b\n   c\nx\n\n');
    });

    test('--to-json round-trip', () async {
      var json = {
        'a': {
          'b': {'c': null},
          'd': null,
        },
      };
      var path = file('round.json', jsonEncode(json));

      var r = await cli([path, '--to-json']);
      expect(r.exitCode, equals(0));
      expect(jsonDecode(r.stdout as String), equals(json));

      var path2 = file('round2.json', r.stdout as String);
      await expectOutput([path2], 'a\n├─┬─ b\n│ └──> c\n└──> d\n\n');
    });

    test('String values are node references', () async {
      // `"b": "b"` is a reference to the node itself; without `allowGraphs`
      // (the CLI default) each path is its own node:
      await expectOutput([
        file('refs.json', '{"a": {"b": {"c": null}}, "x": {"b": "b"}}'),
      ], 'a\n└─┬─ b\n  └──> c\nx\n└──> b\n\n');
    });
  });

  group('errors', () {
    test('no file path', () async {
      await expectError(['--dots'], 1, '** No file path provided.\n');
      await expectError(
        ['--elegant', '--spaces', '--from-json', '--to-json'],
        1,
        'No file path provided',
      );
    });

    test('missing file, directory and unknown flags', () async {
      var missing = '${dir.path}/missing.txt';
      await expectError([missing], 1, '** File does NOT exists: $missing\n');

      // A directory is not a file:
      await expectError([dir.path], 1, 'File does NOT exists');

      // Unknown flags are taken as the file path:
      await expectError(['--unknown'], 1, 'File does NOT exists');
    });

    test('stdin is not supported: "-" is a file path', () async {
      var p = await Process.start(Platform.resolvedExecutable, [
        cliKernel,
        '-',
      ]);
      p.stdin.writeln('a/b');
      await p.stdin.close();

      var stdout = await p.stdout.transform(utf8.decoder).join();
      var stderr = await p.stderr.transform(utf8.decoder).join();

      expect(await p.exitCode, equals(1));
      expect(stdout, isEmpty);
      expect(stderr, contains('File does NOT exists'));
    });

    test('JSON that is not a Map', () async {
      await expectError(
        [file('list.json', '[1, 2]')],
        1,
        '** Loaded JSON is not a `Map`. Loaded JSON type: List',
      );
      await expectError(
        [file('string.json', '"x"')],
        1,
        'Loaded JSON type: String',
      );
    });

    test('invalid JSON: uncaught error', () async {
      await expectError([file('bad.json', '{"a": ')], 255, 'FormatException');
    });

    test('invalid node type', () async {
      await expectError(
        [file('type.json', '{"a": {"b": 1}}')],
        255,
        'Invalid node type',
      );
    });
  });
}
