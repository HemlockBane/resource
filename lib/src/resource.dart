

import 'package:meta/meta.dart';

/// A wrapper that encapsulates either a value or a throwable
abstract class Resource<S, F extends Object> {
  const Resource();

  /// Returns an instance that encapsulates a value as a success.
  factory Resource.success(S value) = Success<S, F>;

  /// Returns an instance that encapsulates a throwable as a failure.
  factory Resource.failure(F throwable) = Failure<S, F>;

  // Shorthand for try/catch
  //===========================================================================

  /// Runs [function] and returns an instance that encapsulates a value
  /// of type [V]
  ///
  /// If an error occurred while running [function], it returns an instance
  /// that encapsulates the error as type [T].
  ///
  /// [onFailure] can be used to map/process
  /// the error and stacktrace to any throwable of type [T] before
  /// the failure instance is returned
  static Future<Resource<V, T>> guardRun<V, T extends Object>({
    required Future<V> Function() function,
    T Function(Object throwable, StackTrace stackTrace)? onFailure,
  }) async {
    try {
      return Resource.success(await function.call());
    } catch (err, stacktrace) {
      if (onFailure != null) {
        final throwable = onFailure.call(err, stacktrace);
        return Resource.failure(throwable);
      }
      return Resource.failure(err as T);
    }
  }

  /// Like guardRun, but for streams
  static Stream<Resource<V, T>> guardEmit<V, T extends Object>({
    required Stream<V> Function() function,
    T Function(Object throwable, StackTrace stackTrace)? onFailure,
  }) async* {
    try {
      await for (final event in function.call()) {
        yield Resource.success(event);
      }
    } catch (err, stacktrace) {
      if (onFailure != null) {
        final throwable = onFailure.call(err, stacktrace);
        yield Resource.failure(throwable);
      }
      yield Resource.failure(err as T);
    }
  }

  // Discovering the status
  //===========================================================================

  /// Whether this instance represents a successful outcome.
  ///
  /// In this case [isFailure] returns false.
  bool get isSuccess => this is Success<S, F>;

  /// Whether this instance represents a failed outcome.
  ///
  ///In this case [isSuccess] returns false.
  bool get isFailure => this is Failure<S, F>;

  // Getting values and exceptions
  //===========================================================================

  /// The encapsulated value if this instance represents a success.
  ///
  /// If this instance represents a failure, it returns null
  S? get valueOrNull;

  /// The encapsulated throwable if this instance represents a failure.
  ///
  /// If this instance represents a success, it returns null
  F? get throwableOrNull;

  /// Returns the encapsulated value if this instance represents a success.
  ///
  /// If this instance represents a failure, it returns the [defaultValue]
  S valueOrDefault({required S defaultValue});

  /// Returns the encapsulated value if this instance represents a success.
  ///
  /// If this instance represents a failure, it returns the result of
  /// [ orElse]
  S valueOrElse({required S Function(F throwable) orElse});

  /// Returns the encapsulated value if this instance represents a success.
  ///
  /// If this instance represents a failure, it throws the
  /// encapsulated throwable
  S valueOrThrow();

  // Handling events
  //===========================================================================

  /// Returns the result of [onSuccess] for the encapsulated value if this
  /// instance represents a success.
  ///
  /// If this instance represents a failure, it returns
  /// the result of [onFailure]
  T when<T>({
    required T Function(S value) onSuccess,
    required T Function(F throwable) onFailure,
  });

  /// Runs [onSuccess] on the encapsulated value if
  /// this instance represents a success and returns the original instance
  ///  unchanged.
  Resource<S, F> whenSuccess({required void Function(S value) onSuccess});

  /// Runs [onFailure] on the encapsulated throwable if
  /// this instance represents failure and returns the original instance
  /// unchanged.
  Resource<S, F> whenFailure({required void Function(F throwable) onFailure});

// Transforming values and exceptions
//===========================================================================
// Coming soon...
}

/// A wrapper that encapsulates a value
@immutable
class Success<S, F extends Object> extends Resource<S, F> {
  const Success(this._value);

  /// The encapsulated value
  final S _value;

  @override
  S get valueOrNull => _value;

  @override
  F? get throwableOrNull => null;

  @override
  S valueOrDefault({required S defaultValue}) => _value;

  @override
  S valueOrElse({required S Function(F throwable) orElse}) => _value;

  @override
  S valueOrThrow() => _value;

  @override
  T when<T>({
    required T Function(S value) onSuccess,
    required T Function(F failure) onFailure,
  }) {
    return onSuccess(_value);
  }

  @override
  Resource<S, F> whenSuccess({
    required void Function(S value) onSuccess,
  }) {
    onSuccess(_value);
    return this;
  }

  @override
  Resource<S, F> whenFailure({
    required void Function(F throwable) onFailure,
  }) {
    return this;
  }

  @override
  bool operator ==(Object other) =>
      (other is Success) && other._value == _value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Success($_value)';
}

/// A wrapper that encapsulates a throwable
@immutable
class Failure<S, F extends Object> extends Resource<S, F> {
  const Failure(this._throwable);

  /// The encapsulated throwable
  final F _throwable;

  @override
  S? get valueOrNull => null;

  @override
  F? get throwableOrNull => _throwable;

  @override
  S valueOrDefault({required S defaultValue}) => defaultValue;

  @override
  S valueOrElse({required S Function(F failure) orElse}) => orElse(_throwable);

  @override
  S valueOrThrow() {
    if (_throwable is Error) {
      throw _throwable as Error;
    }
    if (_throwable is Exception) {
      throw _throwable as Exception;
    }

    throw Exception(
      'You can only throw an error or an exception',
    );
  }

  @override
  T when<T>({
    required T Function(S value) onSuccess,
    required T Function(F failure) onFailure,
  }) {
    return onFailure(_throwable);
  }

  @override
  Resource<S, F> whenSuccess({
    required void Function(S value) onSuccess,
  }) {
    return this;
  }

  @override
  Resource<S, F> whenFailure({
    required void Function(F throwable) onFailure,
  }) {
    onFailure(_throwable);
    return this;
  }

  @override
  bool operator ==(Object other) =>
      (other is Failure) && other._throwable == _throwable;

  @override
  int get hashCode => _throwable.hashCode;

  @override
  String toString() => 'Failure($_throwable)';
}
