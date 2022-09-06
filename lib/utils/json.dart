import 'package:nool/utils/log.dart';

class JSON {
  static int? parseInt(j, f) {
    final jv = j[f];
    if (jv == null) return null;

    if (jv.runtimeType == int) return jv;
    if (jv.runtimeType == double) return jv.toInt();
    if (jv.runtimeType == String) {
      int? i = int.tryParse(jv);
      if (i == null) {
        double? d = double.tryParse(jv);
        if (d != null) i = d.toInt();
      }
      return i;
    }

    return null;
  }

  static double? parseDouble(j, f) {
    final jv = j[f];
    if (jv == null) return jv;

    if (jv.runtimeType == double) return jv;
    if (jv.runtimeType == int) return jv.toDouble();
    if (jv.runtimeType == String) return double.tryParse(jv);

    return null;
  }

  static String parseString(j, f) {
    final jv = j[f];
    if (jv == null) return '';

    if (jv.runtimeType == String) return jv;
    return "$jv";
  }

  static String parseObjectString(j, o, f) {
    final jo = j[o];
    if (jo == null) return '';
    return parseString(jo, f);
  }

  static bool? parseBool(j, f) {
    final jv = j[f];
    if (jv == null) return null;

    if (jv.runtimeType == bool) return jv;
    if (jv.runtimeType == String) {
      final lc = jv.toLowerCase();
      if (lc == "true" || lc == 'y' || lc == 't') return true;
      if (lc == 'false' || lc == 'n' || lc == 'f') return false;
    }
    return null;
  }

  static DateTime? parseDate(j, f) {
    final s = parseString(j, f);
    if (s.isEmpty) return null;
    DateTime? jv = DateTime.tryParse(s);
    return (jv != null) ? jv.toLocal() : null;
  }

  static List<String> parseStringArray(j) {
    List<String> ls = <String>[];
    if (j == null) return ls;

    if (j.runtimeType == String) {
      ls.add(j);
      return ls;
    }

    final l = j.length ?? 0;
    if (l <= 0) return ls;

    for (var i = 0; i < l; i++) {
      ls.add(j[i]);
    }

    return ls;
  }

  static void updateStringArray(j, String f, List<String> l) {
    List<String> ls = parseStringArray(j[f]);
    l.addAll(ls);
  }

  static List<String> pluckStringArray(j, f) {
    List<String> ls = <String>[];
    if (j == null) return ls;

    final l = j.length ?? 0;
    if (l <= 0) return ls;

    for (var i = 0; i < l; i++) {
      ls.add(parseString(j[i], f));
    }

    return ls;
  }

  static int toIntFromList(List<dynamic> m, int index, {int dflt = 0}) {
    try {
      final int n = m[index];
      return n;
    } catch (e) {
      NLog.log(e);
    }
    return dflt;
  }

  static double toDoubleFromList(List<dynamic> m, int index,
      {double dflt = 0.0}) {
    try {
      double d = m[index];
      return d;
    } catch (e) {
      try {
        final int n = m[index];
        double d = n.toDouble();
        return d;
      } catch (e) {
        NLog.log(e);
      }
    }

    return dflt;
  }
}
