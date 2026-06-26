import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxPerfil/smxPerfil_controller.dart';
import 'package:venture_saldify/smxLayout/smxScreenTmp.dart';
import 'package:venture_widgets/smxDatePicker/smxDatePicker.dart';
import 'package:venture_widgets/smxTextField/smxTextField.dart';

class SmxPerfil extends StatefulWidget {
  final VoidCallback onNavigateToHome;

  // Key interna para manejar el estado
  @override
  final GlobalKey<_SmxPerfil> key = GlobalKey();

  SmxPerfil({super.key, required this.onNavigateToHome});
  @override
  _SmxPerfil createState() => _SmxPerfil();

  void refresh() {
    key.currentState?.refresh();
  }
}

class _SmxPerfil extends State<SmxPerfil> {
  static const _profileFields = [
    'SYSUSER10_NOMBRES',
    'SYSUSER10_APELLIDOS',
    'SYSUSER10_TELEFONO',
    'SYSUSER10_FECHA',
    'SYSUSER10_CORREO_01',
  ];

  late final SmxPerfil_controller controller;
  late final Map<String, dynamic> _originalValues;
  int _formVersion = 0;

  @override
  void initState() {
    super.initState();
    controller = SmxPerfil_controller(context);
    _originalValues = {
      for (final field in _profileFields)
        field: controller.controllerMain.rstSysUser10.getValue(field),
    };
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.transparent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    _buildProfileHeader(context),
                    const SizedBox(height: 8),
                    KeyedSubtree(
                      key: ValueKey(_formVersion),
                      child: _buildDatas(context),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDatas(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmxTextField(
            field: "SYSUSER10_NOMBRES",
            textInputType: SmxTextInputType.mayusculas,
            controller: controller,
            label: 'Nombres',
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          SmxTextField(
            field: "SYSUSER10_APELLIDOS",
            textInputType: SmxTextInputType.mayusculas,
            controller: controller,
            label: 'Apellidos',
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SmxTextField(
                  field: "SYSUSER10_TELEFONO",
                  textInputType: SmxTextInputType.phone,
                  controller: controller,
                  label: 'Teléfono',
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textTheme: Theme.of(context).textTheme.apply(
                      bodyColor: SmxColors.white,
                      displayColor: SmxColors.white,
                    ),
                    inputDecorationTheme: const InputDecorationTheme(
                      labelStyle: TextStyle(color: SmxColors.white70),
                      floatingLabelStyle: TextStyle(
                        color: SmxColors.brandAccent,
                        fontWeight: FontWeight.bold,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: SmxColors.white54),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: SmxColors.brandAccent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  child: SmxDatePicker(
                    field: "SYSUSER10_FECHA",
                    controller: controller,
                    label: 'Fecha Nacimiento',
                    withEmpty: false,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SmxTextField(
            field: "SYSUSER10_CORREO_01",
            controller: controller,
            textInputType: SmxTextInputType.email,
            label: 'Correo',
            color: Colors.white,
          ),
          const SizedBox(height: 16), // Espacio mínimo
          _buildAcceptButton(),
        ],
      ),
    );
  }

  Widget _buildAcceptButton() {
    final borderRadius = BorderRadius.circular(16);

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        elevation: 10,
        shadowColor: Colors.black.withValues(alpha: .32),
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 180,
          height: 56,
          child: Ink(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [SmxColors.brandAccent, SmxColors.brandSecondary],
              ),
            ),
            child: InkWell(
              onTap: () {
                if (!controller.showValida()) {
                  _restoreOriginalValues();
                  return;
                }

                controller.save();
                widget.onNavigateToHome();
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Acepta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _restoreOriginalValues() {
    for (final entry in _originalValues.entries) {
      controller.controllerMain.rstSysUser10.update(entry.key, entry.value);

      if (entry.value is DateTime) {
        controller.setDate(entry.key, entry.value as DateTime);
      } else {
        controller.setText(entry.key, entry.value?.toString() ?? '');
      }
    }

    setState(() {
      _formVersion++;
    });
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Círculo grande (avatar)
              InkWell(
                onTap: () {
                  _openUnderConstruction(context, 'Configuracion de perfil');
                },
                borderRadius: BorderRadius.circular(40),
                child: FutureBuilder<Uint8List>(
                  future: controller.getImagen(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey, // opcional
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    final imagen = snapshot.data;

                    return CircleAvatar(
                      radius: 50,
                      backgroundImage: imagen != null
                          ? MemoryImage(imagen)
                          : null,
                      child: imagen == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    );
                  },
                ),
              ),

              // Círculo pequeño (mano)
              InkWell(
                onTap: () {
                  _openUnderConstruction(context, 'Accion especial');
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.touch_app, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            controller.getNombres(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            controller.getCorreo(),
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

void _openUnderConstruction(BuildContext context, String title) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => SmxSaldiFyScreenTmp(title: title)),
  );
}
