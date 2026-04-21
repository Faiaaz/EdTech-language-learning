import 'package:flutter/material.dart';

/// Labeled field with icon, optional password visibility toggle,
/// controller, error text, and onChanged callback.
class LabeledField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  /// Sky / glass sign-up theme (blue labels, frosted pill fields).
  final bool glassStyle;

  const LabeledField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.errorText,
    this.onChanged,
    this.glassStyle = false,
  });

  @override
  State<LabeledField> createState() => _LabeledFieldState();
}

class _LabeledFieldState extends State<LabeledField> {
  bool _obscure = true;

  static const _fieldBlue = Color(0xFF1A4F8C);
  static const _fieldBorderGlass = Color(0xFFB3DFFA);

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final g = widget.glassStyle;

    final labelColor =
        g ? const Color(0xFF0090D4) : Colors.white;
    final borderColor = hasError
        ? const Color(0xFFFF2D2D)
        : (g ? _fieldBorderGlass : Colors.white);
    final iconColor = hasError
        ? const Color(0xFFFF2D2D)
        : (g ? _fieldBlue.withValues(alpha: 0.45) : Colors.white70);
    final textColor = g ? _fieldBlue : Colors.white;
    final hintColor =
        g ? _fieldBlue.withValues(alpha: 0.4) : Colors.white60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: g ? Colors.white.withValues(alpha: 0.55) : null,
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscure,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: g ? FontWeight.w500 : FontWeight.normal,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: hintColor, fontSize: 14),
              border: InputBorder.none,
              prefixIcon: Icon(
                widget.icon,
                color: iconColor,
                size: 20,
              ),
              suffixIcon: widget.isPassword
                  ? GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: iconColor,
                        size: 20,
                      ),
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: Color(0xFFFF2D2D),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
