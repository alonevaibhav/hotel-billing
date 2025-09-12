import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotelbilling/app/modules/view/ChefPanel/widgets/order_card_widget.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../apputils/Utils/common_utils.dart';
import '../../controllers/ChefController/accept_order_controller.dart';

class AcceptOrder extends StatelessWidget {
  const AcceptOrder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scaleFactor = 0.9;
    final controller = Get.put(AcceptOrderController());
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            Column(
              children: [
                Expanded(
                  child: buildOrdersList(controller, scaleFactor),
                ),
              ],
            ),
            // Rejection Dialog Overlay
            Obx(() => controller.isRejectDialogVisible.value
                ? _buildRejectDialog(context, controller, scaleFactor)
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget buildOrdersList(AcceptOrderController controller, double scaleFactor) {
    return Obx(() {
      if (controller.ordersData.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.clipboard(PhosphorIconsStyle.regular),
                size: (64 * scaleFactor).sp,
                color: Colors.grey[400],
              ),
              Gap((16 * scaleFactor).h),
              Text(
                'No pending orders',
                style: GoogleFonts.inter(
                  fontSize: (16 * scaleFactor).sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: (20 * scaleFactor).w),
        itemCount: controller.ordersData.length,
        itemBuilder: (context, index) {
          final order = controller.ordersData[index];
          return buildOrderCard(context, controller, order, index, scaleFactor);
        },
      );
    });
  }

  Widget _buildRejectDialog(BuildContext context,
      AcceptOrderController controller, double scaleFactor) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: EdgeInsets.all((24 * scaleFactor).w),
          padding: EdgeInsets.all((20 * scaleFactor).w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular((16 * scaleFactor).r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reason For Cancelling The Order',
                    style: GoogleFonts.inter(
                      fontSize: (16 * scaleFactor).sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.hideRejectDialog(),
                    child: Container(
                      padding: EdgeInsets.all((4 * scaleFactor).w),
                      child: Icon(
                        PhosphorIcons.x(PhosphorIconsStyle.regular),
                        size: (20 * scaleFactor).sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              Gap(1.h),
              // Reason Text Field
              CommonUiUtils.buildTextFormField(
                controller: controller.reasonController,
                label: '',
                hint: 'explain your reason',
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                validator: controller.validateRejectionReason,
                onChanged: controller.updateRejectionReason,
                icon: Icons.import_contacts,
              ),
              Gap((20 * scaleFactor).h),
              // Cancel Order Button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.rejectOrder(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[500],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular((8 * scaleFactor).r),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: (14 * scaleFactor).h),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            height: (20 * scaleFactor).h,
                            width: (20 * scaleFactor).w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'cancel order',
                            style: GoogleFonts.inter(
                              fontSize: (14 * scaleFactor).sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
