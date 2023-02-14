// Copyright (c) 2023, devCoffee Business Solutions. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:idempiere_rest/src/model_base.dart';

/// Class that abstracts the response of [IdempiereClient.getRoles]
class Role extends ModelBase {
  late String name;

  Role(Map<String, dynamic> json) : super(json) {
    id = json['id'];
    name = json['name'];
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  @override
  ModelBase fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}
