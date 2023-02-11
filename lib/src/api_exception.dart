// Copyright (c) 2023, devCoffee Business Solutions. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// An exception used to indicate that a request was unsuccessful.
///
/// This shouldn't be captured by any code other than the [IdempiereClient]
class APIException implements Exception {
  final String message;
  final int statusCode;

  const APIException(this.message, this.statusCode);

  @override
  String toString() {
    return "[$statusCode] - $message";
  }
}
