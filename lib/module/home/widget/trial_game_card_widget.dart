import 'package:ez_trainz/utils/utils.dart';
import 'package:flutter/material.dart';

class TrialGameCardWidget {

  Widget trialGameCardWidget({
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 428.w(context),
        padding: EdgeInsets.fromLTRB(
          18.w(context),
          16.h(context),
          16.w(context),
          16.h(context),
        ),
        decoration: BoxDecoration(
          color: ColorUtils.cardAlt,
          borderRadius: BorderRadius.circular(18.r(context)),
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
              width: 52.w(context),
              height: 52.h(context),
              decoration: BoxDecoration(
                color: ColorUtils.accentBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16.r(context)),
                border: Border.all(color: ColorUtils.accentBlue.withValues(alpha: 0.25)),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.bolt_rounded, color: ColorUtils.accentBlueDk, size: 30.r(context)),
            ),

            SpaceHelperWidget.h(context: context,width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  TextHelperWidget().headingTextWithoutWidth(
                    text: 'Trial Game',
                    context: context,
                    textColor: ColorUtils.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    lineHeight: 1.1,
                  ),

                  SpaceHelperWidget.v(context: context,height: 4.h(context)),

                  TextHelperWidget().headingTextWithoutWidth(
                    text: 'Try a language in 60 seconds with a mini-game.',
                    textColor: ColorUtils.textMuted,
                    context: context,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    lineHeight: 1.25,
                  ),
                ],
              ),
            ),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.hp(context), vertical: 6.vp(context)),
              decoration: BoxDecoration(
                color: ColorUtils.accentYellow,
                borderRadius: BorderRadius.circular(999.r(context)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextHelperWidget().headingTextWithoutWidth(
                    text: 'Try',
                    context: context,
                    textColor: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                  SpaceHelperWidget.h(context: context,width: 6),
                  Icon(Icons.arrow_forward_rounded, color: Colors.black87, size: 16.r(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}