import 'package:flutter/material.dart';

class CommandButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double width;

  const CommandButton({
    required this.title,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.width,
    Key? key,
  }) : super(key: key);

  @override
  _CommandButtonState createState() => _CommandButtonState();
}

class _CommandButtonState extends State<CommandButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: InkWell(
        onTap: widget.onPressed,
        onHover: (hovering) {
          if (mounted)
          setState(() {
            isHovered = hovering;
          });
        },
        borderRadius: BorderRadius.circular(12.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 48,
          width: widget.width,
          decoration: BoxDecoration(
            color: isHovered ? Colors.deepPurpleAccent : Colors.deepPurple,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
                blurRadius: isHovered ? 12.0 : 6.0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // Handle long text
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
