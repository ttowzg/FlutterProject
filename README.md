# App Flutter: Semana da Computação DECSI/UFOP

Este projeto consiste no desenvolvimento de uma aplicação móvel multiplataforma para modernizar a gestão e a interação da **Semana da Computação do DECSI/UFOP**. O sistema centraliza informações e automatiza processos críticos, como o registo de presença dos participantes através de tecnologia digital.

## Equipa de Desenvolvimento

* **Henrique Ângelo Duarte Alves** – 23.1.8028
* **Kalvin de Souza Pimenta** – 22.1.8021
* **Luis Eduardo Bastos Rocha** – 23.1.8095
* **Tomaz Guedes** – 22.1.8175


## Funcionalidades

Com base na Especificação de Requisitos, a aplicação entrega:

* **Check-in Digital**: Registo de presença via smartphone com suporte a **modo offline** para mitigar falhas de Wi-Fi no local do evento.
* **Programação em Tempo Real**: Grade completa de atividades sincronizada via Firebase, permitindo atualizações instantâneas de horários e locais.
* **Agenda Personalizada**: Permite que o participante organize o seu próprio cronograma e evite conflitos de horário entre palestras e oficinas.
* **Interação Q&A**: Painel direto para envio de perguntas por texto aos palestrantes durante as sessões, facilitando a participação do público.
* **Módulo de Feedback**: Coleta de avaliações (1 a 5 estrelas) e comentários qualitativos após a conclusão das atividades.

## Tecnologias Utilizadas

* **Framework**: [Flutter](https://flutter.dev/) (Compilação nativa para Android/iOS).
* **Backend & Infraestrutura**: [Firebase](https://firebase.google.com/) (Authentication para gestão de perfis e Cloud Firestore para base de dados em tempo real).
* **Prototipagem**: Figma (Design de interface e UX).
* **Gestão de Projeto**: Baseada no Guia PMBOK e Metodologia GQM.

## Como Executar o Projeto

1.  **Pré-requisitos**:
    * Ter o Flutter SDK instalado.
    * Um emulador (Android/iOS) ou dispositivo físico configurado.

2.  **Clonar o repositório**:
    ```bash
    git clone [https://github.com/ttowzg/FlutterProject.git](https://github.com/ttowzg/FlutterProject.git)
    ```

3.  **Instalar dependências**:
    ```bash
    flutter pub get
    ```

4.  **Configurar Firebase**:
    * Adicionar o ficheiro `google-services.json` na pasta `android/app/`.
    * Adicionar o ficheiro `GoogleService-Info.plist` na pasta `ios/Runner/`.

5.  **Executar a aplicação**:
    ```bash
    flutter run
    ```

## Qualidade e Métricas (GQM)

O projeto segue metas rigorosas de desempenho e usabilidade, fundamentadas no modelo **Goal-Question-Metric**:

* **Responsividade**: Tempo de transição entre telas de até 1 segundo.
* **Eficiência**: Carregamento da programação completa e dados externos em até 5 segundos.
* **Confiabilidade**: Garantia de 100% de integridade na sincronização de dados de check-in realizados em modo offline.

---
*Projeto desenvolvido para a disciplina de Gerência de Projetos de Software (CSI405)*