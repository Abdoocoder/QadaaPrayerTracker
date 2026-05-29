import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class ToggleTile extends StatefulWidget {
  final String name;
  final String time;
  final bool completed;
  final VoidCallback onToggle;

  const ToggleTile({super.key, required this.name, required this.time, required this.completed, required this.onToggle});

  @override
  State<ToggleTile> createState() => _ToggleTileState();
}

class _ToggleTileState extends State<ToggleTile> with SingleTickerProviderStateMixin {
  late bool _done;
  late AnimationController _animController;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _done = widget.completed;
    _animController = AnimationController(vsync: this, duration: AppTheme.durationFast);
    _scale = CurvedAnimation(parent: _animController, curve: AppTheme.springOut);
    if (_done) _animController.value = 1;
  }

  @override
  void didUpdateWidget(ToggleTile old) {
    super.didUpdateWidget(old);
    if (widget.completed != _done) {
      _done = widget.completed;
      if (_done) { _animController.forward(); } else { _animController.reverse(); }
    }
  }

  @override
  void dispose() { _animController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        onTap: widget.onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg, vertical: AppTheme.spaceMd),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onToggle,
                child: AnimatedBuilder(
                  animation: _scale,
                  builder: (_, child) => Transform.scale(scale: 0.85 + _scale.value * 0.15, child: child),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: _done ? AppTheme.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: _done ? AppTheme.primary : AppTheme.outline, width: 2),
                    ),
                    child: _done ? const Icon(Icons.check, size: 16, color: AppTheme.onPrimary) : null,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceLg),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.name, style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 15, fontWeight: FontWeight.w600, color: _done ? AppTheme.onSurfaceVariant : AppTheme.onSurface, decoration: _done ? TextDecoration.lineThrough : null)),
              ])),
              Text(widget.time, style: const TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.outline)),
            ],
          ),
        ),
      ),
    );
  }
}
