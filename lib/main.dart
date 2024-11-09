import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[800],
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.network(
                'https://res.cloudinary.com/dprkiyc1j/image/upload/v1731151515/macimage_era5dl.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Dock menu at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Dock(
                  items: const [
                    'https://res.cloudinary.com/dprkiyc1j/image/upload/v1731135122/3d-mac-os-finder_nfxqni.png',
                    'https://res.cloudinary.com/dprkiyc1j/image/upload/v1731137370/macMonitor_zqiv68.png',
                    'https://res.cloudinary.com/dprkiyc1j/image/upload/v1731138138/termi_jvwcru.png',
                    'https://res.cloudinary.com/dprkiyc1j/image/upload/v1731135186/mail_p0p35q.png',
                    'https://res.cloudinary.com/dprkiyc1j/image/upload/v1731135054/macos-messages_lgb0ih.png',
                    'https://res.cloudinary.com/dprkiyc1j/image/upload/v1731135311/macos-calendar_z7xyj2.png',
                    'https://res.cloudinary.com/dprkiyc1j/image/upload/v1731135581/notes_be94gn.png',
                    'https://res.cloudinary.com/dprkiyc1j/image/upload/v1731135379/music_hj6hvj.png',
                    'https://res.cloudinary.com/dprkiyc1j/image/upload/v1731135438/reminders_fwlewx.png',
                  ],
                  builder: (url) {
                    return Container(
                      constraints: const BoxConstraints(minWidth: 48),
                      height: 48,
                      margin: const EdgeInsets.all(8),
                      child: Center(
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                        ),
                      ),
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

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> {
  late List<T> _items;
  int? _hoveringIndex;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _hoveringIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black26,
      ),
      padding: const EdgeInsets.all(4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length, (index) {
            return _buildDraggableItem(index);
          }),
        ),
      ),
    );
  }

  Widget _buildDraggableItem(int index) {
    return LongPressDraggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: widget.builder(_items[index]),
      ),
      childWhenDragging: const SizedBox.shrink(),
      child: DragTarget<int>(
        onAcceptWithDetails: (details) {
          setState(() {
            final oldIndex = details.data;
            final item = _items.removeAt(oldIndex);
            _items.insert(index, item);
            _hoveringIndex = null;
          });
        },
        onWillAcceptWithDetails: (details) {
          setState(() {
            _hoveringIndex = index;
          });
          return true;
        },
        onLeave: (_) {
          setState(() {
            _hoveringIndex = null;
          });
        },
        builder: (context, candidateData, rejectedData) {
          // Apply padding only between adjacent items when hovering
          final double leftPadding =
              (_hoveringIndex != null && _hoveringIndex == index - 1)
                  ? 12.0
                  : 0.0;
          final double rightPadding =
              (_hoveringIndex != null && _hoveringIndex == index + 1)
                  ? 12.0
                  : 0.0;

          return AnimatedPadding(
            padding: EdgeInsets.only(right: rightPadding, left: leftPadding),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: widget.builder(_items[index]),
          );
        },
      ),
    );
  }
}
