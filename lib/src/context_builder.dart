// Copyright (c) 2023, devCoffee Business Solutions. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Class that abstracts the Context QueryOption in get requests,
/// using builder pattern
/// See (https://wiki.idempiere.org/en/REST_Web_Services#Query_Option_.24context)
class ContextBuilder {
  final Set<_Context> _context = {};

  // put variables in context to be parsed by the $valRule QueryOption
  ContextBuilder put(String contextName, dynamic contextValue) {
    _context.add(_Context(contextName, contextValue));
    return this;
  }

  @override
  String toString() {
    if (_context.isNotEmpty) return "\$context=${_context.join(",")}";
    return "";
  }
}

class _Context {
  String contextName;
  dynamic contextValue;
  _Context(this.contextName, this.contextValue);

  @override
  String toString() {
    return "$contextName:$contextValue";
  }
}
