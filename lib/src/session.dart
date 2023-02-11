// Copyright (c) 2023, devCoffee Business Solutions. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:idempiere_rest/src/model_base.dart';

/// Class that abstracts the response of [IdempiereClient.initSession] and [IdempiereClient.oneStepLogin]
/// This class holds all session information
class Session extends ModelBase {
  late String token, userName, password;
  late int clientId, roleId;
  String? language;
  int? userId, organizationId, warehouseId;
  bool _isOneStepLogin = false;
  static const String className = "SessionModel";

  Session(this.token, this.clientId, this.roleId,
      {this.organizationId, this.warehouseId, this.language})
      : super({});

  Session.oneStepLogin(this.userName, this.password, this.clientId, this.roleId,
      {this.organizationId, this.warehouseId, this.language})
      : super({}) {
    _isOneStepLogin = true;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> parameters = {'clientId': clientId, 'roleId': roleId};

    if (organizationId != null) {
      parameters['organizationId'] = organizationId;
    }

    if (warehouseId != null) {
      parameters['warehouseId'] = warehouseId;
    }

    if (language != null) {
      parameters['language'] = language;
    }

    if (_isOneStepLogin) {
      return {
        'userName': userName,
        'password': password,
        'parameters': parameters
      };
    } else {
      return parameters;
    }
  }

  @override
  ModelBase fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }
}
