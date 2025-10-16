# Diaum - Focus & Productivity App

Diaum é um aplicativo iOS focado em produtividade que permite aos usuários bloquear aplicativos e sites específicos para manter o foco. O app utiliza tecnologias avançadas como FamilyControls, DeviceActivity e ManagedSettings para fornecer controle granular sobre o acesso a aplicativos e conteúdo web.

## 🎯 Funcionalidades Principais

- **Bloqueio de Aplicativos**: Controle granular sobre quais apps podem ser acessados
- **Bloqueio de Sites**: Restrição de acesso a domínios específicos
- **Perfis Personalizados**: Criação de diferentes configurações de bloqueio
- **Estratégias de Desbloqueio**: NFC, QR Code e outras formas físicas de desbloqueio
- **Live Activities**: Notificações em tempo real sobre o status do bloqueio
- **Agendamento**: Bloqueios automáticos baseados em horários
- **Widgets**: Controle rápido via widgets do iOS
- **Siri Shortcuts**: Integração com comandos de voz

## 📁 Estrutura do Projeto

### 🏗️ Arquivos Principais

#### **App Entry Point**
- **`foqosApp.swift`** - Ponto de entrada principal do aplicativo
  - Configuração do ModelContainer para SwiftData
  - Inicialização de managers e singletons
  - Configuração de background tasks
  - Tratamento de universal links

#### **Views Principais**
- **`HomeView.swift`** - Tela principal do aplicativo
  - Interface minimalista com botão central de bloqueio/desbloqueio
  - Navegação inferior com abas (BRICK, SCHEDULE, ACTIVITY, SETTINGS)
  - Gerenciamento de estado de bloqueio
  - Design responsivo com modo claro/escuro

- **`BlockedProfileView.swift`** - Criação e edição de perfis de bloqueio
  - Configuração de apps e sites a serem bloqueados
  - Definição de estratégias de desbloqueio
  - Configurações de agendamento e lembretes
  - Interface de seleção de atividades

- **`BlockedProfileListView.swift`** - Lista de todos os perfis criados
  - Visualização de perfis existentes
  - Opções de edição e exclusão
  - Estatísticas de uso por perfil

- **`IntroView.swift`** - Tela de introdução e permissões
  - Solicitação de permissões necessárias
  - Tutorial inicial do aplicativo
  - Configuração inicial

- **`EmergencyView.swift`** - Tela de emergência para desbloqueio
  - Desbloqueio rápido em situações críticas
  - Acesso temporário a apps bloqueados

- **`SupportView.swift`** - Tela de suporte e configurações
  - Informações de contato
  - Configurações gerais do app
  - Gerenciamento de dados

- **`ProfileInsightsView.swift`** - Análise de uso e estatísticas
  - Gráficos de tempo bloqueado
  - Métricas de produtividade
  - Relatórios de atividade

### 🗃️ Models (SwiftData)

#### **Modelos de Dados Principais**
- **`BlockedProfiles.swift`** - Modelo principal de perfis de bloqueio
  - Configurações de apps e sites bloqueados
  - Estratégias de desbloqueio (NFC, QR Code)
  - Configurações de agendamento
  - Modos especiais (Allow Mode, Strict Mode)

- **`BlockedProfileSessions.swift`** - Sessões ativas de bloqueio
  - Controle de sessões em andamento
  - Timestamps de início e fim
  - Duração das sessões
  - Status de bloqueio

- **`Schedule.swift`** - Agendamento de bloqueios
  - Horários programados
  - Repetições e frequências
  - Configurações de dias da semana

#### **Estratégias de Bloqueio**
- **`Strategies/`** - Pasta com diferentes estratégias
  - **`NFCStrategy.swift`** - Bloqueio via NFC
  - **`QRCodeStrategy.swift`** - Bloqueio via QR Code
  - **`PhysicalStrategy.swift`** - Estratégias físicas
  - **`TimeBasedStrategy.swift`** - Bloqueio baseado em tempo
  - **`LocationStrategy.swift`** - Bloqueio baseado em localização
  - **`CustomStrategy.swift`** - Estratégias personalizadas

### 🛠️ Utils (Utilitários)

#### **Managers Principais**
- **`StrategyManager.swift`** - Gerenciador central de estratégias
  - Coordenação entre diferentes estratégias
  - Controle de estado de bloqueio
  - Gerenciamento de sessões ativas

- **`RequestAuthorizer.swift`** - Gerenciamento de permissões
  - Solicitação de permissões do FamilyControls
  - Verificação de status de autorização
  - Tratamento de erros de permissão

- **`FamilyActivityUtil.swift`** - Utilitários para FamilyControls
  - Seleção de aplicativos e sites
  - Configuração de restrições
  - Validação de seleções

- **`DeviceActivityCenterUtil.swift`** - Gerenciamento de DeviceActivity
  - Agendamento de atividades
  - Monitoramento de uso
  - Configuração de restrições

- **`LiveActivityManager.swift`** - Gerenciamento de Live Activities
  - Criação e atualização de atividades
  - Notificações em tempo real
  - Controle de estado das atividades

#### **Utilitários Específicos**
- **`NFCWriter.swift`** - Escrita de tags NFC
- **`NFCScannerUtil.swift`** - Leitura de tags NFC
- **`PhysicalReader.swift`** - Leitura de códigos físicos
- **`DataExporter.swift`** - Exportação de dados
- **`ProfileInsightsUtil.swift`** - Análise de perfis
- **`RatingManager.swift`** - Gerenciamento de avaliações
- **`TipManager.swift`** - Sistema de doações
- **`NavigationManager.swift`** - Gerenciamento de navegação
- **`TimersUtil.swift`** - Utilitários de timer
- **`DocumentsUtil.swift`** - Gerenciamento de documentos
- **`FocusMessages.swift`** - Mensagens de foco
- **`TextFieldAlert.swift`** - Alertas personalizados
- **`Extensions.swift`** - Extensões úteis

### 🎨 Components (Componentes UI)

#### **Componentes Comuns**
- **`Common/`** - Componentes reutilizáveis
  - **`ActionButton.swift`** - Botões de ação
  - **`AppTitle.swift`** - Título do app
  - **`RoundedButton.swift`** - Botões arredondados
  - **`SectionTitle.swift`** - Títulos de seção
  - **`CustomToggle.swift`** - Toggles personalizados
  - **`EmptyView.swift`** - View para estados vazios
  - **`GlassButton.swift`** - Botões com efeito glass
  - **`MultiStatCard.swift`** - Cards de estatísticas
  - **`ChartCard.swift`** - Cards de gráficos
  - **`SelectableChart.swift`** - Gráficos selecionáveis
  - **`CardBackground.swift`** - Fundos de cards
  - **`AnimationModifiers.swift`** - Modificadores de animação
  - **`BreakGlassButton.swift`** - Botão de emergência

#### **Componentes de Perfil**
- **`BlockedProfileCards/`** - Cards relacionados a perfis
  - **`BlockedProfileCard.swift`** - Card principal de perfil
  - **`BlockedProfileCarousel.swift`** - Carrossel de perfis
  - **`ProfileIndicators.swift`** - Indicadores de perfil
  - **`ProfileScheduleRow.swift`** - Linha de agendamento
  - **`ProfileStatsRow.swift`** - Linha de estatísticas
  - **`ProfileTimerButton.swift`** - Botão de timer
  - **`StrategyInfoView.swift`** - Informações de estratégia

#### **Componentes de Dashboard**
- **`Dashboard/`** - Componentes do dashboard
  - **`Welcome.swift`** - Tela de boas-vindas
  - **`RefreshControl.swift`** - Controle de atualização
  - **`VersionFooter.swift`** - Rodapé com versão

#### **Componentes de Estratégia**
- **`Strategy/`** - Componentes de estratégias
  - **`QRCodeView.swift`** - Visualização de QR Code
  - **`QRCodeScanner.swift`** - Scanner de QR Code
  - **`PhysicalUnblockView.swift`** - Desbloqueio físico

### 🔧 Extensions e Targets

#### **Device Monitor Extension**
- **`DiaumDeviceMonitor/`** - Extensão de monitoramento
  - **`DeviceActivityMonitorExtension.swift`** - Monitoramento de atividade do dispositivo
  - **`DiaumDeviceMonitor.entitlements`** - Permissões da extensão

#### **Shield Configuration**
- **`DiaumShieldConfig/`** - Configuração do shield
  - **`ShieldConfigurationExtension.swift`** - Personalização da tela de bloqueio
  - **`DiaumShieldConfig.entitlements`** - Permissões do shield

#### **Widget Extension**
- **`DiaumWidget/`** - Widget do iOS
  - **`DiaumWidgetBundle.swift`** - Bundle do widget
  - **`DiaumWidgetLiveActivity.swift`** - Live Activity do widget
  - **`ProfileControlWidget.swift`** - Widget de controle de perfil
  - **`ProfileControlProvider.swift`** - Provider do widget
  - **`ProfileWidgetEntryView.swift`** - View de entrada do widget
  - **`ProfileWidgetEntry.swift`** - Modelo de entrada do widget
  - **`ProfileSelectionIntent.swift`** - Intent de seleção de perfil

### 📱 Intents (Siri Shortcuts)

- **`Intents/`** - Integração com Siri
  - **`BlockedProfileEntity.swift`** - Entidade de perfil bloqueado
  - **`CheckProfileStatusIntent.swift`** - Intent para verificar status
  - **`StartProfileIntent.swift`** - Intent para iniciar perfil
  - **`StopProfileIntent.swift`** - Intent para parar perfil

### 🎨 Assets e Recursos

- **`Assets.xcassets/`** - Recursos visuais
  - **`AppIcon.appiconset/`** - Ícones do aplicativo
  - **`AccentColor.colorset/`** - Cores de destaque
  - **`ThankYouStamp.imageset/`** - Selo de agradecimento
  - **`Threads.imageset/`** - Ícones do Threads
  - **`Twitter.imageset/`** - Ícones do Twitter/X

### ⚙️ Configurações

- **`Info.plist`** - Configurações do aplicativo
- **`foqos.entitlements`** - Permissões e capacidades
- **`Tip for developer.storekit`** - Configuração de doações
- **`buildServer.json`** - Configuração do servidor de build

## 🚀 Tecnologias Utilizadas

- **SwiftUI** - Interface de usuário moderna
- **SwiftData** - Persistência de dados
- **FamilyControls** - Controle parental e de foco
- **DeviceActivity** - Monitoramento de atividade
- **ManagedSettings** - Gerenciamento de configurações
- **CoreNFC** - Funcionalidades NFC
- **AVFoundation** - Scanner de QR Code
- **ActivityKit** - Live Activities
- **AppIntents** - Integração com Siri
- **WidgetKit** - Widgets do iOS

## 📋 Requisitos

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Permissões de FamilyControls
- Permissões de NFC (opcional)
- Permissões de Câmera (para QR Code)

## 🔐 Permissões Necessárias

- **FamilyControls** - Para bloquear aplicativos
- **DeviceActivity** - Para monitorar uso
- **NFC** - Para funcionalidades NFC
- **Camera** - Para scanner de QR Code
- **Background App Refresh** - Para funcionalidades em background

## 🏗️ Arquitetura

O aplicativo segue uma arquitetura MVVM (Model-View-ViewModel) com:

- **Models**: SwiftData para persistência
- **Views**: SwiftUI para interface
- **ViewModels**: Managers e Utils para lógica de negócio
- **Extensions**: Funcionalidades específicas do iOS
- **Intents**: Integração com Siri

## 📝 Notas de Desenvolvimento

- O aplicativo utiliza singletons para managers compartilhados
- SwiftData é usado para persistência local
- FamilyControls requer configuração especial no projeto
- Live Activities precisam de configuração no Info.plist
- Widgets requerem target separado

## 🤝 Contribuição

Para contribuir com o projeto, certifique-se de:

1. Entender as permissões necessárias do FamilyControls
2. Configurar corretamente os entitlements
3. Testar em dispositivos físicos (simulador tem limitações)
4. Seguir as diretrizes de design do iOS

---

**Diaum** - Mantenha o foco, maximize a produtividade! 🎯