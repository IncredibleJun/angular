@TestOn('browser')

import 'package:test/test.dart';
import 'package:angular/angular.dart';
import 'package:angular_test/angular_test.dart';

import '721_view_event_crash_test.template.dart' as ng_generated;

// Source: https://github.com/dart-lang/angular/issues/721.
//
// All exceptions thrown in event listeners should be caught for logging.
void main() {
  ng_generated.initReflector();

  test('should be able to catch a thrown event listener error', () async {
    final testBed = new NgTestBed<ComponentWithHostEventThatThrows>();
    final fixture = await testBed.create();
    expect(
      fixture.update((_) => fixture.rootElement.click()),
      throwsIntentional,
    );
  });
}

@Component(
  selector: 'test',
  template: '',
  // TODO(b/71710685): Change to `Visibility.local` to reduce code size.
  visibility: Visibility.all,
)
class ComponentWithHostEventThatThrows {
  @HostListener('click')
  void onClick() => throw new IntentionalError();
}

class IntentionalError extends Error {}

final throwsIntentional = throwsA(const isInstanceOf<IntentionalError>());
