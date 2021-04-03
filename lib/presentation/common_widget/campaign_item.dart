import 'package:flutter/material.dart';

import '../theme/theme_color.dart';
import 'cache_network_image_wrapper.dart';

class CampaignItem<T> extends StatelessWidget {
  final T item;
  final String Function(T) getTitle;
  final String Function(T) getImage;
  final String Function(T) getDateStr;
  final String Function(T) getPointStr;
  final Function(T) onTap;

  const CampaignItem({
    Key key,
    @required this.item,
    @required this.getTitle,
    @required this.getImage,
    @required this.getDateStr,
    @required this.getPointStr,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black54,
        child: InkWell(
          onTap: () => onTap?.call(item),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
                child: CachedNetworkImageWrapper.item(
                  url: getImage(item),
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTitle(item),
                        style: textTheme.bodyText1,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getDateStr(item),
                        style: textTheme.subtitle1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        getPointStr(item),
                        style: textTheme.subtitle1.copyWith(
                          color: AppColor.green,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
