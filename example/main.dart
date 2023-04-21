import 'package:resource/resource.dart';

void main(List<String> args) {
  final resource = Resource.guardSync(
    function: () => <int>[].sublist(0, 6),
    onFailure: (_, __) => false,
  );

  final list = resource
      .mapFailure((throwable) => true)
      .recover((throwable) => [])
      .valueOrNull;

  final b = list
      ?.where((value) => value != 0)
      .toList()
      .map((value) => 'my $value')
      .forEach(print);
}
