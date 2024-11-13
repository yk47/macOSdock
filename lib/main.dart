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
        backgroundColor: Colors.grey[600],
        body: Stack(
          children: [
            Positioned.fill(
              // Background Image
              child: Image.network(
                'https://res.cloudinary.com/dprkiyc1j/image/upload/v1731151515/macimage_era5dl.jpg',
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Dock(
                  //Icons Images
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

class _DockState<T> extends State<Dock<T>> with SingleTickerProviderStateMixin {
  late List<T> _items;
  int? _hoveringIndex;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _hoveringIndex = null;

    /// Using AnimationController for sliding icons animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    return GestureDetector(
      /// Using GestureDetector
      /// when we just click on the icon nothing will happen,
      /// when we drag the icon it will start anumation.
      onTap: () {
        _controller.forward();

        _startDrag(index);
      },
      child: Draggable<int>(
        data: index,
        onDragStarted: () {
          _controller.forward();
        },
        onDragEnd: (_) {
          _controller.reverse();
        },
        feedback: ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            color: Colors.transparent,
            child: widget.builder(_items[index]),
          ),
        ),
        // Icon out Dock size shrink.
        childWhenDragging: const SizedBox.shrink(),
        // when drag complete or cancle hoveringIndex Value Set to null
        onDragCompleted: () {
          setState(() {
            _hoveringIndex = null;
          });
        },
        onDraggableCanceled: (_, __) {
          setState(() {
            _hoveringIndex = null;
          });
        },
        child: DragTarget<int>(
          onAcceptWithDetails: (details) {
            /// seting old and new index
            /// Index or data value changes when we select or drag the Icon
            setState(() {
              final oldIndex = details.data;
              if (oldIndex != index) {
                final item = _items.removeAt(oldIndex);
                _items.insert(index > oldIndex ? index - 1 : index, item);
              }
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
            final isHovering = _hoveringIndex == index;
            final double gapPadding = isHovering ? 32.0 : 0.0;

            /// Setting Animation Padding to create the gap between two icons
            return AnimatedPadding(
              padding: EdgeInsets.only(left: gapPadding),
              duration: const Duration(milliseconds: 200),
              child: widget.builder(_items[index]),
            );
          },
        ),
      ),
    );
  }

  void _startDrag(int index) {
    _controller.forward();

    setState(() {});
  }
}
