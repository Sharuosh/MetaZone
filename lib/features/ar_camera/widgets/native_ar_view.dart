import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class NativeArView extends StatelessWidget {
  const NativeArView({
    super.key,
  });

  static const String viewType = 'metazone/native_ar_view';

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const ColoredBox(
        color: Colors.black,
      );
    }


    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory: (
          BuildContext context,
          PlatformViewController controller,
          ) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers:
          const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (
          PlatformViewCreationParams params,
          ) {
        final controller =
        PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: null,
          creationParamsCodec: const StandardMessageCodec(),
        );

        controller.addOnPlatformViewCreatedListener(
          params.onPlatformViewCreated,
        );

        controller.create();

        return controller;
      },
    );
  }
}
