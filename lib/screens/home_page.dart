import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../models/user_role.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.state, required this.onOpenMyProfile, required this.onOpenService});

  final AppState state;
  final void Function(BuildContext) onOpenMyProfile;
  final void Function(BuildContext, String) onOpenService;

  static const services = [
    'Electrician', 'Plumber', 'Painter', 'Carpenter', 'AC Repair', 'Gardener', 'Cleaning', 'Mechanic'
  ];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _query = '';
  String? _lastAutoOpenedFor;

  List<String> get _filteredServices {
    if (_query.trim().isEmpty) return HomePage.services;
    final lower = _query.toLowerCase();
    return HomePage.services.where((s) => s.toLowerCase().contains(lower)).toList();
  }

  bool _isExactMatch(String query) {
    final q = query.trim().toLowerCase();
    return HomePage.services.any((s) => s.toLowerCase() == q);
  }

  String? _primarySuggestion(String query) {
    if (query.trim().isEmpty) return null;
    final lower = query.toLowerCase();
    final results = HomePage.services
        .where((s) => s.toLowerCase().contains(lower))
        .toList();
    if (results.isEmpty) return null;
    // Prefer prefix matches, otherwise first contains match
    results.sort((a, b) {
      final aStarts = a.toLowerCase().startsWith(lower) ? 0 : 1;
      final bStarts = b.toLowerCase().startsWith(lower) ? 0 : 1;
      return aStarts.compareTo(bStarts);
    });
    return results.first;
  }

  List<String> _suggestServices(String query, {int maxResults = 3}) {
    if (query.trim().isEmpty) return const [];
    final lower = query.toLowerCase();

    // If we already have matches, no need to suggest alternatives.
    final matches = HomePage.services.where((s) => s.toLowerCase().contains(lower)).toList();
    if (matches.isNotEmpty) return const [];

    int distance(String a, String b) {
      final m = a.length;
      final n = b.length;
      final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
      for (var i = 0; i <= m; i++) dp[i][0] = i;
      for (var j = 0; j <= n; j++) dp[0][j] = j;
      for (var i = 1; i <= m; i++) {
        for (var j = 1; j <= n; j++) {
          final cost = a[i - 1] == b[j - 1] ? 0 : 1;
          dp[i][j] = [
            dp[i - 1][j] + 1, // deletion
            dp[i][j - 1] + 1, // insertion
            dp[i - 1][j - 1] + cost, // substitution
          ].reduce((v, e) => v < e ? v : e);
        }
      }
      return dp[m][n];
    }

    final scored = [
      for (final s in HomePage.services)
        MapEntry(s, distance(lower, s.toLowerCase()))
    ];
    scored.sort((a, b) => a.value.compareTo(b.value));
    return scored.take(maxResults).map((e) => e.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredServices;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Labor Service Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
            onPressed: () => Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => widget.onOpenMyProfile(context),
            tooltip: 'My Profile',
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 6),
          child: Column(
            children: [
              TextField(
                onChanged: (v) {
                  setState(() => _query = v);
                  // Only auto-open when there's an exact full-name match
                  if (_isExactMatch(v)) {
                    final matched = HomePage.services.firstWhere(
                          (s) => s.toLowerCase() == v.trim().toLowerCase(),
                    );
                    if (_lastAutoOpenedFor != matched) {
                      _lastAutoOpenedFor = matched;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                        widget.onOpenService(context, matched);
                      });
                    }
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search for services (e.g., Electrician)',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() {
                      _query = '';
                      _lastAutoOpenedFor = null;
                    }),
                    tooltip: 'Clear',
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Popular Services',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: HomePage.services.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final s = HomePage.services[index];
                    final selected = _query.toLowerCase() == s.toLowerCase();
                    return ChoiceChip(
                      label: Text(s),
                      selected: selected,
                      onSelected: (_) => setState(() => _query = s),
                      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: selected ? Theme.of(context).colorScheme.primary : null,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
              // Inline primary suggestion when there are matches but not an exact one
              if (_query.isNotEmpty && !_isExactMatch(_query))
                Builder(
                  builder: (context) {
                    final suggestion = _primarySuggestion(_query);
                    if (suggestion == null) return const SizedBox(height: 8);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() => _query = suggestion);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            widget.onOpenService(context, suggestion);
                          });
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.north_east, size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              'Suggestion: $suggestion',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 6),
              if (results.isEmpty)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'No services found',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.center,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in _suggestServices(_query))
                              ActionChip(
                                label: Text(s),
                                onPressed: () {
                                  setState(() => _query = s);
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (!mounted) return;
                                    widget.onOpenService(context, s);
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    itemCount: results.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.48,
                    ),
                    itemBuilder: (context, index) {
                      final s = results[index];
                      return _ServiceCard(
                        name: s,
                        onTap: () => widget.onOpenService(context, s),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Removed old rectangular service cards in favor of rounded round items below.

/// Restored rectangular service cards; removed round items.

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ColoredServiceIcon(name: name),
              const Spacer(),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              const Text('Tap to explore', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColoredServiceIcon extends StatelessWidget {
  const _ColoredServiceIcon({required this.name});

  final String name;

  IconData _iconFor(String s) {
    final t = s.toLowerCase();
    if (t.contains('electric')) return Icons.electrical_services;
    if (t.contains('plumb')) return Icons.plumbing;
    if (t.contains('paint')) return Icons.format_paint;
    if (t.contains('carpenter')) return Icons.chair_alt;
    if (t.contains('ac')) return Icons.ac_unit;
    if (t.contains('garden')) return Icons.yard;
    if (t.contains('clean')) return Icons.cleaning_services;
    if (t.contains('mechanic')) return Icons.build_circle;
    return Icons.handyman;
  }

  List<Color> _colorsFor(String s, BuildContext context) {
    final palette = [
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.cyan,
    ];
    final idx = name.codeUnits.fold<int>(0, (p, c) => (p + c)) % palette.length;
    final base = palette[idx];
    return [base.withOpacity(0.18), base.withOpacity(0.06)];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(name, context);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        _iconFor(name),
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}


