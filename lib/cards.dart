import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/product_model.dart';

class NewProductCard extends StatelessWidget {
  const NewProductCard({
    super.key,
    required this.product,
    this.footer,
    this.trailing,
    this.elevation = 1,
    this.refundQuantity,
  });

  final ProductModel product;
  final Widget? footer;
  final Widget? trailing;
  final double elevation;
  final int? refundQuantity;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: () async {
        // Navigate to url
        try {
          await launchUrl(
            Uri.parse(
              'https://web.sadiq.ai/products/${product.name.replaceAll(' ', '')}/${product.id}',
            ),
          );
        } catch (e) {
          print(e);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Product recomendation: ', style: textTheme.titleMedium),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              //  Image of the product
              Image.network(
                product.thumbnail,
                height: 90,
                width: 90,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Product Name
                  SizedBox(
                    width: 150,
                    child: Text(
                      product.name,
                      style: textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Post hashtags
                  SizedBox(
                    width: 150,
                    child: Text(
                      product.category,
                      style: textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Product Price
                  SizedBox(
                    width: 150,
                    child: Text(
                      'PKR ${product.price.toStringAsFixed(2)}',
                      style: textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
