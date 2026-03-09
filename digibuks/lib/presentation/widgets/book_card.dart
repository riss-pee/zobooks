import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

import '../widgets/glass_container.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onTap;
  final bool showWishlistButton;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.showWishlistButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      blur: 10,
      opacity: 0.1,
      borderRadius: 20,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Book Cover
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Container(
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  child: book.coverImage != null
                      ? Image.network(
                          book.coverImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
            ),
            // Book Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Author
                  Text(
                    book.authorName ?? 'Unknown Author',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      if (book.rating != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book.rating!.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      // Price
                      _buildPrice(context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        // Use a single neutral surface color following Material 3 (no gradients)
        color: AppTheme.primaryColor.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book,
          size: 64,
          color: AppTheme.primaryColor.withAlpha(179),
        ),
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    if (book.type == AppConstants.bookTypeFree) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withAlpha(26),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'FREE',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.successColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
        ),
      );
    } else if (book.type == AppConstants.bookTypeRental && book.rentalPrice != null) {
      return Text(
        '₹${book.rentalPrice!.toStringAsFixed(0)}/rent',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (book.price != null) {
      return Text(
        '₹${book.price!.toStringAsFixed(0)}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return const SizedBox.shrink();
  }
}

