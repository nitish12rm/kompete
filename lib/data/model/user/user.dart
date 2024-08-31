class UserModel {
  String? name;
  String? email;
  String? password;
  String? weight;
  String? height;
  String? sId;
  int? iV;

  UserModel(
      {this.name,
        this.email,
        this.password,
        this.weight,
        this.height,
        this.sId,
        this.iV});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    password = json['password'];
    weight = json['weight'];
    height = json['height'];
    sId = json['_id'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['weight'] = this.weight;
    data['height'] = this.height;
    data['_id'] = this.sId;
    data['__v'] = this.iV;
    return data;
  }
}
