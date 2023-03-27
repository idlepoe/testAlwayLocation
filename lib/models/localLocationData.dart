part 'localLocationData.g.dart';

String _toString(dynamic value) => "$value";

class LocalLocationData {
  DateTime locationDateTime;
  double locationLatitude;
  double locationLongitude;
  bool isAppActive;

  LocalLocationData.init() : this(DateTime.now(), 0, 0, false);

  LocalLocationData(this.locationDateTime, this.locationLatitude,
      this.locationLongitude, this.isAppActive);

  factory LocalLocationData.fromJson(Map<String, dynamic> json) {
    return _$LocalLocationDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LocalLocationDataToJson(this);

  @override
  String toString() {
    return 'LocalLocationData{locationDateTime: $locationDateTime, locationLatitude: $locationLatitude, locationLongitude: $locationLongitude, isAppActive: $isAppActive}';
  }
}
