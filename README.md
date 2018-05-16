This is a prototype of what a deep cast package might look like.

## Usage

### Simple schema

Simple schema can be defined and used like this:

```dart
  // Lists
  const schema = cast.List(cast.int);
  List<dynamic> someList = ....;
  // Inferred type is List<String>, runtime reified type is List<String>
  var typedList = schema.cast(someList);  
```

```dart
  // Maps
  const schema = cast.Map(cast.String, cast.int);
  Map<dynamic, dynamic> someMap = ....;
  // Inferred type is Map<String, int>, runtime reified type is Map<String, int>
  var typedMap = schema.cast(someMap);
```

Casts can be applied arbitrarily deep:

```dart
  // Maps
  const schema = cast.Map(cast.String, cast.List(cast.int));
  Map<dynamic, dynamic> someMap = ....;
  // Inferred type is Map<String, List<int>>, 
  // runtime reified type is Map<String, List<int>>
  var typedMap = schema.cast(someMap);
  // Inferred type is List<int>, 
  // runtime reified type is List<int>
  var typedList = typedMap["field"];
```

### Structured schema

Complex schemas with different types for different fields can also be defined:

```dart
   const typed = cast.Keyed<String, dynamic>({
      "id": cast.int,
      "fields": cast.Keyed({"field1": cast.int, "field2": cast.int}),
      "extra1": cast.OneOf(cast.String, cast.List(cast.String)),
      "extra2": cast.OneOf(cast.String, cast.List(cast.String)),
    });
```

Given structured data matching that schema:

```dart
 var json = <String, dynamic>{
    "id": 0,
    "fields": <String, dynamic>{"field1": 1, "field2": 2},
    "extra1": "hello",
    "extra2": <dynamic>["hello"],
  };
```

Applying the cast gives back a deeply cast object of the right type:

```dart
Map<String, dynamic> result = typed.cast(json);
Map<String, int> fields = result["fields"]; // Implicit cast will not fail
```
