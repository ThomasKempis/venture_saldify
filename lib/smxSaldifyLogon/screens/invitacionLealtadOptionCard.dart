import 'package:flutter/material.dart';
import '../../smxApis/smxConfig.dart';

class InvitacionLealtadOptioncard extends StatelessWidget {
  final bool compact;
  final String remitente;
  final VoidCallback? onTap;

  const InvitacionLealtadOptioncard({
    super.key,
    required this.compact,
    required this.remitente,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 22.0 : 28.0;
    final descripcion = remitente.isEmpty
        ? 'Accede a beneficios exclusivos de la red ${SmxConfig.titulo} con tu código de lealtad validado.'
        : '$remitente te invita a participar en el programa de lealtad de ${SmxConfig.titulo}.';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4500).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.all(compact ? 20 : 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF8C00), // DarkOrange
                    Color(0xFFFF4500), // OrangeRed
                    Color(0xFFE63946), // Smx brand Red
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Efecto de brillo/fuego de fondo
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      size: compact ? 120 : 150,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BIENVENIDO A LEALTAD',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  'Invitación Premium',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: compact ? 22 : 26,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        descripcion,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: compact ? 14 : 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 22),
                      // El botón ahora es un componente interactivo real
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        elevation: 4,
                        shadowColor: Colors.black.withValues(alpha: 0.2),
                        child: InkWell(
                          onTap: onTap,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: compact ? 50 : 56,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'INGRESAR AHORA',
                                    style: TextStyle(
                                      color: Color(0xFFE63946),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: const Color(0xFFE63946),
                                    size: compact ? 20 : 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
