import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AgriTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const AgriTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AgriColors.textMain,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: AgriColors.surfaceWhite,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AgriColors.textMain,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AgriColors.inputBorder, width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AgriColors.inputBorder, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AgriColors.primaryGreen, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AgriFileUploadField extends StatelessWidget {
  final String label;
  final String? fileName;
  final VoidCallback onTap;

  const AgriFileUploadField({
    super.key,
    required this.label,
    this.fileName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AgriColors.surfaceWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AgriColors.inputBorder, width: 1.2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                fileName ?? label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: fileName != null ? AgriColors.textMain : AgriColors.textHint,
                  fontWeight: fileName != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              fileName != null ? Icons.check_circle : Icons.upload_file,
              color: fileName != null ? AgriColors.primaryGreen : AgriColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

