import 'package:flutter/material.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/editorial_background.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';

/// Layered page scaffold — atmospheric background + motion + safe content zone.
class LayeredPageScaffold extends StatelessWidget {
  const LayeredPageScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.safeArea = true,
    this.atmosphereIntensity = 1,
    this.variant = EditorialVariant.member,
    this.extendBody = false,
    this.bottomInset = VelvetTokens.plinthClearance,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool safeArea;
  final double atmosphereIntensity;
  final EditorialVariant variant;
  final bool extendBody;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    Widget content = body;
    if (safeArea) {
      content = SafeArea(
        bottom: !extendBody,
        child: Padding(
          padding: extendBody
              ? EdgeInsets.zero
              : EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 0),
          child: content,
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.velvet.surface,
      extendBody: extendBody,
      extendBodyBehindAppBar: appBar != null,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          EditorialAtmosphere(
            intensity: atmosphereIntensity,
            variant: variant,
          ),
          VelvetPageMotion(child: content),
        ],
      ),
    );
  }
}
