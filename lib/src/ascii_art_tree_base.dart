import 'dart:math' as math;

import 'package:graph_explorer/graph_explorer.dart';

/// ASCII Art Tree Styles.
enum ASCIIArtTreeStyle { spaces, dots, elegant }

/// The value of each [Node] in an [ASCIIArtTree.graph].
class ASCIIArtTreeNode {
  /// The global identity of this node in the graph.
  ///
  /// When [ASCIIArtTree.allowGraphs] is `false` this is the full path of the
  /// node (joined with [ASCIIArtTree.pathDelimiter]); otherwise it is [key].
  final String graphKey;

  /// The local key of this node: the text rendered in the tree.
  final String key;

  ASCIIArtTreeNode(this.graphKey, this.key);

  int get length => key.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // When walking the tree:
    if (other is ASCIIArtTreeNode) {
      return runtimeType == other.runtimeType && graphKey == other.graphKey;
    }
    // When accessing a JSON node:
    else if (other is String) {
      return key == other;
    }
    // When accessing processed nodes.
    else if (other is Node<ASCIIArtTreeNode>) {
      return graphKey == other.value.graphKey;
    } else {
      return false;
    }
  }

  // Consistent with `==` between nodes, which compares [graphKey].
  @override
  int get hashCode => graphKey.hashCode;

  @override
  String toString() => key;
}

/// Copies [tree] into `Map<String, dynamic>`s, stringifying the keys.
///
/// `Graph.fromJson` needs `String` keys at every level and merges the
/// definitions of a node referenced more than once into its JSON node
/// (`addAll`), so the caller's [tree] is copied rather than used directly.
///
/// Iterative (not recursive) to support deep trees. A [Map] referenced more
/// than once (or cyclically) is copied only once, preserving the sharing.
Map<String, dynamic> _copyJsonTree(Map tree) {
  final copies = Map<Map, Map<String, dynamic>>.identity();
  final pending = <Map>[];

  Map<String, dynamic> copyOf(Map map) {
    var copy = copies[map];
    if (copy == null) {
      copies[map] = copy = <String, dynamic>{};
      pending.add(map);
    }
    return copy;
  }

  final root = copyOf(tree);

  while (pending.isNotEmpty) {
    final map = pending.removeLast();
    final copy = copies[map]!;
    for (final e in map.entries) {
      final value = e.value;
      copy[e.key.toString()] = value is Map ? copyOf(value) : value;
    }
  }

  return root;
}

/// A line of a rendered tree: the tree structure (indentation, bars,
/// connector and arrow) and the node label (including any path info or
/// reference mark).
///
/// Kept apart so the styles only rewrite the structure, never a label.
typedef _TreeLine = ({String prefix, String label});

/// ASCII Art Tree generator.
class ASCIIArtTree {
  /// The tree.
  late final Graph<ASCIIArtTreeNode> _graph;

  /// The delimiter to use when joining nodes to represent a full path.
  final String pathDelimiter;

  /// Prefix to strip from each tree entry while generating the ASCII Art.
  String? stripPrefix;

  /// Suffix to strip from each tree entry while generating the ASCII Art.
  String? stripSuffix;

  /// The ASCII Art to generate.
  ASCIIArtTreeStyle style;

  /// If `true`, the [tree] will allow graphs.
  /// This means that each node in the tree is a global "key"
  /// (not a local node key), allowing multiple references to the same node.
  ///
  /// Cases:
  /// - If your tree is like a file directory, you don't want to have files
  ///   with the same name but in different directories to be treated as the
  ///   same node (`allowGraphs = false`).
  /// - If your tree is like an import graph, every node with value `x` should
  ///   be treated as the same [Node] (`allowGraphs = true`).
  final bool allowGraphs;

  ASCIIArtTree.fromGraph(
    this._graph, {
    this.pathDelimiter = '/',
    this.stripPrefix,
    this.stripSuffix,
    this.style = ASCIIArtTreeStyle.elegant,
    this.allowGraphs = false,
  });

  ASCIIArtTree(
    Map tree, {
    this.pathDelimiter = '/',
    this.stripPrefix,
    this.stripSuffix,
    this.style = ASCIIArtTreeStyle.elegant,
    this.allowGraphs = false,
  }) {
    _graph = Graph<ASCIIArtTreeNode>.fromJson(
      _copyJsonTree(tree),
      nodeValueMapper: _jsonToNode,
    );
  }

  ASCIIArtTreeNode _jsonToNode(
    GraphStep<ASCIIArtTreeNode>? prevStep,
    String key,
  ) {
    if (allowGraphs) {
      return ASCIIArtTreeNode(key, key);
    } else {
      var graphKey = prevStep != null
          ? prevStep.fullPathToRoot(
              tailString: [key],
              pathDelimiter: pathDelimiter,
            )
          : key;

      return ASCIIArtTreeNode(graphKey, key);
    }
  }

  /// Constructs an [ASCIIArtTree] from a list of paths, splitting
  /// the paths by [delimiter] or using the [splitter] if provided.
  /// See [ASCIIArtTree.fromPaths].
  factory ASCIIArtTree.fromStringPaths(
    Iterable<String> paths, {
    Pattern delimiter = '/',
    List<String> Function(String s)? splitter,
    String blankRoot = '/',
    String? stripPrefix,
    String? stripSuffix,
    ASCIIArtTreeStyle style = ASCIIArtTreeStyle.elegant,
    bool allowGraphs = false,
  }) {
    splitter ??= (p) => p.split(delimiter);

    var paths2 = paths.map(splitter).toList(growable: false);

    if (blankRoot != '') {
      for (var p in paths2) {
        if (p.isNotEmpty && p[0] == '') {
          p[0] = blankRoot;
        }
      }
    }

    return ASCIIArtTree.fromPaths(
      paths2,
      pathDelimiter: delimiter is String ? delimiter : '/',
      stripPrefix: stripPrefix,
      stripSuffix: stripSuffix,
      style: style,
      allowGraphs: allowGraphs,
    );
  }

  /// Constructs an [ASCIIArtTree] from a list of paths (already split).
  /// See [ASCIIArtTree.fromStringPaths].
  factory ASCIIArtTree.fromPaths(
    Iterable<List<String>> paths, {
    String pathDelimiter = '/',
    String? stripPrefix,
    String? stripSuffix,
    ASCIIArtTreeStyle style = ASCIIArtTreeStyle.elegant,
    bool allowGraphs = false,
  }) {
    var tree = <String, dynamic>{};

    for (var path in paths.where((p) => p.isNotEmpty)) {
      var p0 = path[0];
      var node = tree[p0] ??= <String, dynamic>{};

      for (var j = 1; j < path.length; ++j) {
        var p = path[j];
        node = node[p] ??= <String, dynamic>{};
      }
    }

    return ASCIIArtTree(
      tree,
      pathDelimiter: pathDelimiter,
      stripPrefix: stripPrefix,
      stripSuffix: stripSuffix,
      style: style,
      allowGraphs: allowGraphs,
    );
  }

  /// Constructs an [ASCIIArtTree] from a JSON [Map].
  factory ASCIIArtTree.fromJson(
    Map<String, dynamic> json, {
    String pathDelimiter = '/',
    String? stripPrefix,
    String? stripSuffix,
    ASCIIArtTreeStyle style = ASCIIArtTreeStyle.elegant,
    bool allowGraphs = false,
  }) {
    return ASCIIArtTree(
      json,
      pathDelimiter: pathDelimiter,
      stripPrefix: stripPrefix,
      stripSuffix: stripSuffix,
      style: style,
      allowGraphs: allowGraphs,
    );
  }

  /// The internal graph to represent the tree.
  Graph<ASCIIArtTreeNode> get graph => _graph;

  /// Returns the total number of roots in the [tree].
  int get totalRoots => _graph.roots.length;

  /// Returns the roots of the [tree].
  List<String> get roots => _graph.roots.toListOfString();

  /// Returns the total number of leaves in the [tree].
  int get totalLeaves => _graph.allLeaves.length;

  /// Returns the leaves of the [tree].
  List<String> get leaves => _graph.allLeaves.toListOfString();

  /// Computes and returns the total number of nodes in the tree.
  int get totalNodes => _graph.length;

  static const _defaultMaxExpansion = 99999999;

  /// Generates the ASCII Art Tree.
  /// - If [style] is passed overrides the instance style.
  String generate({
    String indent = '',
    bool trim = false,
    ASCIIArtTreeStyle? style,
    bool expandGraphs = false,
    bool expandSideBranches = false,
    bool hideReferences = false,
    String referenceMark = 'ººº',
  }) {
    if (_graph.isEmpty) return '';

    style ??= this.style;

    final graphWalker = GraphWalker<ASCIIArtTreeNode>(
      maxExpansion: _defaultMaxExpansion,
    );

    var trees = <List<_TreeLine>>[];

    for (var e in _graph.rootValues) {
      var treeLines = _buildTree(
        graphWalker,
        e,
        expandGraphs,
        expandSideBranches,
        hideReferences,
        referenceMark,
        style == ASCIIArtTreeStyle.elegant,
      );

      trees.add(treeLines);
    }

    switch (style) {
      case ASCIIArtTreeStyle.spaces:
        {
          var text = trees.map((t) => _simplifyStyle(t, ' ')).join();
          return _applyIndent(indent, text, trim: trim);
        }
      case ASCIIArtTreeStyle.dots:
        {
          var text = trees.map((t) => _simplifyStyle(t, '.')).join();
          return _applyIndent(indent, text, trim: trim);
        }
      case ASCIIArtTreeStyle.elegant:
        {
          var text = trees.map((t) => _fixElegantTree(t)).join();
          return _applyIndent(indent, text, trim: trim);
        }
    }
  }

  String _applyIndent(String indent, String text, {bool trim = false}) {
    if (trim) {
      text = text.trim();
    }

    if (indent.isEmpty) return text;

    return text.split('\n').map((l) => '$indent$l').join('\n');
  }

  final _sideBranchBar = '╠';
  final _sideBranchBar2 = '║';

  /// If defined provides optional extra info
  /// for each entry in the [generate]d tree:
  String? Function(List<String> parents, Map<String, dynamic> node, String key)?
  pathInfoProvider;

  List<_TreeLine> _buildTree(
    GraphWalker<ASCIIArtTreeNode> graphWalker,
    ASCIIArtTreeNode rootValue,
    bool expandGraphs,
    bool expandSideBranches,
    bool hideReferences,
    String referenceMark,
    bool elegant, {
    String? rootLine,
  }) {
    if (!elegant) {
      rootLine ??= rootValue.key.length > 1 ? '   ' : '  ';
    }

    var rootNodes = _graph.valuesToNodes([rootValue]);

    final treeLines = <_TreeLine>[];

    final pathInfoProvider = this.pathInfoProvider;

    String computeIndent(int depth, String? rootLine) {
      var indent = depth > 0 && rootLine != null && rootLine.length > 1
          ? (rootLine.length > 2 ? '  ' : ' ')
          : '';

      indent += '  ' * (depth - 1).clamp(0, depth);

      return indent;
    }

    process(GraphNodeStep<ASCIIArtTreeNode> step) {
      final parent = step.parentNode;
      final node = step.node;
      final depth = step.depth;

      final nodeKey = node.value.toString();
      final children = node.outputs;

      final indent = computeIndent(depth, rootLine);

      String arrow;
      if (children.isEmpty) {
        arrow = '──> ';
      } else {
        arrow = '─┬─ ';
      }

      var i = parent?.outputs.indexOf(node) ?? 0;
      var lastI = (parent?.outputs.length ?? 1) - 1;

      String conn;

      if (i == 0 && depth == 0) {
        conn = '';
        arrow = '';
      } else if (i == 0 && depth == 1) {
        conn = i == lastI ? '└' : '├';
      } else if (i == lastI) {
        conn = '└';
      } else {
        conn = '├';
      }

      var importStripped = _stripSuffix(
        stripSuffix,
        _stripPrefix(stripPrefix, nodeKey),
      );

      var processed = step.processed;

      // Already processed node. If NOT `expandGraphs`, not writing it again:
      if (!expandGraphs && allowGraphs && (processed[node] ?? 0) >= 2) {
        if (!hideReferences) {
          treeLines.add((
            prefix: '$indent$conn$arrow',
            label: '$importStripped $referenceMark',
          ));
        }
        return GraphWalkingInstruction.next();
      }

      var pathInfo = '';
      if (pathInfoProvider != null) {
        var parents =
            step.previous?.valuePathToRoot.map((e) => e.toString()).toList() ??
            [];

        var parentJson = parent?.attachment as Map<String, dynamic>?;
        parentJson ??= {};

        pathInfo = pathInfoProvider(parents, parentJson, nodeKey) ?? '';
        if (pathInfo.trim().isNotEmpty) {
          pathInfo = ' $pathInfo';
        }
      }

      rootLine ??= importStripped;

      if (step.sideBranch) {
        conn = _sideBranchBar;
      }

      treeLines.add((
        prefix: '$indent$conn$arrow',
        label: '$importStripped$pathInfo',
      ));

      return null;
    }

    graphWalker.walkByNodes<bool>(
      rootNodes,
      process: process,
      expandSideBranches: expandSideBranches,
      outputsProvider: (step, node) => node.outputs,
    );

    return treeLines;
  }

  String _stripPrefix(String? prefix, String path) {
    if (prefix != null && path.startsWith(prefix)) {
      path = path.substring(prefix.length);
    }
    return path;
  }

  String _stripSuffix(String? suffix, String path) {
    if (suffix != null && path.endsWith(suffix)) {
      path = path.substring(0, path.length - suffix.length);
    }
    return path;
  }

  static final _regExpNoSpace = RegExp(r'\S');

  /// Joins the lines of a tree. Like the generated text, ends with a new line.
  static String _joinTreeLines(Iterable<String> lines) =>
      '${lines.join('\n')}\n';

  String _fixElegantTree(List<_TreeLine> treeLines) {
    // Only the tree structure is fixed: labels may contain any character,
    // including the box-drawing ones used by this style.
    // The final blank entry stands for the text after the last line.
    var lines = [for (var l in treeLines) l.prefix, ''];

    final length = lines.length;
    final limit = length - 1;

    while (true) {
      var fixed = false;

      var lastSideBranchIdx = <int, bool>{};

      for (var i = 0; i < limit; ++i) {
        var line = lines[i];
        var next = lines[i + 1];

        var idx = line.indexOf(_regExpNoSpace);
        if (idx < 0) continue;

        var idxChar = line[idx];
        if (idxChar == _sideBranchBar || idxChar == _sideBranchBar2) {
          lastSideBranchIdx[idx] = true;
        } else {
          lastSideBranchIdx[idx] = false;
        }

        var idxNext = next.indexOf(_regExpNoSpace);

        if (idxNext < idx && idxNext >= 0) {
          var sideBranch = lastSideBranchIdx[idxNext] ?? false;

          var bar = sideBranch ? _sideBranchBar2 : '│';
          line = line.substring(0, idxNext) + bar + line.substring(idxNext + 1);
          lines[i] = line;
          fixed = true;
        }
      }

      if (!fixed) break;
    }

    for (var i = 0; i < limit; ++i) {
      var line = lines[i];
      var next = lines[i + 1];

      var idx = line.indexOf('├');
      if (idx < 0) {
        idx = line.indexOf(_sideBranchBar);
      }

      if (idx < 0) continue;

      // Nothing continues below this connector (its following siblings were
      // hidden): it is the last one drawn, so it becomes a corner.
      var nextChar = idx < next.length ? next[idx] : ' ';

      if (nextChar == ' ') {
        var char = line[idx];
        var sideBranch = char == _sideBranchBar;

        var corner = sideBranch ? '╚' : '└';

        lines[i] = line.substring(0, idx) + corner + line.substring(idx + 1);
      }
    }

    for (var i = 0; i < lines.length; ++i) {
      var line = lines[i];
      lines[i] = line.replaceAll('╚─', '╚═').replaceAll('╠─', '╠═');
    }

    for (var i = 0; i < limit; ++i) {
      var line = lines[i];
      var next = lines[i + 1];

      var idx = line.indexOf('═┬');
      if (idx < 0) continue;
      ++idx;

      if (idx < next.length) {
        var nextChar = next[idx];

        if (nextChar == _sideBranchBar || nextChar == '╚') {
          lines[i] = '${line.substring(0, idx)}╦${line.substring(idx + 1)}';
        }
      }
    }

    for (var i = 0; i < lines.length; ++i) {
      var line = lines[i];
      lines[i] = line.replaceAll('╦─', '╦═').replaceAll('═┬─', '═╦═');
    }

    return _joinTreeLines([
      for (var i = 0; i < treeLines.length; ++i) lines[i] + treeLines[i].label,
    ]);
  }

  String _simplifyStyle(List<_TreeLine> treeLines, String c) {
    // The indentation of each label: its prefix without the connector and
    // arrow (`├─┬─ `, `└──> `). The root (no prefix) is not indented.
    var linesIndented = [
      for (var l in treeLines)
        MapEntry(math.max(0, l.prefix.length - 5), l.label),
    ];

    // A blank root (see `ASCIIArtTree.fromStringPaths(blankRoot: '')`)
    // is not rendered:
    if (linesIndented.isNotEmpty && linesIndented[0].value == '') {
      linesIndented.removeAt(0);
    }

    if (linesIndented.isEmpty) return '';

    final min = linesIndented.map((e) => e.key).reduce(math.min);

    if (min > 0) {
      linesIndented = linesIndented
          .map((e) => MapEntry(e.key - min, e.value))
          .toList();
    }

    return _joinTreeLines(linesIndented.map((e) => (c * e.key) + e.value));
  }

  dynamic toJson() => _graph.toJson();
}

extension ASCIIArtTreeGraphExtension<T> on Graph<T> {
  /// Returns an [ASCIIArtTree] of this graph.
  /// - [keyCast] converts each node value to its tree key
  ///   (defaults to `toString()`).
  ASCIIArtTree toASCIIArtTree({
    String? stripPrefix,
    String? stripSuffix,
    ASCIIArtTreeStyle style = ASCIIArtTreeStyle.elegant,
    bool allowGraphs = true,
    bool sortByInputDependency = true,
    String Function(T value)? keyCast,
  }) {
    var tree = toTree<String>(
      keyCast: keyCast,
      sortByInputDependency: sortByInputDependency,
      bfs: true,
    );

    return ASCIIArtTree(
      tree,
      stripPrefix: stripPrefix,
      stripSuffix: stripSuffix,
      style: style,
      allowGraphs: allowGraphs,
    );
  }
}
