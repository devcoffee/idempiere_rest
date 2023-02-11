// Copyright (c) 2023, devCoffee Business Solutions. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:idempiere_rest/src/operators.dart';

/// Class that abstracts the Filter QueryOption in get requests,
/// using builder pattern
/// See (https://wiki.idempiere.org/en/REST_Web_Services#Query_Option_.24filter)
class FilterBuilder {
  final List<_Filter> _filters = [];
  final List<String> _andOrs = [];
  static const String _and = "and";
  static const String _or = "or";

  FilterBuilder addFilter(
      String columnName, Operators operator, dynamic value) {
    _filters.add(_Filter(columnName, operator, value));

    return this;
  }

  /// [and] or [or] must be used between calls to [addFilter]
  FilterBuilder and() {
    _andOrs.add(_and);
    return this;
  }

  /// [and] or [or] must be used between calls to [addFilter]
  FilterBuilder or() {
    _andOrs.add(_or);
    return this;
  }

  bool isEmpty() {
    return _filters.isEmpty;
  }

  String build() {
    if (_filters.isEmpty) {
      return "";
    }

    if (_filters.length - 1 > _andOrs.length) {
      throw Exception("Disbalanced Expression");
    }

    int index = 0;
    StringBuffer s = StringBuffer("\$filter=");
    for (_Filter filter in _filters) {
      if (index != 0) {
        s.write(" ");
        s.write(_andOrs[index - 1]);
        s.write(" ");
      }

      s.write(filter);

      index++;
    }
    return s.toString();
  }
}

class _Filter {
  String columnName;
  Operators operator;
  dynamic value;

  _Filter(this.columnName, this.operator, this.value);

  @override
  String toString() {
    StringBuffer s = StringBuffer();
    switch (operator) {
      case Operators.contains:
      case Operators.startswith:
      case Operators.endswith:
      case Operators.tolower:
      case Operators.toupper:
        s.write(operator.name);
        s.write("(");
        s.write(columnName);
        s.write(",");
        s.write(_getStringRepresentation(value));
        s.write(")");
        break;
      default:
        s.write(columnName);
        s.write(" ");
        s.write(operator.name);
        s.write(" ");
        s.write(_getStringRepresentation(value));
        s.write(" ");
    }

    return s.toString();
  }

  String _getStringRepresentation(Object? value) {
    //TODO: type conversion
    if (value == null) return "null";
    if (value is String || value is DateTime) {
      return "'$value'";
    } else {
      return value.toString();
    }
  }
}
