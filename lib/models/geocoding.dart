class Geocoding {
  final List<Result> results;
  final Status status;
  Geocoding({required this.results, required this.status});
  factory Geocoding.fromJson(Map<String, dynamic> json) {
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
  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(code: json['code'], message: json['message']);
  }
}

class Result {
  final Components components;
  final Geometry geometry;
  Result({required this.components, required this.geometry});
  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      components: Components.fromJson(json['components']),
      geometry: Geometry.fromJson(json['geometry']),
    );
  }
}

class Components {
  final String? city; // "city" doesn't exist in all "results" in json
  final String country;
  Components({this.city, required this.country});
  factory Components.fromJson(Map<String, dynamic> json) {
    return Components(city: json['city'], country: json['country']);
  }
}

class Geometry {
  final double lat, lng;
  Geometry({required this.lat, required this.lng});
  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(lat: json['lat'], lng: json['lng']);
  }
}
