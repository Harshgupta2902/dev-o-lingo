class PublicUserModel {
  bool? status;
  String? message;
  Data? data;

  PublicUserModel({this.status, this.message, this.data});

  PublicUserModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  int? id;
  String? name;
  String? profile;
  int? xp;
  int? streak;
  int? gems;
  int? hearts;
  Level? level;
  int? followerCount;
  int? followingCount;
  bool? isFollowing;

  Data(
      {this.id,
      this.name,
      this.profile,
      this.xp,
      this.streak,
      this.gems,
      this.hearts,
      this.level,
      this.followerCount,
      this.followingCount,
      this.isFollowing});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profile = json['profile'];
    xp = json['xp'];
    streak = json['streak'];
    gems = json['gems'];
    hearts = json['hearts'];
    level = json['level'] != null ? Level.fromJson(json['level']) : null;
    followerCount = json['followerCount'];
    followingCount = json['followingCount'];
    isFollowing = json['isFollowing'];
  }
}

class Level {
  int? rank;
  String? title;
  String? emoji;
  int? nextLevelXp;
  int? xpToNext;

  Level({this.rank, this.title, this.emoji, this.nextLevelXp, this.xpToNext});

  Level.fromJson(Map<String, dynamic> json) {
    rank = json['rank'];
    title = json['title'];
    emoji = json['emoji'];
    nextLevelXp = json['next_level_xp'];
    xpToNext = json['xp_to_next'];
  }
}
