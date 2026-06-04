import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxLogonMovil_controller.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxTmps/smxMenu/smxMenu_controller.dart';

class SmxMenu extends StatefulWidget {
  final SmxLogonMovil_controller controllerLogonMovil;

  // Key interna para manejar el estado
  @override
  final GlobalKey<_SmxMenu> key = GlobalKey();
  final Function() onNavigate;

  SmxMenu({
    super.key,
    required this.controllerLogonMovil,
    required this.onNavigate
  });

  @override
  State<SmxMenu> createState() => _SmxMenu();
}

class _SmxMenu extends State<SmxMenu> {
  late final SmxMenu_controller controller;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Menu'));
  }
}