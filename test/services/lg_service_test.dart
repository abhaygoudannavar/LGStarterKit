// Copyright 2024 LG-Flutter-StarterKit Authors
// Licensed under the Apache License, Version 2.0
// See LICENSE file for details.

import 'package:flutter_test/flutter_test.dart';
import 'package:lg_flutter_starter_kit/services/lg_service.dart';
import 'package:lg_flutter_starter_kit/services/ssh_service.dart';
import 'package:lg_flutter_starter_kit/core/errors/lg_exceptions.dart';
import 'package:lg_flutter_starter_kit/models/placemark_data.dart';

void main() {
  group('LGService', () {
    late LGService lgService;

    setUp(() {
      lgService = LGService.instance;
    });

    test('instance should be singleton', () {
      final instance1 = LGService.instance;
      final instance2 = LGService.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('isConnected should reflect SSHService state', () {
      expect(lgService.isConnected, isFalse);
    });

    test('navigateTo should throw when not connected', () async {
      expect(
        () => lgService.navigateTo(40.7, -74.0),
        throwsA(isA<LGNotConnectedException>()),
      );
    });

    test('displayPlacemark should throw when not connected', () async {
      expect(
        () => lgService.displayPlacemark(
          const PlacemarkData(
            latitude: 10,
            longitude: 20,
            name: 'Test',
          ),
        ),
        throwsA(isA<LGNotConnectedException>()),
      );
    });

    test('executeCleanup should throw when not connected', () async {
      expect(
        () => lgService.executeCleanup(),
        throwsA(isA<LGNotConnectedException>()),
      );
    });

    test('startOrbit should throw when not connected', () async {
      expect(
        () => lgService.startOrbit(10, 20),
        throwsA(isA<LGNotConnectedException>()),
      );
    });

    test('showBalloon should throw when not connected', () async {
      expect(
        () => lgService.showBalloon(10, 20, 'Title', '<p>html</p>'),
        throwsA(isA<LGNotConnectedException>()),
      );
    });

    test('SSHService singleton should be accessible', () {
      final ssh1 = SSHService.instance;
      final ssh2 = SSHService.instance;
      expect(identical(ssh1, ssh2), isTrue);
      expect(ssh1.isConnected, isFalse);
    });
  });
}
