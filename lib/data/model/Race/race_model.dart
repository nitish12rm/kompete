class RaceModel {
  User? user;
  String? userid;
  String? lobbyid;
  List<String>? rank;

  RaceModel({this.user, this.userid, this.lobbyid, this.rank});

  RaceModel.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    userid = json['userid'];
    lobbyid = json['lobbyid'];
    rank = json['rank'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['userid'] = this.userid;
    data['lobbyid'] = this.lobbyid;
    data['rank'] = this.rank;
    return data;
  }
}

class User {
  String? id;
  String? name;
  List<double>? coord;
  String? eta;
  String? distance;
  String? speed;

  User({this.id, this.name, this.coord, this.eta, this.distance, this.speed});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    coord = json['coord'].cast<double>();
    eta = json['eta'];
    distance = json['distance'];
    speed = json['speed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['coord'] = this.coord;
    data['eta'] = this.eta;
    data['distance'] = this.distance;
    data['speed'] = this.speed;
    return data;
  }
}
