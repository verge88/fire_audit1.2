import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/model/assistant.dart';

class AIAssistantScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AIAssistantBloc(),
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: ChatMessagesWidget(),
            ),
            ChatInputWidget(),
          ],
        ),
      ),
    );
  }
}

class ChatMessagesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AIAssistantBloc, AIAssistantState>(
      builder: (context, state) {
        if (state is AIAssistantLoaded) {
          return ListView.builder(
            reverse: true,
            itemCount: state.messages.length,
            itemBuilder: (context, index) {
              final message = state.messages[state.messages.length - 1 - index];
              return ChatMessageBubble(
                message: message.content,
                isUser: message.isUser,
              );
            },
          );
        } else if (state is AIAssistantError) {
          return Center(
            child: Text('Error: ${state.error}', style: TextStyle(color: Colors.red)),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatMessageBubble({Key? key, required this.message, required this.isUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: SelectableText(message), // Changed Text to SelectableText
      ),
    );
  }
}

class ChatInputWidget extends StatefulWidget {
  @override
  _ChatInputWidgetState createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Напишите вопрос...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          FloatingActionButton(
            elevation: 1,
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                context.read<AIAssistantBloc>().add(AskAIAssistant(_controller.text));
                _controller.clear();
              }
            },
            child: Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}