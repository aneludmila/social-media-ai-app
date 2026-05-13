import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Modelo representando uma sugestão de conteúdo gerada pela IA
class ContentSuggestion {
  final String tipo;
  final String titulo;
  final String descricao;
  final String legenda;
  final String cta;
  final List<String> hashtags;

  const ContentSuggestion({
    required this.tipo,
    required this.titulo,
    required this.descricao,
    required this.legenda,
    required this.cta,
    required this.hashtags,
  });

  factory ContentSuggestion.fromJson(Map<String, dynamic> json) {
    return ContentSuggestion(
      tipo: json['tipo'] as String? ?? 'post',
      titulo: json['titulo'] as String? ?? '',
      descricao: json['descricao'] as String? ?? '',
      legenda: json['legenda'] as String? ?? '',
      cta: json['cta'] as String? ?? '',
      hashtags:
          (json['hashtags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Ícone adequado ao tipo de conteúdo
  String get tipoEmoji {
    switch (tipo.toLowerCase()) {
      case 'reels':
        return '🎬';
      case 'story':
      case 'stories':
        return '📱';
      case 'post':
      default:
        return '📸';
    }
  }
}

/// Sugestões de fallback para quando a API falha
const List<ContentSuggestion> _fallbackSugestoes = [
  ContentSuggestion(
    tipo: 'reels',
    titulo: 'Bastidores do seu dia',
    descricao:
        'Mostre um pouco da sua rotina de trabalho em um reels rápido e autêntico.',
    legenda:
        '📍 Um dia na vida de quem trabalha com [seu nicho].\nVocê também passa por isso? Comenta aqui! 👇',
    cta: 'Salve esse reels para se inspirar depois!',
    hashtags: [
      '#bastidores',
      '#rotina',
      '#marketing',
      '#reels',
      '#empreendedorismo',
    ],
  ),
  ContentSuggestion(
    tipo: 'post',
    titulo: 'Dica rápida para engajamento',
    descricao:
        'Carrossel com 5 dicas práticas para aumentar o engajamento nos posts.',
    legenda:
        '🚀 5 dicas que vão turbinar seu engajamento!\nQual dessas você já usa? Conta nos comentários! 💬',
    cta: 'Compartilhe com alguém que precisa ver isso!',
    hashtags: [
      '#dicasdemarketing',
      '#engajamento',
      '#carrossel',
      '#socialmedia',
    ],
  ),
  ContentSuggestion(
    tipo: 'story',
    titulo: 'Enquete do dia',
    descricao: 'Story interativo com enquete sobre tendências do nicho.',
    legenda: '🤔 Qual formato funciona melhor pra você?',
    cta: 'Vote na enquete!',
    hashtags: ['#stories', '#enquete', '#interacao'],
  ),
];

/// Serviço de integração com a API do Google Gemini
/// Utiliza a SDK oficial google_generative_ai
class GeminiService {
  // ⚠️ Em produção, use variáveis de ambiente ou configuração segura
  static const String _apiKey = 'VAZA';
  static const String _modelName = 'gemini-2.0-flash';

  /// Validação da API key
  static bool get isApiKeyValid =>
      _apiKey.isNotEmpty && _apiKey.startsWith('AIza') && _apiKey.length > 20;

  /// Instância lazy do modelo generativo
  static GenerativeModel? _model;
  static GenerativeModel get _getModel {
    _model ??= GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.8,
        topP: 0.95,
        topK: 40,
        maxOutputTokens: 2048,
        responseMimeType: 'application/json',
      ),
    );
    return _model!;
  }

  /// Gera sugestões de conteúdo para social media com base na data
  static Future<List<ContentSuggestion>> gerarSugestoes(String data) async {
    // ── Validação da API Key ──────────────────────────────
    if (!isApiKeyValid) {
      debugPrint('╔══════════════════════════════════════════╗');
      debugPrint('║  ⚠️  GEMINI: API KEY INVÁLIDA            ║');
      debugPrint('║  Verifique a chave em GeminiService      ║');
      debugPrint('╚══════════════════════════════════════════╝');
      debugPrint(
        '🔑 API Key (primeiros 10 chars): ${_apiKey.substring(0, _apiKey.length > 10 ? 10 : _apiKey.length)}...',
      );
      return _fallbackSugestoes;
    }

    if (data.isEmpty) {
      throw Exception('Data não pode estar vazia');
    }

    final prompt = _montarPrompt(data);

    // ── Log do payload ────────────────────────────────────
    debugPrint('');
    debugPrint('╔══════════════════════════════════════════╗');
    debugPrint('║  🤖 GEMINI AI — Gerando Sugestões         ║');
    debugPrint('╚══════════════════════════════════════════╝');
    debugPrint('📅 Data solicitada: $data');
    debugPrint('🧠 Modelo: $_modelName');
    debugPrint('📝 Tamanho do prompt: ${prompt.length} caracteres');
    debugPrint('────────────────────────────────────────────');

    try {
      final model = _getModel;
      final content = [Content.text(prompt)];

      debugPrint('📤 Enviando requisição para Gemini...');
      final stopwatch = Stopwatch()..start();

      final response = await model.generateContent(content);

      stopwatch.stop();
      debugPrint('⏱️  Tempo de resposta: ${stopwatch.elapsedMilliseconds}ms');

      // ── Log da resposta ───────────────────────────────
      final textContent = response.text;

      if (textContent == null || textContent.isEmpty) {
        debugPrint('❌ Resposta vazia recebida da API');
        debugPrint('📦 Response candidates: ${response.candidates.length}');
        if (response.candidates.isNotEmpty) {
          debugPrint(
            '📦 Finish reason: ${response.candidates.first.finishReason}',
          );
        }
        debugPrint('🔄 Usando sugestões de fallback...');
        return _fallbackSugestoes;
      }

      debugPrint('✅ Resposta recebida com sucesso!');
      debugPrint('📦 Tamanho da resposta: ${textContent.length} caracteres');
      debugPrint(
        '📦 Preview: ${textContent.substring(0, textContent.length > 150 ? 150 : textContent.length)}...',
      );

      final sugestoes = _parseResponse(textContent);
      debugPrint('🎯 ${sugestoes.length} sugestões geradas com sucesso!');
      debugPrint('════════════════════════════════════════════');
      debugPrint('');

      return sugestoes;
    } on GenerativeAIException catch (e) {
      // ── Erros específicos da SDK ──────────────────────
      debugPrint('');
      debugPrint('╔══════════════════════════════════════════╗');
      debugPrint('║  ❌ GEMINI AI — ERRO DA SDK              ║');
      debugPrint('╚══════════════════════════════════════════╝');
      debugPrint('🔴 Tipo: ${e.runtimeType}');
      debugPrint('🔴 Mensagem: ${e.message}');
      debugPrint('════════════════════════════════════════════');

      if (e.message.contains('API_KEY') ||
          e.message.contains('403') ||
          e.message.contains('401')) {
        debugPrint('🔑 Possível problema com a API Key');
      }

      debugPrint('🔄 Usando sugestões de fallback...');
      return _fallbackSugestoes;
    } catch (e, stackTrace) {
      // ── Erros genéricos ───────────────────────────────
      debugPrint('');
      debugPrint('╔══════════════════════════════════════════╗');
      debugPrint('║  ❌ GEMINI AI — ERRO INESPERADO          ║');
      debugPrint('╚══════════════════════════════════════════╝');
      debugPrint('🔴 Tipo: ${e.runtimeType}');
      debugPrint('🔴 Erro: $e');
      debugPrint('📋 Stack trace (primeiras linhas):');
      final stackLines = stackTrace.toString().split('\n');
      for (var i = 0; i < stackLines.length && i < 5; i++) {
        debugPrint('   ${stackLines[i]}');
      }
      debugPrint('════════════════════════════════════════════');

      debugPrint('🔄 Usando sugestões de fallback...');
      return _fallbackSugestoes;
    }
  }

  /// Monta o prompt de marketing digital
  static String _montarPrompt(String data) {
    return '''Você é um especialista em marketing digital focado em social media.

Sua tarefa é gerar sugestões estratégicas de conteúdo com base na data abaixo:

Data: $data

Gere no mínimo 3 ideias de conteúdo para Instagram.

Para cada ideia inclua:
- tipo (post, reels ou story)
- titulo
- descricao
- legenda
- cta
- hashtags

Retorne em JSON válido, usando o seguinte formato:
{
  "sugestoes": [
    {
      "tipo": "post | reels | story",
      "titulo": "...",
      "descricao": "...",
      "legenda": "...",
      "cta": "...",
      "hashtags": ["#exemplo1", "#exemplo2"]
    }
  ]
}''';
  }

  /// Faz o parse da resposta do Gemini
  static List<ContentSuggestion> _parseResponse(String text) {
    try {
      final parsed = jsonDecode(text) as Map<String, dynamic>;
      final List<dynamic> sugestoes = parsed['sugestoes'] as List<dynamic>;
      final result = sugestoes
          .map((e) => ContentSuggestion.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('✅ Parse JSON bem-sucedido: ${result.length} sugestões');
      return result;
    } catch (parseError) {
      debugPrint('⚠️  Primeira tentativa de parse falhou: $parseError');

      // Tenta limpar markdown code blocks
      final cleaned = text
          .replaceAll(RegExp(r'```json\s*', caseSensitive: false), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();
      try {
        final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
        final List<dynamic> sugestoes = parsed['sugestoes'] as List<dynamic>;
        final result = sugestoes
            .map((e) => ContentSuggestion.fromJson(e as Map<String, dynamic>))
            .toList();
        debugPrint(
          '✅ Parse JSON (cleaned) bem-sucedido: ${result.length} sugestões',
        );
        return result;
      } catch (cleanedError) {
        debugPrint('❌ Parse JSON falhou completamente');
        debugPrint('📄 Texto recebido: $text');
        debugPrint('📄 Texto limpo: $cleaned');
        debugPrint('🔴 Erro: $cleanedError');

        // Retorna fallback em vez de crashar
        debugPrint('🔄 Usando sugestões de fallback após falha no parse...');
        return _fallbackSugestoes;
      }
    }
  }
}
