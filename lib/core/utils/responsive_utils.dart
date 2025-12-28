import 'package:flutter/material.dart';

/// Screen size breakpoints following Material Design guidelines
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1800;
}

/// Device type based on screen width
enum DeviceType { mobile, tablet, desktop, largeDesktop }

/// Responsive utilities for adaptive layouts
class ResponsiveUtils {
  final BuildContext context;

  ResponsiveUtils(this.context);

  /// Get screen width
  double get width => MediaQuery.of(context).size.width;

  /// Get screen height
  double get height => MediaQuery.of(context).size.height;

  /// Get device type based on width
  DeviceType get deviceType {
    if (width < Breakpoints.mobile) return DeviceType.mobile;
    if (width < Breakpoints.tablet) return DeviceType.tablet;
    if (width < Breakpoints.desktop) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  /// Check if device is mobile
  bool get isMobile => width < Breakpoints.mobile;

  /// Check if device is tablet
  bool get isTablet =>
      width >= Breakpoints.mobile && width < Breakpoints.desktop;

  /// Check if device is desktop
  bool get isDesktop => width >= Breakpoints.desktop;

  /// Check if device is large desktop
  bool get isLargeDesktop => width >= Breakpoints.largeDesktop;

  /// Get responsive value based on screen size
  T responsive<T>({required T mobile, T? tablet, T? desktop, T? largeDesktop}) {
    if (width >= Breakpoints.largeDesktop && largeDesktop != null) {
      return largeDesktop;
    }
    if (width >= Breakpoints.desktop && desktop != null) {
      return desktop;
    }
    if (width >= Breakpoints.mobile && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get responsive padding
  EdgeInsets get horizontalPadding => EdgeInsets.symmetric(
    horizontal: responsive(
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
      largeDesktop: 48.0,
    ),
  );

  /// Get responsive spacing
  double get spacing =>
      responsive(mobile: 16.0, tablet: 24.0, desktop: 32.0, largeDesktop: 40.0);

  /// Get responsive content max width
  double? get contentMaxWidth => responsive(
    mobile: null,
    tablet: 700.0,
    desktop: 1000.0,
    largeDesktop: 1200.0,
  );

  /// Get number of columns for grid layouts
  int get gridColumns =>
      responsive(mobile: 1, tablet: 2, desktop: 2, largeDesktop: 3);

  /// Get responsive font size multiplier
  double get fontSizeMultiplier =>
      responsive(mobile: 1.0, tablet: 1.05, desktop: 1.1, largeDesktop: 1.15);

  /// Scale font size responsively
  double fontSize(double baseSize) => baseSize * fontSizeMultiplier;

  /// Get responsive icon size
  double get iconSize =>
      responsive(mobile: 24.0, tablet: 28.0, desktop: 32.0, largeDesktop: 36.0);

  /// Get responsive card elevation
  double get cardElevation =>
      responsive(mobile: 2.0, tablet: 4.0, desktop: 6.0, largeDesktop: 8.0);

  /// Get responsive border radius
  double get borderRadius =>
      responsive(mobile: 12.0, tablet: 14.0, desktop: 16.0, largeDesktop: 18.0);

  /// Center content with max width on larger screens
  Widget centerMaxWidth({required Widget child, double? maxWidth}) {
    final width = maxWidth ?? contentMaxWidth;
    if (width == null) return child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: child,
      ),
    );
  }

  /// Create responsive grid with dynamic columns
  Widget responsiveGrid({
    required List<Widget> children,
    double spacing = 16.0,
    double runSpacing = 16.0,
  }) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children
          .map(
            (child) =>
                SizedBox(width: _getGridItemWidth(spacing), child: child),
          )
          .toList(),
    );
  }

  double _getGridItemWidth(double spacing) {
    final columns = gridColumns;
    if (columns == 1) return width;
    final totalSpacing = spacing * (columns - 1);
    return (width - totalSpacing - horizontalPadding.horizontal) / columns;
  }
}

/// Extension to easily access responsive utils from BuildContext
extension ResponsiveExtension on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils(this);
}
