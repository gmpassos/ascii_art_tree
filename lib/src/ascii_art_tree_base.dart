import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:graph_explorer/graph_explorer.dart';

/// ASCII Art Tree Styles.
enum ASCIIArtTreeStyle {
  spaces,
  dots,
  elegant,
}

class _ASCIINode {
  final String graphKey;
  final String key;

  _ASCIINode(this.graphKey, this.key);

  int get length => key.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    // When walking the tree:
    if (other is _ASCIINode) {
      return runtimeType == other.runtimeType && graphKey == other.graphKey;
    }
    // When accessing a JSON node:
    else if (other is String) {
      return key == other;
    }
    // When accessing processed nodes.
    else if (other is Node<_ASCIINode>) {
      return graphKey == other.value.graphKey;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => key;
}

/// ASCII Art Tree generator.
class ASCIIArtTree {
  /// The tree.
  late final Graph<_ASCIINode> _graph;

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
    _graph = Graph<_ASCIINode>.fromJson(
        tree.map<String, dynamic>((k, v) => MapEntry(k.toString(), v)),
        nodeValueMapper: _jsonToNode);
  }

  _ASCIINode _jsonToNode(GraphStep<_ASCIINode>? prevStep, String key) {
    if (allowGraphs) {
      return _ASCIINode(key, key);
    } else {
      var graphKey = prevStep != null
          ? prevStep
              .fullPathToRoot(tailString: [key], pathDelimiter: pathDelimiter)
          : key;

      return _ASCIINode(graphKey, key);
    }
  }

  /// Constructs an [ASCIIArtTree] from a list of paths, splitting
  /// the paths by [delimiter] or using the [splitter] if provided.
  /// See [ASCIIArtTree.fromPaths].
  factory ASCIIArtTree.fromStringPaths(Iterable<String> paths,
      {Pattern delimiter = '/',
      List<String> Function(String s)? splitter,
      String blankRoot = '/',
      String? stripPrefix,
      String? stripSuffix,
      ASCIIArtTreeStyle style = ASCIIArtTreeStyle.elegant,
      bool allowGraphs = false}) {
    splitter ??= (p) => p.split(delimiter);

    var paths2 = paths.map(splitter).toList(growable: false);

    if (blankRoot != '') {
      for (var p in paths2) {
        if (p.isNotEmpty && p[0] == '') {
          p[0] = blankRoot;
        }
      }
    }

    return ASCIIArtTree.fromPaths(paths2,
        pathDelimiter: delimiter is String ? delimiter : '/',
        stripPrefix: stripPrefix,
        stripSuffix: stripSuffix,
        style: style,
        allowGraphs: allowGraphs);
  }

  /// Constructs an [ASCIIArtTree] from a list of paths (already split).
  /// See [ASCIIArtTree.fromStringPaths].
  factory ASCIIArtTree.fromPaths(Iterable<List<String>> paths,
      {String pathDelimiter = '/',
      String? stripPrefix,
      String? stripSuffix,
      ASCIIArtTreeStyle style = ASCIIArtTreeStyle.elegant,
      bool allowGraphs = false}) {
    var tree = <String, dynamic>{};

    for (var path in paths.where((p) => p.isNotEmpty)) {
      var p0 = path[0];
      var node = tree[p0] ??= <String, dynamic>{};

      for (var j = 1; j < path.length; ++j) {
        var p = path[j];
        node = node[p] ??= <String, dynamic>{};
      }
    }

    return ASCIIArtTree(tree,
        pathDelimiter: pathDelimiter,
        stripPrefix: stripPrefix,
        stripSuffix: stripSuffix,
        style: style,
        allowGraphs: allowGraphs);
  }

  /// Constructs an [ASCIIArtTree] from a JSON [Map].
  factory ASCIIArtTree.fromJson(Map<String, dynamic> json,
      {String pathDelimiter = '/',
      String? stripPrefix,
      String? stripSuffix,
      ASCIIArtTreeStyle style = ASCIIArtTreeStyle.elegant,
      bool allowGraphs = false}) {
    return ASCIIArtTree(json,
        pathDelimiter: pathDelimiter,
        stripPrefix: stripPrefix,
        stripSuffix: stripSuffix,
        style: style,
        allowGraphs: allowGraphs);
  }

  /// The internal graph to represent the tree.
  Graph<_ASCIINode> get graph => _graph;

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
  String generate(
      {String indent = '',
      bool trim = false,
      ASCIIArtTreeStyle? style,
      bool expandGraphs = false,
      bool expandSideBranches = false,
      bool hideReferences = false,
      String referenceMark = 'ººº'}) {
    if (_graph.isEmpty) return '';

    style ??= this.style;

    final graphWalker =
        GraphWalker<_ASCIINode>(maxExpansion: _defaultMaxExpansion);

    var treesTexts = <String>[];

    for (var e in _graph.rootValues) {
      var treeText = _buildTree(
        graphWalker,
        e,
        expandGraphs,
        expandSideBranches,
        hideReferences,
        referenceMark,
        style == ASCIIArtTreeStyle.elegant,
      );

      treesTexts.add(treeText);
    }

    switch (style) {
      case ASCIIArtTreeStyle.spaces:
        {
          var text = treesTexts.map((t) => _simplifyStyle(t, ' ')).join();
          return _applyIndent(indent, text, trim: trim);
        }
      case ASCIIArtTreeStyle.dots:
        {
          var text = treesTexts.map((t) => _simplifyStyle(t, '.')).join();
          return _applyIndent(indent, text, trim: trim);
        }
      case ASCIIArtTreeStyle.elegant:
        {
          var text = treesTexts.map((t) => _fixElegantTree(t)).join();
          return _applyIndent(indent, text, trim: trim);
        }
    }
  }

  String _applyIndent(String indent, String text,
      {bool trim = false, String? indent0}) {
    if (trim) {
      text = text.trim();
    }

    if (indent.isEmpty) return text;
    var lines = text.split('\n');

    Iterable<String> lines2;
    if (indent0 != null) {
      lines2 = lines.mapIndexed((i, l) => '${i == 0 ? indent0 : indent}$l');
    } else {
      lines2 = lines.map((l) => '$indent$l');
    }

    var text2 = lines2.join('\n');
    return text2;
  }

  final _sideBranchBar = '╠';
  final _sideBranchBar2 = '║';

  /// If defined provides optional extra info
  /// for each entry in the [generate]d tree:
  String? Function(List<String> parents, Map<String, dynamic> node, String key)?
      pathInfoProvider;

  String _buildTree(
      GraphWalker<_ASCIINode> graphWalker,
      _ASCIINode rootValue,
      bool expandGraphs,
      bool expandSideBranches,
      bool hideReferences,
      String referenceMark,
      bool elegant,
      {String? rootLine}) {
    if (!elegant) {
      rootLine ??= rootValue.key.length > 1 ? '   ' : '  ';
    }

    var rootNodes = _graph.valuesToNodes([rootValue]);

    final stringBuffer = StringBuffer();

    final pathInfoProvider = this.pathInfoProvider;

    String computeIndent(int depth, String? rootLine) {
      var indent = depth > 0 && rootLine != null && rootLine.length > 1
          ? (rootLine.length > 2 ? '  ' : ' ')
          : '';

      indent += '  ' * (depth - 1).clamp(0, depth);

      return indent;
    }

    process(GraphNodeStep<_ASCIINode> step) {
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

      var importStripped =
          _stripSuffix(stripSuffix, _stripPrefix(stripPrefix, nodeKey));

      var processed = step.processed;

      // Already processed node. If NOT `expandGraphs`, not writing it again:
      if (!expandGraphs && allowGraphs && (processed[node] ?? 0) >= 2) {
        if (!hideReferences) {
          stringBuffer
              .write('$indent$conn$arrow$importStripped $referenceMark\n');
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

      stringBuffer.write('$indent$conn$arrow$importStripped$pathInfo\n');

      return null;
    }

    graphWalker.walkByNodes<bool>(
      rootNodes,
      process: process,
      expandSideBranches: expandSideBranches,
      outputsProvider: (step, node) => node.outputs,
    );

    return stringBuffer.toString();
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
  static final _regExpSpace = RegExp(r'\s');

  String _fixElegantTree(String treeText) {
    var lines = treeText.split('\n');

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

      if (idx < next.length) {
        var nextChar = next[idx];

        if (nextChar == ' ') {
          var char = line[idx];
          var sideBranch = char == _sideBranchBar;

          var corner = sideBranch ? '╚' : '└';

          lines[i] = line.substring(0, idx) + corner + line.substring(idx + 1);
        }
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
          lines[i] = line.substring(0, idx) + '╦' + line.substring(idx + 1);
        }
      }
    }

    for (var i = 0; i < lines.length; ++i) {
      var line = lines[i];
      lines[i] = line.replaceAll('╦─', '╦═').replaceAll('═┬─', '═╦═');
    }

    var treeText2 = lines.join('\n');
    return treeText2;
  }

  String _simplifyStyle(String treeText, String c) {
    var lines = treeText.split('\n');
    if (lines.isEmpty) return treeText;

    var linesIndented = _toLinesIndented(lines).toList();

    if (linesIndented[0].value == '') {
      linesIndented.removeAt(0);
    }

    var needsFinalBlankLine = false;
    if (linesIndented.last.value == '') {
      linesIndented.removeLast();
      needsFinalBlankLine = true;
    }

    var min = linesIndented.map((e) => e.key).reduce((v, e) => math.min(v, e));

    if (min > 0) {
      linesIndented =
          linesIndented.map((e) => MapEntry(e.key - min, e.value)).toList();
    }

    if (needsFinalBlankLine) {
      linesIndented.add(MapEntry(0, ''));
    }

    var lines2 = linesIndented.map((e) => (c * e.key) + e.value).toList();

    var treeText2 = lines2.join('\n');
    return treeText2;
  }

  Iterable<MapEntry<int, String>> _toLinesIndented(List<String> lines) =>
      lines.map((line) {
        var idx1 = line.indexOf(_regExpNoSpace);
        if (idx1 < 0) return MapEntry(0, line);

        var idx2 = line.indexOf(_regExpSpace, idx1 + 1);
        if (idx2 < 0) return MapEntry(0, line);

        var indent = (idx2 - 4).clamp(0, idx2);

        var path = line.substring(idx2 + 1);

        return MapEntry(indent, path);
      }).toList();

  dynamic toJson() => _graph.toJson();
}

extension ASCIIArtTreeGraphExtension<T> on Graph<T> {
  /// Returns an [ASCIIArtTree] of this graph.
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
        bfs: true);

    return ASCIIArtTree(tree,
        stripPrefix: stripPrefix,
        stripSuffix: stripSuffix,
        style: style,
        allowGraphs: allowGraphs);
  }
}
