class LobbyModel {
  String? createdBy;
  int? maxUsers;
  String? status;
  String? sId;
  String? lobbyId;
  List<Users>? users;
  int? iV;

  LobbyModel(
      {this.createdBy,
        this.maxUsers,
        this.status,
        this.sId,
        this.lobbyId,
        this.users,
        this.iV});

  LobbyModel.fromJson(Map<String, dynamic> json) {
    createdBy = json['createdBy'];
    maxUsers = json['maxUsers'];
    status = json['status'];
    sId = json['_id'];
    lobbyId = json['lobbyId'];
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(new Users.fromJson(v));
      });
    }
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdBy'] = this.createdBy;
    data['maxUsers'] = this.maxUsers;
    data['status'] = this.status;
    data['_id'] = this.sId;
    data['lobbyId'] = this.lobbyId;
    if (this.users != null) {
      data['users'] = this.users!.map((v) => v.toJson()).toList();
    }
    data['__v'] = this.iV;
    return data;
  }
}

class Users {
  String? userId;
  String? role;
  String? sId;

  Users({this.userId, this.role, this.sId});

  Users.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    role = json['role'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['role'] = this.role;
    data['_id'] = this.sId;
    return data;
  }
}
