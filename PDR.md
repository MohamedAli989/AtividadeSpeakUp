PRD: Aplicativo SpeakUp (Treino de Fala)
Autor: Mohamed Ali Awale
Versão: 1.0
Data: 07 de outubro de 2025

1. Visão Geral e Objetivo
O SpeakUp é um aplicativo mobile desenvolvido em Flutter com o objetivo de auxiliar estudantes de idiomas a praticar e melhorar sua pronúncia (speaking). O app oferecerá frases guiadas e, futuramente, feedback sobre a fala do usuário, focando em uma experiência de aprendizado local, sem a necessidade de upload de áudio para a nuvem, garantindo a privacidade.

2. Persona (Público-Alvo)
Estudante de Idiomas Autodidata: Um indivíduo que estuda uma nova língua por conta própria e busca ferramentas para praticar a fala, uma das maiores dificuldades para quem não tem com quem conversar.

3. Requisitos e Funcionalidades (Features)
3.1. Fluxo de Primeiro Acesso (Onboarding e Consentimento)
Tela de Splash: Tela inicial que verifica se o usuário já passou pelo onboarding e consentiu com os termos.

Tela de Onboarding: Apresenta o propósito do aplicativo em uma única tela.

Tela de Termos (LGPD): Exibe os termos de uso e política de privacidade. O usuário deve consentir explicitamente (marcando um checkbox) para poder prosseguir. O consentimento deve ser salvo no dispositivo.

3.2. Tela Principal (Home)
Lista de Lições: Exibe as lições disponíveis para prática (Ex: "Saudações").

Card de Prática Rápida: Um card com uma "frase do dia" para o usuário praticar rapidamente.

Acesso ao Microfone: O app deve solicitar permissão de uso do microfone quando o usuário tentar praticar pela primeira vez.

Revogação de Consentimento (Futuro): Deverá haver uma opção para o usuário revogar seu consentimento com os termos, o que o levaria de volta à tela de consentimento.

3.3. Tela de Lição
Lista de Frases: Mostra uma lista de frases relacionadas ao tema da lição.

Botão de Prática: Ao lado de cada frase, um ícone de microfone permite que o usuário inicie a prática daquela frase específica.

4. Design e UX
Paleta de Cores:

Blue: #3B82F6

Violet: #7C3AED

Slate: #1F2937

Ícone Principal: Microfone com um check, simbolizando a prática bem-sucedida.

Acessibilidade: Os alvos de toque devem ter no mínimo 48dp e o contraste das cores deve ser adequado para leitura.

5. Requisitos Não-Funcionais
Plataforma: Flutter (Android & iOS).

Persistência de Dados: As preferências do usuário (onboarding visto, termos aceitos) serão salvas localmente usando shared_preferences.

Privacidade: O processamento de áudio (futuro) deve ocorrer localmente no dispositivo, sem upload para servidores.