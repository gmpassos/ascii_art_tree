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

    test('toJson/fromJson', () async {
      var asciiArtTree = ASCIIArtTree.fromStringPaths([
        '/root/dir1/subA/file1',
        '/root/dir1/subA/file2',
        '/root/dir2/subB/file3',
        '/root/dir2/subC/file4',
      ], style: ASCIIArtTreeStyle.dots);

      var generateTreeText = asciiArtTree.generate();

      print('\n\n$generateTreeText');

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
    });
  });
}
