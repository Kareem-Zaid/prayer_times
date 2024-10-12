class Geocoding {
  final List<Result> results;
  final Status status;
  Geocoding({required this.results, required this.status});
  factory Geocoding.fromJson(json) {
    return Geocoding(
      results: List.from(
        (json['results'] as List).map(
          // https://chatgpt.com/c/bdfc2535-0230-4425-89ba-a28273f5308e
          (result) {
            return Result.fromJson(result);
          },
        ),
      ),
      status: Status.fromJson(json['status']),
    );
  }
}

class Status {
  final int code;
  final String message;
  Status({required this.code, required this.message});
  factory Status.fromJson(json) {
    return Status(code: json['code'], message: json['message']);
  }
}

class Result {
  final Geometry geometry;
  Result({required this.geometry});
  factory Result.fromJson(json) =>
      Result(geometry: Geometry.fromJson(json['geometry']));
}

class Geometry {
  final double lat, lng;
  Geometry({required this.lat, required this.lng});
  factory Geometry.fromJson(json) {
    return Geometry(lat: json['lat'], lng: json['lng']);
  }
}
