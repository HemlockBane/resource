// ignore_for_file: lines_longer_than_80_chars

import 'package:resource/resource.dart';
import 'package:test/test.dart';

void main() {
  late ResourceTestFunctions resourceTestFunctions;

  setUp(() async {
    resourceTestFunctions = ResourceTestFunctions();
  });

  const successfulResponse = 'Successful Response';
  const defaultValueResponse = 'Default Success Response';

  test('Test if ${Resource<String, int>} return isSuccess', () async {
    final resourceResponse = await resourceTestFunctions.successRequest();
    final result = resourceResponse.isSuccess;

    expect(result, equals(true));
  });

  test('Test if ${Resource<String, int>} return isFailure', () async {
    final resourceResponse = await resourceTestFunctions.failedRequest();
    final result = resourceResponse.isFailure;

    expect(result, equals(true));
  });

  test(
      'Test valueOrDefault ${Resource<String, int>} returns success response onSuccess',
      () async {
    final resourceResponse = await resourceTestFunctions.successRequest();
    final result = resourceResponse.valueOrDefault(
      defaultValue: defaultValueResponse,
    );

    expect(result, equals(successfulResponse));
  });

  test(
      'Test valueOrDefault ${Resource<String, int>} returns defaultValue success onFailure',
      () async {
    final resourceResponse = await resourceTestFunctions.failedRequest();
    final result = resourceResponse.valueOrDefault(
      defaultValue: defaultValueResponse,
    );

    expect(result, equals(defaultValueResponse));
  });

  // test('Test valueOrElse $Resource returns success onFailure',
  //     () async {
  //   final resourceResponse = await failedRequest();
  //   final result = resourceResponse.valueOrElse(orElse: (_) => successfulResponse);

  //   expect(result, equals(successfulResponse));
  // });

  test('Test valueOrThrow  ${Resource<String, int>} returns success onSuccess',
      () async {
    final resourceResponse = await resourceTestFunctions.successRequest();
    final result = resourceResponse.valueOrThrow();

    expect(result, equals(successfulResponse));
  });

  // test(
  //     'Test valueOrThrow  ${Resource<String, int>} throws exception onFailure',
  //     () async {
  //   // when(failedRequest()).thenAnswer((_) => throw Exception());
  //   final resourceResponse = await resourceTestFunctions.failedRequest();

  //   final result = resourceResponse.valueOrThrow();

  //   expect(
  //     // resourceTestFunctions.failedRequest().then((_) => throw Exception(0)),
  //     result,
  //     throwsA(const TypeMatcher<Exception>()),
  //   );
  // });

  test('Test when of ${Resource<String, int>} calls onSuccess', () async {
    final resourceResponse = await resourceTestFunctions.successRequest();
    final result = resourceResponse.when(
      onFailure: (failureResponse) => failureResponse,
      onSuccess: (successResponse) => successResponse,
    );

    // if return type is String it means onSuccess was called
    expect(result.runtimeType, equals(String));
  });

  test('Test when of ${Resource<String, int>} calls onFailure', () async {
    final resourceResponse = await resourceTestFunctions.failedRequest();
    final result = resourceResponse.when(
      onFailure: (failureResponse) => failureResponse,
      onSuccess: (successResponse) => successResponse,
    );

    // if return type is int it means onFailure was called
    expect(result.runtimeType, equals(int));
  });

  test(
      'Test whenSuccess of ${Resource<String, int>} returns ${Success<String, int>} type',
      () async {
    final resourceResponse = await resourceTestFunctions.successRequest();
    final result =
        resourceResponse.whenSuccess(onSuccess: (success) => success);

    expect(result.runtimeType, equals(Success<String, int>));
  });

  test(
      'Test whenFailure of ${Resource<String, int>} returns ${Failure<String, int>} type',
      () async {
    final resourceResponse = await resourceTestFunctions.failedRequest();
    final result =
        resourceResponse.whenFailure(onFailure: (failure) => failure);

    expect(result.runtimeType, equals(Failure<String, int>));
  });

  test(
      'Test map of ${Resource<String, int>} returns transformed success type from $String to ${List<String>}',
      () async {
    final resourceResponse = await resourceTestFunctions.successRequest();
    final transformResult =
        resourceResponse.map<List<String>>((res) => res.split(''));

    expect(transformResult.runtimeType, equals(Success<List<String>, int>));
  });

  test(
      'Test map of ${Resource<String, int>} returns transformed failure type from $int to $String',
      () async {
    final resourceResponse = await resourceTestFunctions.failedRequest();
    final transformResult = resourceResponse.map<String>((res) => '0');

    expect(transformResult.runtimeType, equals(Failure<String, int>));
  });

  test(
      'Test guardMap of ${Resource<String, int>} returns transformed success type',
      () async {
    final resourceResponse = await resourceTestFunctions.successRequest();
    final transformResult =
        resourceResponse.guardMap<List<String>>((value) => value.split(''));

    expect(transformResult.runtimeType, equals(Success<List<String>, int>));
  });

  test(
      'Test guardMap of ${Resource<String, int>} returns transformed failure type',
      () async {
    final resourceResponse = await resourceTestFunctions.failedRequest();
    final transformResult = resourceResponse.guardMap<String>((value) => '');

    expect(transformResult.runtimeType, equals(Failure<String, int>));
  });
}

class ResourceTestFunctions {
  Future<Resource<String, int>> successRequest() async {
    try {
      final response = await Future.delayed(const Duration(seconds: 3), () {
        return 'Successful Response';
      });
      return Resource.success(response);
    } catch (e) {
      return Resource.failure(0);
    }
  }

  Future<Resource<String, int>> failedRequest() async {
    try {
      await Future.delayed(const Duration(seconds: 3), () {
        throw Exception(0);
      });
    } catch (e) {
      return Resource.failure(0);
    }
  }

  Future<Resource<String, int>> failedRequestThatThrows() async {
    await Future.delayed(const Duration(seconds: 3), () {
      throw Exception(0);
    });
  }
}
