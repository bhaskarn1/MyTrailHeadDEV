/**
@author        Manjunath Keshava (Deloitte)
@description	create the SMS object record  When lead is inserted/update with event type  IPhone X
@param         None
@return           
*/  
@isTest
public class CCPM_dateTimeCoversionTest 
{
    @isTest
    public static void dateTimeTest()
    {
            CCPM_datetimeConversionClass.datetimeConversion('2017-10-26 18:30:00', 'America/New_York');

    }

}