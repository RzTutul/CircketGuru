
import 'package:intl/intl.dart';

class HelperUtils
{

  static String dateFormat(DateTime dateTime)
  {
    // create a DateTime object representing the GMT time
    final gmtTime = dateTime.toUtc();

    // calculate the offset between GMT and IST in seconds
    final istOffset = dateTime.timeZoneOffset.inSeconds + 19800;

    // apply the offset to the GMT time to get the IST time
    final istTime = gmtTime.add(Duration(seconds: istOffset));

    // format the IST time as a string
    final istFormatter = DateFormat('dd-MMMM-yyyy hh:mm:ss a');
    final istString = istFormatter.format(istTime);

    print('GMT time: ${gmtTime.toIso8601String()}');
    print('IST time: $istString');
    return "$istString (IST)";
  }
}