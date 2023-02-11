A Dart client to facilitate the consume of idempiere rest api (https://github.com/bxservice/idempiere-rest)

## Features

This package implements some api calls listed in official documentation (https://wiki.idempiere.org/en/REST_Web_Services)

+ One-step log-in
+ Normal log-in
+ Requesting PO Collections
+ Requesting an Individual PO by ID
+ Create a PO
+ Remove a PO
+ Update a PO
+ Processes

## Usage

The main class is IdempiereClient, which is a singleton. Once instanciated, the method setBaseUrl must be called. 

```dart
// instantiate the singleton idempiere client with the API url
IdempiereClient().setBaseUrl("https://mundodocafe.brerp.cloud/api/v1");
```

After that, you can choose between One-step log-in and Normal log-in, depending on your case.

If you already know the parameters (Client, Role, Org, Warehouse, Lang), you can use One-Step log-in: 

```dart
IdempiereClient().oneStepLogin("/auth/tokens", "superuser @ brerp.com.br",
      "cafe123", "1000000", "1000000")
```
To create or update a PO, we have to create a class that extends the abstract class ModelBase and implemented it methods:

```dart
import 'package:idempiere_rest/src/model_base.dart';

class MBPartner extends ModelBase {
    
    late String name;

    MBPartner(Map<String, dynamic> json) : super(json) {
        id = json['id'];
        name = json['Name'];
    }

    @override
    Map<String, dynamic> toJson() {
        return {'Name' : name};
    }

    @override
    MBPartner fromJson(Map<String, dynamic> json) {
        id = json['id'];
        name = json['Name'];
        return this;
    }
}
```

After that, we can do the PO request:

```dart
// getting records
List<MBPartner> records = await IdempiereClient().get<MBPartner>(
          "/models/c_bpartner", (json) => MBPartner(json))

//create a record
MBPartner newRecord = MBPartner();
IdempiereClient().post<MBPartner>("/models/c_bpartner", newRecord); 

//update a record
IdempiereClient().put<MBPartner>("/models/c_bpartner", newRecord);
```

For a complete example, including the Normal log-in and the query options in get requests, see example/idempiere_rest_example.dart 

See the official documentation for more details about the parameters.

## Contribution

If you find any bugs or have any suggestions, feel free to create an issue or submit a pull request.


