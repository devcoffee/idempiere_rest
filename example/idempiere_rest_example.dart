import 'package:idempiere_rest/idempiere_rest.dart';

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

  //TODO: getrecords (with expand(select), select, orderby, filter)
  //TODO: getrecord
  //TODO: post
  //TODO: put
  //TODO: delete
  //TODO: runProcess
}
