import 'dart:collection';
import 'dart:math' as math;

import 'package:collection/collection.dart';

/// ASCII Art Tree Styles.
enum ASCIIArtTreeStyle {
  spaces,
  dots,
  elegant,
}

/// ASCII Art Tree generator.
class ASCIIArtTree {
  /// The tree.
  Map<String, dynamic> tree;

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

  final Map<String, Map<String, dynamic>> _allNodes = {};

  final Set<String> _allLeaves = {};

  ASCIIArtTree(
    Map tree, {
    this.pathDelimiter = '/',
    this.stripPrefix,
    this.stripSuffix,
    this.style = ASCIIArtTreeStyle.elegant,
    this.allowGraphs = false,
  }) : tree = tree.map<String, dynamic>((k, v) => MapEntry(k.toString(), v)) {
    _updateAllNodes();
  }

  /// Constructs an [ASCIIArtTree] from a list of paths, splitting
  /// the paths by [delimiter] or using the [splitter] if provided.
  /// See [ASCIIArtTree.fromPaths].
  factory ASCIIArtTree.fromStringPaths(List<String> paths,
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
  factory ASCIIArtTree.fromPaths(List<List<String>> paths,
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

  static final ListEquality<String> _listOfStringEquality =
      ListEquality<String>();

  void _updateAllNodes() {
    _allNodes.clear();
    _allLeaves.clear();

    var queue = ListQueue<List>()..add(['', tree]);

    while (queue.isNotEmpty) {
      var entry = queue.removeFirst();

      var parentGlobalKey = entry[0] as String;
      var parent = entry[1] as Map<String, dynamic>;

      var childKeys = parent.keys.toList();

      for (var childKey in childKeys) {
        var childValue = parent[childKey];

        if (childValue == null) {
          childValue = <String, dynamic>{};
        } else if (childValue is Map) {
          if (childValue.isEmpty) {
            childValue = <String, dynamic>{};
          } else {
            childValue = childValue
                .map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
          }
        }

        var childGlobalKey =
            allowGraphs ? childKey : '$parentGlobalKey$pathDelimiter$childKey';

        var node = _allNodes[childGlobalKey];

        if (node == null) {
          if (childValue is Map<String, dynamic>) {
            node = _allNodes[childGlobalKey] = childValue;
            parent[childKey] = node;
            if (node.isEmpty) {
              _allLeaves.add(childGlobalKey);
            } else {
              queue.add([childGlobalKey, node]);
            }
          } else if (childValue is String) {
            if (childValue == childKey || childValue == '') {
              node = _allNodes[childGlobalKey] ??= {};
              parent[childKey] = node;
            } else {
              throw StateError(
                  "Invalid graph reference. `$childKey` as `$childValue`");
            }
          } else {
            throw StateError("Invalid node type: $childValue");
          }
        } else {
          if (identical(childValue, node)) {
            continue;
          } else if (childValue is Map<String, dynamic>) {
            var keys1 = childValue.keys.toList()..sort();
            var keys2 = node.keys.toList()..sort();

            if (!_listOfStringEquality.equals(keys1, keys2)) {
              var newKeys = keys1
                  .where((e) => !keys2.contains(e))
                  .toList(growable: false);

              if (newKeys.isNotEmpty) {
                var newEntries =
                    childValue.entries.where((e) => newKeys.contains(e.key));
                node.addEntries(newEntries);
                queue.add([childGlobalKey, node]);
              }
            }

            parent[childKey] = node;
          } else if (childValue is String) {
            if (childValue == childGlobalKey || childValue == '') {
              node = _allNodes[childGlobalKey] ??= {};
              parent[childKey] = node;
            } else {
              throw StateError(
                  "Invalid graph reference. `$childKey` as `$childValue`");
            }
          }
        }
      }
    }
  }

  /// Returns the total number of roots in the [tree].
  int get totalRoots => tree.length;

  /// Returns the roots of the [tree].
  List<String> get roots => tree.keys.toList();

  /// Returns the total number of leaves in the [tree].
  int get totalLeaves => _allLeaves.length;

  /// Returns the leaves of the [tree].
  List<String> get leaves => _allLeaves.toList();

  /// Computes and returns the total number of nodes in the tree.
  int get totalNodes => _allNodes.length;

  /// Generates the ASCII Art Tree.
  /// - If [style] is passed overrides the instance style.
  String generate(
      {String indent = '',
      bool trim = false,
      ASCIIArtTreeStyle? style,
      bool expandGraphs = false}) {
    if (tree.isEmpty) return '';

    style ??= this.style;

    final isElegant = style == ASCIIArtTreeStyle.elegant;

    List<String> treesTexts;

    if (tree.length > 1) {
      treesTexts = tree.entries.map((e) {
        String? root;
        if (!isElegant) {
          root = e.key.length > 1 ? '   ' : '  ';
        }
        return _buildTree(Map.fromEntries([e]),
                rootLine: root, expandGraphs: expandGraphs)
            .toString();
      }).toList();
    } else {
      String? root;
      if (!isElegant) {
        root = tree.keys.first.length > 1 ? '   ' : '  ';
      }

      treesTexts = [
        _buildTree(tree, rootLine: root, expandGraphs: expandGraphs).toString()
      ];
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

  String _applyIndent(String indent, String text, {bool trim = false}) {
    if (trim) {
      text = text.trim();
    }

    if (indent.isEmpty) return text;
    var lines = text.split('\n');

    var lines2 = lines.map((l) => '$indent$l');
    var text2 = lines2.join('\n');
    return text2;
  }

  /// If defined provides optional extra info
  /// for each entry in the [generate]d tree:
  String? Function(List<String> parents, Map<String, dynamic> node, String key)?
      pathInfoProvider;

  StringBuffer _buildTree(Map<String, dynamic> rootNode,
      {String? rootLine, bool expandGraphs = false}) {
    final stringBuffer = StringBuffer();

    final pathInfoProvider = this.pathInfoProvider;

    Map<String, dynamic>? nodeResolver(Object? value) {
      if (value is Map<String, dynamic>) {
        return value;
      } else if (value is String) {
        return _allNodes[value] ??
            (throw StateError("Can't find node: $value"));
      } else {
        return null;
      }
    }

    Iterable<List> buildTasks(
        Map<String, dynamic> node, List<String>? parents, int level) {
      return node.entries.mapIndexed((i, e) => [i, node, e, parents, level]);
    }

    final processed = <String>{};

    final queue = ListQueue<List>();
    queue.addAll(buildTasks(rootNode, null, 0));

    while (queue.isNotEmpty) {
      var task = queue.removeFirst();

      final i = task[0] as int;
      final parent = task[1] as Map<String, dynamic>;
      final node = task[2] as MapEntry<String, dynamic>;
      final parents = task[3] as List<String>?;
      final level = task[4] as int;

      final lastI = parent.length - 1;

      {
        final nodeKey = node.key;
        final children = nodeResolver(node.value);

        var indent = level > 0 && rootLine != null && rootLine.length > 1
            ? (rootLine.length > 2 ? '  ' : ' ')
            : '';
        indent += '  ' * (level - 1).clamp(0, level);

        String arrow;
        if (children == null || children.isEmpty) {
          arrow = '──> ';
        } else {
          arrow = '─┬─ ';
        }

        String conn;

        if (i == 0 && level == 0) {
          conn = '';
          arrow = '';
        } else if (i == 0 && level == 1) {
          conn = i == lastI ? '└' : '├';
        } else if (i == lastI) {
          conn = '└';
        } else {
          conn = '├';
        }

        var importStripped =
            _stripSuffix(stripSuffix, _stripPrefix(stripPrefix, nodeKey));

        // Already processed node. If NOT `expandGraphs`, not writing it again:
        if (!expandGraphs && allowGraphs && !processed.add(nodeKey)) {
          stringBuffer.write('$indent$conn$arrow$importStripped ººº\n');
          continue;
        }

        var pathInfo = '';
        if (pathInfoProvider != null) {
          pathInfo = pathInfoProvider(parents ?? [], parent, nodeKey) ?? '';
          if (pathInfo.trim().isNotEmpty) {
            pathInfo = ' $pathInfo';
          }
        }

        rootLine ??= importStripped;

        stringBuffer.write('$indent$conn$arrow$importStripped$pathInfo\n');

        if (children != null && children.isNotEmpty) {
          final parents2 =
              pathInfoProvider != null ? [...?parents, nodeKey] : null;

          var tasks =
              buildTasks(children, parents2, level + 1).toList(growable: false);

          // Building tree in Depth-First Search (DFS):
          for (var t in tasks.reversed) {
            queue.addFirst(t);
          }
        }
      }
    }

    return stringBuffer;
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

      for (var i = 0; i < limit; ++i) {
        var line = lines[i];
        var next = lines[i + 1];

        var idx = line.indexOf(_regExpNoSpace);
        if (idx < 0) continue;

        var idxNext = next.indexOf(_regExpNoSpace);

        if (idxNext < idx && idxNext >= 0) {
          line = line.substring(0, idxNext) + '│' + line.substring(idxNext + 1);
          lines[i] = line;
          fixed = true;
        }
      }

      if (!fixed) break;
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

  dynamic toJson() {
    if (tree.isEmpty) return null;

    final json = <String, dynamic>{};

    var processed = <String>{};
    var queue = ListQueue<List<Map<String, dynamic>>>()..add([tree, json]);

    while (queue.isNotEmpty) {
      var entry = queue.removeFirst();

      var node = entry[0];
      var jsonNode = entry[1];

      for (var e in node.entries) {
        var childKey = e.key;
        var childNode = e.value;

        if (processed.add(childKey)) {
          if (childNode is Map<String, dynamic>) {
            if (childNode.isEmpty) {
              jsonNode[childKey] = null;
            } else {
              var childJsonNode =
                  childNode.map<String, dynamic>((k, v) => MapEntry(k, null));
              jsonNode[childKey] = childJsonNode;
              queue.add([childNode, childJsonNode]);
            }
          }
        } else {
          jsonNode[childKey] = childKey;
        }
      }
    }

    return json;
  }
}
