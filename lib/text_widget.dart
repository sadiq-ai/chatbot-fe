import 'package:expandable_richtext/expandable_rich_text.dart';
import 'package:flutter/material.dart';

class SadiqExpandableText extends StatelessWidget {
  const SadiqExpandableText({
    super.key,
    required this.text,
    required this.color,
    this.toggleColor,
    this.safe = true,
    this.style,
    this.maxLines = 3,
  });
  final String text;
  final bool safe;
  final Color color;
  final Color? toggleColor;
  final TextStyle? style;
  final int maxLines;
  @override
  Widget build(BuildContext context) {
    if (text == '‎') return const SizedBox();

    return ExpandableRichText(
      //  RichText to cater for the text formatting
      text,
      style: TextStyle(
        color: color,
      ),
      collapseOnTextTap: true,
      expandOnTextTap: true,
      animation: true,
      collapseText: 'see less',
      expandText: 'see more',
      toggleTextStyle: TextStyle(
        color: toggleColor ?? color,
      ),
      hashtagStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
      ),
      mentionStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
      urlStyle: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
      ),
      customTagStyle: const TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.bold,
      ),
      onMentionTap: (String mention) => print('Mention tapped: $mention'),
      onCustomTagTap: (String mention) => print('Mention tapped: $mention'),
      onHashtagTap: (String? hash) => print('Hashtag tapped: $hash'),
      maxLines: maxLines,
    );
  }
}
