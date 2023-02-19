import 'package:idempiere_rest/idempiere_rest.dart';
import 'package:test/test.dart';

void main() async {
  // instantiate the singleton idempiere client with the API url
  IdempiereClient().setBaseUrl("https://mundodocafe.brerp.cloud/api/v1");
  // do the first token request
  LoginResponse login = await IdempiereClient()
      .login("/auth/tokens", "superuser @ brerp.com.br", "cafe123");

  //using the first client id in loginresponse (just for example purposes)
  int clientId = login.clients.first.id!;
  List<Role> roles = await IdempiereClient().getRoles(clientId);

  //using the first role id in roles (just for example purposes)
  int roleId = roles.first.id!;
  List<Organization> orgs =
      await IdempiereClient().getOrganizations(clientId, roleId);

  //using the first org id in orgs (just for example purporses)
  int orgId = orgs.first.id!;
  List<Warehouse> warehouses =
      await IdempiereClient().getWarehouses(clientId, roleId, orgId);

  //using the first warehouseId in warehouses (just for example purposes)
  int whId = warehouses.first.id!;

  //init session
  IdempiereClient().initSession(
      "/auth/tokens", login.token, login.clients.first.id!, roleId,
      organizationId: orgId, warehouseId: whId);

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

  List<MBPartner> records = await IdempiereClient().get<MBPartner>(
      "/models/c_bpartner", (json) => MBPartner(json),
      filter: filter,
      expand: expand,
      orderBy: ['COF_SituacaoComercial', 'Name'],
      select: ['Name', 'Name2'],
      top: 10,
      skip: 2,
      showsql: true);

  print(records);

  MBPartner newRecord = MBPartner.newTest(1000000, 'BParner Test');
  MBPartner? record =
      await IdempiereClient().post<MBPartner>("/models/c_bpartner", newRecord);

  print(record);

  record = await IdempiereClient().getRecord<MBPartner>(
      "/models/c_bpartner", record.id!, (json) => MBPartner(json));

  print(record);

  record!.name = 'BPartner Test Put';
  MBPartner updatedRecord =
      await IdempiereClient().put<MBPartner>("/models/c_bpartner", record);
  print(updatedRecord);

  bool isDeleted =
      await IdempiereClient().delete("/models/c_bpartner", record.id!);
  print(isDeleted);

  ProcessSummary ps = await IdempiereClient().runProcess(
      "/processes/ad_role_accessupdate",
      params: {'AD_Role_ID': 1000000, 'ResetAccess': 'N'});

  print(ps.logs);
}

class MBPartner extends ModelBase {
  late int cBPGroupId;
  late String name;

  MBPartner.newTest(this.cBPGroupId, this.name) : super({});

  MBPartner(Map<String, dynamic> json) : super(json) {
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
  MBPartner fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['Name'];
    return this;
  }
}
