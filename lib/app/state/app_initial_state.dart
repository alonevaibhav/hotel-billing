import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AsyncStateBuilder<T extends GetxController> extends StatelessWidget {
  final T controller;
  final RxBool isLoading;
  final RxString errorMessage;
  final Widget Function(T controller) builder;

  // Optional features
  final VoidCallback? onRetry;
  final bool Function(T controller)? isEmpty;
  final Future<void> Function()? onRefresh;
  final double? scaleFactor;

  // Customization
  final String? loadingText;
  final String? emptyStateText;
  final String? errorTitle;
  final Widget? customLoadingWidget;
  final Widget? customErrorWidget;
  final Widget? customEmptyWidget;

  const AsyncStateBuilder({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.errorMessage,
    required this.builder,
    this.onRetry,
    this.isEmpty,
    this.onRefresh,
    this.scaleFactor = 0.8,
    this.loadingText,
    this.emptyStateText,
    this.errorTitle,
    this.customLoadingWidget,
    this.customErrorWidget,
    this.customEmptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Fast-path: Loading state (most common initial state)
      if (isLoading.value) {
        return customLoadingWidget ??
            _LoadingState(scaleFactor: scaleFactor!, text: loadingText);
      }

      // Fast-path: Error state
      final error = errorMessage.value;
      if (error.isNotEmpty) {
        return customErrorWidget ??
            _ErrorState(
              scaleFactor: scaleFactor!,
              errorMessage: error,
              errorTitle: errorTitle,
              onRetry: onRetry,
            );
      }

      // Fast-path: Empty state
      if (isEmpty != null && isEmpty!(controller)) {
        return customEmptyWidget ??
            _EmptyState(scaleFactor: scaleFactor!, text: emptyStateText);
      }

      // Success state
      final content = builder(controller);

      return onRefresh != null
          ? RefreshIndicator(
        onRefresh: onRefresh!,
        color: Colors.green[600],
        child: content,
      )
          : content;
    });
  }
}

// ==================== ENHANCED STATE WIDGETS ====================

class _LoadingState extends StatefulWidget {
  final double scaleFactor;
  final String? text;

  const _LoadingState({required this.scaleFactor, this.text});

  @override
  State<_LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<_LoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decorative circles background
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsing circle
                    Container(
                      width: 120.w * widget.scaleFactor,
                      height: 120.h * widget.scaleFactor,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.green.withOpacity(0.1),
                            Colors.green.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                    // Middle circle
                    Container(
                      width: 80.w * widget.scaleFactor,
                      height: 80.h * widget.scaleFactor,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withOpacity(0.05),
                      ),
                    ),
                    // Animated loading indicator
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 56.w * widget.scaleFactor,
                        height: 56.h * widget.scaleFactor,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.green.withOpacity(0.2),
                          //     blurRadius: 20,
                          //     spreadRadius: 5,
                          //   ),
                          // ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12.w * widget.scaleFactor),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green[600]!,
                            ),
                            strokeWidth: 3.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(28.h * widget.scaleFactor),
                Text(
                  widget.text ?? 'Loading...',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp * widget.scaleFactor,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                Gap(8.h * widget.scaleFactor),
                Text(
                  'Please wait a moment',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp * widget.scaleFactor,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatefulWidget {
  final double scaleFactor;
  final String errorMessage;
  final String? errorTitle;
  final VoidCallback? onRetry;

  const _ErrorState({
    required this.scaleFactor,
    required this.errorMessage,
    this.errorTitle,
    this.onRetry,
  });

  @override
  State<_ErrorState> createState() => _ErrorStateState();
}

class _ErrorStateState extends State<_ErrorState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Padding(
              padding: EdgeInsets.all(32.w * widget.scaleFactor),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Error icon with background
                  Container(
                    width: 100.w * widget.scaleFactor,
                    height: 100.h * widget.scaleFactor,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red[50]!,
                          Colors.red[100]!,
                        ],
                      ),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.red.withOpacity(0.15),
                      //     blurRadius: 25,
                      //     spreadRadius: 5,
                      //   ),
                      // ],
                    ),
                    child: Icon(
                      PhosphorIcons.warningCircle(PhosphorIconsStyle.fill),
                      size: 52.sp * widget.scaleFactor,
                      color: Colors.red[500],
                    ),
                  ),
                  Gap(24.h * widget.scaleFactor),
                  // Error title
                  Text(
                    widget.errorTitle ?? 'Oops! Something went wrong',
                    style: GoogleFonts.inter(
                      fontSize: 20.sp * widget.scaleFactor,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Gap(12.h * widget.scaleFactor),
                  // Error message with container
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w * widget.scaleFactor,
                      vertical: 12.h * widget.scaleFactor,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12.r * widget.scaleFactor),
                      border: Border.all(
                        color: Colors.red[100]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.errorMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp * widget.scaleFactor,
                        color: Colors.red[800],
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (widget.onRetry != null) ...[
                    Gap(32.h * widget.scaleFactor),
                    // Retry button with gradient
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r * widget.scaleFactor),
                        gradient: LinearGradient(
                          colors: [Colors.green[500]!, Colors.green[700]!],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: widget.onRetry,
                        icon: Icon(
                          PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.bold),
                          size: 18.sp * widget.scaleFactor,
                        ),
                        label: Text(
                          'Try Again',
                          style: GoogleFonts.inter(
                            fontSize: 15.sp * widget.scaleFactor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w * widget.scaleFactor,
                            vertical: 16.h * widget.scaleFactor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r * widget.scaleFactor),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatefulWidget {
  final double scaleFactor;
  final String? text;

  const _EmptyState({required this.scaleFactor, this.text});

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Floating icon with background
              Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Container(
                  width: 140.w * widget.scaleFactor,
                  height: 140.h * widget.scaleFactor,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blue[50]!,
                        Colors.purple[50]!,
                      ],
                    ),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.blue.withOpacity(0.15),
                    //     blurRadius: 30,
                    //     spreadRadius: 10,
                    //   ),
                    // ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Decorative dots
                      Positioned(
                        top: 25,
                        right: 25,
                        child: Container(
                          width: 8.w * widget.scaleFactor,
                          height: 8.h * widget.scaleFactor,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue[300],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        left: 30,
                        child: Container(
                          width: 6.w * widget.scaleFactor,
                          height: 6.h * widget.scaleFactor,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.purple[300],
                          ),
                        ),
                      ),
                      // Main icon
                      Icon(
                        PhosphorIcons.package(PhosphorIconsStyle.duotone),
                        size: 64.sp * widget.scaleFactor,
                        color: Colors.blue[400],
                      ),
                    ],
                  ),
                ),
              ),
              Gap(32.h * widget.scaleFactor),
              // Title
              Text(
                widget.text ?? 'No Data Yet',
                style: GoogleFonts.inter(
                  fontSize: 22.sp * widget.scaleFactor,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              Gap(10.h * widget.scaleFactor),
              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w * widget.scaleFactor),
                child: Text(
                  'Theres nothing here right now.\nCheck back later or add something new!',
                textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp * widget.scaleFactor,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}