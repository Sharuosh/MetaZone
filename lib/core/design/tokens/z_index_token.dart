import 'package:flutter/foundation.dart';

import 'design_token.dart';
import 'token.dart';

@immutable
class ZIndexToken extends Token<int> {
  const ZIndexToken({
    required super.name,
    required super.value,
    super.description,
    super.isDeprecated,
    super.alias,
  }) : super(
    category: TokenCategory.zIndex,
  );

  @override
  ZIndexToken copyWith({
    String? name,
    int? value,
    String? description,
    bool? isDeprecated,
    String? alias,
    TokenCategory? category,
  }) {
    return ZIndexToken(
      name: name ?? this.name,
      value: value ?? this.value,
      description: description ?? this.description,
      isDeprecated: isDeprecated ?? this.isDeprecated,
      alias: alias ?? this.alias,
    );
  }

  int get index => value;
}

abstract final class ZIndexScale {
  ZIndexScale._();

  static const background = 0;
  static const content = 100;
  static const sticky = 200;
  static const navigation = 300;
  static const floatingAction = 400;
  static const dropdown = 500;
  static const appBar = 600;
  static const bottomSheet = 700;
  static const dialog = 800;
  static const snackbar = 900;
  static const tooltip = 1000;
  static const overlay = 1100;
  static const loading = 1200;
  static const notification = 1300;
  static const debug = 9999;
}

abstract final class ZIndexTokens {
  ZIndexTokens._();

  static final background = ZIndexToken(
    name: 'z.background',
    value: ZIndexScale.background,
  );

  static final content = ZIndexToken(
    name: 'z.content',
    value: ZIndexScale.content,
  );

  static final sticky = ZIndexToken(
    name: 'z.sticky',
    value: ZIndexScale.sticky,
  );

  static final navigation = ZIndexToken(
    name: 'z.navigation',
    value: ZIndexScale.navigation,
  );

  static final floatingAction = ZIndexToken(
    name: 'z.floatingAction',
    value: ZIndexScale.floatingAction,
  );

  static final dropdown = ZIndexToken(
    name: 'z.dropdown',
    value: ZIndexScale.dropdown,
  );

  static final appBar = ZIndexToken(
    name: 'z.appBar',
    value: ZIndexScale.appBar,
  );

  static final bottomSheet = ZIndexToken(
    name: 'z.bottomSheet',
    value: ZIndexScale.bottomSheet,
  );

  static final dialog = ZIndexToken(
    name: 'z.dialog',
    value: ZIndexScale.dialog,
  );

  static final snackbar = ZIndexToken(
    name: 'z.snackbar',
    value: ZIndexScale.snackbar,
  );

  static final tooltip = ZIndexToken(
    name: 'z.tooltip',
    value: ZIndexScale.tooltip,
  );

  static final overlay = ZIndexToken(
    name: 'z.overlay',
    value: ZIndexScale.overlay,
  );

  static final loading = ZIndexToken(
    name: 'z.loading',
    value: ZIndexScale.loading,
  );

  static final notification = ZIndexToken(
    name: 'z.notification',
    value: ZIndexScale.notification,
  );

  static final debug = ZIndexToken(
    name: 'z.debug',
    value: ZIndexScale.debug,
  );

  static final List<ZIndexToken> values = [
    background,
    content,
    sticky,
    navigation,
    floatingAction,
    dropdown,
    appBar,
    bottomSheet,
    dialog,
    snackbar,
    tooltip,
    overlay,
    loading,
    notification,
    debug,
  ];

  static void register() {
    DesignTokens.registerAll(values);
  }
}

extension ZIndexTokenExtension on ZIndexToken {
  int operator +(int offset) => value + offset;

  int operator -(int offset) => value - offset;

  bool get isOverlay => value >= ZIndexScale.overlay;

  bool get isModal => value >= ZIndexScale.dialog;

  bool get isFloating => value >= ZIndexScale.floatingAction;

  bool get isBackground => value == ZIndexScale.background;
}