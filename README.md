# ascii_art_tree

[![pub package](https://img.shields.io/pub/v/ascii_art_tree.svg?logo=dart&logoColor=00b9fc)](https://pub.dartlang.org/packages/ascii_art_tree)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![Codecov](https://img.shields.io/codecov/c/github/gmpassos/ascii_art_tree)](https://app.codecov.io/gh/gmpassos/ascii_art_tree)
[![Dart CI](https://github.com/gmpassos/ascii_art_tree/actions/workflows/dart.yml/badge.svg?branch=master)](https://github.com/gmpassos/ascii_art_tree/actions/workflows/dart.yml)
[![GitHub Tag](https://img.shields.io/github/v/tag/gmpassos/ascii_art_tree?logo=git&logoColor=white)](https://github.com/gmpassos/ascii_art_tree/releases)
[![New Commits](https://img.shields.io/github/commits-since/gmpassos/ascii_art_tree/latest?logo=git&logoColor=white)](https://github.com/gmpassos/ascii_art_tree/network)
[![Last Commits](https://img.shields.io/github/last-commit/gmpassos/ascii_art_tree?logo=git&logoColor=white)](https://github.com/gmpassos/ascii_art_tree/commits/master)
[![Pull Requests](https://img.shields.io/github/issues-pr/gmpassos/ascii_art_tree?logo=github&logoColor=white)](https://github.com/gmpassos/ascii_art_tree/pulls)
[![Code size](https://img.shields.io/github/languages/code-size/gmpassos/ascii_art_tree?logo=github&logoColor=white)](https://github.com/gmpassos/ascii_art_tree)
[![License](https://img.shields.io/github/license/gmpassos/ascii_art_tree?logo=open-source-initiative&logoColor=green)](https://github.com/gmpassos/ascii_art_tree/blob/master/LICENSE)

A minimalistic ASCII Art Tree generator with multiple styles.

## Usage

```dart
import 'package:ascii_art_tree/ascii_art_tree.dart';

void main() async {
  var paths = [
    '/workspace/project-x/src/base.dart',
    '/workspace/project-x/src/entities.dart',
    '/workspace/project-x/src/system.dart',
    '/workspace/project-x/assets/file2.txt',
    '/workspace/project-x/assets/images/imgX.png',
    '/workspace/project-x/assets/images/imgY.png',
  ];

  var asciiArtTree = ASCIIArtTree.fromStringPaths(
    paths,
    style: ASCIIArtTreeStyle.elegant,
  );

  var tree = asciiArtTree.generate();
  print(tree);
}
```

Output in `elegant` style (default):
```text
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
```

Output in `dots` style:

```text
/
.workspace
...project-x
.....src
.......base.dart
.......entities.dart
.......system.dart
.....assets
.......file2.txt
.......images
.........imgX.png
.........imgY.png
```

Output in `spaces` style:

```text
/
 workspace
   project-x
     src
       base.dart
       entities.dart
       system.dart
     assets
       file2.txt
       images
         imgX.png
         imgY.png
```

## CLI Tool

You can utilize the CLI tool `ascii_art_tree` with ease on any platform supported by Dart.

To activate the CLI tool just run:

```shell
dart pub global activate ascii_art_tree
```

Then you can create a ASCII Art Tree from the terminal.

### CLI Examples

- Read a text file with path entries and generate the ASCII Art Tree in `elegant` style:
    ```shell
    ascii_art_tree /dir/paths.txt --elegant
    ```

- Read a text file with path entries using ":" delimiter:
    ```shell
    ascii_art_tree /dir/paths.txt :    
    ```

- Read a JSON file:
    ```shell
    ascii_art_tree /dir/tree.json
    ```
    Forcing from JSON:
    ```shell
    ascii_art_tree /dir/tree.txt --from-json
    ```
- Generating a JSON output:
    ```shell
    ascii_art_tree /dir/paths.txt : --to-json
    ```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/gmpassos/ascii_art_tree/issues

## Author

Graciliano M. Passos: [gmpassos@GitHub][github].

[github]: https://github.com/gmpassos

## Sponsor

Don't be shy, show some love, and become our [GitHub Sponsor][github_sponsors].
Your support means the world to us, and it keeps the code caffeinated! ☕✨

Thanks a million! 🚀😄

[github_sponsors]: https://github.com/sponsors/gmpassos

## License

Dart free & open-source [license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).
