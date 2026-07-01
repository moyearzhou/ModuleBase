import 'package:flutter_test/flutter_test.dart';
import 'package:module_base/routing/routing.dart';

void main() {
  group('ZPRouteSpec validation', () {
    const syncSpec = ZPRouteSpec(
      route: 'sync.home',
      path: '/sync/home',
      loginPolicy: ZPLoginPolicy.zoteroRequired,
      fallbackType: ZPFallbackType.login,
      params: {
        'syncSource': ZPRouteParamSpec(
          type: ZPRouteParamType.string,
          defaultValue: 'route',
          allowedValues: {'manual', 'startup', 'route', 'legacy'},
        ),
      },
    );

    test('uses defaults for optional params', () {
      final result = syncSpec.validate(const {});

      expect(result.valid, isTrue);
      expect(result.params['syncSource'], 'route');
    });

    test('rejects enum values outside the route spec', () {
      final result = syncSpec.validate(const {'syncSource': 'push'});

      expect(result.valid, isFalse);
      expect(result.reason, 'invalidParam');
      expect(result.paramKey, 'syncSource');
    });

    test('reports missing required params before page construction', () {
      const modifySpec = ZPRouteSpec(
        route: 'library.collection.modify',
        path: '/library/collection/modify',
        loginPolicy: ZPLoginPolicy.zoteroRequired,
        fallbackType: ZPFallbackType.login,
        params: {
          'collectionKey': ZPRouteParamSpec(
            type: ZPRouteParamType.string,
            required: true,
          ),
        },
      );

      final result = modifySpec.validate(const {});

      expect(result.valid, isFalse);
      expect(result.reason, 'missingRequiredParam');
      expect(result.paramKey, 'collectionKey');
    });

    test('keeps route source minimal for phase one', () {
      const request = ZPRouteRequest(
        route: 'app.settings',
        routeSource: ZPRouteSource.legacy,
        legacyRoute: 'settingsPage',
      );

      expect(request.version, 1);
      expect(request.routeSource, ZPRouteSource.legacy);
      expect(ZPRouteSource.values, [
        ZPRouteSource.internal,
        ZPRouteSource.legacy,
      ]);
    });
  });
}
