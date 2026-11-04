## 1.1.2

- graph_explorer: ^1.1.2
  - Fixes `GraphWalker` `maxDepth` in DFS walks (a node reached again within `maxDepth` could be
    skipped), which affects side-branch expansion (`walkByNodes(expandSideBranches: ...)`).

## 1.1.1

- graph_explorer: ^1.1.1, which fixes `Graph.fromJson` for non-`String` node values and
  `Graph.toTree` ignoring `keyCast`:
  - The input tree is still copied (to stringify keys and keep the caller's map unmodified),
    but into plain `Map`s: the lookup-by-node workaround map class was removed.
  - `Graph.toASCIIArtTree` now uses `Graph.toTree`.
- `generate`: the styles now rewrite only the tree structure of each line, never the labels:
  - Fix: labels containing box-drawing characters (`├`, `╚─`, `═┬─`, ...) were altered by
    the `elegant` style.
  - Fix: `dots` and `spaces` dropped a root label up to its first space (`my dir` rendered
    as `dir`), and a root's `pathInfoProvider` info replaced the root label.
  - Fix: `dots` and `spaces` threw a `StateError` for a tree with only a blank root.
  - Fix: with `hideReferences`, a connector before hidden references at the end of a tree
    was not turned into a corner (`├` instead of `└`).
- Removed the unused `collection` dependency.
- Tests: golden outputs for every style (wide, deep, multi-root, unicode, special
  characters), path delimiters, JSON round-trips and CLI end-to-end. Line coverage: 100%.

- graph_explorer: ^1.1.1

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
