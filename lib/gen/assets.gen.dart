// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/Location.svg
  SvgGenImage get location => const SvgGenImage('assets/icons/Location.svg');

  /// File path: assets/icons/ai-game.svg
  SvgGenImage get aiGame => const SvgGenImage('assets/icons/ai-game.svg');

  /// File path: assets/icons/book.svg
  SvgGenImage get book => const SvgGenImage('assets/icons/book.svg');

  /// File path: assets/icons/calender.svg
  SvgGenImage get calender => const SvgGenImage('assets/icons/calender.svg');

  /// File path: assets/icons/camera.svg
  SvgGenImage get camera => const SvgGenImage('assets/icons/camera.svg');

  /// File path: assets/icons/chatting.svg
  SvgGenImage get chatting => const SvgGenImage('assets/icons/chatting.svg');

  /// File path: assets/icons/coffee-mug.svg
  SvgGenImage get coffeeMug => const SvgGenImage('assets/icons/coffee-mug.svg');

  /// File path: assets/icons/coffee.svg
  SvgGenImage get coffee => const SvgGenImage('assets/icons/coffee.svg');

  /// File path: assets/icons/coffee_color.svg
  SvgGenImage get coffeeColor =>
      const SvgGenImage('assets/icons/coffee_color.svg');

  /// File path: assets/icons/community.svg
  SvgGenImage get community => const SvgGenImage('assets/icons/community.svg');

  /// File path: assets/icons/dumbbell-2.svg
  SvgGenImage get dumbbell2 => const SvgGenImage('assets/icons/dumbbell-2.svg');

  /// File path: assets/icons/dumbbell.svg
  SvgGenImage get dumbbell => const SvgGenImage('assets/icons/dumbbell.svg');

  /// File path: assets/icons/earth.svg
  SvgGenImage get earth => const SvgGenImage('assets/icons/earth.svg');

  /// File path: assets/icons/film-wheel.svg
  SvgGenImage get filmWheel => const SvgGenImage('assets/icons/film-wheel.svg');

  /// File path: assets/icons/gift.svg
  SvgGenImage get gift => const SvgGenImage('assets/icons/gift.svg');

  /// File path: assets/icons/gradient-check.svg
  SvgGenImage get gradientCheck =>
      const SvgGenImage('assets/icons/gradient-check.svg');

  /// File path: assets/icons/group.svg
  SvgGenImage get group => const SvgGenImage('assets/icons/group.svg');

  /// File path: assets/icons/ice-cream.svg
  SvgGenImage get iceCream => const SvgGenImage('assets/icons/ice-cream.svg');

  /// File path: assets/icons/kitty.svg
  SvgGenImage get kitty => const SvgGenImage('assets/icons/kitty.svg');

  /// File path: assets/icons/make-up-brash.svg
  SvgGenImage get makeUpBrash =>
      const SvgGenImage('assets/icons/make-up-brash.svg');

  /// File path: assets/icons/message.svg
  SvgGenImage get message => const SvgGenImage('assets/icons/message.svg');

  /// File path: assets/icons/music.svg
  SvgGenImage get music => const SvgGenImage('assets/icons/music.svg');

  /// File path: assets/icons/music_color.svg
  SvgGenImage get musicColor =>
      const SvgGenImage('assets/icons/music_color.svg');

  /// File path: assets/icons/nano-technology.svg
  SvgGenImage get nanoTechnology =>
      const SvgGenImage('assets/icons/nano-technology.svg');

  /// File path: assets/icons/organic-food.svg
  SvgGenImage get organicFood =>
      const SvgGenImage('assets/icons/organic-food.svg');

  /// File path: assets/icons/paint-board.svg
  SvgGenImage get paintBoard =>
      const SvgGenImage('assets/icons/paint-board.svg');

  /// File path: assets/icons/unchecked-circle.svg
  SvgGenImage get uncheckedCircle =>
      const SvgGenImage('assets/icons/unchecked-circle.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
    location,
    aiGame,
    book,
    calender,
    camera,
    chatting,
    coffeeMug,
    coffee,
    coffeeColor,
    community,
    dumbbell2,
    dumbbell,
    earth,
    filmWheel,
    gift,
    gradientCheck,
    group,
    iceCream,
    kitty,
    makeUpBrash,
    message,
    music,
    musicColor,
    nanoTechnology,
    organicFood,
    paintBoard,
    uncheckedCircle,
  ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/open_for_coffee.png
  AssetGenImage get openForCoffee =>
      const AssetGenImage('assets/images/open_for_coffee.png');

  /// File path: assets/images/profile_picture.jpg
  AssetGenImage get profilePicture =>
      const AssetGenImage('assets/images/profile_picture.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [openForCoffee, profilePicture];
}

class Assets {
  const Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
