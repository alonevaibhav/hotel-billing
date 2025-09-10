// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gap/gap.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import '../../app/core/constants/color_constant.dart';
//
// class CommonUiUtils {
//   static const double sizeFactor = 0.75; // Size constant variable
//
//   /// Simple Text Widget
//   static Widget buildText({
//     required String text,
//     required TextStyle style,
//     TextAlign? textAlign,
//     int? maxLines,
//     TextOverflow? overflow,
//   }) {
//     return Text(
//       text,
//       style: style,
//       textAlign: textAlign,
//       maxLines: maxLines,
//       overflow: overflow,
//     );
//   }
//
//   static Widget buildStepHeader(String title, [String? subtitle]) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         buildText(
//           text: title,
//           style: GoogleFonts.poppins(
//             fontSize: 22.sp * sizeFactor,
//             fontWeight: FontWeight.w700,
//             color: AppColors.primaryGreen,
//           ),
//         ),
//         if (subtitle != null && subtitle.trim().isNotEmpty) ...[
//           Gap(6.h * sizeFactor),
//           buildText(
//             text: subtitle,
//             style: GoogleFonts.poppins(
//               fontSize: 14.sp * sizeFactor,
//               color: AppColors.textSecondary,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ],
//       ],
//     );
//   }
//
//   /// Calendar Date Picker Field
//   static Widget buildDatePickerField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     String? Function(String?)? validator,
//     String? errorText,
//     DateTime? initialDate,
//     DateTime? firstDate,
//     DateTime? lastDate,
//     String dateFormat = 'dd/MM/yyyy',
//     ValueChanged<DateTime>? onDateSelected,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         buildText(
//           text: label,
//           style: GoogleFonts.poppins(
//             fontSize: 16.sp * sizeFactor,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         Gap(8.h * sizeFactor),
//         TextFormField(
//           controller: controller,
//           readOnly: true,
//           style: GoogleFonts.poppins(fontSize: 20.sp * sizeFactor),
//           validator: validator,
//           onTap: () async {
//             final selectedDate = await _showCustomDatePicker(
//               context: controller.text.isNotEmpty
//                   ? null
//                   : null, // This needs proper context
//               initialDate: initialDate ?? DateTime.now(),
//               firstDate: firstDate ?? DateTime(1900),
//               lastDate: lastDate ?? DateTime(2100),
//             );
//
//             if (selectedDate != null) {
//               controller.text = DateFormat(dateFormat).format(selectedDate);
//               if (onDateSelected != null) {
//                 onDateSelected(selectedDate);
//               }
//             }
//           },
//           decoration: InputDecoration(
//             hintText: hint,
//             prefixIcon: Icon(icon,
//                 color: AppColors.primaryGreen, size: 20.w * sizeFactor),
//             suffixIcon: Icon(
//               PhosphorIcons.caretDown(PhosphorIconsStyle.regular),
//               color: AppColors.textSecondary,
//               size: 16.w * sizeFactor,
//             ),
//             filled: true,
//             fillColor: AppColors.background,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r * sizeFactor),
//               borderSide:
//                   BorderSide(color: AppColors.lightGreen.withOpacity(0.3)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r * sizeFactor),
//               borderSide:
//                   BorderSide(color: AppColors.lightGreen.withOpacity(0.3)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r * sizeFactor),
//               borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r * sizeFactor),
//               borderSide: BorderSide(color: AppColors.error, width: 1),
//             ),
//             focusedErrorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r * sizeFactor),
//               borderSide: BorderSide(color: AppColors.error, width: 2),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16.w * sizeFactor, vertical: 16.h * sizeFactor),
//             errorText: errorText,
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// Custom Date Picker with attractive design
//   static Future<DateTime?> _showCustomDatePicker({
//     required BuildContext?
//         context, // Made nullable since we can't always pass context
//     required DateTime initialDate,
//     required DateTime firstDate,
//     required DateTime lastDate,
//   }) async {
//     if (context == null) return null; // Return null if no context provided
//
//     return showDialog<DateTime>(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           child: Container(
//             width: 350.w * sizeFactor,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20.r * sizeFactor),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.primaryGreen.withOpacity(0.1),
//                   blurRadius: 20,
//                   offset: const Offset(0, 10),
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Header
//                 Container(
//                   padding: EdgeInsets.all(20.w * sizeFactor),
//                   decoration: BoxDecoration(
//                     color: AppColors.primaryGreen.withOpacity(0.1),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(20.r * sizeFactor),
//                       topRight: Radius.circular(20.r * sizeFactor),
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         PhosphorIcons.calendar(PhosphorIconsStyle.fill),
//                         color: AppColors.primaryGreen,
//                         size: 24.w * sizeFactor,
//                       ),
//                       Gap(12.w * sizeFactor),
//                       Text(
//                         'Select Date',
//                         style: GoogleFonts.poppins(
//                           fontSize: 18.sp * sizeFactor,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.primaryGreen,
//                         ),
//                       ),
//                       const Spacer(),
//                       InkWell(
//                         onTap: () => Navigator.of(context).pop(),
//                         borderRadius: BorderRadius.circular(20.r * sizeFactor),
//                         child: Container(
//                           padding: EdgeInsets.all(8.w * sizeFactor),
//                           child: Icon(
//                             Icons.close,
//                             color: AppColors.textSecondary,
//                             size: 20.w * sizeFactor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Calendar
//                 Padding(
//                   padding: EdgeInsets.all(20.w * sizeFactor),
//                   child: Theme(
//                     data: Theme.of(context).copyWith(
//                       colorScheme: ColorScheme.light(
//                         primary: AppColors.primaryGreen,
//                         onPrimary: Colors.white,
//                         surface: Colors.white,
//                         onSurface: AppColors.textPrimary,
//                       ),
//                       textTheme: TextTheme(
//                         headlineSmall: GoogleFonts.poppins(
//                           fontSize: 20.sp * sizeFactor,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.textPrimary,
//                         ),
//                         bodyLarge: GoogleFonts.poppins(
//                           fontSize: 14.sp * sizeFactor,
//                           color: AppColors.textPrimary,
//                         ),
//                         bodyMedium: GoogleFonts.poppins(
//                           fontSize: 12.sp * sizeFactor,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ),
//                     child: CalendarDatePicker(
//                       initialDate: initialDate,
//                       firstDate: firstDate,
//                       lastDate: lastDate,
//                       onDateChanged: (DateTime date) {
//                         Navigator.of(context).pop(date);
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   static Widget buildTextFormField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//     int maxLines = 1,
//     int? maxLength,
//     String? Function(String?)? validator,
//     String? errorText,
//     ValueChanged<String>? onChanged,
//     GestureTapCallback? onTap,
//     bool readOnly = false,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         buildText(
//           text: label,
//           style: GoogleFonts.poppins(
//             fontSize: 16.sp * sizeFactor,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         Gap(8.h * sizeFactor),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           maxLines: maxLines,
//           maxLength: maxLength,
//           style: GoogleFonts.poppins(fontSize: 16.sp * sizeFactor),
//           validator: validator,
//           onChanged: onChanged,
//           onTap: onTap,
//           readOnly: readOnly,
//           decoration: InputDecoration(
//             hintText: hint,
//             prefixIcon: Icon(icon,
//                 color: AppColors.primaryGreen, size: 20.w * sizeFactor),
//             filled: true,
//             fillColor: AppColors.background,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r * sizeFactor),
//               borderSide:
//                   BorderSide(color: AppColors.lightGreen.withOpacity(0.3)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r * sizeFactor),
//               borderSide:
//                   BorderSide(color: AppColors.lightGreen.withOpacity(0.3)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r * sizeFactor),
//               borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
//             ),
//             errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r * sizeFactor),
//               borderSide: BorderSide(color: AppColors.error, width: 1),
//             ),
//             focusedErrorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r * sizeFactor),
//               borderSide: BorderSide(color: AppColors.error, width: 2),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16.w * sizeFactor, vertical: 16.h * sizeFactor),
//             errorText: errorText,
//           ),
//         ),
//       ],
//     );
//   }
//
//   static Widget buildDropdownField({
//     required String label,
//     required String? value,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//     required IconData icon,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         buildText(
//           text: label,
//           style: GoogleFonts.poppins(
//             fontSize: 16.sp * sizeFactor,
//             fontWeight: FontWeight.w600,
//             color: AppColors.textPrimary,
//           ),
//         ),
//         Gap(8.h * sizeFactor),
//         DropdownButtonFormField<String>(
//           value: value == null || value.isEmpty ? null : value,
//           items: items.map((item) {
//             return DropdownMenuItem(
//               value: item,
//               child: Text(
//                 item,
//                 style: GoogleFonts.poppins(fontSize: 16.sp * sizeFactor),
//               ),
//             );
//           }).toList(),
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             prefixIcon: Icon(icon,
//                 color: AppColors.primaryGreen, size: 20.w * sizeFactor),
//             filled: true,
//             fillColor: AppColors.background,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r * sizeFactor),
//               borderSide:
//                   BorderSide(color: AppColors.lightGreen.withOpacity(0.3)),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r * sizeFactor),
//               borderSide:
//                   BorderSide(color: AppColors.lightGreen.withOpacity(0.3)),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r * sizeFactor),
//               borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16.w * sizeFactor, vertical: 16.h * sizeFactor),
//           ),
//         ),
//       ],
//     );
//   }
//
//   static Future<T?> showCustomDialog<T>({
//     required BuildContext context,
//     required String title,
//     required String message,
//     String? primaryButtonText,
//     String? secondaryButtonText,
//     VoidCallback? onPrimaryPressed,
//     VoidCallback? onSecondaryPressed,
//     IconData? icon,
//     Color? iconColor,
//     Color? primaryButtonColor,
//     Color? backgroundColor,
//     bool barrierDismissible = true,
//     Widget? customContent,
//     double? maxWidth,
//   }) async {
//     return showDialog<T>(
//       context: context,
//       barrierDismissible: barrierDismissible,
//       barrierColor: Colors.black.withOpacity(0.5),
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           child: Container(
//             constraints: BoxConstraints(
//               maxWidth: maxWidth ?? 400.w * sizeFactor,
//             ),
//             child: Card(
//               elevation: 20,
//               shadowColor: AppColors.primaryGreen.withOpacity(0.3),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.r * sizeFactor),
//               ),
//               color: backgroundColor ?? Colors.white,
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20.r * sizeFactor),
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       (backgroundColor ?? Colors.white),
//                       (backgroundColor ?? Colors.white).withOpacity(0.9),
//                     ],
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Header with icon and close button
//                     Container(
//                       padding: EdgeInsets.all(20.w * sizeFactor),
//                       decoration: BoxDecoration(
//                         color: (iconColor ?? AppColors.primaryGreen)
//                             .withOpacity(0.1),
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(20.r * sizeFactor),
//                           topRight: Radius.circular(20.r * sizeFactor),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           if (icon != null) ...[
//                             Container(
//                               padding: EdgeInsets.all(12.w * sizeFactor),
//                               decoration: BoxDecoration(
//                                 color: (iconColor ?? AppColors.primaryGreen)
//                                     .withOpacity(0.2),
//                                 borderRadius:
//                                     BorderRadius.circular(50.r * sizeFactor),
//                               ),
//                               child: Icon(
//                                 icon,
//                                 color: iconColor ?? AppColors.primaryGreen,
//                                 size: 28.w * sizeFactor,
//                               ),
//                             ),
//                             Gap(16.w * sizeFactor),
//                           ],
//                           Expanded(
//                             child: buildText(
//                               text: title,
//                               style: GoogleFonts.poppins(
//                                 fontSize: 20.sp * sizeFactor,
//                                 fontWeight: FontWeight.w700,
//                                 color: AppColors.textPrimary,
//                               ),
//                             ),
//                           ),
//                           if (barrierDismissible)
//                             InkWell(
//                               onTap: () => Navigator.of(context).pop(),
//                               borderRadius:
//                                   BorderRadius.circular(20.r * sizeFactor),
//                               child: Container(
//                                 padding: EdgeInsets.all(8.w * sizeFactor),
//                                 child: Icon(
//                                   Icons.close,
//                                   color: AppColors.textSecondary,
//                                   size: 20.w * sizeFactor,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//
//                     // Content
//                     Padding(
//                       padding: EdgeInsets.all(20.w * sizeFactor),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           if (customContent != null)
//                             customContent
//                           else
//                             buildText(
//                               text: message,
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp * sizeFactor,
//                                 color: AppColors.textSecondary,
//                                 height: 1.5,
//                               ),
//                             ),
//
//                           Gap(24.h * sizeFactor),
//
//                           // Action buttons
//                           Row(
//                             children: [
//                               if (secondaryButtonText != null) ...[
//                                 Expanded(
//                                   child: _buildDialogButton(
//                                     text: secondaryButtonText,
//                                     onPressed: onSecondaryPressed ??
//                                         () => Navigator.of(context).pop(),
//                                     backgroundColor: Colors.grey.shade100,
//                                     textColor: AppColors.textSecondary,
//                                     borderColor: Colors.grey.shade300,
//                                   ),
//                                 ),
//                                 Gap(12.w * sizeFactor),
//                               ],
//                               Expanded(
//                                 child: _buildDialogButton(
//                                   text: primaryButtonText ?? 'OK',
//                                   onPressed: onPrimaryPressed ??
//                                       () => Navigator.of(context).pop(),
//                                   backgroundColor: primaryButtonColor ??
//                                       AppColors.primaryGreen,
//                                   textColor: Colors.white,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   /// Helper method to build dialog buttons
//   static Widget _buildDialogButton({
//     required String text,
//     required VoidCallback onPressed,
//     Color? backgroundColor,
//     Color? textColor,
//     Color? borderColor,
//   }) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: backgroundColor ?? AppColors.primaryGreen,
//         elevation: 0,
//         padding: EdgeInsets.symmetric(vertical: 14.h * sizeFactor),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12.r * sizeFactor),
//           side: borderColor != null
//               ? BorderSide(color: borderColor, width: 1)
//               : BorderSide.none,
//         ),
//       ),
//       child: buildText(
//         text: text,
//         style: GoogleFonts.poppins(
//           fontSize: 16.sp * sizeFactor,
//           fontWeight: FontWeight.w600,
//           color: textColor ?? Colors.white,
//         ),
//       ),
//     );
//   }
// }


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../app/core/constants/color_constant.dart';
import 'custom_drop_down.dart';

class CommonUiUtils {
  static const double sizeFactor = 0.75; // Size constant variable



  static Widget buildStepHeader(String title, [String? subtitle]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          text: title,
          style: GoogleFonts.poppins(
            fontSize: 22.sp * sizeFactor,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryGreen,
          ),
        ),
        if (subtitle != null && subtitle.trim().isNotEmpty) ...[
          Gap(6.h * sizeFactor),
          buildText(
            text: subtitle,
            style: GoogleFonts.poppins(
              fontSize: 14.sp * sizeFactor,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }

  /// Calendar Date Picker Field
  static Widget buildDatePickerField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    String? errorText,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String dateFormat = 'dd/MM/yyyy',
    ValueChanged<DateTime>? onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          text: label,
          style: GoogleFonts.poppins(
            fontSize: 16.sp * sizeFactor,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Gap(8.h * sizeFactor),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: GoogleFonts.poppins(fontSize: 20.sp * sizeFactor),
          validator: validator,
          onTap: () async {
            final selectedDate = await _showCustomDatePicker(
              context: controller.text.isNotEmpty
                  ? null
                  : null, // This needs proper context
              initialDate: initialDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(1900),
              lastDate: lastDate ?? DateTime(2100),
            );

            if (selectedDate != null) {
              controller.text = DateFormat(dateFormat).format(selectedDate);
              if (onDateSelected != null) {
                onDateSelected(selectedDate);
              }
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon,
                color: AppColors.primaryGreen, size: 20.w * sizeFactor),
            suffixIcon: Icon(
              PhosphorIcons.caretDown(PhosphorIconsStyle.regular),
              color: AppColors.textSecondary,
              size: 16.w * sizeFactor,
            ),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r * sizeFactor),
              borderSide:
              BorderSide(color: AppColors.lightGreen.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r * sizeFactor),
              borderSide:
              BorderSide(color: AppColors.lightGreen.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r * sizeFactor),
              borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r * sizeFactor),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r * sizeFactor),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w * sizeFactor, vertical: 16.h * sizeFactor),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  /// Custom Date Picker with attractive design
  static Future<DateTime?> _showCustomDatePicker({
    required BuildContext?
    context, // Made nullable since we can't always pass context
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    if (context == null) return null; // Return null if no context provided

    return showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 350.w * sizeFactor,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r * sizeFactor),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20.w * sizeFactor),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r * sizeFactor),
                      topRight: Radius.circular(20.r * sizeFactor),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.calendar(PhosphorIconsStyle.fill),
                        color: AppColors.primaryGreen,
                        size: 24.w * sizeFactor,
                      ),
                      Gap(12.w * sizeFactor),
                      Text(
                        'Select Date',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp * sizeFactor,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20.r * sizeFactor),
                        child: Container(
                          padding: EdgeInsets.all(8.w * sizeFactor),
                          child: Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                            size: 20.w * sizeFactor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Calendar
                Padding(
                  padding: EdgeInsets.all(20.w * sizeFactor),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primaryGreen,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: AppColors.textPrimary,
                      ),
                      textTheme: TextTheme(
                        headlineSmall: GoogleFonts.poppins(
                          fontSize: 20.sp * sizeFactor,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        bodyLarge: GoogleFonts.poppins(
                          fontSize: 14.sp * sizeFactor,
                          color: AppColors.textPrimary,
                        ),
                        bodyMedium: GoogleFonts.poppins(
                          fontSize: 12.sp * sizeFactor,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    child: CalendarDatePicker(
                      initialDate: initialDate,
                      firstDate: firstDate,
                      lastDate: lastDate,
                      onDateChanged: (DateTime date) {
                        Navigator.of(context).pop(date);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
    String? errorText,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          text: label,
          style: GoogleFonts.poppins(
            fontSize: 16.sp * sizeFactor,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Gap(8.h * sizeFactor),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          style: GoogleFonts.poppins(fontSize: 16.sp * sizeFactor),
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon,
                color: AppColors.primaryGreen, size: 20.w * sizeFactor),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r * sizeFactor),
              borderSide:
              BorderSide(color: AppColors.lightGreen.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r * sizeFactor),
              borderSide:
              BorderSide(color: AppColors.lightGreen.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r * sizeFactor),
              borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r * sizeFactor),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r * sizeFactor),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w * sizeFactor, vertical: 16.h * sizeFactor),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  /// Custom Dropdown Field using CustomDropdownField
  static Widget buildCustomDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabelBuilder,
    required ValueChanged<T?> onChanged,
    required IconData icon,
    String? hintText,
    FormFieldValidator<T>? validator,
    bool isRequired = false,
  }) {
    return CustomDropdownField<T>(
      value: value,
      labelText: label,
      hintText: hintText,
      items: items,
      itemLabelBuilder: itemLabelBuilder,
      onChanged: onChanged,
      prefixIcon: icon,
      validator: validator,
      isRequired: isRequired,
      borderColor: AppColors.lightGreen.withOpacity(0.3),
      focusedBorderColor: AppColors.primaryGreen,
      fillColor: AppColors.background,
      borderRadius: 12.r * sizeFactor,
      labelStyle: GoogleFonts.poppins(
        fontSize: 16.sp * sizeFactor,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      itemTextStyle: GoogleFonts.poppins(
        fontSize: 16.sp * sizeFactor,
      ),
    );
  }

  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    IconData? icon,
    Color? iconColor,
    Color? primaryButtonColor,
    Color? backgroundColor,
    bool barrierDismissible = true,
    Widget? customContent,
    double? maxWidth,
  }) async {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? 400.w * sizeFactor,
            ),
            child: Card(
              elevation: 20,
              shadowColor: AppColors.primaryGreen.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r * sizeFactor),
              ),
              color: backgroundColor ?? Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r * sizeFactor),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (backgroundColor ?? Colors.white),
                      (backgroundColor ?? Colors.white).withOpacity(0.9),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with icon and close button
                    Container(
                      padding: EdgeInsets.all(20.w * sizeFactor),
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppColors.primaryGreen)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r * sizeFactor),
                          topRight: Radius.circular(20.r * sizeFactor),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (icon != null) ...[
                            Container(
                              padding: EdgeInsets.all(12.w * sizeFactor),
                              decoration: BoxDecoration(
                                color: (iconColor ?? AppColors.primaryGreen)
                                    .withOpacity(0.2),
                                borderRadius:
                                BorderRadius.circular(50.r * sizeFactor),
                              ),
                              child: Icon(
                                icon,
                                color: iconColor ?? AppColors.primaryGreen,
                                size: 28.w * sizeFactor,
                              ),
                            ),
                            Gap(16.w * sizeFactor),
                          ],
                          Expanded(
                            child: buildText(
                              text: title,
                              style: GoogleFonts.poppins(
                                fontSize: 20.sp * sizeFactor,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (barrierDismissible)
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius:
                              BorderRadius.circular(20.r * sizeFactor),
                              child: Container(
                                padding: EdgeInsets.all(8.w * sizeFactor),
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.textSecondary,
                                  size: 20.w * sizeFactor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: EdgeInsets.all(20.w * sizeFactor),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (customContent != null)
                            customContent
                          else
                            buildText(
                              text: message,
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp * sizeFactor,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),

                          Gap(24.h * sizeFactor),

                          // Action buttons
                          Row(
                            children: [
                              if (secondaryButtonText != null) ...[
                                Expanded(
                                  child: _buildDialogButton(
                                    text: secondaryButtonText,
                                    onPressed: onSecondaryPressed ??
                                            () => Navigator.of(context).pop(),
                                    backgroundColor: Colors.grey.shade100,
                                    textColor: AppColors.textSecondary,
                                    borderColor: Colors.grey.shade300,
                                  ),
                                ),
                                Gap(12.w * sizeFactor),
                              ],
                              Expanded(
                                child: _buildDialogButton(
                                  text: primaryButtonText ?? 'OK',
                                  onPressed: onPrimaryPressed ??
                                          () => Navigator.of(context).pop(),
                                  backgroundColor: primaryButtonColor ??
                                      AppColors.primaryGreen,
                                  textColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Helper method to build dialog buttons
  static Widget _buildDialogButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primaryGreen,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 14.h * sizeFactor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r * sizeFactor),
          side: borderColor != null
              ? BorderSide(color: borderColor, width: 1)
              : BorderSide.none,
        ),
      ),
      child: buildText(
        text: text,
        style: GoogleFonts.poppins(
          fontSize: 16.sp * sizeFactor,
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }


  static Widget buildText({
    required String text,
    required TextStyle style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

