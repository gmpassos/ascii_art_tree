import 'dart:convert';

import 'package:ascii_art_tree/ascii_art_tree.dart';
import 'package:graph_explorer/graph_explorer.dart';
import 'package:test/test.dart';

/// Expects the exact rendering of [tree] in every style.
void _expectStyles(
  ASCIIArtTree tree, {
  required String elegant,
  required String dots,
  required String spaces,
}) {
  expect(tree.generate(style: ASCIIArtTreeStyle.elegant), equals(elegant));
  expect(tree.generate(style: ASCIIArtTreeStyle.dots), equals(dots));
  expect(tree.generate(style: ASCIIArtTreeStyle.spaces), equals(spaces));
}

/// Expects [tree] to survive `toJson` -> `fromJson` (also through a JSON
/// string) with the same rendering in every style.
void _expectJsonRoundTrip(ASCIIArtTree tree, {bool allowGraphs = false}) {
  var json = tree.toJson() as Map<String, dynamic>;
  var decoded = jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
  // `equals` compares nested structures up to 100 levels by default:
  const depthLimit = 1000;
  expect(decoded, equals(json, depthLimit));

  for (var j in [json, decoded]) {
    var tree2 = ASCIIArtTree.fromJson(j, allowGraphs: allowGraphs);
    expect(tree2.toJson(), equals(json, depthLimit));
    expect(tree2.totalNodes, equals(tree.totalNodes));
    expect(tree2.roots, equals(tree.roots));
    expect(tree2.leaves, equals(tree.leaves));
    for (var style in ASCIIArtTreeStyle.values) {
      expect(
        tree2.generate(style: style),
        equals(tree.generate(style: style)),
        reason: style.name,
      );
    }
  }
}

void main() {
  group('Golden: every style', () {
    test('single root, wide', () {
      var tree = ASCIIArtTree({
        'r': {
          'a': {'a1': null, 'a2': null},
          'b': null,
          'c': {'c1': null},
          'd': null,
        },
      });

      _expectStyles(
        tree,
        elegant: '''
r
├─┬─ a
│ ├──> a1
│ └──> a2
├──> b
├─┬─ c
│ └──> c1
└──> d
''',
        dots: '''
r
.a
...a1
...a2
.b
.c
...c1
.d
''',
        spaces: '''
r
 a
   a1
   a2
 b
 c
   c1
 d
''',
      );
      _expectJsonRoundTrip(tree);
    });

    test('multiple roots, deep', () {
      var tree = ASCIIArtTree.fromStringPaths(['x/y/z', 'p/q', 'p/r/s']);

      expect(tree.roots, equals(['x', 'p']));
      _expectStyles(
        tree,
        elegant: '''
x
└─┬─ y
  └──> z
p
├──> q
└─┬─ r
  └──> s
''',
        dots: '''
x
.y
...z
p
.q
.r
...s
''',
        spaces: '''
x
 y
   z
p
 q
 r
   s
''',
      );
      _expectJsonRoundTrip(tree);
    });

    test('multiple roots with long names, deep and wide', () {
      var tree = ASCIIArtTree.fromStringPaths([
        'lib/src/a.dart',
        'lib/src/b.dart',
        'lib/main.dart',
        'test/a_test.dart',
      ]);

      _expectStyles(
        tree,
        elegant: '''
lib
  ├─┬─ src
  │ ├──> a.dart
  │ └──> b.dart
  └──> main.dart
test
  └──> a_test.dart
''',
        dots: '''
lib
..src
....a.dart
....b.dart
..main.dart
test
..a_test.dart
''',
        spaces: '''
lib
  src
    a.dart
    b.dart
  main.dart
test
  a_test.dart
''',
      );
      _expectJsonRoundTrip(tree);
    });

    test('unicode: CJK, emoji and ZWJ sequences', () {
      var tree = ASCIIArtTree({
        '根': {
          '日本語': {'😀': null, '👨‍👩‍👧': null},
          '한국어': null,
        },
      });

      // Indentation counts UTF-16 code units, not display width:
      // `根` is a single code unit, so its children are not indented.
      _expectStyles(
        tree,
        elegant: '''
根
├─┬─ 日本語
│ ├──> 😀
│ └──> 👨‍👩‍👧
└──> 한국어
''',
        dots: '''
根
.日本語
...😀
...👨‍👩‍👧
.한국어
''',
        spaces: '''
根
 日本語
   😀
   👨‍👩‍👧
 한국어
''',
      );
      _expectJsonRoundTrip(tree);
    });

    test('unicode: root length is counted in code units', () {
      // `😀` is a surrogate pair (2 code units), like the 2-char `ab`.
      _expectStyles(
        ASCIIArtTree({
          '😀': {'x': null},
          '根': {'y': null},
          'ab': {'z': null},
        }),
        elegant: '''
😀
 └──> x
根
└──> y
ab
 └──> z
''',
        dots: '''
😀
..x
根
.y
ab
..z
''',
        spaces: '''
😀
  x
根
 y
ab
  z
''',
      );
    });

    test('labels with delimiter and punctuation characters', () {
      var tree = ASCIIArtTree.fromStringPaths([
        'a/b c/d-e',
        r'a/x.y:z\w',
        'a/[q]{r}',
      ]);

      _expectStyles(
        tree,
        elegant: r'''
a
├─┬─ b c
│ └──> d-e
├──> x.y:z\w
└──> [q]{r}
''',
        dots: r'''
a
.b c
...d-e
.x.y:z\w
.[q]{r}
''',
        spaces: r'''
a
 b c
   d-e
 x.y:z\w
 [q]{r}
''',
      );
      _expectJsonRoundTrip(tree);
    });

    test('labels with box-drawing characters are not altered', () {
      var tree = ASCIIArtTree({
        'a': {
          'b': {'├x': null},
          'cc cc': null,
          '╚─y': null,
          '╠─z': null,
          'q═┬─r': {'└──> s': null},
        },
      });

      _expectStyles(
        tree,
        elegant: '''
a
├─┬─ b
│ └──> ├x
├──> cc cc
├──> ╚─y
├──> ╠─z
└─┬─ q═┬─r
  └──> └──> s
''',
        dots: '''
a
.b
...├x
.cc cc
.╚─y
.╠─z
.q═┬─r
...└──> s
''',
        spaces: '''
a
 b
   ├x
 cc cc
 ╚─y
 ╠─z
 q═┬─r
   └──> s
''',
      );
      _expectJsonRoundTrip(tree);
    });

    test('root labels with spaces', () {
      var tree = ASCIIArtTree({
        'my dir': {'a b': null},
        'other dir': null,
      });

      _expectStyles(
        tree,
        elegant: '''
my dir
  └──> a b
other dir
''',
        dots: '''
my dir
..a b
other dir
''',
        spaces: '''
my dir
  a b
other dir
''',
      );
      _expectJsonRoundTrip(tree);
    });

    test('labels with new lines (pinned: not re-indented)', () {
      // Multi-line labels are written as is: the continuation lines are not
      // indented (an ASCII tree has one line per node).
      var tree = ASCIIArtTree({
        'a\nb': {'c\nd': null, 'e': null},
      });

      _expectStyles(
        tree,
        elegant: '''
a
b
  ├──> c
d
  └──> e
''',
        dots: '''
a
b
..c
d
..e
''',
        spaces: '''
a
b
  c
d
  e
''',
      );
      _expectJsonRoundTrip(tree);
    });

    test('pathInfoProvider: info on every node, including roots', () {
      var tree = ASCIIArtTree({
        'my dir': {
          'a': {'b': null},
        },
      });
      tree.pathInfoProvider = (parents, node, key) =>
          '(${[...parents, key].join('/')})';

      _expectStyles(
        tree,
        elegant: '''
my dir (my dir)
  └─┬─ a (my dir/a)
    └──> b (my dir/a/b)
''',
        dots: '''
my dir (my dir)
..a (my dir/a)
....b (my dir/a/b)
''',
        spaces: '''
my dir (my dir)
  a (my dir/a)
    b (my dir/a/b)
''',
      );

      // Pinned: a blank info is appended as is (no separating space).
      tree.pathInfoProvider = (parents, node, key) => key == 'a' ? ' ' : null;
      expect(
        tree.generate(style: ASCIIArtTreeStyle.dots),
        equals('my dir\n..a \n....b\n'),
      );
      tree.pathInfoProvider = (parents, node, key) => key == 'a' ? '' : null;
      expect(
        tree.generate(style: ASCIIArtTreeStyle.dots),
        equals('my dir\n..a\n....b\n'),
      );
    });

    test('empty root label', () {
      // A blank root is not rendered by `dots` and `spaces`:
      _expectStyles(
        ASCIIArtTree({'': null}),
        elegant: '\n',
        dots: '',
        spaces: '',
      );
      _expectStyles(
        ASCIIArtTree({
          '': {'a': null},
          'b': null,
        }),
        elegant: '\n└──> a\nb\n',
        dots: 'a\nb\n',
        spaces: 'a\nb\n',
      );
    });

    test('empty child labels', () {
      var tree = ASCIIArtTree.fromStringPaths(['a/b/', 'a//c']);

      expect(tree.totalNodes, equals(5));
      _expectStyles(
        tree,
        elegant: 'a\n├─┬─ b\n│ └──> \n└─┬─ \n  └──> c\n',
        dots: 'a\n.b\n...\n.\n...c\n',
        spaces: 'a\n b\n   \n \n   c\n',
      );
    });
  });

  group('Golden: hidden references', () {
    Graph<String> graph() {
      var g = Graph<String>();
      g.node('a')
        ..addOutput('b')
        ..addOutput('c');
      g.node('b').getOrAddOutput('c').addOutput('d');
      return g;
    }

    test('connector before hidden siblings becomes a corner', () {
      var tree = graph().toASCIIArtTree();

      _expectStyles(
        tree,
        elegant: '''
a
├─┬─ b
│ └─┬─ c
│   └──> d
└─┬─ c ººº
''',
        dots: '''
a
.b
...c
.....d
.c ººº
''',
        spaces: '''
a
 b
   c
     d
 c ººº
''',
      );

      expect(
        tree.generate(hideReferences: true),
        equals('''
a
└─┬─ b
  └─┬─ c
    └──> d
'''),
      );
      expect(
        tree.generate(hideReferences: true, style: ASCIIArtTreeStyle.dots),
        equals('a\n.b\n...c\n.....d\n'),
      );
    });

    test('last line of a tree before hidden siblings', () {
      var g = Graph<String>();
      g.node('r1').addOutput('c');
      g.node('r2')
        ..addOutput('b')
        ..addOutput('c');
      var tree = g.toASCIIArtTree(sortByInputDependency: false);

      expect(
        tree.generate(),
        equals('''
r1
 └──> c
r2
 ├──> b
 └──> c ººº
'''),
      );
      expect(
        tree.generate(hideReferences: true),
        equals('''
r1
 └──> c
r2
 └──> b
'''),
      );
    });

    test('graph round-trip through JSON keeps references', () {
      var g = Graph<String>();
      g.node('a')
        ..addOutput('b')
        ..addOutput('c')
        ..addOutput('e');
      g.node('b')
        ..addOutput('c')
        ..addOutput('e');
      g.node('c').addOutput('d');
      var tree = g.toASCIIArtTree(sortByInputDependency: false);

      expect(
        tree.toJson(),
        equals({
          'a': {
            'b': {
              'c': {'d': null},
              'e': null,
            },
            'c': 'c',
            'e': 'e',
          },
        }),
      );
      expect(
        tree.generate(),
        equals('''
a
├─┬─ b
│ ├─┬─ c
│ │ └──> d
│ └──> e
├─┬─ c ººº
└──> e ººº
'''),
      );
      expect(
        tree.generate(hideReferences: true),
        equals('''
a
└─┬─ b
  ├─┬─ c
  │ └──> d
  └──> e
'''),
      );
      expect(
        tree.generate(expandGraphs: true),
        equals('''
a
├─┬─ b
│ ├─┬─ c
│ │ └──> d
│ └──> e
├─┬─ c
│ └──> d
└──> e
'''),
      );

      _expectJsonRoundTrip(tree, allowGraphs: true);
    });
  });

  group('Golden: indent and trim (all styles)', () {
    var tree = ASCIIArtTree({
      'a': {'b': null},
      'c': null,
    });

    test('indent without trim keeps a trailing indented line', () {
      // Pinned: the text ends with a new line, so the indent is also applied
      // to the empty line after it.
      expect(
        tree.generate(indent: '> ', style: ASCIIArtTreeStyle.elegant),
        equals('> a\n> └──> b\n> c\n> '),
      );
      expect(
        tree.generate(indent: '> ', style: ASCIIArtTreeStyle.dots),
        equals('> a\n> .b\n> c\n> '),
      );
      expect(
        tree.generate(indent: '> ', style: ASCIIArtTreeStyle.spaces),
        equals('> a\n>  b\n> c\n> '),
      );
    });

    test('indent with trim', () {
      expect(
        tree.generate(indent: '> ', trim: true, style: ASCIIArtTreeStyle.dots),
        equals('> a\n> .b\n> c'),
      );
      expect(
        tree.generate(
          indent: '> ',
          trim: true,
          style: ASCIIArtTreeStyle.spaces,
        ),
        equals('> a\n>  b\n> c'),
      );
      expect(
        tree.generate(trim: true, style: ASCIIArtTreeStyle.spaces),
        equals('a\n b\nc'),
      );
    });
  });

  group('Paths', () {
    test('":" delimiter', () {
      var tree = ASCIIArtTree.fromStringPaths(['a:b:c', 'a:d'], delimiter: ':');

      expect(tree.pathDelimiter, equals(':'));
      _expectStyles(
        tree,
        elegant: 'a\n├─┬─ b\n│ └──> c\n└──> d\n',
        dots: 'a\n.b\n...c\n.d\n',
        spaces: 'a\n b\n   c\n d\n',
      );
    });

    test('multi-character delimiter', () {
      var tree = ASCIIArtTree.fromStringPaths([
        'a::b::c',
        'a::d',
        'a:x',
      ], delimiter: '::');

      expect(tree.pathDelimiter, equals('::'));
      expect(tree.roots, equals(['a', 'a:x']));
      expect(tree.generate(), equals('a\n├─┬─ b\n│ └──> c\n└──> d\na:x\n'));
    });

    test(r'backslash delimiter (Windows paths)', () {
      var tree = ASCIIArtTree.fromStringPaths([
        r'C:\Windows\System32',
        r'C:\Users',
      ], delimiter: r'\');

      _expectStyles(
        tree,
        elegant: '''
C:
 ├─┬─ Windows
 │ └──> System32
 └──> Users
''',
        dots: '''
C:
..Windows
....System32
..Users
''',
        spaces: '''
C:
  Windows
    System32
  Users
''',
      );
    });

    test('RegExp delimiter: graph keys use "/"', () {
      var tree = ASCIIArtTree.fromStringPaths([
        'a.b-c',
        'a-b.d',
      ], delimiter: RegExp(r'[.-]'));

      expect(tree.pathDelimiter, equals('/'));
      expect(
        tree.graph.allNodes.map((n) => n.value.graphKey).toList(),
        equals(['a', 'a/b', 'a/b/c', 'a/b/d']),
      );
      expect(tree.generate(), equals('a\n└─┬─ b\n  ├──> c\n  └──> d\n'));
    });

    test('splitter takes precedence over delimiter', () {
      var tree = ASCIIArtTree.fromStringPaths(
        ['a|b/c', 'a|d'],
        delimiter: '/',
        splitter: (s) => s.split('|'),
      );

      expect(tree.generate(), equals('a\n├──> b/c\n└──> d\n'));
    });

    test('duplicate and prefix paths are merged', () {
      var tree = ASCIIArtTree.fromStringPaths([
        'a/b',
        'a/b',
        'a',
        'a/b/c',
        'a/d',
      ]);

      expect(tree.totalNodes, equals(4));
      // In node creation order (`d` is created before `c`):
      expect(tree.leaves, equals(['d', 'c']));
      expect(tree.generate(), equals('a\n├─┬─ b\n│ └──> c\n└──> d\n'));
    });

    test('blank root: default, custom and empty', () {
      var paths = ['/a', '/b'];

      expect(
        ASCIIArtTree.fromStringPaths(paths).generate(),
        equals('/\n├──> a\n└──> b\n'),
      );
      expect(
        ASCIIArtTree.fromStringPaths(paths, blankRoot: '~').generate(),
        equals('~\n├──> a\n└──> b\n'),
      );

      var tree = ASCIIArtTree.fromStringPaths(paths, blankRoot: '');
      expect(tree.roots, equals(['']));
      _expectStyles(
        tree,
        elegant: '\n├──> a\n└──> b\n',
        dots: 'a\nb\n',
        spaces: 'a\nb\n',
      );
    });

    test('allowGraphs: same name is the same node', () {
      var paths = ['a/x', 'b/x/y'];

      var tree = ASCIIArtTree.fromStringPaths(paths);
      expect(tree.totalNodes, equals(5));
      expect(tree.generate(), equals('a\n└──> x\nb\n└─┬─ x\n  └──> y\n'));

      var graph = ASCIIArtTree.fromStringPaths(paths, allowGraphs: true);
      expect(graph.totalNodes, equals(4));
      expect(graph.generate(), equals('a\n└─┬─ x\n  └──> y\nb\n└─┬─ x ººº\n'));
      expect(
        graph.generate(expandGraphs: true),
        equals('a\n└─┬─ x\n  └──> y\nb\n└─┬─ x\n  └──> y\n'),
      );
    });

    test('fromPaths: strip and style', () {
      var tree = ASCIIArtTree.fromPaths(
        [
          ['pkg', 'lib_a.dart'],
          ['pkg', 'lib_b.dart'],
        ],
        stripPrefix: 'lib_',
        stripSuffix: '.dart',
        style: ASCIIArtTreeStyle.dots,
      );

      expect(tree.generate(), equals('pkg\n..a\n..b\n'));
      expect(tree.leaves, equals(['lib_a.dart', 'lib_b.dart']));
    });
  });

  group('JSON', () {
    test('fromJson forwards every option', () {
      var tree = ASCIIArtTree.fromJson(
        {
          'pkg': {'lib_a.dart': null},
        },
        pathDelimiter: '::',
        stripPrefix: 'lib_',
        stripSuffix: '.dart',
        style: ASCIIArtTreeStyle.spaces,
        allowGraphs: true,
      );

      expect(tree.pathDelimiter, equals('::'));
      expect(tree.stripPrefix, equals('lib_'));
      expect(tree.stripSuffix, equals('.dart'));
      expect(tree.style, equals(ASCIIArtTreeStyle.spaces));
      expect(tree.allowGraphs, isTrue);
      expect(tree.generate(), equals('pkg\n  a\n'));
    });

    test('graph keys: full path unless allowGraphs', () {
      var json = {
        'a': {
          'b': {'c': null},
        },
      };

      expect(
        ASCIIArtTree.fromJson(
          json,
          pathDelimiter: '::',
        ).graph.allNodes.map((n) => n.value.graphKey),
        equals(['a', 'a::b', 'a::b::c']),
      );
      expect(
        ASCIIArtTree.fromJson(
          json,
          allowGraphs: true,
        ).graph.allNodes.map((n) => n.value.graphKey),
        equals(['a', 'b', 'c']),
      );
    });

    test('shared (identical) maps are rendered for each parent', () {
      var shared = {'s': null};
      var tree = ASCIIArtTree({
        'a': {'x': shared, 'y': shared},
      });

      expect(
        tree.generate(),
        equals('a\n├─┬─ x\n│ └──> s\n└─┬─ y\n  └──> s\n'),
      );
      expect(
        tree.toJson(),
        equals({
          'a': {
            'x': {'s': null},
            'y': {'s': null},
          },
        }),
      );
    });

    test('a reference merges the definitions of a node (allowGraphs)', () {
      var json = <String, dynamic>{
        'a': {
          'b': {'c': null},
          'd': {'b': 'b'},
        },
      };
      var tree = ASCIIArtTree.fromJson(json, allowGraphs: true);

      expect(
        tree.generate(),
        equals('a\n├─┬─ b\n│ └──> c\n└─┬─ d\n  └─┬─ b ººº\n'),
      );
      _expectJsonRoundTrip(tree, allowGraphs: true);
    });

    test('a 300-level deep tree round-trips', () {
      var path = List.generate(300, (i) => 'n$i');
      var tree = ASCIIArtTree.fromPaths([path]);

      _expectJsonRoundTrip(tree);
    });
  });
}
