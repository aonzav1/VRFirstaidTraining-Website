import 'package:vrfirstaid/classes/patient.dart';
import 'dart:convert';

class ScenarioData {
  String createdBy = "User";
  String name = "";
  String description = "";
  int difficulty = 2;
  String introduction = "";
  int location = 0;
  String thumbnail = "";
  List<Patient> patients = [];
  List<int> items = [];
  int timeLimit = 120;
  double timeScoreMult = 1;
  double interactMult = 1;
  bool endOnDeath = true;
  bool endOnWrong = false;
  double penaltyScoreMult = 1;
  double bonusScoreMult = 1;
  bool allowTablet = true;
  bool showGuide = true;
  bool showStatus = true;
  int passScore = 800;
  int goldBadgeScore = 1500;
  DateTime lastUpdated = DateTime.now();
  DateTime createdAt = DateTime.now();

  ScenarioData(
      this.createdBy,
      this.name,
      this.description,
      this.difficulty,
      this.introduction,
      this.location,
      this.thumbnail,
      this.patients,
      this.items,
      this.timeLimit,
      this.timeScoreMult,
      this.interactMult,
      this.endOnDeath,
      this.endOnWrong,
      this.penaltyScoreMult,
      this.bonusScoreMult,
      this.allowTablet,
      this.showGuide,
      this.showStatus,
      this.passScore,
      this.goldBadgeScore,
      this.lastUpdated,
      this.createdAt);

  Map toJson() {
    var JsonPatient = [];
    for (var i = 0; i < patients.length; i++) {
      JsonPatient.add(patients[i].toJson());
    }
    return {
      "name": name,
      "description": description,
      "difficulty": difficulty,
      "introduction": introduction,
      "location": location,
      "thumbnail": thumbnail,
      "patients": {"data": JsonPatient},
      "items": {"data": jsonEncode(items)},
      "timeLimit": timeLimit,
      "timeScoreMult": timeScoreMult,
      "interactMult": interactMult,
      "endOnDeath": endOnDeath,
      "endOnWrong": endOnWrong,
      "penaltyScoreMult": penaltyScoreMult,
      "bonusScoreMult": bonusScoreMult,
      "allowTablet": allowTablet,
      "showGuide": showGuide,
      "showStatus": showStatus,
      "passScore": passScore,
      "goldBadgeScore": goldBadgeScore,
    };
  }

  factory ScenarioData.fromJson(Map<String, dynamic> json) {
    return ScenarioData(
        json["createdBy"] ?? '',
        json["name"],
        json["description"],
        json["difficulty"],
        "",
        json["location"],
        json["thumbnail"],
        [],
        [],
        0,
        0,
        0,
        false,
        false,
        0,
        0,
        false,
        false,
        false,
        0,
        0,
        DateTime.now(),
        DateTime.now());
  }
}
