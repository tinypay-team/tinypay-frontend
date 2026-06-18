import 'package:flutter/foundation.dart';

// 결제 완료 시 increment → MyPage에서 listen해서 잔액 갱신
final paymentCompletedNotifier = ValueNotifier<int>(0);
