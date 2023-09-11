import 'package:ascii_art_tree/ascii_art_tree.dart';
import 'package:test/test.dart';

void main() {
  group('ASCIITree', () {
    test('generateTreeText: default', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        'file:/x-root/dir1/subA/file1.txt',
        'file:/x-root/dir1/subA/file2.txt',
        'file:/x-root/dir1/subB/file1',
        'file:/x-root/dir1/subB/file2',
        'file:/x-root/dir1/subB/subB1/fileX',
        'file:/x-root/dir1/subB/subB2/fileY',
      ], stripPrefix: 'x-', stripSuffix: '.txt');

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(6));

      expect(
          generateTreeText,
          '''
file:
  └─┬─ root
    └─┬─ dir1
      ├─┬─ subA
      │ ├──> file1
      │ └──> file2
      └─┬─ subB
        ├──> file1
        ├──> file2
        ├─┬─ subB1
        │ └──> fileX
        └─┬─ subB2
          └──> fileY
'''
              .trimLeft());
    });

    test('generateTreeText: elegant 1', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        '_X/dir1/subA/file1',
        '_X/root/dir1/subA/file2',
      ], style: ASCIIArtTreeStyle.elegant);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(2));
      expect(asciiArtTree.totalNodes, equals(8));

      expect(
          generateTreeText,
          '''
_X
 ├─┬─ dir1
 │ └─┬─ subA
 │   └──> file1
 └─┬─ root
   └─┬─ dir1
     └─┬─ subA
       └──> file2
'''
              .trimLeft());
    });

    test('generateTreeText: elegant 2', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        '/root/dir1/subA/file1',
        '/root/dir1/subA/file2',
        '/root/dir1/subB/file1',
        '/root/dir1/subB/file2',
        '/root/dir1/subB/subB1/fileX',
        '/root/dir1/subB/subB2/fileY',
      ], style: ASCIIArtTreeStyle.elegant);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(6));
      expect(asciiArtTree.totalNodes, equals(13));

      expect(
          generateTreeText,
          '''
/
└─┬─ root
  └─┬─ dir1
    ├─┬─ subA
    │ ├──> file1
    │ └──> file2
    └─┬─ subB
      ├──> file1
      ├──> file2
      ├─┬─ subB1
      │ └──> fileX
      └─┬─ subB2
        └──> fileY
'''
              .trimLeft());
    });

    test('generateTreeText: elegant 3', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        '/workspace/project-x/src/base.dart',
        '/workspace/project-x/src/entities.dart',
        '/workspace/project-x/src/system.dart',
        '/workspace/project-x/assets/file2.txt',
        '/workspace/project-x/assets/images/imgX.png',
        '/workspace/project-x/assets/images/imgY.png',
      ], style: ASCIIArtTreeStyle.elegant);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(6));
      expect(asciiArtTree.totalNodes, equals(12));

      expect(
          generateTreeText,
          '''
/
└─┬─ workspace
  └─┬─ project-x
    ├─┬─ src
    │ ├──> base.dart
    │ ├──> entities.dart
    │ └──> system.dart
    └─┬─ assets
      ├──> file2.txt
      └─┬─ images
        ├──> imgX.png
        └──> imgY.png
'''
              .trimLeft());
    });

    test('generateTreeText: elegant 4', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        '/workspace-code/project-x/src/base.dart',
        '/workspace-code/project-x/src/entities.dart',
        '/workspace-code/project-x/src/system.dart',
        '/workspace-assets/project-x/assets/file2.txt',
        '/workspace-assets/project-x/assets/images/imgX.png',
        '/workspace-assets/project-x/assets/images/imgY.png',
      ], style: ASCIIArtTreeStyle.elegant);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(6));
      expect(asciiArtTree.totalNodes, equals(14));

      expect(
          generateTreeText,
          '''
/
├─┬─ workspace-code
│ └─┬─ project-x
│   └─┬─ src
│     ├──> base.dart
│     ├──> entities.dart
│     └──> system.dart
└─┬─ workspace-assets
  └─┬─ project-x
    └─┬─ assets
      ├──> file2.txt
      └─┬─ images
        ├──> imgX.png
        └──> imgY.png
'''
              .trimLeft());
    });

    test('generateTreeText: elegant 5', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        'workspace-code/project-x/src/base.dart',
        'workspace-code/project-x/src/entities.dart',
        'workspace-code/project-x/src/system.dart',
        'workspace-assets/project-x/assets/file2.txt',
        'workspace-assets/project-x/assets/images/imgX.png',
        'workspace-assets/project-x/assets/images/imgY.png',
      ], style: ASCIIArtTreeStyle.elegant);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(6));
      expect(asciiArtTree.totalNodes, equals(13));

      expect(
          generateTreeText,
          '''
workspace-code
  └─┬─ project-x
    └─┬─ src
      ├──> base.dart
      ├──> entities.dart
      └──> system.dart
workspace-assets
  └─┬─ project-x
    └─┬─ assets
      ├──> file2.txt
      └─┬─ images
        ├──> imgX.png
        └──> imgY.png
'''
              .trimLeft());
    });

    test('generateTreeText: elegant 6', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        'a/project-x/src/base.dart',
        'a/project-x/src/entities.dart',
        'a/project-x/src/system.dart',
        'b/project-x/assets/file2.txt',
        'b/project-x/assets/images/imgX.png',
        'b/project-x/assets/images/imgY.png',
      ], style: ASCIIArtTreeStyle.elegant);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(6));
      expect(asciiArtTree.totalNodes, equals(13));

      expect(
          generateTreeText,
          '''
a
└─┬─ project-x
  └─┬─ src
    ├──> base.dart
    ├──> entities.dart
    └──> system.dart
b
└─┬─ project-x
  └─┬─ assets
    ├──> file2.txt
    └─┬─ images
      ├──> imgX.png
      └──> imgY.png
'''
              .trimLeft());
    });

    test('generateTreeText: elegant 7', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        'aa/project-x/src/base.dart',
        'aa/project-x/src/entities.dart',
        'aa/project-x/src/system.dart',
        'bb/project-x/assets/file2.txt',
        'bb/project-x/assets/images/imgX.png',
        'bb/project-x/assets/images/imgY.png',
      ], style: ASCIIArtTreeStyle.elegant);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(6));
      expect(asciiArtTree.totalNodes, equals(13));

      expect(
          generateTreeText,
          '''
aa
 └─┬─ project-x
   └─┬─ src
     ├──> base.dart
     ├──> entities.dart
     └──> system.dart
bb
 └─┬─ project-x
   └─┬─ assets
     ├──> file2.txt
     └─┬─ images
       ├──> imgX.png
       └──> imgY.png
'''
              .trimLeft());
    });

    test('generateTreeText: elegant 8', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        '/workspace/project-code/src/base.dart',
        '/workspace/project-code/src/entities.dart',
        '/workspace/project-code/src/system.dart',
        '/workspace/project-assets/assets/file2.txt',
        '/workspace/project-assets/assets/images/imgX.png',
        '/workspace/project-assets/assets/images/imgY.png',
      ], style: ASCIIArtTreeStyle.elegant);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(6));
      expect(asciiArtTree.totalNodes, equals(13));

      expect(
          generateTreeText,
          '''
/
└─┬─ workspace
  ├─┬─ project-code
  │ └─┬─ src
  │   ├──> base.dart
  │   ├──> entities.dart
  │   └──> system.dart
  └─┬─ project-assets
    └─┬─ assets
      ├──> file2.txt
      └─┬─ images
        ├──> imgX.png
        └──> imgY.png
'''
              .trimLeft());
    });

    test('generateTreeText: elegant 9', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        'root/file1',
        'root/file2',
        'root/file3',
        'root/file4',
      ], stripPrefix: "file:", style: ASCIIArtTreeStyle.elegant);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(4));
      expect(asciiArtTree.totalNodes, equals(5));

      expect(
          generateTreeText,
          '''
root
  ├──> file1
  ├──> file2
  ├──> file3
  └──> file4
'''
              .trimLeft());
    });

    test('generateTreeText: dots 1', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        'file:/root/dir1/subA/file1',
        'file:/root/dir1/subA/file2',
        'file:/root/dir1/subB/file1',
        'file:/root/dir1/subB/file2',
      ], stripPrefix: "file:", style: ASCIIArtTreeStyle.dots);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(4));
      expect(asciiArtTree.totalNodes, equals(9));

      expect(
          generateTreeText,
          '''
root
..dir1
....subA
......file1
......file2
....subB
......file1
......file2
'''
              .trimLeft());
    });

    test('generateTreeText: dots 2', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        '/root/dir1/subA/file1',
        '/root/dir1/subA/file2',
        '/root/dir1/subB/file1',
        '/root/dir1/subB/file2',
      ], style: ASCIIArtTreeStyle.dots);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(4));
      expect(asciiArtTree.totalNodes, equals(9));

      expect(
          generateTreeText,
          '''
/
.root
...dir1
.....subA
.......file1
.......file2
.....subB
.......file1
.......file2
'''
              .trimLeft());
    });

    test('generateTreeText: dots 3', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        'root/dir1/subA/file1',
        'root/dir1/subA/file2',
        'root/dir1/subB/file1',
        'root/dir1/subB/file2',
      ], style: ASCIIArtTreeStyle.dots);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(4));
      expect(asciiArtTree.totalNodes, equals(8));

      expect(
          generateTreeText,
          '''
root
..dir1
....subA
......file1
......file2
....subB
......file1
......file2
'''
              .trimLeft());
    });

    test('generateTreeText: dots 4', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        'workspace-code/project-x/src/base.dart',
        'workspace-code/project-x/src/entities.dart',
        'workspace-code/project-x/src/system.dart',
        'workspace-assets/project-x/assets/file2.txt',
        'workspace-assets/project-x/assets/images/imgX.png',
        'workspace-assets/project-x/assets/images/imgY.png',
      ], style: ASCIIArtTreeStyle.dots);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(6));
      expect(asciiArtTree.totalNodes, equals(13));

      expect(
          generateTreeText,
          '''
workspace-code
..project-x
....src
......base.dart
......entities.dart
......system.dart
workspace-assets
..project-x
....assets
......file2.txt
......images
........imgX.png
........imgY.png
'''
              .trimLeft());
    });

    test('generateTreeText: dots 5', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        'a/project-x/src/base.dart',
        'a/project-x/src/entities.dart',
        'a/project-x/src/system.dart',
        'b/project-x/assets/file2.txt',
        'b/project-x/assets/images/imgX.png',
        'b/project-x/assets/images/imgY.png',
      ], style: ASCIIArtTreeStyle.dots);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(6));
      expect(asciiArtTree.totalNodes, equals(13));

      expect(
          generateTreeText,
          '''
a
.project-x
...src
.....base.dart
.....entities.dart
.....system.dart
b
.project-x
...assets
.....file2.txt
.....images
.......imgX.png
.......imgY.png
'''
              .trimLeft());
    });

    test('generateTreeText: dots 6', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        'aa/project-x/src/base.dart',
        'aa/project-x/src/entities.dart',
        'aa/project-x/src/system.dart',
        'bb/project-x/assets/file2.txt',
        'bb/project-x/assets/images/imgX.png',
        'bb/project-x/assets/images/imgY.png',
      ], style: ASCIIArtTreeStyle.dots);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalRoots, equals(2));
      expect(asciiArtTree.totalLeaves, equals(6));
      expect(asciiArtTree.totalNodes, equals(13));
      expect(asciiArtTree.roots, equals(['aa', 'bb']));

      expect(
          generateTreeText,
          '''
aa
..project-x
....src
......base.dart
......entities.dart
......system.dart
bb
..project-x
....assets
......file2.txt
......images
........imgX.png
........imgY.png
'''
              .trimLeft());
    });

    test('generateTreeText: spaces', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        '/root/dir1/subA/file1',
        '/root/dir1/subA/file2',
        '/root/dir1/subB/file1',
        '/root/dir1/subB/file2',
      ], blankRoot: '', style: ASCIIArtTreeStyle.spaces);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(4));
      expect(asciiArtTree.totalNodes, equals(9));

      expect(
          generateTreeText,
          '''
root
  dir1
    subA
      file1
      file2
    subB
      file1
      file2
'''
              .trimLeft());
    });

    test('generateTreeText: with pathInfoProvider', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        '/root/dir1/subA/file1',
        '/root/dir1/subA/file2',
        '/root/dir1/subB/file1',
        '/root/dir1/subB/file2',
      ], blankRoot: '', style: ASCIIArtTreeStyle.spaces);

      asciiArtTree.pathInfoProvider = (parents, node, path) {
        var fullPath = [...parents, path].join('/');
        if (fullPath.endsWith('subA/file1')) {
          return '(x)';
        } else if (fullPath.endsWith('subB/file1')) {
          return '(y)';
        } else {
          return null;
        }
      };

      var generateTreeText = asciiArtTree.generate(indent: '> ', trim: true);

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(4));
      expect(asciiArtTree.totalNodes, equals(9));

      expect(
          generateTreeText,
          '''
> root
>   dir1
>     subA
>       file1 (x)
>       file2
>     subB
>       file1 (y)
>       file2
'''
              .trim());
    });

    test('toJson/fromJson', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        '/root/dir1/subA/file1',
        '/root/dir1/subA/file2',
        '/root/dir2/subB/file3',
        '/root/dir2/subC/file4',
      ], style: ASCIIArtTreeStyle.dots);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalRoots, equals(1));
      expect(asciiArtTree.totalLeaves, equals(4));
      expect(asciiArtTree.totalNodes, equals(11));
      expect(asciiArtTree.roots, equals(['/']));

      expect(
          generateTreeText,
          '''
/
.root
...dir1
.....subA
.......file1
.......file2
...dir2
.....subB
.......file3
.....subC
.......file4
'''
              .trimLeft());

      var json = asciiArtTree.toJson();

      expect(
          json,
          equals({
            '/': {
              'root': {
                'dir1': {
                  'subA': {'file1': null, 'file2': null}
                },
                'dir2': {
                  'subB': {'file3': null},
                  'subC': {'file4': null}
                }
              }
            }
          }));

      var asciiArtTree2 =
          ASCIIArtTree.fromJson(json, style: ASCIIArtTreeStyle.dots);

      expect(asciiArtTree2.generate(), equals(generateTreeText));

      expect(asciiArtTree2.totalLeaves, equals(4));
      expect(asciiArtTree2.totalNodes, equals(11));
    });

    test('graph 1', () async {
      var asciiArtTree = ASCIIArtTree({
        'a': {
          'b': {
            'c': {
              'f': {'x': null}
            },
            'd': {
              'e': {'f': 'f'}
            },
          }
        }
      }, allowGraphs: true);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(1));
      expect(asciiArtTree.totalNodes, equals(7));

      expect(
          generateTreeText,
          '''
a
└─┬─ b
  ├─┬─ c
  │ └─┬─ f
  │   └──> x
  └─┬─ d
    └─┬─ e
      └─┬─ f ººº
'''
              .trimLeft());

      var json = asciiArtTree.toJson();

      expect(
          json,
          equals({
            'a': {
              'b': {
                'c': {
                  'f': {'x': null}
                },
                'd': {
                  'e': {'f': 'f'}
                }
              }
            }
          }));

      var asciiArtTree2 = ASCIIArtTree.fromJson(json, allowGraphs: true);

      expect(asciiArtTree2.generate(), equals(generateTreeText));

      expect(asciiArtTree2.totalLeaves, equals(1));
      expect(asciiArtTree2.totalNodes, equals(7));
    });

    test('graph 1 (expandGraphs)', () async {
      var asciiArtTree = ASCIIArtTree({
        'a': {
          'b': {
            'c': {
              'f': {'x': null}
            },
            'd': {
              'e': {'f': 'f'}
            },
          }
        }
      }, allowGraphs: true);

      var generateTreeText = asciiArtTree.generate(expandGraphs: true);

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(1));
      expect(asciiArtTree.totalNodes, equals(7));

      expect(
          generateTreeText,
          '''
a
└─┬─ b
  ├─┬─ c
  │ └─┬─ f
  │   └──> x
  └─┬─ d
    └─┬─ e
      └─┬─ f
        └──> x
'''
              .trimLeft());

      var json = asciiArtTree.toJson();

      expect(
          json,
          equals({
            'a': {
              'b': {
                'c': {
                  'f': {'x': null}
                },
                'd': {
                  'e': {'f': 'f'}
                }
              }
            }
          }));

      var asciiArtTree2 = ASCIIArtTree.fromJson(json, allowGraphs: true);

      expect(
          asciiArtTree2.generate(expandGraphs: true), equals(generateTreeText));

      expect(asciiArtTree2.totalLeaves, equals(1));
      expect(asciiArtTree2.totalNodes, equals(7));
    });

    test('graph 2', () async {
      var asciiArtTree = ASCIIArtTree({
        'a': {
          'b': {
            'c': {
              'f': {'x': null}
            },
            'd': {
              'e': {
                'f': {'y': null}
              }
            },
          }
        }
      }, allowGraphs: true);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(2));
      expect(asciiArtTree.totalNodes, equals(8));
      expect(asciiArtTree.leaves, equals(['x', 'y']));

      expect(
          generateTreeText,
          '''
a
└─┬─ b
  ├─┬─ c
  │ └─┬─ f
  │   ├──> x
  │   └──> y
  └─┬─ d
    └─┬─ e
      └─┬─ f ººº
'''
              .trimLeft());
    });

    test('graph 2 (expandGraphs)', () async {
      var asciiArtTree = ASCIIArtTree({
        'a': {
          'b': {
            'c': {
              'f': {'x': null}
            },
            'd': {
              'e': {
                'f': {'y': null}
              }
            },
          }
        }
      }, allowGraphs: true);

      var generateTreeText = asciiArtTree.generate(expandGraphs: true);

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalLeaves, equals(2));
      expect(asciiArtTree.totalNodes, equals(8));
      expect(asciiArtTree.leaves, equals(['x', 'y']));

      expect(
          generateTreeText,
          '''
a
└─┬─ b
  ├─┬─ c
  │ └─┬─ f
  │   ├──> x
  │   └──> y
  └─┬─ d
    └─┬─ e
      └─┬─ f
        ├──> x
        └──> y
'''
              .trimLeft());

      var json = asciiArtTree.toJson();

      expect(
          json,
          equals({
            'a': {
              'b': {
                'c': {
                  'f': {'x': null, 'y': null}
                },
                'd': {
                  'e': {'f': 'f'}
                }
              }
            }
          }));

      var asciiArtTree2 = ASCIIArtTree.fromJson(json, allowGraphs: true);

      expect(
          asciiArtTree2.generate(expandGraphs: true), equals(generateTreeText));

      expect(asciiArtTree2.totalLeaves, equals(2));
      expect(asciiArtTree2.totalNodes, equals(8));
    });

    test('graph 3 (node ref error)', () async {
      expect(
          () => ASCIIArtTree({
                'a': {
                  'b': {
                    'c': {
                      'f': {'x': null}
                    },
                    'd': {
                      'e': {'f': 'z'}
                    },
                  }
                }
              }, allowGraphs: true),
          throwsStateError);
    });

    test('graph 3 (node type error)', () async {
      expect(
          () => ASCIIArtTree({
                'a': {
                  'b': {
                    'c': {
                      'f': {
                        'x': ['!']
                      }
                    },
                    'd': {
                      'e': {'f': 'f'}
                    },
                  }
                }
              }, allowGraphs: true),
          throwsStateError);
    });

    test('graph 4 (expandGraphs)', () async {
      var asciiArtTree = ASCIIArtTree({
        'a': {
          'b': {
            'c': {'f': 'f'},
            'd': {
              'e': {
                'f': {'g': null}
              }
            },
          }
        }
      }, allowGraphs: true);

      var generateTreeText = asciiArtTree.generate(expandGraphs: true);

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalRoots, equals(1));
      expect(asciiArtTree.totalLeaves, equals(1));
      expect(asciiArtTree.totalNodes, equals(7));
      expect(asciiArtTree.roots, equals(['a']));
      expect(asciiArtTree.leaves, equals(['g']));

      expect(
          generateTreeText,
          '''
a
└─┬─ b
  ├─┬─ c
  │ └─┬─ f
  │   └──> g
  └─┬─ d
    └─┬─ e
      └─┬─ f
        └──> g
'''
              .trimLeft());
    });

    test('graph 5', () async {
      var asciiArtTree = ASCIIArtTree({
        'a': {
          'b': {
            'c': {'f': null},
            'd': {
              'e': {'f': 'f'}
            },
          }
        }
      }, allowGraphs: true);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalRoots, equals(1));
      expect(asciiArtTree.totalLeaves, equals(1));
      expect(asciiArtTree.totalNodes, equals(6));
      expect(asciiArtTree.roots, equals(['a']));
      expect(asciiArtTree.leaves, equals(['f']));

      expect(
          generateTreeText,
          '''
a
└─┬─ b
  ├─┬─ c
  │ └──> f
  └─┬─ d
    └─┬─ e
      └──> f ººº
'''
              .trimLeft());
    });

    test('graph 5 (expandGraphs)', () async {
      var asciiArtTree = ASCIIArtTree({
        'a': {
          'b': {
            'c': {'f': null},
            'd': {
              'e': {'f': 'f'}
            },
          }
        }
      }, allowGraphs: true);

      var generateTreeText = asciiArtTree.generate(expandGraphs: true);

      print('\n\n$generateTreeText');

      expect(asciiArtTree.totalRoots, equals(1));
      expect(asciiArtTree.totalLeaves, equals(1));
      expect(asciiArtTree.totalNodes, equals(6));
      expect(asciiArtTree.roots, equals(['a']));
      expect(asciiArtTree.leaves, equals(['f']));

      expect(
          generateTreeText,
          '''
a
└─┬─ b
  ├─┬─ c
  │ └──> f
  └─┬─ d
    └─┬─ e
      └──> f
'''
              .trimLeft());
    });
  });
}
