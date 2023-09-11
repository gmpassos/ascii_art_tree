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
