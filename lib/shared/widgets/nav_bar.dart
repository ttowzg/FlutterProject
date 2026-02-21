import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  final String role; 
  final Function(int) onDestinationSelected;

  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.role,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Destino padrão para todos os perfis
    final List<NavigationDestination> destinations = [
      const NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'Programação',
      ),
    ];

    // Adiciona abas específicas conforme o papel definido no Firestore
    if (role == 'aluno') {
      destinations.add(const NavigationDestination(icon: Icon(Icons.bookmark_border), label: 'Agenda'));
      destinations.add(const NavigationDestination(icon: Icon(Icons.check_circle_outline), label: 'Check-in'));
    } else if (role == 'palestrante') {
      destinations.add(const NavigationDestination(icon: Icon(Icons.question_answer_outlined), label: 'Perguntas'));
    } else if (role == 'organizador') {
      destinations.add(const NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), label: 'Gestão'));
    }

    // Perfil é comum a todos
    destinations.add(const NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'));

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
    );
  }
}