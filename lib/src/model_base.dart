// Copyright (c) 2023, devCoffee Business Solutions. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Abstract class used in [IdempiereClient] request
/// This class must be extended in every model used for json
/// serialization/deserealization
abstract class ModelBase {
  int? id;

  ///Constructor used in [IdempiereClient.get] and [IdempiereClient.getRecord]
  ///to deserialize the response of the request
  ModelBase(Map<String, dynamic> json);

  ///Method used in [IdempiereClient.post] and [IdempiereClient.put]
  ///to deserialize the response of the request with current model
  ModelBase fromJson(Map<String, dynamic> json);

  ///Method used in [IdempiereClient.post] and [IdempiereClient.put]
  ///to serialize the model
  Map<String, dynamic> toJson();
}
