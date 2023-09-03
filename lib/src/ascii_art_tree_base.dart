import 'dart:math' as math;

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

  /// Prefix to strip from each tree entry while generating the ASCII Art.
  String? stripPrefix;

  /// Suffix to strip from each tree entry while generating the ASCII Art.
  String? stripSuffix;

  /// The ASCII Art to generate.
  ASCIIArtTreeStyle style;

  ASCIIArtTree(
    this.tree, {
    this.stripPrefix,
    this.stripSuffix,
    this.style = ASCIIArtTreeStyle.elegant,
  });

  /// Constructs an [ASCIIArtTree] from a list of paths, splitting
  /// the paths by [delimiter] or using the [splitter] if provided.
  /// See [ASCIIArtTree.fromPaths].
  factory ASCIIArtTree.fromStringPaths(List<String> paths,
      {Pattern delimiter = '/',
      List<String> Function(String s)? splitter,
      String blankRoot = '/',
      String? stripPrefix,
      String? stripSuffix,
      ASCIIArtTreeStyle style = ASCIIArtTreeStyle.elegant}) {
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
        stripPrefix: stripPrefix, stripSuffix: stripSuffix, style: style);
  }

  /// Constructs an [ASCIIArtTree] from a list of paths (already split).
  /// See [ASCIIArtTree.fromStringPaths].
  factory ASCIIArtTree.fromPaths(List<List<String>> paths,
      {String? stripPrefix,
      String? stripSuffix,
      ASCIIArtTreeStyle style = ASCIIArtTreeStyle.elegant}) {
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
        stripPrefix: stripPrefix, stripSuffix: stripSuffix, style: style);
  }

  /// Constructs an [ASCIIArtTree] from a JSON [Map].
  factory ASCIIArtTree.fromJson(Map<String, dynamic> json,
      {String? stripPrefix,
      String? stripSuffix,
      ASCIIArtTreeStyle style = ASCIIArtTreeStyle.elegant}) {
    return ASCIIArtTree(json,
        stripPrefix: stripPrefix, stripSuffix: stripSuffix, style: style);
  }

  /// Computes and returns the total number of leafs in the tree.
  int get totalLeafs => _expandLeafs(tree.values).length;

  Iterable _expandLeafs(v) {
    if (v is Map) {
      if (v.isEmpty) {
        return [true];
      }
      return v.values.expand(_expandLeafs);
    } else if (v is Iterable) {
      return v.expand(_expandLeafs);
    } else {
      return [true];
    }
  }

  /// Computes and returns the total number of nodes in the tree.
  int get totalNodes => _expandNodes(tree.values).length;

  Iterable _expandNodes(v) {
    if (v is Map) {
      if (v.isEmpty) {
        return [true];
      }
      return [true, ...v.values.expand(_expandNodes)];
    } else if (v is Iterable) {
      return v.expand(_expandNodes);
    } else {
      return [true];
    }
  }

  /// Generates the ASCII Art Tree.
  /// - If [style] is passed overrides the instance style.
  String generate({ASCIIArtTreeStyle? style}) {
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
        return _buildTree(Map.fromEntries([e]), root: root).toString();
      }).toList();
    } else {
      String? root;
      if (!isElegant) {
        root = tree.keys.first.length > 1 ? '   ' : '  ';
      }

      treesTexts = [_buildTree(tree, root: root).toString()];
    }

    switch (style) {
      case ASCIIArtTreeStyle.spaces:
        {
          var text = treesTexts.map((t) => _simplifyStyle(t, ' ')).join();
          return text;
        }
      case ASCIIArtTreeStyle.dots:
        {
          var text = treesTexts.map((t) => _simplifyStyle(t, '.')).join();
          return text;
        }
      case ASCIIArtTreeStyle.elegant:
        {
          var text = treesTexts.map((t) => _fixElegantTree(t)).join();
          return text;
        }
    }
  }

  StringBuffer _buildTree(Map<String, dynamic> node,
      {String? root, int level = 0, StringBuffer? stringBuffer}) {
    stringBuffer ??= StringBuffer();

    var entries = node.entries.toList(growable: false);
    final lastI = entries.length - 1;

    for (var i = 0; i < entries.length; ++i) {
      var e = entries[i];

      final path = e.key;
      final children = e.value as Map<String, dynamic>?;

      var indent = level > 0 && root != null && root.length > 1
          ? (root.length > 2 ? '  ' : ' ')
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
          _stripSuffix(stripSuffix, _stripPrefix(stripPrefix, path));

      stringBuffer.write('$indent$conn$arrow$importStripped\n');

      if (children != null) {
        _buildTree(children,
            root: root ?? importStripped,
            level: level + 1,
            stringBuffer: stringBuffer);
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

  dynamic toJson() => _toJsonEntries(tree.entries);

  dynamic _toJsonEntries(Iterable<MapEntry<String, dynamic>> entries) {
    if (entries.isEmpty) return null;

    var entries2 = entries.map((e) {
      var k = e.key;
      var v = e.value;
      if (v is Map<String, dynamic>) {
        return MapEntry(k, _toJsonEntries(v.entries) as Map?);
      } else {
        return e;
      }
    });

    return Map<String, dynamic>.fromEntries(entries2);
  }
}
