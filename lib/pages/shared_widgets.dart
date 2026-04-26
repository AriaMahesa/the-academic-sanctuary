// lib/pages/shared_widgets.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

// ─── Field Label ──────────────────────────────────────────────────────────────
class FieldLabel extends StatelessWidget {
  final String text;
  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.outlineVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Input Field ──────────────────────────────────────────────────────────────
class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final bool enabled;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const InputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.enabled = true,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        enabled: enabled,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurface),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle:
              GoogleFonts.inter(fontSize: 14, color: AppColors.outlineVariant),
          prefixIcon: Icon(icon, size: 18, color: AppColors.outlineVariant),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────
class ErrorBanner extends StatelessWidget {
  final String message;
  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Success Banner ───────────────────────────────────────────────────────────
class SuccessBanner extends StatelessWidget {
  final String message;
  const SuccessBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: Color(0xFF16A34A), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF16A34A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Gradient Button ──────────────────────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  const GradientButton({
    super.key,
    required this.isLoading,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedOpacity(
        opacity: isLoading ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: mainGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.30),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward,
                          color: Colors.white, size: 18),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Background Blob Decoration ───────────────────────────────────────────────
class BackgroundBlobs extends StatelessWidget {
  const BackgroundBlobs({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80, left: -60,
          child: Container(
            width: 320, height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryContainer.withOpacity(0.10),
            ),
          ),
        ),
        Positioned(
          bottom: -100, right: -60,
          child: Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tertiaryContainer.withOpacity(0.18),
            ),
          ),
        ),
      ],
    );
  }
}
