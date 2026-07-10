import '../smxApis/smxConfig.dart';

enum SmxSaldifyAssistantRole { publico, anfitrion, invitado }

extension SmxSaldifyAssistantRoleLabel on SmxSaldifyAssistantRole {
  String get label {
    return switch (this) {
      SmxSaldifyAssistantRole.publico => 'Acceso',
      SmxSaldifyAssistantRole.anfitrion => 'Anfitrion',
      SmxSaldifyAssistantRole.invitado => 'Invitado',
    };
  }

  String get payloadValue {
    return switch (this) {
      SmxSaldifyAssistantRole.publico => 'publico',
      SmxSaldifyAssistantRole.anfitrion => 'anfitrion',
      SmxSaldifyAssistantRole.invitado => 'invitado',
    };
  }
}

enum SmxSaldifyAssistantScreen {
  logon,
  dashboardAnfitrion,
  perfilAnfitrion,
  dashboardCliente,
  perfilCliente,
}

extension SmxSaldifyAssistantScreenLabel on SmxSaldifyAssistantScreen {
  String get label {
    return switch (this) {
      SmxSaldifyAssistantScreen.logon => 'Acceso ${SmxConfig.titulo}',
      SmxSaldifyAssistantScreen.dashboardAnfitrion => 'Dashboard anfitrion',
      SmxSaldifyAssistantScreen.perfilAnfitrion => 'Perfil anfitrion',
      SmxSaldifyAssistantScreen.dashboardCliente => 'Dashboard cliente',
      SmxSaldifyAssistantScreen.perfilCliente => 'Perfil cliente',
    };
  }

  String get payloadValue {
    return switch (this) {
      SmxSaldifyAssistantScreen.logon => 'logon',
      SmxSaldifyAssistantScreen.dashboardAnfitrion => 'dashboard_anfitrion',
      SmxSaldifyAssistantScreen.perfilAnfitrion => 'perfil_anfitrion',
      SmxSaldifyAssistantScreen.dashboardCliente => 'dashboard_cliente',
      SmxSaldifyAssistantScreen.perfilCliente => 'perfil_cliente',
    };
  }
}
