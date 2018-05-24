public class CCPM_datetimeConversionClass
{
  public static datetime datetimeConversion(string strInConvertDate,string strInTimeZone)
    {

		DateTime dtmConvertDateInGMT = DateTime.valueofGmt(strInConvertDate);
        //System.debug('******dtmConvertDateInGMT*******'+dtmConvertDateInGMT);
        TimeZone tzInputTimeZone = TimeZone.getTimeZone(strInTimeZone);
        Integer intOffsetToInputTimeZone = tzInputTimeZone.getOffset(dtmConvertDateInGMT);
        //SYstem.debug('*********intOffsetToInputTimeZone*******'+intOffsetToInputTimeZone);
        //SYstem.debug('*********intOffsetToInputTimeZone 2*******'+(intOffsetToInputTimeZone/(1000 * 60))/60);
        TimeZone tz = UserInfo.getTimeZone();
        integer intOffsetToUserTimeZone = tz.getOffset(dtmConvertDateInGMT);
        //System.debug('****GMT Offset: ' + (intOffsetToUserTimeZone/(1000 * 60))/60 + ' (milliseconds) to NZDT');
        integer correction = intOffsetToUserTimeZone - intOffsetToInputTimeZone;
        DateTime correctedDateTime = DateTime.valueOf(dtmConvertDateInGMT.addMinutes(correction / (1000 * 60)));
        //System.debug('***correctedDateTime: ' + correctedDateTime);
        DateTime newdate = datetime.newInstance(correctedDateTime.dateGMT(), correctedDateTime.TimeGMT());
        //system.debug('*****newdate is'+newdate);
        return newdate;
        
    }
}