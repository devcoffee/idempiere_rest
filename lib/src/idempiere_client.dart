// Copyright (c) 2023, devCoffee Business Solutions. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:idempiere_rest/src/api_exception.dart';
import 'package:idempiere_rest/src/context_builder.dart';
import 'package:idempiere_rest/src/expand_builder.dart';
import 'package:idempiere_rest/src/filter_builder.dart';
import 'package:idempiere_rest/src/login_response.dart';
import 'package:idempiere_rest/src/model_base.dart';
import 'package:idempiere_rest/src/organization_model.dart';
import 'package:idempiere_rest/src/process_summary.dart';
import 'package:idempiere_rest/src/role_model.dart';
import 'package:idempiere_rest/src/session.dart';
import 'package:idempiere_rest/src/warehouse_model.dart';

/// The main class to do all requests to idempiere-rest API
/// developed following the singleton pattern, once logged in,
/// can be called in every part of the applications.
/// Once instanciated, [setBaseUrl] must be the first method called.
/// After that, [login] or [oneStepLogin] can be called, to retrieve the token.
/// This class holds all [Session] information.
class IdempiereClient {
  static final IdempiereClient _repository = IdempiereClient._internal();
  late String _baseURL;
  Session? _session;
  late String _firstToken;

  factory IdempiereClient() {
    return _repository;
  }

  IdempiereClient._internal();

  setBaseUrl(String baseURL) {
    _baseURL = baseURL;
  }

  _getRecordType(String endpoint) {
    if (endpoint.startsWith("/models/")) {
      return "records";
    } else if (endpoint.startsWith("/windows/")) {
      return "window-records";
    } else if (endpoint.contains("/organizations")) {
      return "organizations";
    } else if (endpoint.contains("/roles")) {
      return "roles";
    } else if (endpoint.contains("/warehouses")) {
      return "warehouses";
    }
  }

  String _buildUrl(final String endpoint,
      {FilterBuilder? filter,
      ExpandBuilder? expand,
      List<String>? orderBy,
      List<String>? select,
      int? top,
      int? skip,
      Object? valRule,
      ContextBuilder? context,
      bool showsql = false}) {
    StringBuffer newUrl = StringBuffer(_baseURL + endpoint);
    bool hasQueryOptions = false;

    if (filter != null) {
      hasQueryOptions = true;
      newUrl.write("?${filter.build()}");
    }

    if (expand != null) {
      if (hasQueryOptions) {
        newUrl.write("&");
      } else {
        hasQueryOptions = true;
        newUrl.write("?");
      }

      newUrl.write(expand.build());
    }

    if (orderBy != null) {
      if (hasQueryOptions) {
        newUrl.write("&");
      } else {
        hasQueryOptions = true;
        newUrl.write("?");
      }

      newUrl.write("\$orderby=${orderBy.join(",")}");
    }

    if (select != null) {
      if (hasQueryOptions) {
        newUrl.write("&");
      } else {
        hasQueryOptions = true;
        newUrl.write("?");
      }

      newUrl.write("\$select=${select.join(",")}");
    }

    if (top != null) {
      if (hasQueryOptions) {
        newUrl.write("&");
      } else {
        hasQueryOptions = true;
        newUrl.write("?");
      }

      newUrl.write("\$top=$top");
    }

    if (skip != null) {
      if (hasQueryOptions) {
        newUrl.write("&");
      } else {
        hasQueryOptions = true;
        newUrl.write("?");
      }

      newUrl.write("\$skip=$skip");
    }

    if (valRule != null) {
      if (valRule is int || valRule is String) {
        if (hasQueryOptions) {
          newUrl.write("&");
        } else {
          hasQueryOptions = true;
          newUrl.write("?");
        }

        newUrl.write("\$valrule=$valRule");
      } else {
        print("valRule must be a int or String");
      }
    }

    if (context != null) {
      if (hasQueryOptions) {
        newUrl.write("&");
      } else {
        hasQueryOptions = true;
        newUrl.write("?");
      }
      newUrl.write(context.toString());
    }

    if (showsql) {
      if (hasQueryOptions) {
        newUrl.write("&");
      } else {
        hasQueryOptions = true;
        newUrl.write("?");
      }

      newUrl.write("showsql");
    }

    print(newUrl);

    return newUrl.toString();
  }

  Map<String, String> _getReqHeaders({String? token}) {
    final Session? s = _session;

    if (token != null) {
      return {
        "Content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };
    }

    if (s != null) {
      return {
        "Content-type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer ${s.token}",
      };
    } else {
      throw Exception(
          "Sessão Inválida, realize login para iniciar uma sessão!");
    }
  }

  /// Abstracts the One-step log-in request in idempiere-rest API
  /// See https://wiki.idempiere.org/en/REST_Web_Services#One-step_log-in
  /// [endpoint] normally /auth/tokens
  /// return [LoginResponse]
  Future<Session> oneStepLogin(String endpoint, String userName,
      String password, int clientId, int roleId,
      {int? organizationId, int? warehouseId, String? language}) async {
    _session = Session.oneStepLogin(userName, password, clientId, roleId,
        organizationId: organizationId,
        warehouseId: warehouseId,
        language: language);

    var response = await http.post(Uri.parse(_baseURL + endpoint),
        headers: _getReqHeaders(), body: jsonEncode(_session!.toJson()));

    if (response.statusCode == HttpStatus.ok) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      _session!.userId = json['userId'];
      _session!.language = json['language'];
      _session!.token = json['token'];
      return _session!;
    } else {
      final message = jsonDecode(utf8.decode(response.bodyBytes));
      throw APIException(message['detail'], response.statusCode);
    }
  }

  /// Abstracts the Normal log-in request in idempiere-rest API
  /// See (https://wiki.idempiere.org/en/REST_Web_Services#Normal_log-in)
  /// [endpoint] normally /auth/tokens
  /// return [LoginResponse]
  Future<LoginResponse> login(
      String endpoint, String userName, String password) async {
    Map params = {
      "userName": userName,
      "password": password,
    };

    var header = {
      "Content-Type": " application/json",
      "Accept": "application/json",
    };

    var body = json.encode(params);

    var response = await http.post(Uri.parse(_baseURL + endpoint),
        headers: header, body: body);

    if (response.statusCode == HttpStatus.ok) {
      LoginResponse lResponse =
          LoginResponse(jsonDecode(utf8.decode(response.bodyBytes)));
      _firstToken = lResponse.token;
      return lResponse;
    } else {
      final message = jsonDecode(utf8.decode(response.bodyBytes));
      throw APIException(message['detail'], response.statusCode);
    }
  }

  /// Abstracts the GET /auth/roles request in idempiere-rest API
  /// See (https://wiki.idempiere.org/en/REST_Web_Services#Normal_log-in)
  /// Must be call only after the [login] method call, in order to obtain [clientId]
  /// return List of [Role]
  Future<List<Role>> getRoles(int clientId) async {
    return await _get("/auth/roles?client=$clientId", (json) => Role(json),
        token: _firstToken);
  }

  /// Abstracts the GET /auth/organizations request in idempiere-rest API
  /// See (https://wiki.idempiere.org/en/REST_Web_Services#Normal_log-in)
  /// Must be call only after the [getRoles] method call, in order to obtain [roleId]
  /// return List of [Organization]
  Future<List<Organization>> getOrganizations(int clientId, int roleId) async {
    return await _get("/auth/organizations?client=$clientId&role=$roleId",
        (json) => Organization(json),
        token: _firstToken);
  }

  /// Abstracts the GET /auth/warehouses request in idempiere-rest API
  /// See (https://wiki.idempiere.org/en/REST_Web_Services#Normal_log-in)
  /// Must be call only after the [getOrganizations] method call, in order to obtain [roleId]
  /// return List of [Warehouse]
  Future<List<Warehouse>> getWarehouses(
      int clientId, int roleId, int organizationId) async {
    return await _get(
        "/auth/warehouses?client=$clientId&role=$roleId&organization=$organizationId",
        (json) => Warehouse(json),
        token: _firstToken);
  }

  /// Abstracts the PUT /auth/tokens request in idempiere-rest API
  /// See (https://wiki.idempiere.org/en/REST_Web_Services#Normal_log-in)
  /// Must be call only after got [clientId] and [roleId]
  /// return [Session]
  Future<Session> initSession(
      String endpoint, String token, int clientId, int roleId,
      {int? organizationId, int? warehouseId, String? language}) async {
    _session = Session(token, clientId, roleId,
        organizationId: organizationId,
        warehouseId: warehouseId,
        language: language);

    var response = await http.put(Uri.parse(_baseURL + endpoint),
        headers: _getReqHeaders(), body: jsonEncode(_session!.toJson()));

    if (response.statusCode == HttpStatus.ok) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      _session!.userId = json['userId'];
      _session!.language = json['language'];
      _session!.token = json['token'];
      return _session!;
    } else {
      final message = jsonDecode(utf8.decode(response.bodyBytes));
      throw APIException(message['detail'], response.statusCode);
    }
  }

  Future<List<T>> _get<T extends ModelBase>(
      String endpoint, T Function(Map<String, dynamic>) constructor,
      {FilterBuilder? filter,
      ExpandBuilder? expand,
      List<String>? orderBy,
      List<String>? select,
      int? top,
      int? skip,
      Object? valRule,
      ContextBuilder? context,
      bool showsql = false,
      String? token}) async {
    var response = await http.get(
        Uri.parse(_buildUrl(endpoint,
            expand: expand,
            select: select,
            filter: filter,
            orderBy: orderBy,
            top: top,
            skip: skip,
            valRule: valRule,
            context: context,
            showsql: showsql)),
        headers: _getReqHeaders(token: token));

    List<T> records = [];

    if (response.statusCode == HttpStatus.ok) {
      final fromJson = jsonDecode(utf8.decode(response.bodyBytes));

      String recordType = _getRecordType(endpoint);

      final decodeList = fromJson[recordType];
      if (decodeList != null) {
        records = List.generate(decodeList.length, (index) {
          T record = constructor(decodeList[index]);
          return record;
        });
      }
    } else {
      final message = jsonDecode(utf8.decode(response.bodyBytes));
      throw APIException(message["message"], response.statusCode);
    }

    return records;
  }

  /// Abstracts the Requesting PO Colletions request in idempiere-rest API
  /// See (https://wiki.idempiere.org/en/REST_Web_Services#Requesting_PO_Collections)
  /// [constructor] is a function that receives a json and return a object of
  /// the requested type [T] that extends [ModelBase]
  /// return List of [T] that extends [ModelBase]
  Future<List<T>> get<T extends ModelBase>(
      String endpoint, T Function(Map<String, dynamic>) constructor,
      {FilterBuilder? filter,
      ExpandBuilder? expand,
      List<String>? orderBy,
      List<String>? select,
      int? top,
      int? skip,
      Object? valRule,
      ContextBuilder? context,
      bool showsql = false}) async {
    return _get(endpoint, constructor,
        filter: filter,
        expand: expand,
        orderBy: orderBy,
        select: select,
        top: top,
        skip: skip,
        valRule: valRule,
        context: context,
        showsql: showsql);
  }

  /// Abstracts the Requesting an Individual PO by ID request in idempiere-rest API
  /// See (https://wiki.idempiere.org/en/REST_Web_Services#Requesting_an_Individual_PO_by_ID)
  /// [constructor] is a function that receives a json and return a object of
  /// the requested type [T] that extends [ModelBase]
  /// return [T] tjat extends [ModelBase]
  Future<T?> getRecord<T extends ModelBase>(
      String endpoint, int id, T Function(Map<String, dynamic>) constructor,
      {ExpandBuilder? expand, List<String>? select}) async {
    var response = await http.get(
        Uri.parse(_buildUrl("$endpoint/$id", expand: expand, select: select)),
        headers: _getReqHeaders());

    if (response.statusCode == HttpStatus.ok) {
      final fromJson = jsonDecode(utf8.decode(response.bodyBytes));
      if (fromJson == null) return null;
      T record = constructor(fromJson);
      return record;
    } else {
      final message = jsonDecode(utf8.decode(response.bodyBytes));
      throw APIException(message["detail"], response.statusCode);
    }
  }

  /// Abstracts the Create a PO request in idempiere-rest API
  /// See (https://wiki.idempiere.org/en/REST_Web_Services#Create_a_PO)
  /// return created [T] that extends [ModelBase] using the [ModelBase.fromJson] method
  /// of [model]
  Future<T> post<T extends ModelBase>(String endpoint, T model) async {
    var response = await http.post(Uri.parse(_baseURL + endpoint),
        headers: _getReqHeaders(), body: jsonEncode(model.toJson()));

    if (response.statusCode != HttpStatus.created) {
      final message = jsonDecode(utf8.decode(response.bodyBytes));
      throw APIException(
          "Erro ao criar: ${message['detail']}", response.statusCode);
    } else {
      T record =
          model.fromJson(jsonDecode(utf8.decode(response.bodyBytes))) as T;
      return record;
    }
  }

  /// Abstracts the Remove a PO request in idempiere-rest API
  /// See (https://wiki.idempiere.org/en/REST_Web_Services#Remove_a_PO)
  /// return true if po is deleted or throw [APIException]
  Future<bool> delete(String endpoint, int id) async {
    var response = await http.delete(Uri.parse("$_baseURL$endpoint/$id"),
        headers: _getReqHeaders());
    if (response.statusCode != HttpStatus.ok) {
      throw APIException(
          "Erro ao deletar: : ${jsonDecode(utf8.decode(response.bodyBytes))['detail']}",
          response.statusCode);
    } else {
      return true;
    }
  }

  /// Abstracts the Update a PO request in idempiere-rest API
  /// See (https://wiki.idempiere.org/en/REST_Web_Services#Update_a_PO)
  /// return updated [T] that extends [ModelBase] using the [ModelBase.fromJson] method
  /// of [model]
  Future put<T extends ModelBase>(String endpoint, T model) async {
    var response = await http.put(Uri.parse("$_baseURL$endpoint/${model.id}"),
        headers: _getReqHeaders(), body: jsonEncode(model.toJson()));

    if (response.statusCode != HttpStatus.ok) {
      final message = jsonDecode(utf8.decode(response.bodyBytes));
      throw APIException(
          "Erro ao atualizar: ${message["detail"]}", response.statusCode);
    } else {
      T record =
          model.fromJson(jsonDecode(utf8.decode(response.bodyBytes))) as T;
      return record;
    }
  }

  /// Run a Process and retrieve the [ProcessSummary]
  /// See (https://wiki.idempiere.org/en/REST_Web_Services#Processses_api.2Fv1.2Fprocesses)
  /// [params] is columnName:value to be passed to the process
  Future<ProcessSummary> runProcess(String endpoint,
      {Map<String, dynamic>? params}) async {
    var response = await http.post(Uri.parse(_baseURL + endpoint),
        headers: _getReqHeaders(), body: jsonEncode(params));

    if (response.statusCode != HttpStatus.ok) {
      final message = jsonDecode(utf8.decode(response.bodyBytes));
      throw APIException(message["detail"], response.statusCode);
    } else {
      return ProcessSummary.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    }
  }
}
