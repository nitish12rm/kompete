import 'dart:convert';

class LobbyModel {
  String? createdBy;
  int? maxUsers;
  List<Coordinate>? coordinates;
  String? distance;
  String? status;
  String? id;
  String? lobbyId;
  List<User>? users;
  List<Ready>? ready;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  LobbyModel({
    this.createdBy,
    this.maxUsers,
    this.coordinates,
    this.distance,
    this.status,
    this.id,
    this.lobbyId,
    this.users,
    this.ready,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory LobbyModel.fromRawJson(String str) => LobbyModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LobbyModel.fromJson(Map<String, dynamic> json) => LobbyModel(
    createdBy: json["createdBy"],
    maxUsers: json["maxUsers"],
    coordinates: json["coordinates"] == null ? [] : List<Coordinate>.from(json["coordinates"]!.map((x) => Coordinate.fromJson(x))),
    distance: json["distance"],
    status: json["status"],
    id: json["_id"],
    lobbyId: json["lobbyId"],
    users: json["users"] == null ? [] : List<User>.from(json["users"]!.map((x) => User.fromJson(x))),
    ready: json["ready"] == null ? [] : List<Ready>.from(json["ready"]!.map((x) => Ready.fromJson(x))),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "createdBy": createdBy,
    "maxUsers": maxUsers,
    "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x.toJson())),
    "distance": distance,
    "status": status,
    "_id": id,
    "lobbyId": lobbyId,
    "users": users == null ? [] : List<dynamic>.from(users!.map((x) => x.toJson())),
    "ready": ready == null ? [] : List<dynamic>.from(ready!.map((x) => x.toJson())),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Coordinate {
  List<Marker>? markers;
  List<List<double>>? polyline;
  String? id;

  Coordinate({
    this.markers,
    this.polyline,
    this.id,
  });

  factory Coordinate.fromRawJson(String str) => Coordinate.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Coordinate.fromJson(Map<String, dynamic> json) => Coordinate(
    markers: json["markers"] == null ? [] : List<Marker>.from(json["markers"]!.map((x) => Marker.fromJson(x))),
    polyline: json["polyline"] == null ? [] : List<List<double>>.from(json["polyline"]!.map((x) => List<double>.from(x.map((x) => x?.toDouble())))),
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "markers": markers == null ? [] : List<dynamic>.from(markers!.map((x) => x.toJson())),
    "polyline": polyline == null ? [] : List<dynamic>.from(polyline!.map((x) => List<dynamic>.from(x.map((x) => x)))),
    "_id": id,
  };
}

class Marker {
  List<double>? origin;
  List<double>? destination;
  String? id;

  Marker({
    this.origin,
    this.destination,
    this.id,
  });

  factory Marker.fromRawJson(String str) => Marker.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Marker.fromJson(Map<String, dynamic> json) => Marker(
    origin: json["origin"] == null ? [] : List<double>.from(json["origin"]!.map((x) => x?.toDouble())),
    destination: json["destination"] == null ? [] : List<double>.from(json["destination"]!.map((x) => x?.toDouble())),
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "origin": origin == null ? [] : List<dynamic>.from(origin!.map((x) => x)),
    "destination": destination == null ? [] : List<dynamic>.from(destination!.map((x) => x)),
    "_id": id,
  };
}

class User {
  String? userId;
  String? role;
  String? id;

  User({
    this.userId,
    this.role,
    this.id,
  });

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json["userId"],
    role: json["role"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "role": role,
    "_id": id,
  };
}

class Ready {
  String? userId;
  String? id;

  Ready({
    this.userId,
    this.id,
  });

  factory Ready.fromRawJson(String str) => Ready.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Ready.fromJson(Map<String, dynamic> json) => Ready(
    userId: json["userId"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "_id": id,
  };
}
