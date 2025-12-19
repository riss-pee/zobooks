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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 180,
              width: double.infinity,
              color: AppTheme.primaryColor.withOpacity(0.1),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title - Flexible height
                  Flexible(
                    child: Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Author
                  Text(
                    book.authorName ?? 'Unknown Author',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Rating - Compact
                  if (book.rating != null)
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${book.rating!.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  // Price - at bottom
                  const Spacer(),
                  _buildPrice(context),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.menu_book,
          size: 64,
          color: AppTheme.primaryColor.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildPrice(BuildContext context) {
    if (book.type == AppConstants.bookTypeFree) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'FREE',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.successColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
        ),
      );
    } else if (book.type == AppConstants.bookTypeRental && book.rentalPrice != null) {
      return Text(
        '₹${book.rentalPrice!.toStringAsFixed(0)}/rent',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    } else if (book.price != null) {
      return Text(
        '₹${book.price!.toStringAsFixed(0)}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return const SizedBox.shrink();
  }
}

