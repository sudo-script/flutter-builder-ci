import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(onTap: () => context.go('/dashboard'), child: const Text('←', style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 22))),
                  SizedBox(width: 60),
                  const Text('Profile', style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 32),
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(color: const Color(0xFF1E293B), shape: BoxShape.circle),
                child: Center(child: Text('👤', style: TextStyle(fontSize: 40, color: Color(0xFF94A3B8)))),
              ),
              SizedBox(height: 16),
              const Text('John Doe', style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              const Text('john@email.com', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              SizedBox(height: 4),
              const Text('Member since Jan 2026', style: TextStyle(color: Color(0xFF475569), fontSize: 11)),
              SizedBox(height: 28),
              Align(alignment: Alignment.centerLeft, child: const Text('STATS', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold))),
              SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(value: '142', label: 'Completed', color: const Color(0xFF3B82F6)),
                  SizedBox(width: 9),
                  _StatCard(value: '8', label: 'Pending', color: const Color(0xFFF59E0B)),
                  SizedBox(width: 9),
                  _StatCard(value: '12', label: 'Day streak', color: const Color(0xFF22C55E)),
                ],
              ),
              SizedBox(height: 28),
              Align(alignment: Alignment.centerLeft, child: const Text('SETTINGS', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold))),
              SizedBox(height: 12),
              _SettingsRow(icon: '🔔', label: 'Notifications', hasArrow: true),
              SizedBox(height: 8),
              _SettingsRow(icon: '🌙', label: 'Dark Mode', hasArrow: false),
              SizedBox(height: 8),
              _SettingsRow(icon: '📊', label: 'Export Data', hasArrow: true),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C1917),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: Color(0xFFEF4444), width: 1),
                  ),
                  child: const Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444), fontSize: 15)),
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
