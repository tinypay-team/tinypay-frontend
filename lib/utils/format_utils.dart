String formatUsdc(double value) => value.toStringAsFixed(2);

/// ISO 8601 문자열을 UTC → 로컬(KST)로 변환
/// 서버가 'Z' 없이 UTC 시간을 반환하므로 강제로 UTC 처리
/// "2026-06-11T07:05:00" / "2026-06-11" / "2026-6-11" 모두 처리
DateTime _parseUtcToLocal(String isoString) {
  String s = isoString.trim();

  // 날짜만 있는 경우 (T 없음) → 시간 붙여주기
  // e.g. "2026-06-11" or "2026-6-11"
  if (!s.contains('T') && !s.contains(' ')) {
    // 월/일 zero-padding 보정 후 datetime 완성
    final parts = s.split('-');
    if (parts.length == 3) {
      final y = parts[0].padLeft(4, '0');
      final m = parts[1].padLeft(2, '0');
      final d = parts[2].padLeft(2, '0');
      s = '${y}-${m}-${d}T00:00:00Z';
    } else {
      s = '${s}T00:00:00Z';
    }
  } else {
    // datetime 형태 — Z/+가 없으면 UTC 처리
    if (!s.endsWith('Z') && !s.contains('+')) {
      s = '${s}Z';
    }
  }

  return DateTime.parse(s).toLocal();
}

/// "6월 11일 오후 3:59" 형식 (UTC → KST)
String formatDateTime(String isoString) {
  try {
    final dt = _parseUtcToLocal(isoString);
    final mm = dt.month;
    final dd = dt.day;
    final hour = dt.hour;
    final min = dt.minute;
    final isAm = hour < 12;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$mm월 ${dd}일 ${isAm ? "오전" : "오후"} $displayHour:${min.toString().padLeft(2, "0")}';
  } catch (_) {
    return isoString;
  }
}

String formatDateTimeFull(String isoString) => formatDateTime(isoString);

/// "2026.04.23" 형식 (세션 목록용)
String formatSessionDate(String isoString) {
  try {
    final dt = _parseUtcToLocal(isoString);
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  } catch (_) {
    return isoString;
  }
}
