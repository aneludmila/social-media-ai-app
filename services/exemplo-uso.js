/**
 * Exemplo de uso do serviço Gemini para gerar sugestões de conteúdo.
 *
 * Para executar:
 *   1. Copie .env.example para .env e preencha sua GEMINI_API_KEY
 *   2. npm install dotenv
 *   3. node services/exemplo-uso.js
 */

const { gerarSugestoes } = require('./geminiService');

async function main() {
  try {
    console.log('🤖 Gerando sugestões de conteúdo para 10/05...\n');

    const resultado = await gerarSugestoes('10/05');

    console.log('✅ Sugestões geradas com sucesso!\n');
    console.log(JSON.stringify(resultado, null, 2));
  } catch (err) {
    console.error('❌ Erro:', err.message);
    process.exit(1);
  }
}

main();
