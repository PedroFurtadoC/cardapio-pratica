# App Cardápio (Flutter)

Este diretório concentra exclusivamente a construção do aplicativo mobile do cardápio. Deixei a estrutura de pastas organizada para facilitar o trabalho da equipe e a integração com a nossa API atual.

## Primeiros Passos

O projeto já está estruturado e com o Firebase configurado. Depois de clonar o repositório, dentro da pasta `mobile`:

```bash
flutter pub get
flutter run
```

Não é preciso rodar `flutter create` nem configurar o Firebase manualmente: os arquivos de configuração já vêm versionados (veja a seção "Autenticação com Firebase").

## Estrutura Interna Recomendada (lib)

A pasta `lib` já foi separada por especialidades para mantermos o código de fácil leitura. O alinhamento ideal é:

- **models/**: As representações dos dados vindos da API. Aqui transformamos o JSON bruto do backend em objetos do Dart (ex: classes para Produto e Pedido).
- **screens/**: Toda a parte visual onde o cliente navega na tela.
- **services/**: Arquivos responsáveis pelas requisições de rede. Todas as comunicações via HTTP com o FastAPI (como enviar um login ou puxar a lista de itens) devem ficar isoladas aqui.
- **widgets/**: Pedaços de interface que usamos várias vezes. Botões customizados, cartões de produto, banners, tudo que for reutilizável e independente.
- **providers/**: Arquivos voltados ao gerenciamento de estado. Aqui centralizaremos o controle global do app, como manipular os itens do carrinho, o total do pedido e os dados da sessão do usuário logado.

## Conexão com o Backend

O grande trunfo dessa organização é que não há necessidade de reescrever servidor de banco de dados ou autenticação. O nosso próprio backend construído em Python vai fornecer as respostas que precisamos.

**Ponto de atenção no Desenvolvimento Local:**
O backend roda na porta `8000`. Porém, se usarmos o emulador do Android, acessar `localhost` não direciona à máquina real. Nestes casos:
- No emulador do Android, tentem apontar as requisições para: `http://10.0.2.2:8000`
- Caso usem o celular físico espetado via USB/Wi-Fi, as requisições devem ir para o endereço de rede da máquina local, como por exemplo: `http://192.168.0.X:8000`

Para ter certeza do que estão tentando enviar ou o formato da resposta, sempre confiram o painel de documentação da API em `http://localhost:8000/docs`. Pode bater e testar por lá. Bom trabalho!

## Autenticação com Firebase

O acesso dos clientes (login, cadastro e recuperação de senha) é feito pelo **Firebase Authentication** (provedor e-mail/senha). No cadastro, além de criar a conta, guardamos nome e telefone na coleção `usuarios` do **Cloud Firestore**. O restante do app (cardápio e pedidos) continua consumindo a nossa API REST.

A configuração do Firebase já vem versionada no projeto (`lib/firebase_options.dart` e `android/app/google-services.json`), gerada com a CLI do FlutterFire. Então, após o `flutter pub get`, o app já sobe conectado ao Firebase, sem nenhum passo extra.

O fluxo segue o uso real da marmitaria: o **cardápio é aberto**, ou seja, o app abre direto nele, o que funciona bem tanto para um tablet no balcão quanto para quem só quer dar uma olhada. O login com Firebase é pedido **na hora de finalizar o pedido**, para identificar o cliente. A **administração** (gestão de pedidos e produtos) fica numa **área restrita com login próprio** (autenticação via API, igual ao painel web), acessível por um toque longo na logo.

## Aplicativo publicado

O app está publicado como WebApp no **Firebase Hosting**:

🔗 https://cardapio-coracao-de-mae.web.app

Para gerar uma nova versão e publicar:

```bash
flutter build web --release
firebase deploy --only hosting
```
