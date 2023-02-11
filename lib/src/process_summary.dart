// Copyright (c) 2023, devCoffee Business Solutions. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Class that abstracts the response of [IdempiereClient.runProcess]
class ProcessSummary {
  int? adPinstanceId;
  String? process;
  String? summary;
  bool? isError;
  String? exportFile;
  String? exportFileName;
  int? exportFileLength;
  String? reportFile;
  String? reportFileName;
  int? reportFileLength;
  String? nodeId;
  List<String>? logs;

  ProcessSummary.fromJson(Map<String, dynamic> json) {
    adPinstanceId = json['AD_PInstance_ID'];
    process = json['process'];
    summary = json['summary'];
    isError = json['isError'];
    exportFile = json['exportFile'];
    exportFileName = json['exportFileName'];
    exportFileLength = json['exportFileLength'];
    nodeId = json['nodeId'];
    logs = List<String>.from(json['logs'].map((log) => log.toString()));
  }
}
