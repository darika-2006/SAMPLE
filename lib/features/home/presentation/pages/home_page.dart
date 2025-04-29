import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Campus Connect',
          style: TextStyle(
            color: AppColors.marineBluePrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          NotificationBadge(),
          const SizedBox(width: 8),
          ProfileAvatar(),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    FeatureCard(
                      title: 'Lost & Found',
                      icon: Icons.search,
                      description: 'Report or find lost items',
                      color: AppColors.marineBluePrimary,
                      status: 'Active items: 12',
                    ),
                    FeatureCard(
                      title: 'Announcements',
                      icon: Icons.campaign_outlined,
                      description: 'Stay updated with campus news',
                      color: AppColors.redSecondary,
                      status: 'New updates: 3',
                    ),
                    FeatureCard(
                      title: 'Events',
                      icon: Icons.event_available_outlined,
                      description: 'Discover campus events',
                      color: AppColors.lightTealAccent,
                      status: 'Today: 5 events',
                    ),
                    FeatureCard(
                      title: 'Clubs',
                      icon: Icons.groups_outlined,
                      description: 'Join and manage clubs',
                      color: Colors.orange,
                      status: 'Active clubs: 25',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.notifications_outlined,
              color: AppColors.marineBluePrimary),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.redSecondary,
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {},
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.marineBluePrimary.withOpacity(0.1),
      child: IconButton(
        icon: const Icon(Icons.person_outline, size: 20),
        color: AppColors.marineBluePrimary,
        onPressed: () {},
      ),
    );
  }
}

class WelcomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back,',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Student!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.marineBluePrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final Color color;
  final String status;

  const FeatureCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.color,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: color.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: color.withOpacity(0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
