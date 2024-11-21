import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:trippy_threads/core/utilities.dart';

class SettingPopup extends StatelessWidget {
  SettingPopup({super.key, this.radius = 8, required this.mdFilename})
      : assert(
            mdFilename.contains('.md'), 'The file must contain .md extension');
  final double radius;
  final String mdFilename;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        children: [
          Expanded(
              child: FutureBuilder(
            future: Future.delayed(const Duration(microseconds: 150))
                .then((value) => rootBundle.loadString('assets/$mdFilename')),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Markdown(
                    styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
                        textTheme: const TextTheme(
                            bodyMedium: TextStyle(
                                fontSize: 15.0, color: Colors.white)))),
                    data: snapshot.data.toString());
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          )),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              )),
              alignment: Alignment.center,
              height: 50,
              width: double.infinity,
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
