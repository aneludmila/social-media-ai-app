/**
 * Gemini AI Service — Gerador de Sugestões de Conteúdo para Social Media
 *
 * Integração com a API Google Generative Language (Gemini 1.5 Flash).
 * Recebe uma data (DD/MM) e retorna sugestões estratégicas de conteúdo
 * para Instagram em formato JSON.
 *
 * @requires GEMINI_API_KEY — variável de ambiente com a chave da API
 *
 * @example
 *   const { gerarSugestoes } = require('./services/geminiService');
 *   const sugestoes = await gerarSugestoes('10/05');
 */

require('dotenv').config();

const GEMINI_API_URL =
  'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent';

/**
 * Monta o prompt de marketing digital para a data informada.
 * @param {string} data — data no formato DD/MM
 * @returns {string} prompt completo
 */
function montarPrompt(data) {
  return `Você é um especialista em marketing digital focado em social media.

Sua tarefa é gerar sugestões estratégicas de conteúdo com base na data abaixo:

Data: ${data}

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
}`;
}

/**
 * Valida o formato da data (DD/MM).
 * @param {string} data
 * @returns {boolean}
 */
function validarData(data) {
  if (!data || typeof data !== 'string') return false;
  const regex = /^(0[1-9]|[12]\d|3[01])\/(0[1-9]|1[0-2])$/;
  return regex.test(data);
}

/**
 * Gera sugestões de conteúdo para social media usando o Gemini.
 *
 * @param {string} data — data no formato DD/MM (ex: "10/05")
 * @returns {Promise<object>} objeto com as sugestões geradas
 * @throws {Error} se a data for inválida, a API key estiver ausente ou a API falhar
 *
 * @example
 *   const resultado = await gerarSugestoes('10/05');
 *   console.log(resultado.sugestoes);
 */
async function gerarSugestoes(data) {
  // ── Validação da data ──────────────────────────────────────────────
  if (!validarData(data)) {
    throw new Error(
      `Data inválida: "${data}". Use o formato DD/MM (ex: "10/05").`
    );
  }

  // ── Validação da API Key ───────────────────────────────────────────
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new Error(
      'GEMINI_API_KEY não encontrada. Defina a variável de ambiente no arquivo .env.'
    );
  }

  // ── Montagem do body da requisição ─────────────────────────────────
  const prompt = montarPrompt(data);

  const body = {
    contents: [
      {
        parts: [{ text: prompt }],
      },
    ],
    generationConfig: {
      temperature: 0.8,
      topP: 0.95,
      topK: 40,
      maxOutputTokens: 2048,
      responseMimeType: 'application/json',
    },
  };

  // ── Requisição para a API ──────────────────────────────────────────
  const url = `${GEMINI_API_URL}?key=${apiKey}`;

  let response;
  try {
    response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
  } catch (err) {
    throw new Error(`Falha na conexão com a API do Gemini: ${err.message}`);
  }

  // ── Tratamento de erro HTTP ────────────────────────────────────────
  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(
      `Erro na API do Gemini (HTTP ${response.status}): ${errorBody}`
    );
  }

  // ── Parse da resposta ──────────────────────────────────────────────
  const result = await response.json();

  const textContent =
    result?.candidates?.[0]?.content?.parts?.[0]?.text;

  if (!textContent) {
    throw new Error(
      'Resposta inesperada da API do Gemini: nenhum conteúdo de texto retornado.'
    );
  }

  // ── Parse do JSON retornado pelo modelo ────────────────────────────
  try {
    return JSON.parse(textContent);
  } catch {
    // Se o modelo retornar texto com markdown code block, limpa antes de parsear
    const cleaned = textContent
      .replace(/```json\s*/gi, '')
      .replace(/```\s*/g, '')
      .trim();
    try {
      return JSON.parse(cleaned);
    } catch {
      throw new Error(
        `Falha ao interpretar o JSON retornado pelo Gemini:\n${textContent}`
      );
    }
  }
}

module.exports = { gerarSugestoes, montarPrompt, validarData };
