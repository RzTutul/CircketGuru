
import 'package:intl/intl.dart';
enum CountryFlag { bangladesh, india, nepal, pakistan, sriLanka, afghanistan, defaultFlag }

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

  static String convertMillisecondsToIST(int millisecondsSinceEpoch) {
    // Calculate the IST time by adding the offset of 5 hours and 30 minutes to UTC
    DateTime istTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch + 5 * 60 * 60 * 1000 + 30 * 60 * 1000);

    // Format the IST time as a string
    String formattedTime = DateFormat('dd-MMMM-yyyy hh:mm a').format(istTime);

    // Return the formatted IST time
    return "${formattedTime} (IST)";
  }

 static String getFlagFromName(String teamName) {
    switch (teamName) {
      case 'PAK':
        return "assets/images/pakistan.png";
      case 'NEP':
        return "assets/images/nepal_flag.png";
      case 'IND':
        return "assets/images/India.png";
      case 'BAN':
        return "assets/images/bangladesh_flag.png";
      case 'AFG':
        return "assets/images/afghanistan_flag.png";
      case 'SL':
        return "assets/images/sri_lanka.png";
        case 'ENG':
        return "assets/images/england_flag.png";
        case 'AUS':
        return "assets/images/austrila_flag.png";
case 'NZ':
        return "assets/images/new_zealand_flag.png";
case 'WI':
        return "assets/images/west_indies_flag.png";

      default:
        return "assets/images/flag_placeholder.png";
    }
  }
}