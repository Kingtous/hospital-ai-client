import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/alerts.dart';

class AlertsModel {
  Future<List<Alerts>> getAlertsFromTo(int st, int ed) async {
    if (userModel.isAdmin) {
      return appDB.alertDao.getAlertsFromTo(st, ed);
    } else {
      final cams = await videoModel.getAllowedCams();
      if (cams.isEmpty) {
        return [];
      } else {
        return appDB.alertDao
            .getAlertsInCamsFrom(cams.map((e) => e.id!).toList(), st, ed);
      }
    }
  }

  Future<Alerts?> getAlertsByPic() async {
    
  }
}
