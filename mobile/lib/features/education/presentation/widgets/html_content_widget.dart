/// HTML Content Widget for Educational Articles
library;

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlContentWidget extends StatelessWidget {
  final String htmlContent;
  final TextStyle? textStyle;

  const HtmlContentWidget({
    super.key,
    required this.htmlContent,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Html(
      data: htmlContent,
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(16),
          lineHeight: const LineHeight(1.6),
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        "p": Style(
          margin: Margins.only(bottom: 16),
        ),
        "h1": Style(
          fontSize: FontSize(24),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 24, bottom: 16),
        ),
        "h2": Style(
          fontSize: FontSize(20),
          fontWeight: FontWeight.bold,
          margin: Margins.only(top: 20, bottom: 12),
        ),
        "h3": Style(
          fontSize: FontSize(18),
          fontWeight: FontWeight.w600,
          margin: Margins.only(top: 16, bottom: 12),
        ),
        "ul": Style(
          margin: Margins.only(bottom: 16, left: 20),
        ),
        "ol": Style(
          margin: Margins.only(bottom: 16, left: 20),
        ),
        "li": Style(
          margin: Margins.only(bottom: 8),
        ),
        "a": Style(
          color: Theme.of(context).primaryColor,
          textDecoration: TextDecoration.underline,
        ),
        "img": Style(
          width: Width.auto(),
          maxWidth: Width(MediaQuery.of(context).size.width - 32),
          margin: Margins.symmetric(vertical: 16),
        ),
        "blockquote": Style(
          border: Border(
            left: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 4,
            ),
          ),
          margin: Margins.symmetric(vertical: 16),
          padding: HtmlPaddings.only(left: 16),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.05),
        ),
        "code": Style(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
          fontFamily: 'monospace',
        ),
        "pre": Style(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: HtmlPaddings.all(12),
          margin: Margins.symmetric(vertical: 16),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
      },
      onLinkTap: (url, attributes, element) {
        if (url != null) {
          _launchUrl(url);
        }
      },
      onImageTap: (src, attributes, element) {
        if (src != null) {
          // Can implement image viewer here
          _launchUrl(src);
        }
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
