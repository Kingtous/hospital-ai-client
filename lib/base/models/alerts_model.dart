


import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/alerts.dart';

class AlertsModel{

  Future<List<Alerts>> getAlertsFromTo(int st, int ed){
    return appDB.alertDao.getAlertsFromTo(st, ed);
  }


}