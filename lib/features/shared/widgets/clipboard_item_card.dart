import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../history/domain/clipboard_item.dart';

typedef ItemTapCallback = void Function(ClipboardItem item);
typedef FavoriteToggleCallback = void Function(ClipboardItem item);

typedef CopyCallback = void Function(ClipboardItem item);

class ClipboardItemCard extends StatelessWidget {
  const ClipboardItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onToggleFavorite,
    this.onCopy,
  });

  final ClipboardItem item;
  final ItemTapCallback? onTap;
  final FavoriteToggleCallback? onToggleFavorite;
  final CopyCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, h:mm a');
    return Card(
      child: ListTile(
        onTap: onTap == null ? null : () => onTap!(item),
        title: Text(
          item.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(formatter.format(item.createdAt)),
        trailing: Wrap(
          spacing: 8,
          children: <Widget>[
            IconButton(
              icon: Icon(item.isFavorite ? Icons.star : Icons.star_border),
              onPressed: onToggleFavorite == null
                  ? null
                  : () => onToggleFavorite!(item),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: onCopy == null ? null : () => onCopy!(item),
            ),
          ],
        ),
      ),
    );
  }
}
