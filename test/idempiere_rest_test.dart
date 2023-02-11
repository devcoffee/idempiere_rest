import 'package:idempiere_rest/src/expand_builder.dart';
import 'package:idempiere_rest/src/filter_builder.dart';
import 'package:idempiere_rest/src/login_response.dart';
import 'package:idempiere_rest/src/model_base.dart';
import 'package:idempiere_rest/src/operators.dart';
import 'package:idempiere_rest/src/process_summary.dart';
import 'package:idempiere_rest/src/idempiere_client.dart';
import 'package:idempiere_rest/src/session.dart';
import 'package:test/test.dart';

void main() {
  group('Idempiere Rest - Simple Test Suite', () {
    String login = "superuser @ brerp.com.br";
    String password = "cafe123";
    IdempiereClient().setBaseUrl("https://mundodocafe.brerp.cloud/api/v1");
    late LoginResponse response;
    late int roleId;
    late int adOrgId;
    late int warehouseId;
    late TestModel record;

    setUp(() {
      // Additional setup goes here.
    });

    test('Login', () async {
      response = await IdempiereClient().login("/auth/tokens", login, password);

      expect(response.token.isNotEmpty, isTrue);
      expect(response.clients.isNotEmpty, isTrue);
    });

    test('Get Roles', () async {
      roleId = (await IdempiereClient().getRoles(response.clients.first.id!))
          .first
          .id!;
      expect(roleId > 0, isTrue);
    });

    test('Get Organizations', () async {
      adOrgId = (await IdempiereClient()
              .getOrganizations(response.clients.first.id!, roleId))
          .first
          .id!;
      expect(adOrgId > 0, isTrue);
    });

    test('Get Warehouses', () async {
      warehouseId = (await IdempiereClient()
              .getWarehouses(response.clients.first.id!, roleId, adOrgId))
          .first
          .id!;
      expect(true, isTrue);
    });

    test('Init Session', () async {
      Session s = await IdempiereClient().initSession(
          "/auth/tokens", response.token, response.clients.first.id!, roleId,
          organizationId: adOrgId, warehouseId: warehouseId);

      expect(s.token.isNotEmpty, isTrue);
    });

    test('Get Records', () async {
      FilterBuilder filter = FilterBuilder();
      filter
          .addFilter('C_BP_Group_ID', Operators.eq, 1000000)
          .and()
          .addFilter('COF_SituacaoComercial', Operators.eq, 'PA')
          .and()
          .addFilter('lbr_IE', Operators.contains, '1');

      ExpandBuilder expand = ExpandBuilder();

      FilterBuilder childFilter = FilterBuilder();
      childFilter.addFilter('Name', Operators.contains, 'a');

      expand.expand("AD_User",
          columnName: ['Name', 'Phone'],
          filter: childFilter,
          orderBy: ['Name', 'EMail'],
          top: 10,
          skip: 5);

      List<TestModel> records = await IdempiereClient().get<TestModel>(
          "/models/c_bpartner", (json) => TestModel(json),
          filter: filter,
          expand: expand,
          orderBy: ['COF_SituacaoComercial', 'Name'],
          select: ['Name', 'Name2'],
          top: 10,
          skip: 2,
          showsql: true);
      expect(records.isNotEmpty, isTrue);
    });

    //TODO: filter, select, expand, orderby, top, skip, valRule, context, showSql

    test('Get Record', () async {
      TestModel? record = await IdempiereClient().getRecord<TestModel>(
          "/models/c_bpartner", 1000001, (json) => TestModel(json));

      expect(record!.id, 1000001);
    });

    test('Post Record', () async {
      TestModel newRecord = TestModel.newTest(1000000, 'BParner Test');
      record = await IdempiereClient()
          .post<TestModel>("/models/c_bpartner", newRecord);

      expect(record.id! > 0, isTrue);
    });

    test('Put Record', () async {
      TestModel oldRecord = TestModel.newTest(1000000, record.name);
      oldRecord.id = record.id;
      record.name = 'BPartner Test Put';
      TestModel updatedRecord =
          await IdempiereClient().put<TestModel>("/models/c_bpartner", record);

      expect(
          updatedRecord.id == oldRecord.id &&
              updatedRecord.name != oldRecord.name,
          isTrue);
    });

    test('Delete Record', () async {
      bool isDeleted =
          await IdempiereClient().delete("/models/c_bpartner", record.id!);

      expect(isDeleted, isTrue);
    });

    test('Run Process', () async {
      ProcessSummary ps = await IdempiereClient().runProcess(
          "/processes/ad_role_accessupdate",
          params: {'AD_Role_ID': 1000000, 'ResetAccess': 'N'});

      expect(ps.isError, isFalse);
      expect(ps.logs!.isNotEmpty, isTrue);
    });
  });
}

class TestModel extends ModelBase {
  late int cBPGroupId;
  late String name;

  TestModel.newTest(this.cBPGroupId, this.name) : super({});

  TestModel(Map<String, dynamic> json) : super(json) {
    id = json['id'];
    name = json['Name'];
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    if (id != null) {
      data['id'] = id;
    }

    data['Name'] = name;
    data['C_BP_Group_ID'] = cBPGroupId;
    data['AD_Language'] = 'en_US';

    return data;
  }

  @override
  TestModel fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['Name'];
    return this;
  }
}
