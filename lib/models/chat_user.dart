class ChatUser {
  final String uid;
  final String name;
  final String email;
  final String imageUrl;
  late DateTime lastActive;
  ChatUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.lastActive,
  });
  factory ChatUser.fromJson(Map<String, dynamic> _json) {
    return ChatUser(
        uid: _json["uid"],
        name: _json["name"],
        email: _json["email"],
        imageUrl: _json["image"],
        lastActive: _json["last_active"].toDate(),
    );
  }
  Map<String,dynamic>toMap(){

    return {
      "name": name,
      "email": email,
      "uid": uid,
      "image": imageUrl,
      "last_active": lastActive
    };
  }
  String lastDayActive(){
    return "${lastActive.month}/${lastActive.day}/${lastActive.year}";
  }
  bool asRecentlyActive(){
    return DateTime.now().difference(lastActive).inHours<2;
    
  }
}
