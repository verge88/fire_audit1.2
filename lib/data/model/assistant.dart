import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utility/ai_assistant_service.dart';


// Events
abstract class AIAssistantEvent {}

class AskAIAssistant extends AIAssistantEvent {
  final String question;

  AskAIAssistant(this.question);
}

// States
abstract class AIAssistantState {}

class AIAssistantInitial extends AIAssistantState {}

class AIAssistantLoaded extends AIAssistantState {
  final List<ChatMessage> messages;

  AIAssistantLoaded(this.messages);
}

class AIAssistantError extends AIAssistantState {
  final String error;

  AIAssistantError(this.error);
}

// Bloc
class AIAssistantBloc extends Bloc<AIAssistantEvent, AIAssistantState> {
  final AIAssistantService _aiService = AIAssistantService();

  AIAssistantBloc() : super(AIAssistantLoaded([
    ChatMessage(content: "Чем я могу вам помочь?", isUser: false)
  ])) {
    on<AskAIAssistant>(_onAskAIAssistant);
  }

  Future<void> _onAskAIAssistant(AskAIAssistant event, Emitter<AIAssistantState> emit) async {
    final currentState = state;
    if (currentState is AIAssistantLoaded) {
      final updatedMessages = List<ChatMessage>.from(currentState.messages)
        ..add(ChatMessage(content: event.question, isUser: true));
      emit(AIAssistantLoaded(updatedMessages));

      try {
        final response = await _aiService.getAIResponse(event.question);
        final newMessages = List<ChatMessage>.from(updatedMessages)
          ..add(ChatMessage(content: response, isUser: false));
        emit(AIAssistantLoaded(newMessages));
      } catch (e) {
        emit(AIAssistantError('Failed to get AI response: $e'));
      }
    } else {
      emit(AIAssistantLoaded([
        ChatMessage(content: "Чем я могу вам помочь?", isUser: false),
        ChatMessage(content: event.question, isUser: true)
      ]));
      try {
        final response = await _aiService.getAIResponse(event.question);
        emit(AIAssistantLoaded([
          ChatMessage(content: "Чем я могу вам помочь?", isUser: false),
          ChatMessage(content: event.question, isUser: true),
          ChatMessage(content: response, isUser: false),
        ]));
      } catch (e) {
        emit(AIAssistantError('Failed to get AI response: $e'));
      }
    }
  }
}


class ChatMessage {
  final String content;
  final bool isUser;

  ChatMessage({required this.content, required this.isUser});
}

