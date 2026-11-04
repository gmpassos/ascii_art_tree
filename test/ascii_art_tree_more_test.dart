import 'dart:convert';
import 'dart:io';

import 'package:ascii_art_tree/ascii_art_tree.dart';
import 'package:graph_explorer/graph_explorer.dart';
import 'package:test/test.dart';

/// The graph from the `graph_explorer` README:
/// `a -> b -> {c, d}`, `c -> f`, `d -> e -> f`, `f -> x`.
Graph<String> _sampleGraph() {
  var graph = Graph<String>();
  graph.node('a').getOrAddOutput('b')
    ..addOutput('c')
    ..addOutput('d');
  graph.node('c').addOutput('f');
  graph.node('d').getOrAddOutput('e').addOutput('f');
  graph.node('f').addOutput('x');
  return graph;
}

String _render(Map tree, ASCIIArtTreeStyle style) =>
    ASCIIArtTree(tree, style: style).generate();

void main() {
  group('Edge cases', () {
    test('empty tree', () {
      for (var style in ASCIIArtTreeStyle.values) {
        var tree = ASCIIArtTree({}, style: style);
        expect(tree.generate(), equals(''));
        expect(tree.generate(indent: '> ', trim: true), equals(''));
        expect(tree.totalNodes, equals(0));
        expect(tree.totalRoots, equals(0));
        expect(tree.totalLeaves, equals(0));
        expect(tree.roots, isEmpty);
        expect(tree.leaves, isEmpty);
        expect(tree.toJson(), equals({}));
      }
    });

    test('empty paths', () {
      var tree = ASCIIArtTree.fromStringPaths([]);
      expect(tree.generate(), equals(''));
      expect(tree.totalNodes, equals(0));

      // Empty (already split) paths are ignored:
      var tree2 = ASCIIArtTree.fromPaths([[], []]);
      expect(tree2.generate(), equals(''));
    });

    test('single node', () {
      for (var style in ASCIIArtTreeStyle.values) {
        expect(_render({'a': null}, style), equals('a\n'));
        expect(
          ASCIIArtTree.fromStringPaths(['single'], style: style).generate(),
          equals('single\n'),
        );
      }

      var tree = ASCIIArtTree({'a': null});
      expect(tree.totalNodes, equals(1));
      expect(tree.roots, equals(['a']));
      expect(tree.leaves, equals(['a']));
      expect(tree.toJson(), equals({'a': null}));
    });

    test('multiple roots', () {
      var json = {
        'a': {'b': null},
        'c': {'d': null, 'e': null},
      };

      expect(
        _render(json, ASCIIArtTreeStyle.elegant),
        equals('''
a
└──> b
c
├──> d
└──> e
'''),
      );
      expect(
        _render(json, ASCIIArtTreeStyle.dots),
        equals('''
a
.b
c
.d
.e
'''),
      );
      expect(
        _render(json, ASCIIArtTreeStyle.spaces),
        equals('''
a
 b
c
 d
 e
'''),
      );

      var tree = ASCIIArtTree(json);
      expect(tree.totalRoots, equals(2));
      expect(tree.roots, equals(['a', 'c']));
      expect(tree.leaves, equals(['b', 'd', 'e']));
    });

    test('unicode labels', () {
      var json = {
        'raíz': {
          '日本': {'файл': null},
          'ü🌳': null,
        },
      };

      expect(
        _render(json, ASCIIArtTreeStyle.elegant),
        equals('''
raíz
  ├─┬─ 日本
  │ └──> файл
  └──> ü🌳
'''),
      );
      expect(
        _render(json, ASCIIArtTreeStyle.dots),
        equals('''
raíz
..日本
....файл
..ü🌳
'''),
      );
      expect(
        _render(json, ASCIIArtTreeStyle.spaces),
        equals('''
raíz
  日本
    файл
  ü🌳
'''),
      );

      expect(ASCIIArtTree(json).toJson(), equals(json));
    });

    test('non-String keys are stringified', () {
      var tree = ASCIIArtTree({
        1: {2: null, true: null},
      });
      expect(
        tree.generate(),
        equals('''
1
├──> 2
└──> true
'''),
      );
      expect(tree.roots, equals(['1']));
    });

    test('input map is not modified', () {
      var json = <String, dynamic>{
        'a': {
          'b': {'c': null},
          'd': {'b': 'b'},
        },
      };
      var copy = jsonDecode(jsonEncode(json));

      ASCIIArtTree(json, allowGraphs: true).generate();
      ASCIIArtTree(json).generate();

      expect(json, equals(copy));
    });

    test('deep tree', () {
      for (var style in ASCIIArtTreeStyle.values) {
        expect(
          ASCIIArtTree.fromStringPaths(['a/b/c/d/e'], style: style).generate(),
          equals(switch (style) {
            ASCIIArtTreeStyle.elegant =>
              '''
a
└─┬─ b
  └─┬─ c
    └─┬─ d
      └──> e
''',
            ASCIIArtTreeStyle.dots =>
              '''
a
.b
...c
.....d
.......e
''',
            ASCIIArtTreeStyle.spaces =>
              '''
a
 b
   c
     d
       e
''',
          }),
        );
      }
    });

    test('very deep tree (no stack overflow)', () {
      const depth = 2000;
      var path = List.generate(depth, (i) => 'n$i');
      var tree = ASCIIArtTree.fromPaths([path]);

      expect(tree.totalNodes, equals(depth));
      expect(tree.leaves, equals(['n${depth - 1}']));

      var lines = tree.generate().split('\n');
      expect(lines.length, equals(depth + 1));
      expect(lines.first, equals('n0'));
      // A 2-char root (`n0`) indents its children by 1 (see `_X` tests):
      expect(lines[1], equals(' └─┬─ n1'));
      expect(lines[2], equals('   └─┬─ n2'));
      expect(lines[depth - 1], equals(' ${'  ' * (depth - 2)}└──> n1999'));
      expect(lines.last, equals(''));
    });

    test('wide tree', () {
      const width = 100;
      var tree = ASCIIArtTree.fromPaths([
        for (var i = 0; i < width; ++i) ['root', 'c$i'],
      ]);

      expect(tree.totalNodes, equals(width + 1));
      expect(tree.totalLeaves, equals(width));

      var lines = tree.generate().split('\n');
      expect(lines.length, equals(width + 2));
      expect(lines.first, equals('root'));
      expect(lines[1], equals('  ├──> c0'));
      expect(lines[50], equals('  ├──> c49'));
      expect(lines[width], equals('  └──> c99'));

      expect(
        tree.generate(style: ASCIIArtTreeStyle.dots).split('\n').sublist(0, 3),
        equals(['root', '..c0', '..c1']),
      );
    });
  });

  group('Paths', () {
    test('RegExp delimiter', () {
      var tree = ASCIIArtTree.fromStringPaths([
        r'/a\b/c',
        'x:y',
      ], delimiter: RegExp(r'[\\/:]'));

      expect(tree.pathDelimiter, equals('/'));
      expect(
        tree.generate(),
        equals('''
/
└─┬─ a
  └─┬─ b
    └──> c
x
└──> y
'''),
      );
    });

    test('custom splitter', () {
      var tree = ASCIIArtTree.fromStringPaths([
        'a.b.c',
        'a.d',
      ], splitter: (s) => s.split('.'));

      expect(
        tree.generate(),
        equals('''
a
├─┬─ b
│ └──> c
└──> d
'''),
      );
    });

    test('custom blankRoot', () {
      var tree = ASCIIArtTree.fromStringPaths(['/a/b'], blankRoot: 'ROOT');

      expect(tree.roots, equals(['ROOT']));
      expect(
        tree.generate(),
        equals('''
ROOT
  └─┬─ a
    └──> b
'''),
      );
    });

    test('same name in different directories is not a graph', () {
      var tree = ASCIIArtTree.fromStringPaths(['/a/x', '/b/x']);

      expect(tree.totalNodes, equals(5));
      expect(tree.totalLeaves, equals(2));
      expect(
        tree.generate(),
        equals('''
/
├─┬─ a
│ └──> x
└─┬─ b
  └──> x
'''),
      );
    });

    test('custom pathDelimiter is used by pathInfoProvider parents', () {
      var tree = ASCIIArtTree.fromPaths([
        ['a', 'b', 'c'],
      ], pathDelimiter: '::');
      expect(tree.pathDelimiter, equals('::'));

      var seen = <String>[];
      tree.pathInfoProvider = (parents, node, key) {
        seen.add([...parents, key].join('/'));
        return null;
      };

      expect(
        tree.generate(),
        equals('''
a
└─┬─ b
  └──> c
'''),
      );
      expect(seen, equals(['a', 'a/b', 'a/b/c']));
    });
  });

  group('generate options', () {
    test('style override', () {
      var tree = ASCIIArtTree({
        'a': {'b': null},
      }, style: ASCIIArtTreeStyle.dots);

      expect(tree.generate(), equals('a\n.b\n'));
      expect(
        tree.generate(style: ASCIIArtTreeStyle.elegant),
        equals('a\n└──> b\n'),
      );
      expect(tree.style, equals(ASCIIArtTreeStyle.dots));

      tree.style = ASCIIArtTreeStyle.spaces;
      expect(tree.generate(), equals('a\n b\n'));
    });

    test('indent and trim', () {
      var tree = ASCIIArtTree({
        'a': {'b': null},
      });

      expect(tree.generate(indent: '  '), equals('  a\n  └──> b\n  '));
      expect(tree.generate(indent: '  ', trim: true), equals('  a\n  └──> b'));
      expect(tree.generate(trim: true), equals('a\n└──> b'));
    });

    test('stripPrefix and stripSuffix', () {
      var tree = ASCIIArtTree.fromStringPaths(
        ['src/lib_a.dart', 'src/lib_b.dart', 'src/main.dart'],
        stripPrefix: 'lib_',
        stripSuffix: '.dart',
      );

      expect(
        tree.generate(),
        equals('''
src
  ├──> a
  ├──> b
  └──> main
'''),
      );

      tree.stripPrefix = null;
      tree.stripSuffix = null;
      expect(
        tree.generate(),
        equals('''
src
  ├──> lib_a.dart
  ├──> lib_b.dart
  └──> main.dart
'''),
      );
    });

    test('pathInfoProvider receives the parent JSON node', () {
      var tree = ASCIIArtTree({
        'a': {
          'b': {'c': null},
          'd': null,
        },
      });

      var notInParent = <String>[];
      tree.pathInfoProvider = (parents, node, key) {
        if (!node.containsKey(key)) notInParent.add(key);
        var child = node[key];
        return child is Map ? '[${child.length}]' : null;
      };

      expect(
        tree.generate(),
        equals('''
a
├─┬─ b [1]
│ └──> c
└──> d
'''),
      );

      // A root has no parent: it receives an empty node.
      expect(notInParent, equals(['a']));
    });
  });

  group('graph_explorer integration', () {
    test('Graph.toASCIIArtTree', () {
      var tree = _sampleGraph().toASCIIArtTree();

      expect(tree.allowGraphs, isTrue);
      expect(tree.totalNodes, equals(7));
      expect(tree.roots, equals(['a']));
      expect(tree.leaves, equals(['x']));

      expect(
        tree.generate(),
        equals('''
a
└─┬─ b
  ├─┬─ d
  │ └─┬─ e
  │   └─┬─ f
  │     └──> x
  └─┬─ c
    └─┬─ f ººº
'''),
      );

      expect(
        tree.toJson(),
        equals({
          'a': {
            'b': {
              'd': {
                'e': {
                  'f': {'x': null},
                },
              },
              'c': {'f': 'f'},
            },
          },
        }),
      );
    });

    test('Graph.toASCIIArtTree: dots and spaces', () {
      expect(
        _sampleGraph().toASCIIArtTree(style: ASCIIArtTreeStyle.dots).generate(),
        equals('''
a
.b
...d
.....e
.......f
.........x
...c
.....f ººº
'''),
      );
      expect(
        _sampleGraph()
            .toASCIIArtTree(style: ASCIIArtTreeStyle.spaces)
            .generate(),
        equals('''
a
 b
   d
     e
       f
         x
   c
     f ººº
'''),
      );
    });

    test('Graph.toASCIIArtTree: keyCast and strip', () {
      var graph = Graph<int>();
      graph.node(1).getOrAddOutput(10).addOutput(100);
      graph.node(1).addOutput(20);

      var tree = graph.toASCIIArtTree(
        keyCast: (v) => 'n$v',
        stripPrefix: 'n',
        stripSuffix: '0',
      );

      expect(tree.roots, equals(['n1']));
      expect(
        tree.generate(),
        equals('''
1
├─┬─ 1
│ └──> 10
└──> 2
'''),
      );
    });

    test('hideReferences and referenceMark', () {
      var tree = _sampleGraph().toASCIIArtTree();

      expect(
        tree.generate(hideReferences: true),
        equals('''
a
└─┬─ b
  ├─┬─ d
  │ └─┬─ e
  │   └─┬─ f
  │     └──> x
  └─┬─ c
'''),
      );

      expect(
        tree
            .generate(referenceMark: '(ref)')
            .split('\n')
            .reversed
            .skip(1)
            .first,
        equals('    └─┬─ f (ref)'),
      );
    });

    test('expandSideBranches', () {
      var tree = _sampleGraph().toASCIIArtTree();

      expect(
        tree.generate(expandSideBranches: true),
        equals('''
a
└─┬─ b
  ├─┬─ d
  │ └─┬─ e
  │   ╠═╦═ c
  │   ║ └─┬─ f
  │   ║   └──> x
  │   └─┬─ f ººº
  └─┬─ c ººº
'''),
      );

      expect(
        tree.generate(expandSideBranches: true, expandGraphs: true),
        equals('''
a
└─┬─ b
  ├─┬─ d
  │ └─┬─ e
  │   ╠═╦═ c
  │   ║ └─┬─ f
  │   ║   └──> x
  │   └─┬─ f
  │     └──> x
  └─┬─ c
    └─┬─ f
      └──> x
'''),
      );

      expect(
        tree.generate(expandSideBranches: true, style: ASCIIArtTreeStyle.dots),
        equals('''
a
.b
...d
.....e
.......c
.........f
...........x
.......f ººº
...c ººº
'''),
      );
    });

    test('ASCIIArtTree.fromGraph and graph', () {
      var tree = _sampleGraph().toASCIIArtTree();
      var graph = tree.graph;

      expect(graph.length, equals(7));
      expect(
        graph.roots.map((n) => n.value),
        equals([isA<ASCIIArtTreeNode>()]),
      );

      var tree2 = ASCIIArtTree.fromGraph(graph, allowGraphs: true);
      expect(identical(tree2.graph, graph), isTrue);
      expect(tree2.generate(), equals(tree.generate()));
      expect(tree2.toJson(), equals(tree.toJson()));
    });

    test('ASCIIArtTree.fromGraph: hand-built graph', () {
      var graph = Graph<ASCIIArtTreeNode>();
      ASCIIArtTreeNode n(String k) => ASCIIArtTreeNode(k, k);
      graph.node(n('r')).getOrAddOutput(n('s')).addOutput(n('t'));
      graph.node(n('r')).addOutput(n('u'));

      var tree = ASCIIArtTree.fromGraph(graph);
      expect(
        tree.generate(),
        equals('''
r
├─┬─ s
│ └──> t
└──> u
'''),
      );
    });

    test('expandSideBranches: nested side branches', () {
      // `f` has 3 inputs: `c`, `e` and `g`.
      var graph = Graph<String>();
      graph.node('a').getOrAddOutput('b')
        ..addOutput('c')
        ..addOutput('d')
        ..addOutput('g');
      graph.node('c').addOutput('f');
      graph.node('d').getOrAddOutput('e').addOutput('f');
      graph.node('g').addOutput('f');
      graph.node('f').addOutput('x');

      expect(
        graph.toASCIIArtTree().generate(expandSideBranches: true),
        equals('''
a
└─┬─ b
  ├─┬─ d
  │ └─┬─ e
  │   ╠═╦═ c
  │   ║ ╠═╦═ g
  │   ║ ║ └─┬─ f
  │   ║ ║   └──> x
  │   ║ └─┬─ f ººº
  │   ├─┬─ g ººº
  │   └─┬─ f ººº
  ├─┬─ c ººº
  └─┬─ g ººº
'''),
      );
    });

    test('expandSideBranches: unsorted', () {
      var graph = Graph<String>();
      graph.node('a')
        ..addOutput('b')
        ..addOutput('c');
      graph.node('b').getOrAddOutput('d').addOutput('e');
      graph.node('c').getOrAddOutput('d');
      graph.node('c').getOrAddOutput('y').addOutput('e');
      graph.node('e').addOutput('z');

      expect(
        graph
            .toASCIIArtTree(sortByInputDependency: false)
            .generate(expandSideBranches: true),
        equals('''
a
├─┬─ b
│ ╠═╦═ c
│ ║ ├─┬─ d
│ ║ │ ╠═╦═ y
│ ║ │ ║ └─┬─ e
│ ║ │ ║   └──> z
│ ║ │ └─┬─ e ººº
│ ║ └─┬─ y ººº
│ └─┬─ d ººº
└─┬─ c ººº
'''),
      );
    });
  });

  group('ASCIIArtTreeNode', () {
    test('equality and hashCode', () {
      var a1 = ASCIIArtTreeNode('/x/a', 'a');
      var a2 = ASCIIArtTreeNode('/x/a', 'a');
      var a3 = ASCIIArtTreeNode('/y/a', 'a');

      expect(a1, equals(a2));
      expect(a1.hashCode, equals(a2.hashCode));
      expect(a1, isNot(equals(a3)));
      expect({a1, a2, a3}.length, equals(2));

      bool eq(Object a, Object b) => a == b;

      expect(eq(a1, Node(a2)), isTrue);
      expect(eq(a1, Node(a3)), isFalse);
      expect(eq(a1, 'a'), isTrue);
      expect(eq(a1, 1), isFalse);

      expect(a1.length, equals(1));
      expect(a1.toString(), equals('a'));
    });
  });

  group('CLI', () {
    late Directory dir;

    setUpAll(() => dir = Directory.systemTemp.createTempSync('ascii_art_tree'));
    tearDownAll(() => dir.deleteSync(recursive: true));

    Future<ProcessResult> cli(List<String> args) => Process.run(
      Platform.resolvedExecutable,
      ['bin/ascii_art_tree.dart', ...args],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );

    String file(String name, String content) {
      var f = File('${dir.path}/$name')..writeAsStringSync(content);
      return f.path;
    }

    test('usage', () async {
      var r = await cli([]);
      expect(r.exitCode, equals(0));
      expect(r.stdout, contains('ASCII Art Tree - CLI'));
      expect(r.stdout, contains('--to-json'));
    });

    test('text paths', () async {
      var path = file('paths.txt', '/x/y\n/x/z\r\n\n  /w  \n');

      var r = await cli([path]);
      expect(r.exitCode, equals(0));
      expect(
        r.stdout,
        equals('''
/
├─┬─ x
│ ├──> y
│ └──> z
└──> w

'''),
      );
    });

    test('text paths: delimiter and style flags', () async {
      var path = file('paths2.txt', 'a:b\na:c\n');

      var r = await cli(['--dots', path, ':']);
      expect(r.exitCode, equals(0));
      expect(r.stdout, equals('a\n.b\n.c\n\n'));

      r = await cli([path, ':', '--spaces']);
      expect(r.stdout, equals('a\n b\n c\n\n'));

      r = await cli([path, ':', '--elegant']);
      expect(r.stdout, equals('a\n├──> b\n└──> c\n\n'));
    });

    test('JSON file (detected by extension)', () async {
      var path = file('tree.json', '{"a": {"b": null, "c": {"d": null}}}');

      var r = await cli([path]);
      expect(r.exitCode, equals(0));
      expect(
        r.stdout,
        equals('''
a
├──> b
└─┬─ c
  └──> d

'''),
      );
    });

    test('--from-json and --to-json', () async {
      var path = file('tree.data', '{"a": {"b": null}}');

      var r = await cli([path, '--from-json', '--to-json']);
      expect(r.exitCode, equals(0));
      expect(
        jsonDecode(r.stdout as String),
        equals({
          'a': {'b': null},
        }),
      );

      var path2 = file('paths3.txt', '/x/y\n');
      r = await cli([path2, '--to-json']);
      expect(
        jsonDecode(r.stdout as String),
        equals({
          '/': {
            'x': {'y': null},
          },
        }),
      );
    });

    test('errors', () async {
      var r = await cli(['${dir.path}/missing.txt']);
      expect(r.exitCode, equals(1));
      expect(r.stderr, contains('File does NOT exists'));

      r = await cli(['--dots']);
      expect(r.exitCode, equals(1));
      expect(r.stderr, contains('No file path provided'));

      r = await cli([file('list.json', '[1, 2]')]);
      expect(r.exitCode, equals(1));
      expect(r.stderr, contains('is not a `Map`'));
    });
  });
}
