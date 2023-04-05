class Patient {
  String name = "";
  String age = "kid";
  String injury = "bruise";
  double injuryTime;
  int appearance = 0;
  int painSensitivity = 0;
  int emotionalSensitivity = 0;
  int bodyResistance = 0;
  int initialBodyHealth = 0;
  int initialMentalHealth = 0;
  int placement = 0;
  double patientScoreMult = 1.0;

  Patient(
    this.name,
      this.age,
      this.appearance,
      this.injury,
      this.injuryTime,
      this.painSensitivity,
      this.bodyResistance,
      this.emotionalSensitivity,
      this.initialBodyHealth,
      this.initialMentalHealth,
      this.patientScoreMult,
      this.placement);
    
    
        Map toJson() => {
          'name':name,
          'appearancec':appearance,
          'injury':injury,
          'injuryTime':injuryTime,
          'painSensitivity':painSensitivity,
          'bodyResistancec':bodyResistance,
          'emotionalSensitivity':emotionalSensitivity,
          'initialBodyHealth':initialBodyHealth,
          'initialMentalHealth':initialMentalHealth,
          'patientScoreMult':patientScoreMult,
          'placement':placement,
      };
}
