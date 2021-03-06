@TestOn('browser')

import 'dart:async';

import 'package:async/async.dart' show StreamGroup;
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_router/testing.dart';
import 'package:angular_test/angular_test.dart';
import 'package:test/test.dart';

// ingore: uri_has_not_been_generated
import 'on_navigation_start_test.template.dart' as ng;

void main() {
  ng.initReflector();

  tearDown(disposeAnyRunningTest);

  group('Router.onNavigationStart', () {
    test('fires on navigation', () async {
      final testBed = new NgTestBed<TestComponent>();
      final testFixture = await testBed.create();
      final router = testFixture.assertOnlyInstance.router;
      await expectLater(
        navigate(router, '/destination'),
        emitsInOrder([
          '/destination', // Router.onNavigationStart,
          NavigationResult.SUCCESS,
        ]),
      );
    });

    test("doesn't fire when navigation is prohibited", () async {
      final testBed = new NgTestBed<TestComponent>()
          .addProviders([new Provider(canNavigateToken, useValue: false)]);
      final testFixture = await testBed.create();
      final router = testFixture.assertOnlyInstance.router;
      await expectLater(
        navigate(router, '/destination'),
        emits(NavigationResult.BLOCKED_BY_GUARD),
      );
    });

    test('fires when deactivation is prohibited', () async {
      final testBed = new NgTestBed<TestComponent>()
          .addProviders([new Provider(canDeactivateToken, useValue: false)]);
      final testFixture = await testBed.create();
      final router = testFixture.assertOnlyInstance.router;
      await expectLater(
        navigate(router, '/destination'),
        emitsInOrder([
          '/destination', // Router.onNavigationStart
          NavigationResult.BLOCKED_BY_GUARD,
        ]),
      );
    });

    test('fires only once on redirect', () async {
      final testBed = new NgTestBed<TestComponent>();
      final testFixture = await testBed.create();
      final router = testFixture.assertOnlyInstance.router;
      await expectLater(
        navigate(router, '/redirection'),
        emitsInOrder([
          '/redirection', // Router.onNavigationStart
          NavigationResult.SUCCESS,
        ]),
      );
    });
  });
}

Stream navigate(Router router, String path) => StreamGroup.merge([
      router.onNavigationStart,
      router.navigate(path).asStream(),
    ]);

const canDeactivateToken = const OpaqueToken<bool>('canDeactivateToken');
const canNavigateToken = const OpaqueToken<bool>('canNavigateToken');

@Component(
  selector: 'home', template: '',
  // TODO(b/71710685): Change to `Visibility.local` to reduce code size.
  visibility: Visibility.all,
)
class HomeComponent implements CanDeactivate, CanNavigate {
  final bool _canDeactivate;
  final bool _canNavigate;

  HomeComponent(
    @Optional() @Inject(canDeactivateToken) bool canDeactivate,
    @Optional() @Inject(canNavigateToken) bool canNavigate,
  )
      : _canDeactivate = canDeactivate ?? true,
        _canNavigate = canNavigate ?? true;

  @override
  Future<bool> canDeactivate(_, __) => new Future.value(_canDeactivate);

  @override
  Future<bool> canNavigate() => new Future.value(_canNavigate);
}

@Component(
  selector: 'destination', template: '',
  // TODO(b/71710685): Change to `Visibility.local` to reduce code size.
  visibility: Visibility.all,
)
class DestinationComponent {}

@Component(
  selector: 'test',
  template: '<router-outlet [routes]="routes"></router-outlet>',
  directives: const [RouterOutlet],
  providers: const [routerProvidersTest],
  // TODO(b/71710685): Change to `Visibility.local` to reduce code size.
  visibility: Visibility.all,
)
class TestComponent {
  final Router router;
  final List<RouteDefinition> routes = [
    new RouteDefinition(
      path: 'home',
      component: ng.HomeComponentNgFactory,
      useAsDefault: true,
    ),
    new RouteDefinition(
      path: 'destination',
      component: ng.DestinationComponentNgFactory,
    ),
    new RouteDefinition.redirect(
      path: 'redirection',
      redirectTo: 'destination',
    ),
  ];

  TestComponent(this.router);
}
