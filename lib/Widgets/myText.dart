import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget headline({
  required String text,
  required double fontsize,
  TextAlign textAlign = TextAlign.center,
  Color color = Colors.white,
}) {
  return SelectableText(
    text,
    style: GoogleFonts.ubuntu(
      fontSize: fontsize,
      fontWeight: FontWeight.w900,
      color: color,
      letterSpacing: 1,
    ),
    selectionColor: Colors.blue.withOpacity(0.3),
    textAlign: textAlign,
  );
}

Widget paragraph({
  required String text,
  required double fontsize,
  TextAlign textAlign = TextAlign.center,
  Color color = Colors.white70,
}) {
  return SelectableText(
    text,
    style: GoogleFonts.inter(
      fontSize: fontsize,
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: 1,
    ),
    selectionColor: Colors.blue.withOpacity(0.3),
    textAlign: textAlign,
  );
}
