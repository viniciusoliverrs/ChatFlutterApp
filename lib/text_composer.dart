import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  Function(String?, File?) sendMessage;
  TextComposer(this.sendMessage);

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  File? file;
  final ImagePicker _picker = ImagePicker();
  void _reset() {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.photo_camera),
            onPressed: () async {
              var xfile = await _picker.pickImage(source: ImageSource.camera);
              if (xfile!.path.isEmpty) return;
              file = File(xfile.path);
              widget.sendMessage(null, file);
            },
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message',
              ),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage(_textController.text, file);
                _reset();
              },
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              color: Colors.orange,
            ),
            onPressed: _isComposing
                ? () {
                    widget.sendMessage(_textController.text, file);
                    _reset();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
