import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velvet_mobile/core/theme/velvet_editorial_colors.dart';
import 'package:velvet_mobile/core/theme/velvet_tokens.dart';
import 'package:velvet_mobile/core/widgets/kinetic_text.dart';
import 'package:velvet_mobile/core/widgets/velvet_editorial_sheet.dart';
import 'package:velvet_mobile/core/widgets/velvet_filter_chip.dart';
import 'package:velvet_mobile/core/widgets/velvet_widgets.dart';
import 'package:velvet_mobile/features/discover/discover_api.dart';
import 'package:velvet_mobile/l10n/generated/app_localizations.dart';

const kAddisAreas = ['Bole', 'Piazza', 'Kazanchis'];
const kLanguageCodes = ['am', 'en'];
const kIntents = ['serious', 'social'];

Future<void> showFiltersSheet(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  DiscoverPreferences prefs;
  try {
    prefs = await ref.read(discoverApiProvider).preferences();
  } catch (_) {
    prefs = DiscoverPreferences(minAge: 21, maxAge: 55, maxDistanceKm: 50);
  }

  var minAge = prefs.minAge.toDouble();
  var maxAge = prefs.maxAge.toDouble();
  var distance = prefs.maxDistanceKm.toDouble();
  final areas = prefs.cities
      .map((c) => c.trim())
      .where((c) => kAddisAreas.any((a) => a.toLowerCase() == c.toLowerCase()))
      .map(
        (c) => kAddisAreas.firstWhere(
          (a) => a.toLowerCase() == c.toLowerCase(),
        ),
      )
      .toSet();
  final extraCities = prefs.cities
      .where(
        (c) => !kAddisAreas.any((a) => a.toLowerCase() == c.toLowerCase()),
      )
      .toList();
  final languages = prefs.preferredLanguages.map((e) => e.toLowerCase()).toSet();
  final intents = prefs.intents.map((e) => e.toLowerCase()).toSet();
  var verifiedOnly = prefs.verifiedOnly;

  if (!context.mounted) return;
  await showEditorialSheet<void>(
    context: context,
    initialSize: 0.92,
    builder: (context, scrollController) {
      return StatefulBuilder(
        builder: (context, setLocal) {
          return ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              VelvetTokens.pageInset,
              VelvetTokens.space16,
              VelvetTokens.pageInset,
              VelvetTokens.space32 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              KineticEyebrow(
                label: l10n.navBrowse,
                icon: Icons.tune_rounded,
              ),
              const SizedBox(height: VelvetTokens.space8),
              KineticText(
                text: l10n.filtersTitle,
                style: GoogleFonts.syne(
                  fontSize: VelvetTokens.displaySmall,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  height: 0.95,
                  color: context.velvet.ink,
                ),
              ),
              const SizedBox(height: VelvetTokens.space32),
              VelvetSliderSection(
                label: l10n.ageRange,
                valueLabel: '${minAge.round()} – ${maxAge.round()}',
                child: RangeSlider(
                  values: RangeValues(minAge, maxAge),
                  min: 21,
                  max: 70,
                  divisions: 49,
                  activeColor: VelvetTokens.ember,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setLocal(() {
                      minAge = v.start;
                      maxAge = v.end;
                    });
                  },
                ),
              ),
              const SizedBox(height: VelvetTokens.space24),
              VelvetSliderSection(
                label: l10n.maxDistance,
                valueLabel: '${distance.round()} km',
                child: Slider(
                  value: distance,
                  min: 5,
                  max: 200,
                  divisions: 39,
                  activeColor: VelvetTokens.ember,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setLocal(() => distance = v);
                  },
                ),
              ),
              const SizedBox(height: VelvetTokens.space24),
              Text(
                l10n.filterAreas.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: VelvetTokens.labelCaps,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: VelvetTokens.muted,
                ),
              ),
              const SizedBox(height: VelvetTokens.space12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: kAddisAreas.map((area) {
                  final selected = areas.contains(area);
                  return VelvetFilterChip(
                    label: area,
                    selected: selected,
                    icon: Icons.location_on_outlined,
                    onChanged: (v) => setLocal(() {
                      if (v) {
                        areas.add(area);
                      } else {
                        areas.remove(area);
                      }
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: VelvetTokens.space24),
              Text(
                l10n.filterLanguages.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: VelvetTokens.labelCaps,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: VelvetTokens.muted,
                ),
              ),
              const SizedBox(height: VelvetTokens.space12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  VelvetFilterChip(
                    label: l10n.languageAmharic,
                    selected: languages.contains('am'),
                    onChanged: (v) => setLocal(() {
                      if (v) {
                        languages.add('am');
                      } else {
                        languages.remove('am');
                      }
                    }),
                  ),
                  VelvetFilterChip(
                    label: l10n.languageEnglish,
                    selected: languages.contains('en'),
                    onChanged: (v) => setLocal(() {
                      if (v) {
                        languages.add('en');
                      } else {
                        languages.remove('en');
                      }
                    }),
                  ),
                ],
              ),
              const SizedBox(height: VelvetTokens.space24),
              Text(
                l10n.filterIntent.toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontSize: VelvetTokens.labelCaps,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: VelvetTokens.muted,
                ),
              ),
              const SizedBox(height: VelvetTokens.space12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  VelvetFilterChip(
                    label: l10n.intentSerious,
                    selected: intents.contains('serious'),
                    onChanged: (v) => setLocal(() {
                      if (v) {
                        intents.add('serious');
                      } else {
                        intents.remove('serious');
                      }
                    }),
                  ),
                  VelvetFilterChip(
                    label: l10n.intentSocial,
                    selected: intents.contains('social'),
                    onChanged: (v) => setLocal(() {
                      if (v) {
                        intents.add('social');
                      } else {
                        intents.remove('social');
                      }
                    }),
                  ),
                ],
              ),
              const SizedBox(height: VelvetTokens.space20),
              VelvetTactileSlider(
                label: l10n.filterVerifiedOnly,
                initialValue: verifiedOnly,
                onChanged: (v) => setLocal(() => verifiedOnly = v),
              ),
              const SizedBox(height: VelvetTokens.space32),
              VelvetButton(
                label: l10n.save,
                onPressed: () async {
                  final cities = [...areas, ...extraCities];
                  await ref.read(discoverApiProvider).updatePreferences(
                        minAge: minAge.round(),
                        maxAge: maxAge.round(),
                        maxDistanceKm: distance.round(),
                        cities: cities,
                        preferredLanguages: languages.toList(),
                        intents: intents.toList(),
                        verifiedOnly: verifiedOnly,
                      );
                  ref.invalidate(discoverPrefsProvider);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    },
  );
}
