import 'package:flutter/material.dart';

class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final List<_Message> _messages = [];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
    });
    _controller.clear();

    Future.delayed(const Duration(milliseconds: 500), () {
      _respondToMessage(text);
    });
  }

  void _respondToMessage(String userMessage) {
    String response = "Lo siento, no entiendo tu pregunta. Intenta con algo diferente.";

    userMessage = userMessage.toLowerCase();

    if (userMessage.contains('riego')) {
      response = "Para regar tus plantas, asegúrate de no excederte y observa si la tierra está seca antes de regar.";
    } else if (userMessage.contains('luz')) {
      response = "La mayoría de las plantas necesitan luz indirecta. Evita la luz solar directa intensa.";
    } else if (userMessage.contains('temperatura')) {
      response = "Mantén tus plantas en un ambiente entre 18 y 25 grados Celsius para un crecimiento óptimo.";
    } else if (userMessage.contains('sensor')) {
      response = "Si tienes problemas con los sensores, verifica que estén correctamente conectados y que la app tenga permisos necesarios.";
    } else if (userMessage.contains('app')) {
      response = "Para usar la app, navega por las secciones y usa el chatbot para preguntas frecuentes.";
    }

    setState(() {
      _messages.add(_Message(text: response, isUser: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jardinerito 🤖"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.green.shade100 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg.text),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Escribe tu pregunta aquí...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  _Message({required this.text, required this.isUser});
}
