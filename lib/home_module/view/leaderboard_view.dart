// leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _rangeIndex = 0;
  int _navIndex = 1;

  // Mock data
  final List<_User> top3 = const [
    _User(
      name: 'Andrew',
      xp: 872,
      avatar: 'https://i.pravatar.cc/120?img=12',
      medalColor: Color(0xFF9AD0FF),
    ),
    _User(
      name: 'Maryland',
      xp: 948,
      avatar: 'https://i.pravatar.cc/120?img=64',
      medalColor: Color(0xFFFFD66B),
    ),
    _User(
      name: 'Charlotte',
      xp: 769,
      avatar: 'https://i.pravatar.cc/120?img=32',
      medalColor: Color(0xFFFF9BC2),
    ),
  ];

  final List<_User> others = const [
    _User(
        name: 'Florencio Doll...',
        xp: 723,
        avatar: 'https://i.pravatar.cc/120?img=5'),
    _User(
        name: 'Roselle Ehram',
        xp: 640,
        avatar: 'https://i.pravatar.cc/120?img=47'),
    _User(
        name: 'Darron Kulino...',
        xp: 596,
        avatar: 'https://i.pravatar.cc/120?img=23'),
    _User(
        name: 'Darron Kulino...',
        xp: 596,
        avatar: 'https://i.pravatar.cc/120?img=23'),
    _User(
        name: 'Darron Kulino...',
        xp: 596,
        avatar: 'https://i.pravatar.cc/120?img=23'),
    _User(
        name: 'Darron Kulino...',
        xp: 596,
        avatar: 'https://i.pravatar.cc/120?img=23'),
    _User(
        name: 'Darron Kulino...',
        xp: 596,
        avatar: 'https://i.pravatar.cc/120?img=23'),
  ];

  @override
  Widget build(BuildContext context) {
    const gradientStart = Color(0xFF7D5CFF);
    const gradientEnd = Color(0xFF4E2FE3);
    const surface = Colors.white;
    const foreground = Colors.white;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _Pill(
                    label: 'Weekly',
                    selected: _rangeIndex == 0,
                    onTap: () => setState(() => _rangeIndex = 0),
                  ),
                  const SizedBox(width: 10),
                  _Pill(
                    label: 'Monthly',
                    selected: _rangeIndex == 1,
                    onTap: () => setState(() => _rangeIndex = 1),
                  ),
                  const SizedBox(width: 10),
                  _Pill(
                    label: 'All Time',
                    selected: _rangeIndex == 2,
                    onTap: () => setState(() => _rangeIndex = 2),
                  ),
                ],
              ),
            ),

            // Podium + Top 3
            const SizedBox(height: kToolbarHeight),
            _PodiumSection(
              top3: top3,
              foreground: foreground,
            ),

            // List card
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  itemCount: others.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final user = others[index];
                    final rank = index + 4;
                    return _RankTile(
                      rank: rank,
                      name: user.name,
                      xp: user.xp,
                      avatar: user.avatar,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PodiumSection extends StatelessWidget {
  const _PodiumSection({required this.top3, required this.foreground});

  final List<_User> top3;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    const double h1 = 160;
    const double h2 = 135;
    const double h3 = 120;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Subtle arc background
          Positioned.fill(
            top: 26,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.2),
                    radius: 1.1,
                    colors: [
                      Colors.white.withOpacity(.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Avatars + Names + XP chips
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _TopUserBadge(
                    user: top3[0],
                    // sits above second place column
                    offsetFromTop: 0,
                  ),
                ),
                Expanded(
                  child: _TopUserBadge(
                    user: top3[1],
                    // center winner avatar slightly higher
                    offsetFromTop: -30,
                  ),
                ),
                Expanded(
                  child: _TopUserBadge(
                    user: top3[2],
                    offsetFromTop: 0,
                  ),
                ),
              ],
            ),
          ),

          // Podium blocks
          const Padding(
            padding: EdgeInsets.only(top: 98),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _PodiumBlock(height: h2, label: '2')),
                SizedBox(width: 10),
                Expanded(child: _PodiumBlock(height: h1, label: '1')),
                SizedBox(width: 10),
                Expanded(child: _PodiumBlock(height: h3, label: '3')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumBlock extends StatelessWidget {
  const _PodiumBlock({required this.height, required this.label});

  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    const c1 = Color(0xFFB6A5FF);
    const c2 = Color(0xFF7D5CFF);

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c1, c2],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 56,
          height: 1.0,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TopUserBadge extends StatelessWidget {
  const _TopUserBadge({required this.user, this.offsetFromTop = 0});

  final _User user;
  final double offsetFromTop;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Transform.translate(
      offset: Offset(0, offsetFromTop),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withOpacity(.35),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(user.avatar),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: user.medalColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.military_tech,
                      size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.name,
            style: text.labelLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withOpacity(.35)),
            ),
            child: Text(
              '${user.xp} XP',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({
    required this.rank,
    required this.name,
    required this.xp,
    required this.avatar,
  });

  final int rank;
  final String name;
  final int xp;
  final String avatar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '$rank',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(radius: 18, backgroundImage: NetworkImage(avatar)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              Text(
                '$xp XP',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const selectedColor = Colors.white;
    final textColor = selected ? const Color(0xFF5A34E6) : Colors.white;
    final bg = selected ? selectedColor : Colors.white.withOpacity(.15);
    final border =
        selected ? Colors.transparent : Colors.white.withOpacity(.35);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: ShapeDecoration(
          color: bg,
          shape: StadiumBorder(side: BorderSide(color: border, width: 1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon(
      {required this.icon, required this.bg, required this.color});

  final IconData icon;
  final Color bg;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _User {
  final String name;
  final int xp;
  final String avatar;
  final Color medalColor;

  const _User({
    required this.name,
    required this.xp,
    required this.avatar,
    this.medalColor = Colors.white,
  });
}
