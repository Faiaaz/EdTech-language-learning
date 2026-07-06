import 'package:ez_trainz/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ez_trainz/module/module.dart';


class StreakPillWidget extends StatelessWidget {
  const StreakPillWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final streak = StreakController.to.state.value.streakCount;
      final p = StreakController.to.todayProgress.value.clamp(0.0, 1.0);
      final done = p >= 1.0;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.hp(context), vertical: 8.vp(context)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999.r(context)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18.w(context),
              height: 18.h(context),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: p,
                    strokeWidth: 2.3,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      done ? const Color(0xFFFFE000) : Colors.white,
                    ),
                  ),
                  Center(
                    child: Icon(Icons.local_fire_department_rounded, size: 14.r(context), color: Colors.white),
                  ),
                ],
              ),
            ),

            SpaceHelperWidget.h(context: context,width: 8),


            TextHelperWidget().headingTextWithoutWidth(
              text: '$streak',
              context: context,
              textColor: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),


          ],
        ),
      );
    });
  }
}