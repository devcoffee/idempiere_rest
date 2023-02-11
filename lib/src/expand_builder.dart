// Copyright (c) 2023, devCoffee Business Solutions. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:idempiere_rest/idempiere_rest.dart';

/// Class that abstracts the Expand QueryOption in get requests,
/// using builder pattern
/// See (https://wiki.idempiere.org/en/REST_Web_Services#Query_Option_.24expand)
class ExpandBuilder {
  final Set<_Expand> _expands = {};

  /// [tableName] to retrive details
  /// [columnName] to use in $select QueryOption
  /// [filter] to use in $filter QueryOption
  /// [orderBy] to use in $orderBy QueryOption
  /// [top] to use in $top QueryOption
  /// [skip] to use in $skip QueryOption
  ExpandBuilder expand(String tableName,
      {List<String>? columnName,
      FilterBuilder? filter,
      List<String>? orderBy,
      int? top,
      int? skip}) {
    _Expand expand = _expands.firstWhere(
        (element) => element.tableName == tableName,
        orElse: () => _Expand(tableName));
    if (columnName != null) {
      expand.columns.addAll(columnName);
    }
    expand.filter = filter;
    if (orderBy != null) {
      expand.orderBy = orderBy;
    }
    expand.top = top;
    expand.skip = skip;
    _expands.add(expand);
    return this;
  }

  String build() {
    StringBuffer expand = StringBuffer("\$expand=");
    expand.write(_expands.join(","));
    return expand.toString();
  }

  bool isEmpty() {
    return _expands.isEmpty;
  }
}

class _Expand {
  late String tableName;
  List<String> columns = [];
  FilterBuilder? filter;
  List<String> orderBy = [];
  int? top, skip;

  _Expand(this.tableName);

  @override
  String toString() {
    StringBuffer s = StringBuffer(tableName);
    bool hasQueryOptions = false;

    if (columns.isNotEmpty) {
      hasQueryOptions = true;
      s.write("(");
      s.write("\$select=");
      s.write(columns.join(","));
    }
    if (filter != null) {
      if (hasQueryOptions) {
        s.write(";");
      } else {
        hasQueryOptions = true;
        s.write("(");
      }
      s.write(filter!.build());
    }
    if (orderBy.isNotEmpty) {
      if (hasQueryOptions) {
        s.write(";");
      } else {
        hasQueryOptions = true;
        s.write("(");
      }
      s.write("\$orderby=");
      s.write(orderBy.join(","));
    }

    if (top != null) {
      if (hasQueryOptions) {
        s.write(";");
      } else {
        hasQueryOptions = true;
        s.write("(");
      }
      s.write("\$top=$top");
    }

    if (skip != null) {
      if (hasQueryOptions) {
        s.write(";");
      } else {
        hasQueryOptions = true;
        s.write("(");
      }
      s.write("\$skip=$skip");
    }

    if (hasQueryOptions) {
      s.write(")");
    }
    return s.toString();
  }
}
