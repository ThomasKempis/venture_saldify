import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxLogonMovil_controller.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxTmps/smxMenu/smxMenu_controller.dart';

class SmxServicios extends StatefulWidget {
  final SmxLogonMovil_controller controllerLogonMovil;

  // Key interna para manejar el estado
  @override
  final GlobalKey<_SmxServicios> key = GlobalKey();
  final Function() onNavigate;

  SmxServicios({
    super.key,
    required this.controllerLogonMovil,
    required this.onNavigate
  });

  @override
  State<SmxServicios> createState() => _SmxServicios();
}

class _SmxServicios extends State<SmxServicios> {
  late final SmxMenu_controller controller;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Servicios'));
  }
}