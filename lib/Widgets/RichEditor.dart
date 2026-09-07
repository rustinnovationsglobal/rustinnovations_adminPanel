import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:rustinnovations_adminpanel/Assets/Colors.dart';

class RichEditor extends StatefulWidget {
  final HtmlEditorController controller;
  final String initialHtml;
  final double height;
  final Function(String)? onContentChanged;

  const RichEditor({
    super.key,
    required this.controller,
    this.initialHtml = '',
    this.height = 500,
    this.onContentChanged,
  });

  @override
  State<RichEditor> createState() => _RichEditorState();
}

class _RichEditorState extends State<RichEditor> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PrimaryScrollController(
      controller: _controller,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2F3A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: HtmlEditor(
          controller: widget.controller,
          htmlEditorOptions: HtmlEditorOptions(
            hint: "Start writing your blog post...",
            initialText: widget.initialHtml,
            shouldEnsureVisible: true,
            darkMode: true,
            spellCheck: true,
            inputType: HtmlInputType.text,

          ),
          htmlToolbarOptions: HtmlToolbarOptions(
            toolbarPosition: ToolbarPosition.aboveEditor,
            toolbarType: ToolbarType.nativeScrollable,
            allowImagePicking: true,
            buttonHoverColor: Colors.white.withOpacity(0.1),
            buttonBorderRadius: BorderRadius.circular(12),
            buttonSelectedColor: MyColors.BUTTON_COLOR,
            buttonColor: Colors.white70,
            buttonFillColor: const Color(0xFF1A1C23),
            dropdownBackgroundColor: const Color(0xFF2C2F3A),
            textStyle: const TextStyle(color: Colors.white),
            defaultToolbarButtons: [
              const StyleButtons(), // paragraph, headline1-4, blockquote
              const FontButtons(
                clearAll: false,
                subscript: false,
                superscript: false,
              ), // bold, italic
              const FontSettingButtons(fontName: true, fontSizeUnit: true, fontSize: true), // fontsize
              const ColorButtons(foregroundColor: true, highlightColor: true), // fontcolor
              const ListButtons(listStyles: true), // Enables Bullet and Numbered lists
              const ParagraphButtons(
                textDirection: false,
                lineHeight: false,
                caseConverter: false,
              ), // center, left, right
              const InsertButtons(
                video: false,
                audio: false,
                table: true,
                hr: true,
                link: true,
                picture: true,
                otherFile: false,
              ), // link, picture
              const OtherButtons(
                fullscreen: false,
                codeview: true,
                help: false,
              ),
            ],
          ),
          callbacks: Callbacks(
            onChangeContent: (String? changed) {
              if (widget.onContentChanged != null && changed != null) {
                widget.onContentChanged!(changed);
              }
            },
          ),
          otherOptions: OtherOptions(
            height: widget.height,
          ),
        ),
      ),
    );
  }
}
