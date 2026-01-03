import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

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
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ClipRect(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Book Cover
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.primary.withAlpha(26),
                  child: book.coverImage != null
                      ? Image.network(
                          book.coverImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              // Book Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title - Single line to save space
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Author
                    Text(
                      book.authorName ?? 'Unknown Author',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Rating and Price in same row to save space
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Rating - Compact
                        if (book.rating != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 11,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${book.rating!.toStringAsFixed(1)}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 9,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        // Price - at end
                        Flexible(child: _buildPrice(context)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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

