import re

with open('lib/features/discover/listing_catalog.dart', 'r') as f:
    text = f.read()

# Update _ListingHero signature
h_sig = r'''class _ListingHero extends StatelessWidget {
  const _ListingHero({
    required this.listing,
    this.rateLabel,
    this.request = false,
  });'''
h_sig_new = '''class _ListingHero extends StatelessWidget {
  const _ListingHero({
    required this.listing,
    this.rateLabel,
    this.request = false,
    this.aspectRatio = 1.08,
  });
  final double aspectRatio;'''
text = text.replace(h_sig, h_sig_new)

# Update _ListingHero AspectRatio
text = text.replace(
'''    return AspectRatio(
      aspectRatio: 1.08,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(VelvetTheme.radiusMd),
        child: Stack(
          fit: StackFit.expand,
          children: [
            VelvetImageCarousel(
              photoUrls: listing.photoUrls,
              aspectRatio: 1.08,''',
'''    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(VelvetTheme.radiusLg),
        child: Stack(
          fit: StackFit.expand,
          children: [
            VelvetImageCarousel(
              photoUrls: listing.photoUrls,
              aspectRatio: aspectRatio,'''
)

# Replace the PerformerListingTile layout
t_sig = r'''                  _ListingHero(
                    listing: listing,
                    rateLabel: listing.sessionRateEtb == null
                        ? null
                        : l10n.rateSessionLabel(listing.sessionRateEtb!),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          [
                            listing.name,
                            if (listing.age != null) '${listing.age}',
                          ].join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.8,
                            height: 1,
                          ),
                        ),
                      ),
                      if (listing.verified) ...[
                        const SizedBox(width: 8),
                        const VelvetVerifiedBadge(compact: true),
                      ],
                    ],
                  ),'''
t_sig_new = '''                  _ListingHero(
                    listing: listing,
                    aspectRatio: index % 2 == 0 ? 0.75 : 1.2,
                    rateLabel: listing.sessionRateEtb == null
                        ? null
                        : l10n.rateSessionLabel(listing.sessionRateEtb!),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          [
                            listing.name,
                            if (listing.age != null) '${listing.age}',
                          ].join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.syne(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -2.0,
                            height: 0.95,
                          ),
                        ),
                      ),
                      if (listing.verified) ...[
                        const SizedBox(width: 8),
                        const VelvetVerifiedBadge(compact: true),
                      ],
                    ],
                  ),'''
text = text.replace(t_sig, t_sig_new)

with open('lib/features/discover/listing_catalog.dart', 'w') as f:
    f.write(text)

