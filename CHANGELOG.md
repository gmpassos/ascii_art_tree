## 1.1.0

- Fix: on current Dart runtimes every tree was rendered as just its root node.
  - `Graph.fromJson` looks up each node's JSON entry by node value, and the runtime
    compares map keys using the stored `String` key's `==`, so the lookup never matched.
  - The input tree is now copied into maps that resolve node keys explicitly
    (iteratively, preserving shared maps). The caller's input map is no longer modified.
- New public `ASCIIArtTreeNode`: the node value type of `ASCIIArtTree.graph`
  (previously private while exposed by `graph` and `ASCIIArtTree.fromGraph`).
  - `hashCode` is now consistent with `==` (both use `graphKey`).
- `Graph.toASCIIArtTree`: fix `keyCast` being ignored.
- CLI:
  - Fix detection of `.json` files.
  - Accept style flags before the file path.
  - Document `--from-json` and `--to-json`; errors go to `stderr`.
- Improved test coverage: all styles, edge cases, graphs, side branches and the CLI.

- sdk: ^3.13.0
- path: ^1.9.1
- collection: ^1.19.1
- graph_explorer: ^1.1.0
- lints: ^6.1.0
- dependency_validator: ^5.1.0
- test: ^1.33.0
- coverage: ^1.16.0

## 1.0.6 

-`ASCIIArtTree`:
  - Using `Graph` as internal representation.
  - `generate`:
    - added parameter `hideReferences` and `expandSideBranches`.
    - Using `GraphWalker`.

- graph_explorer: ^1.0.1

## 1.0.5

- `ASCIIArtTree`:
  - Added field `pathDelimiter`.
  - Added `allowGraphs`: support for graphs in the "tree".
  - Added `totalRoots`, `roots`, `totalLeaves` and `leaves`.
  - Fix `totalNodes` for graphs.
  - `_buildTree`: remove recursion to avoid stack overflow and allow big trees.
  - `toJson`: remove recursion and handles graphs.

- collection: ^1.17.0

## 1.0.4

- `ASCIIArtTree`:
  - Added `pathInfoProvider`, to allow extra info for each tree entry.
  - `generate`: add parameters `indent` and `trim`.

## 1.0.3

- Expose CLI.
- `ASCIIArtTree`:
  - Not final fields: `stripPrefix`, `stripSuffix` and `style`. 

## 1.0.2

- Fix example file name.
- Improved documentation.

## 1.0.1

- `ASCIIArtTree`:
  - Added `totalLeafs` and `totalNodes`.

## 1.0.0

- Initial version.
