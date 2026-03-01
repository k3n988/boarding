import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Rently Brand Colors  (from logo: deep navy + green + gold keyhole)
// ─────────────────────────────────────────────────────────────────────────────
class _R {
  static const navy       = Color(0xFF1B2A6B);
  static const green      = Color(0xFF2EB85C);
  static const greenDark  = Color(0xFF1E9448);
  static const greenLight = Color(0xFFE8F8EE);
  static const gold       = Color(0xFFE8A020);
  static const divider    = Color(0xFFE8EDF2);
  static const textMain   = Color(0xFF0D1B3E);
  static const textSub    = Color(0xFF6B7A99);
}

// ─────────────────────────────────────────────────────────────────────────────
// Sample data for AI results
// ─────────────────────────────────────────────────────────────────────────────
class _AISampleProperty {
  final String name, location, price, type;
  final List<String> amenities;
  final double rating;
  final String distanceNote;
  const _AISampleProperty({
    required this.name,
    required this.location,
    required this.price,
    required this.type,
    required this.amenities,
    required this.rating,
    required this.distanceNote,
  });
}

const _kSampleProperties = [
  _AISampleProperty(
    name: 'Sunshine Boarding House',
    location: 'Bacolod City – 5 min walk to USLS',
    price: '₱4,500/mo',
    type: 'Boarding House',
    amenities: ['Wi-Fi', 'Aircon', 'Study Area'],
    rating: 4.8,
    distanceNote: '~350 m from USLS',
  ),
  _AISampleProperty(
    name: 'La Paz Dormitory',
    location: 'La Paz, Bacolod – near USLS',
    price: '₱5,200/mo',
    type: 'Dormitory',
    amenities: ['Wi-Fi', 'Aircon', 'Study Lounge', 'CCTV'],
    rating: 4.6,
    distanceNote: '~500 m from USLS',
  ),
  _AISampleProperty(
    name: 'StudyNest Bedspace',
    location: 'General Luna St, Bacolod',
    price: '₱3,800/mo',
    type: 'Bedspace',
    amenities: ['Wi-Fi', 'Aircon', 'Quiet Zone'],
    rating: 4.5,
    distanceNote: '~600 m from USLS',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// AIBanner — tap to open Rently AI chat
// ─────────────────────────────────────────────────────────────────────────────
class AIBanner extends StatelessWidget {
  const AIBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _AIBottomSheet.show(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEEF1FF), Color(0xFFE6F9EE)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _R.green, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: _R.navy.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_R.green, _R.greenDark],
                    ),
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(
                        color: _R.green.withOpacity(0.30),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Need help? Ask Rently AI",
                          style: TextStyle(
                              color: _R.textMain,
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                      SizedBox(height: 2),
                      Text("Find your perfect room in seconds",
                          style: TextStyle(
                              color: _R.textSub,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _R.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Try it',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Chat Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _AIBottomSheet extends StatefulWidget {
  const _AIBottomSheet();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AIBottomSheet(),
    );
  }

  @override
  State<_AIBottomSheet> createState() => _AIBottomSheetState();
}

enum _MsgRole { user, ai }

class _ChatMessage {
  final _MsgRole role;
  final String text;
  final bool showCards;
  const _ChatMessage(
      {required this.role, required this.text, this.showCards = false});
}

class _AIBottomSheetState extends State<_AIBottomSheet> {
  final TextEditingController _ctrl   = TextEditingController();
  final ScrollController      _scroll = ScrollController();
  final List<_ChatMessage>    _messages = [];
  bool _isTyping = false;

  static const _suggestions = [
    "USLS student, ₱4K–₱6K, Wi-Fi + aircon",
    "Near CPU, solo room, ₱3,500",
    "Female dorm near UP Visayas",
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 300,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    setState(() {
      _messages.add(_ChatMessage(role: _MsgRole.user, text: text.trim()));
      _isTyping = true;
    });
    _scrollToBottom();
    await Future.delayed(const Duration(milliseconds: 1400));
    final isUSLS = text.toLowerCase().contains('usls') ||
        text.toLowerCase().contains('4k') ||
        text.toLowerCase().contains('aircon');
    setState(() {
      _isTyping = false;
      _messages.add(_ChatMessage(
        role: _MsgRole.ai,
        text: isUSLS
            ? "Great news! 🎉 I found **3 verified listings** near USLS that match your budget of ₱4,000–₱6,000/month with Wi-Fi, aircon, and a study area. All are within walking distance from campus and recently verified by our team."
            : "I found listings matching your request! Here are the top picks based on your preferences.",
        showCards: true,
      ));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, __) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: _R.divider,
                  borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(height: 16),
            // ── Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_R.green, _R.navy]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rently AI',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _R.textMain)),
                      Text('Finds your perfect room instantly',
                          style: const TextStyle(
                              fontSize: 11.5, color: _R.textSub)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: _R.divider, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: _R.textSub),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Divider(color: _R.divider, height: 20),
            // ── Messages
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount:
                          _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (_isTyping && i == _messages.length) {
                          return _buildTypingIndicator();
                        }
                        final msg = _messages[i];
                        return msg.role == _MsgRole.user
                            ? _buildUserBubble(msg.text)
                            : _buildAIBubble(msg);
                      },
                    ),
            ),
            _buildInputArea(bottomPad),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text('What are you looking for? 👇',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _R.textSub)),
          const SizedBox(height: 16),
          ..._suggestions.map((s) => GestureDetector(
                onTap: () => _sendMessage(s),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: _R.greenLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: _R.green.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded,
                          size: 16, color: _R.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(s,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _R.textMain)),
                      ),
                      const Icon(Icons.north_east_rounded,
                          size: 14, color: _R.green),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildUserBubble(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [_R.navy, Color(0xFF243580)]),
                  borderRadius: BorderRadius.only(
                    topLeft:     Radius.circular(16),
                    topRight:    Radius.circular(16),
                    bottomLeft:  Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(text,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      );

  Widget _buildAIBubble(_ChatMessage msg) {
    final spans = _parseBold(msg.text);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30, height: 30,
            margin: const EdgeInsets.only(right: 10, top: 2),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_R.green, _R.navy]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 14),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _R.greenLight,
                    borderRadius: const BorderRadius.only(
                      topLeft:     Radius.circular(4),
                      topRight:    Radius.circular(16),
                      bottomLeft:  Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(
                        color: _R.green.withOpacity(0.2), width: 0.5),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: _R.textMain, fontSize: 14, height: 1.5),
                      children: spans,
                    ),
                  ),
                ),
                if (msg.showCards) ...[
                  const SizedBox(height: 12),
                  ..._kSampleProperties.map(_buildPropertyCard),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(_AISampleProperty p) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _R.divider),
          boxShadow: [
            BoxShadow(
              color: _R.navy.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(p.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _R.textMain)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: _R.greenLight,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: _R.gold),
                      const SizedBox(width: 3),
                      Text(p.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _R.textMain)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: _R.textSub),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(p.location,
                      style: const TextStyle(
                          fontSize: 12, color: _R.textSub),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _R.greenLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _R.green.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded,
                          size: 12, color: _R.green),
                      SizedBox(width: 3),
                      Text('Verified',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _R.green)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEEF1FF),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(p.type,
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _R.navy)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: p.amenities
                  .map((a) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: _R.divider,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(a,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: _R.textMain)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(p.price,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _R.navy)),
                Row(
                  children: [
                    const Icon(Icons.directions_walk_rounded,
                        size: 13, color: _R.green),
                    const SizedBox(width: 3),
                    Text(p.distanceNote,
                        style: const TextStyle(
                            fontSize: 11,
                            color: _R.green,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: _R.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('View Details',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      );

  Widget _buildTypingIndicator() => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 30, height: 30,
              margin: const EdgeInsets.only(right: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_R.green, _R.navy]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 14),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: _R.greenLight,
                  borderRadius: BorderRadius.circular(16)),
              child: _TypingDots(),
            ),
          ],
        ),
      );

  Widget _buildInputArea(double bottomPad) => Container(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottomPad),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _R.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _R.divider),
                ),
                child: TextField(
                  controller: _ctrl,
                  maxLines: 3,
                  minLines: 1,
                  cursorColor: _R.green,
                  decoration: const InputDecoration(
                    hintText: 'Describe what you\'re looking for...',
                    hintStyle:
                        TextStyle(color: _R.textSub, fontSize: 14),
                    border:         InputBorder.none,
                    isDense:        true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: _sendMessage,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => _sendMessage(_ctrl.text),
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_R.green, _R.greenDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _R.green.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      );

  List<TextSpan> _parseBold(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int last = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
            fontWeight: FontWeight.w700, color: _R.navy),
      ));
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return spans;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Typing dots
// ─────────────────────────────────────────────────────────────────────────────
class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = (_ctrl.value - i * 0.2).clamp(0.0, 1.0);
          final opacity =
              (0.3 + 0.7 * (t < 0.5 ? t * 2 : (1.0 - t) * 2))
                  .clamp(0.0, 1.0);
          return Container(
            margin: EdgeInsets.only(right: i < 2 ? 4.0 : 0),
            width: 7, height: 7,
            decoration: BoxDecoration(
              color: _R.green.withOpacity(opacity),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}