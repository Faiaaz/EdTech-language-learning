import 'package:ez_trainz/utils/utils.dart';
import 'package:flutter/material.dart';

class TrialGameCardWidget {

  Widget trialGameCardWidget({
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 428.w(),
        padding: EdgeInsets.fromLTRB(18.w(), 16.h(), 16.w(), 16.h()),
        decoration: BoxDecoration(
          color: ColorUtils.cardAlt,
          borderRadius: BorderRadius.circular(18.r()),
          border: Border.all(color: ColorUtils.accentYellow, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: ColorUtils.accentBlue.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [

            Container(
              width: 52.w(),
              height: 52.h(),
              decoration: BoxDecoration(
                color: ColorUtils.accentBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16.r()),
                border: Border.all(color: ColorUtils.accentBlue.withValues(alpha: 0.25)),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.bolt_rounded, color: ColorUtils.accentBlueDk, size: 30.r()),
            ),

            SpaceHelperWidget.h(14.w()),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  TextHelperWidget().headingTextWithoutWidth(
                    text: 'Trial Game',
                    textColor: ColorUtils.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    lineHeight: 1.1,
                  ),

                  SpaceHelperWidget.v(4.h()),

                  TextHelperWidget().headingTextWithoutWidth(
                    text: 'Try a language in 60 seconds with a mini-game.',
                    textColor: ColorUtils.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    lineHeight: 1.25,
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.hp(), vertical: 6.vp()),
              decoration: BoxDecoration(
                color: ColorUtils.accentYellow,
                borderRadius: BorderRadius.circular(999.r()),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextHelperWidget().headingTextWithoutWidth(
                    text: 'Try',
                    textColor: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                  SpaceHelperWidget.h(6.w()),
                  Icon(Icons.arrow_forward_rounded, color: Colors.black87, size: 16.r()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}