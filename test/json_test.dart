library cast.test.json;

import 'package:test/test.dart';

import 'package:cast/cast.dart' as cast;

void main() {
  var json = <String, dynamic>{
    "id": 0,
    "fields": <String, dynamic>{"field1": 1, "field2": 2},
    "extra1": "hello",
    "extra2": <dynamic>["hello"],
  };

  test("type casting", () {
    const typed = cast.Keyed<String, dynamic>({
      "id": cast.int,
      "fields": cast.Keyed({"field1": cast.int, "field2": cast.int}),
      "extra1": cast.OneOf(cast.String, cast.List(cast.String)),
      "extra2": cast.OneOf(cast.String, cast.List(cast.String)),
    });
    var result = typed.cast(json);

    expect(result is Map<String, dynamic>, isTrue);

    expect(result["id"] is int, isTrue);
    expect(result["id"], json["id"]);

    expect(result["fields"] is Map<String, int>, isTrue);
    Map<String, int> fields = result["fields"];
    expect(fields["field1"], json["fields"]["field1"]);
    expect(fields["field2"], json["fields"]["field2"]);

    expect(result["extra1"] is String, isTrue);
    expect(result["extra1"], json["extra1"]);

    expect(result["extra2"] is List<String>, isTrue);
    expect(result["extra2"][0] is String, isTrue);
    expect(result["extra2"][0], json["extra2"][0]);
  });

  test("type casting with defaults", () {
    const typed = cast.Keyed<String, dynamic>({
      "fields": cast.Keyed({"field1": cast.int, "field2": cast.int}),
      "extra1": cast.OneOf(cast.String, cast.List(cast.String)),
      "extra2": cast.OneOf(cast.String, cast.List(cast.String)),
    }, otherwise: cast.any);
    var result = typed.cast(json);

    expect(result is Map<String, dynamic>, isTrue);

    expect(result["id"] is int, isTrue);
    expect(result["id"], json["id"]);

    expect(result["fields"] is Map<String, int>, isTrue);
    Map<String, int> fields = result["fields"];
    expect(fields["field1"], json["fields"]["field1"]);
    expect(fields["field2"], json["fields"]["field2"]);

    expect(result["extra1"] is String, isTrue);
    expect(result["extra1"], json["extra1"]);

    expect(result["extra2"] is List<String>, isTrue);
    expect(result["extra2"][0] is String, isTrue);
    expect(result["extra2"][0], json["extra2"][0]);
  });

  test("Casting to custom classes", () {
    var schema = MyCustomClass.schema(cast.Keyed({
      "id": cast.int,
      "fields": cast.Keyed({"field1": cast.int, "field2": cast.int}),
      "extra1": Union.schema(cast.String, cast.List(cast.String)),
      "extra2": Union.schema(cast.String, cast.List(cast.String)),
    }));

    var result = schema.cast(json);
    expect(result is MyCustomClass, isTrue);

    var id = result.id;
    expect(id is int, isTrue);

    var fields = result.fields;
    expect(fields is Map<String, int>, isTrue);

    var extra1 = result.extra1;
    expect(extra1 is Union<String, List<String>>, isTrue);

    expect(extra1.isLeft, isTrue);

    var s = extra1.left;
    expect(s is String, isTrue);

    var extra2 = result.extra2;
    expect(extra2 is Union<String, List<String>>, isTrue);

    expect(extra2.isRight, isTrue);

    var l = extra2.right;
    expect(l is List<String>, isTrue);
  });
}

class Union<S, T> {
  dynamic contents;
  bool get isLeft => contents is S;
  bool get isRight => contents is T;
  S get left => contents as S;
  T get right => contents as T;
  Union(this.contents);
  static cast.Cast<Union<S, T>> schema<S, T>(
          cast.Cast<S> left, cast.Cast<T> right) =>
      cast.Apply((u) => new Union<S, T>(u), cast.OneOf(left, right));
}

class MyCustomClass {
  Map<String, dynamic> parsed;
  MyCustomClass(this.parsed);
  int get id => parsed["id"];
  Map<String, int> get fields => parsed["fields"];
  Union<String, List<String>> get extra1 => parsed["extra1"];
  Union<String, List<String>> get extra2 => parsed["extra2"];
  static cast.Cast<MyCustomClass> schema(
          cast.Cast<Map<String, dynamic>> parse) =>
      cast.Apply((a) => MyCustomClass(a), parse);
}
