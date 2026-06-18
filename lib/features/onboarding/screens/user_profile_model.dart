
class UserProfileModel {

  String? gender;
  int? age;
  int? height;
  int? weight;
  String? mainGoals;
  String? fitnessLevel;
  int? duration;
  String? intensity;
  String? workoutTime;
  String? diet;
  Map<String, dynamic>? injuryDetails;
  Map<String, dynamic>? medicationDetails;
  Map<String, dynamic>? allergyDetails;

  Map<String, dynamic> toJson() {
    Map<String, dynamic>? formattedInjuries;

    if (injuryDetails != null) {
      formattedInjuries = Map<String, dynamic>.from(injuryDetails!);

      if (formattedInjuries['startDate'] != null) {
        // 👇 Add .toUtc() before toIso8601String() to get the "Z" at the end
        formattedInjuries['startDate'] = (formattedInjuries['startDate'] as DateTime).toUtc().toIso8601String();
      }

      if (formattedInjuries['endDate'] != null) {
        // 👇 Same here for the end date
        formattedInjuries['endDate'] = (formattedInjuries['endDate'] as DateTime).toUtc().toIso8601String();
      }
    }
    /* * EXPECTED JSON OUTPUT FOR INJURY :
   * * "injuryDetails": {
   * "hasInjury": true,
   * "areas": ["Knee", "Lower Back"],
   * "startDate": "2025-10-15T00:00:00.000",
   * "endDate": null, // Will be a string like startDate if fully healed
   * "stillFeelIt": true
   * }
   *  EXPECTED JSON OUTPUT FOR MEDICATION:
   * "medicationDetails": {
   * "takesMedication": true,
   * "medicationName": "Lisinopril",
   * "reason": "High Blood Pressure"
   * }
   * EXPECTED JSON OUTPUT FOR ALLERGIES:
   * "allergyDetails": {
   * "hasAllergies": true,
   * "allergies": "Peanuts, Dairy"
   * }
    **/

    return {

      "gender": gender,
      "age": age,
      "height": height,
      "weight": weight,
      "fitnessLevel": fitnessLevel,
      "mainGoal": mainGoals,
      "duration": duration,
      "intensity": intensity,
      "workoutTime": workoutTime,
      "diet": diet,
      'injuryDetails': formattedInjuries,
      'medicationDetails': medicationDetails,
      'allergyDetails': allergyDetails,


    };
  }
}