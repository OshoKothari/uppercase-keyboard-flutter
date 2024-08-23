import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: KeyboardScreen(),
    );
  }
}

class KeyboardScreen extends StatefulWidget {
  @override
  _KeyboardScreenState createState() => _KeyboardScreenState();
}

class _KeyboardScreenState extends State<KeyboardScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _suggestions = ['hello', 'world', 'flutter', 'dart'];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateTextToUppercase);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateTextToUppercase);
    _controller.dispose();
    super.dispose();
  }

  void _updateTextToUppercase() {
    final text = _controller.text;
    final transformedText = text.toUpperCase();
    if (text != transformedText) {
      _controller.value = _controller.value.copyWith(
        text: transformedText,
        selection: TextSelection.fromPosition(
          TextPosition(offset: transformedText.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Keyboard'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Type here',
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                _buildSuggestions(),
              ],
            ),
          ),
          Expanded(
            child: CustomKeyboard(
              onKeyPress: (String key) {
                final text = _controller.text;
                _controller.text = _applyTextTransformations(text + key);
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
              },
              onBackspace: () {
                final text = _controller.text;
                if (text.isNotEmpty) {
                  _controller.text = _applyTextTransformations(
                      text.substring(0, text.length - 1));
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length),
                  );
                }
              },
              onSpace: () {
                final text = _controller.text;
                _controller.text = _applyTextTransformations(text + ' ');
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Wrap(
      spacing: 8.0,
      children: _suggestions.map((word) {
        return ElevatedButton(
          onPressed: () {
            final text = _controller.text;
            _controller.text = _applyTextTransformations(text + ' ' + word);
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
          },
          child: Text(word),
        );
      }).toList(),
    );
  }

  String _applyTextTransformations(String text) {
    final correctedText = _autoCorrect(text);
    return correctedText.toUpperCase();
  }

  String _autoCorrect(String text) {
    final Map<String, String> corrections = {
      'teh': 'the',
      'recieve': 'receive',
      'adress': 'address',
    };

    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    final correctedSentences = sentences.map((sentence) {
      final words = sentence.split(' ');
      final correctedWords = words.map((word) {
        return corrections[word.toLowerCase()] ?? word;
      }).toList();
      return '${correctedWords.join(' ').capitalize()}';
    }).toList();

    return correctedSentences.join(' ');
  }
}

class CustomKeyboard extends StatelessWidget {
  final Function(String) onKeyPress;
  final Function() onBackspace;
  final Function() onSpace;

  CustomKeyboard({
    required this.onKeyPress,
    required this.onBackspace,
    required this.onSpace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
            ),
            itemCount: 26,
            itemBuilder: (context, index) {
              final letter = String.fromCharCode(index + 97); // a-z
              return GestureDetector(
                onTap: () => onKeyPress(letter),
                child: Container(
                  margin: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onSpace,
                child: Text('Space'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: onBackspace,
                child: Text('Backspace'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

extension StringCapitalization on String {
  String capitalize() {
    if (this == null || this.isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}
