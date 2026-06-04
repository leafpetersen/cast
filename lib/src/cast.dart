library cast;

import 'dart:async' as async;
import 'dart:core' as core;
import 'dart:core' hide Map, String, int;

class FailedCast(
  var core.String context,
  var dynamic key,
  var core.String message,
) implements core.Exception {
  toString() {
    if (key == null) {
      return "Failed cast at $context: $message";
    }
    return "Failed cast at $context $key: $message";
  }
}

abstract class const Cast<T>() {
  T _cast(dynamic from, core.String context, dynamic key);
  T cast(dynamic from) => _cast(from, "toplevel", null);
}

class const AnyCast() extends Cast<dynamic> {
  dynamic _cast(dynamic from, core.String context, dynamic key) => from;
}

class const IntCast() extends Cast<core.int> {
  core.int _cast(dynamic from, core.String context, dynamic key) =>
      from is core.int
      ? from
      : throw new FailedCast(context, key, "$from is not an int");
}

class const DoubleCast() extends Cast<core.double> {
  core.double _cast(dynamic from, core.String context, dynamic key) =>
      from is core.double
      ? from
      : throw new FailedCast(context, key, "$from is not an double");
}

class const StringCast() extends Cast<core.String> {
  core.String _cast(dynamic from, core.String context, dynamic key) =>
      from is core.String
      ? from
      : throw new FailedCast(context, key, "$from is not a String");
}

class const BoolCast() extends Cast<core.bool> {
  core.bool _cast(dynamic from, core.String context, dynamic key) =>
      from is core.bool
      ? from
      : throw new FailedCast(context, key, "$from is not a bool");
}

class const Map<K, V>(final Cast<K> _key, final Cast<V> _value)
    extends Cast<core.Map<K, V>> {
  core.Map<K, V> _cast(dynamic from, core.String context, dynamic key) {
    if (from is core.Map) {
      return <K, V>{
        for (var key in from.keys)
          _key._cast(key, "map entry", key): _value._cast(
            from[key],
            "map entry",
            key,
          ),
      };
    }
    return throw new FailedCast(context, key, "not a map");
  }
}

class const StringMap<V>(final Cast<V> _value)
    extends Cast<core.Map<core.String, V>> {
  core.Map<core.String, V> _cast(
    dynamic from,
    core.String context,
    dynamic key,
  ) {
    if (from is core.Map) {
      return <core.String, V>{
        for (core.String key in from.keys)
          key: _value._cast(from[key], "map entry", key),
      };
    }
    return throw new FailedCast(context, key, "not a map");
  }
}

class const List<E>(final Cast<E> _entry) extends Cast<core.List<E>> {
  core.List<E> _cast(dynamic from, core.String context, dynamic key) {
    if (from is core.List) {
      var length = from.length;
      return [
        for (core.int i = 0; i < length; ++i)
          _entry._cast(from[i], "list entry", i),
      ];
    }
    return throw new FailedCast(context, key, "not a list");
  }
}

class const Keyed<K, V>(
  final core.Map<K, Cast<V>> _map, {
  final Cast<V>? _otherwise,
}) extends Cast<core.Map<K, V>> {
  core.Map<K, V> _cast(dynamic from, core.String context, dynamic key) {
    core.Map<K, V> result = {};
    if (from is core.Map) {
      for (K key in from.keys) {
        var entry = _map[key] ?? _otherwise;
        if (entry == null)
          throw new FailedCast("map entry", key, "key not found");
        result[key] = entry._cast(from[key], "map entry", key);
      }
      return result;
    }
    return throw new FailedCast(context, key, "not a map");
  }
}

class const OneOf<S, T>(final Cast<S> _left, final Cast<T> _right)
    extends Cast<dynamic> {
  dynamic _cast(dynamic from, core.String context, dynamic key) {
    try {
      return _left._cast(from, context, key);
    } on FailedCast {
      return _right._cast(from, context, key);
    }
  }
}

class const Apply<S, T>(final T Function(S) _transform, final Cast<S> _first)
    extends Cast<T> {
  T _cast(dynamic from, core.String context, dynamic key) =>
      _transform(_first._cast(from, context, key));
}

class const Future<E>(final Cast<E> _value) extends Cast<async.Future<E>> {
  async.Future<E> _cast(dynamic from, core.String context, dynamic key) {
    if (from is async.Future) {
      return from.then(_value.cast);
    }
    return throw new FailedCast(context, key, "not a Future");
  }
}

const any = AnyCast();
const bool = BoolCast();
const int = IntCast();
const double = DoubleCast();
const String = StringCast();
