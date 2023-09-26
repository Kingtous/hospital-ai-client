import 'package:fluent_ui/fluent_ui.dart';

const kDbVersion = 1;
const kDefaultAdminName = 'admin';
const kDefaultAdminPassword = 'admin';
const kDbName = 'cam.db';
const kHeaderHeight = 35.0;
const kDefaultName = '监控平台';

const kBgColor = Color(0xFFEFF4FA);
const kRadius = 8.0;
const kHighlightColor = Color(0xFFE0EDFF);
const kBlueColor = Color(0xFF409EFF);
const kTableGreyColor = Color(0xFFF5F7FA);

/// UI
Widget get bgImage => SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        'assets/images/bg.png',
        fit: BoxFit.cover,
      ),
    );

warning(BuildContext context, String warnText) {
  displayInfoBar(context,
      alignment: Alignment.topCenter,
      builder: (context, close) => InfoBar(
            title: Text(warnText),
            severity: InfoBarSeverity.error,
          ));
}

info(BuildContext context, String infoText) {
  displayInfoBar(context,
      alignment: Alignment.topCenter,
      builder: (context, close) => InfoBar(
            title: Text(infoText),
            severity: InfoBarSeverity.info,
          ));
}

success(BuildContext context, String infoText) {
  displayInfoBar(context,
      alignment: Alignment.topCenter,
      builder: (context, close) => InfoBar(
            title: Text(infoText),
            severity: InfoBarSeverity.success,
          ));
}

const kMockDataType =<String,int> {"未穿防护服": 2, "未消毒": 1, "擅自离岗": 3, "未戴口罩": 4};
