import 'package:http/http.dart' as http;
import 'dart:html' as html;

Future<void> downloadQr({required String qrUrl, required String id}) async {

  final response = await http.get(Uri.parse(qrUrl));

  final blob = html.Blob([response.bodyBytes]);

  final url =
  html.Url.createObjectUrlFromBlob(blob);

  html.AnchorElement()
    ..href = url
    ..download = '$id.png'
    ..click();

  html.Url.revokeObjectUrl(url);
}