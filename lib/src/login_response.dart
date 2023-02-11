// Copyright (c) 2023, devCoffee Business Solutions. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:idempiere_rest/src/client_model.dart';
import 'package:idempiere_rest/src/model_base.dart';

/// Class that abstracts the [IdempiereClient.login] response
class LoginResponse extends ModelBase {
  late String token;
  late List<Client> clients;

  static const className = "LoginResponseModel";

  LoginResponse(Map<String, dynamic> json) : super(json) {
    token = json['token'];
    clients = [];
    if (json['clients'] != null) {
      json['clients'].forEach((c) {
        clients.add(Client(c));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  @override
  LoginResponse fromJson(Map<String, dynamic> json) {
    return LoginResponse(json);
  }
}
