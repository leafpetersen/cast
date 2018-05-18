library cast.test.cast;

import 'package:test/test.dart';

import 'package:cast/cast.dart' as cast;

void main() {
  test("any casts", () {
    expect(cast.any.cast(3), 3);
    expect(cast.any.cast("hello"), "hello");
  });

  test("int casts", () {
    expect(cast.int.cast(3), 3);
    expect(
        () => cast.int.cast("hello"), throwsA(isInstanceOf<cast.FailedCast>()));
  });

  test("double casts", () {
    expect(cast.double.cast(3.1), 3.1);
    expect(() => cast.double.cast("hello"),
        throwsA(isInstanceOf<cast.FailedCast>()));
  });

  test("String casts", () {
    expect(cast.String.cast("hello"), "hello");
    expect(() => cast.String.cast(3), throwsA(isInstanceOf<cast.FailedCast>()));
  });

  test("bool casts", () {
    expect(cast.bool.cast(true), true);
    expect(() => cast.bool.cast(3), throwsA(isInstanceOf<cast.FailedCast>()));
  });

  test("Casting empty lists", () {
    const listOfInt = cast.List(cast.int);
    const listOfString = cast.List(cast.String);

    expect(listOfInt.cast(<dynamic>[]) is List<int>, isTrue);
    expect(listOfInt.cast(<dynamic>[]), <int>[]);

    expect(
        () => listOfString.cast({}), throwsA(isInstanceOf<cast.FailedCast>()));
  });

  test("Casting non-empty lists", () {
    const listOfInt = cast.List(cast.int);
    const listOfString = cast.List(cast.String);

    expect(listOfInt.cast(<num>[3]) is List<int>, isTrue);
    expect(listOfInt.cast(<num>[3]), <int>[3]);
    expect(() => listOfString.cast(<num>[3]),
        throwsA(isInstanceOf<cast.FailedCast>()));
  });

  test("Casting nested lists", () {
    const listOfInt = cast.List(cast.int);
    const listOfString = cast.List(cast.String);
    const listOfListOfInt = cast.List(listOfInt);
    const listOfListOfString = cast.List(listOfString);

    expect(
        listOfListOfInt.cast(<dynamic>[
          <dynamic>[3]
        ]) is List<List<int>>,
        isTrue);
    expect(
        listOfListOfInt.cast(<dynamic>[
          <dynamic>[3]
        ]),
        <List<int>>[
          <int>[3]
        ]);
    expect(
        () => listOfListOfString.cast(<dynamic>[
              <dynamic>[3]
            ]),
        throwsA(isInstanceOf<cast.FailedCast>()));
  });

  test("Casting empty maps", () {
    const mapOfStringToInt = cast.Map(cast.String, cast.int);
    const mapOfStringToString = cast.Map(cast.String, cast.String);

    expect(mapOfStringToInt.cast(<dynamic, dynamic>{}) is Map<String, int>,
        isTrue);
    expect(mapOfStringToInt.cast(<dynamic, dynamic>{}), <String, int>{});

    expect(() => mapOfStringToString.cast(<dynamic>[]),
        throwsA(isInstanceOf<cast.FailedCast>()));
  });

  test("Casting non-empty maps", () {
    const mapOfStringToInt = cast.Map(cast.String, cast.int);
    const mapOfStringToString = cast.Map(cast.String, cast.String);

    expect(
        mapOfStringToInt.cast(<dynamic, dynamic>{"hello": 3})
            is Map<String, int>,
        isTrue);
    expect(mapOfStringToInt.cast(<dynamic, dynamic>{"hello": 3}),
        <String, int>{"hello": 3});

    expect(() => mapOfStringToString.cast(<dynamic, dynamic>{"hello": 3}),
        throwsA(isInstanceOf<cast.FailedCast>()));
    expect(() => mapOfStringToString.cast(<dynamic, dynamic>{3: "world"}),
        throwsA(isInstanceOf<cast.FailedCast>()));
  });

  test("Casting nested maps", () {
    const schema = cast.Map(cast.String, cast.Map(cast.String, cast.int));

    expect(
        schema.cast(<dynamic, dynamic>{
          "hello": <dynamic, dynamic>{"hello": 3}
        }) is Map<String, Map<String, int>>,
        isTrue);
    expect(
        schema.cast(<dynamic, dynamic>{
          "hello": <dynamic, dynamic>{"hello": 3}
        }),
        <String, Map<String, int>>{
          "hello": <String, int>{"hello": 3}
        });

    expect(
        () => schema.cast(<dynamic, dynamic>{
              "hello": <dynamic, dynamic>{3: "hello"}
            }),
        throwsA(isInstanceOf<cast.FailedCast>()));
  });

  test("Casting nested list/maps", () {
    const schema = cast.Map(cast.String, cast.List(cast.int));

    expect(
        schema.cast(<dynamic, dynamic>{
          "hello": <dynamic>[3]
        }) is Map<String, List<int>>,
        isTrue);
    expect(
        schema.cast(<dynamic, dynamic>{
          "hello": <dynamic>[3]
        }),
        <String, List<int>>{
          "hello": <int>[3]
        });
  });
}
