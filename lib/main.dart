import 'package:flutter/material.dart';

void main() {
  runApp(const ShartenduOS());
}

class ShartenduOS extends StatelessWidget {
  const ShartenduOS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shartendu OS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3F5185),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shartendu OS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good Morning, Shartendu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'आज क्या महत्वपूर्ण है?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 20),

              _sectionTitle('Today'),
              const SizedBox(height: 10),

              _dashboardCard(
                icon: Icons.task_alt,
                title: 'Today\'s Priorities',
                subtitle: 'आज के महत्वपूर्ण काम',
              ),

              const SizedBox(height: 12),

              _dashboardCard(
                icon: Icons.timer_outlined,
                title: 'Focus',
                subtitle: 'एक समय में एक महत्वपूर्ण काम',
              ),

              const SizedBox(height: 20),

              _sectionTitle('Personal Growth'),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _smallCard(
                      icon: Icons.menu_book_outlined,
                      title: 'Knowledge',
                      subtitle: 'Knowledge Vault',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _smallCard(
                      icon: Icons.psychology_outlined,
                      title: 'Reflection',
                      subtitle: 'आज का आत्मचिंतन',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _dashboardCard(
                icon: Icons.explore_outlined,
                title: 'Decision Journal',
                subtitle: 'अपने निर्णय और उनके परिणाम दर्ज करें',
              ),

              const SizedBox(height: 20),

              _sectionTitle('Quick Capture'),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _quickAction(
                      icon: Icons.add_task,
                      label: 'Task',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _quickAction(
                      icon: Icons.lightbulb_outline,
                      label: 'Idea',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _quickAction(
                      icon: Icons.note_add_outlined,
                      label: 'Knowledge',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  Widget _smallCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
  }) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }
}
