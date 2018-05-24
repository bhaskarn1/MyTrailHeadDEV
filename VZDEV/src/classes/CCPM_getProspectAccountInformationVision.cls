/**
*@name          CCPM_getProspectAccountInformationVision
*@author        Manjunath Keshava (Deloitte)
*@date          06/09/2017
@description   @(US_0392) this method makes a call out to vision based on the mtn and returns the account fields 
if vision  has the account 
Modification    Log:
------------------------------------------------------------------------------------
Developer                       Date                                Description
------------------------------------------------------------------------------------
Manjunath Keshava (Deloitte)    07/19/2017               			 Original Version

*/
public class CCPM_getProspectAccountInformationVision
{
    
    public static Map<string,Account> prospectAccountInfo( string strMtnNo)
    {
        boolean boolAccountFlag=false;
        boolean boolNoAccountFlag=false;
        boolean boolFlag=false;
        list<Account>lstAccount=new List<Account>();
        Map<string,Account>mapAccountSearch = new Map<string,Account>();
        sfdcproxyDvsVerizonwirelessCom.VisionDvsPort objSfVd = new sfdcproxyDvsVerizonwirelessCom.VisionDvsPort();
        if(CCPM_utility.isRunningInASandbox){
            objSfVd.timeout_x = Integer.valueOf(Label.CCPM_TimeoutforSandbox);
        }
        else{
            objSfVd.timeout_x = Integer.valueOf(Label.CCPM_TimeoutforPROD);
        } 
        psfDvs.mtnInfo objResMtn = new  psfDvs.mtnInfo();
        //instantiate to meet requirements in exception handling on the controller
        Account ObjAccount=new Account();
        if(strMtnNo!=null )
        {   
            //initalizing wsdl and calling out to get account information 
            String strMtnNbr; 
            String strAccountNbr;
            string strAccountUniqueId;
            string strNondigits = CCPM_staticConstants.strnondigits;    
            strMtnNo = strMtnNo.replaceAll(strnondigits,CCPM_staticConstants.strEmpty);
            //system.debug('the mtn'+strMtnNo);
            try
            {              
                //system.debug('the system exception error'+objSfVd.GetMtnInfo(strMtnNo));
                objResMtn = objSfVd.GetMtnInfo(strMtnNo);
                //system.debug('the system '+objResMtn);
                //throw new CCPM_sampleException ( 'first');
                
                //check for the fields we pull from the vision to  be non empty.
                if(objResMtn != null && objResMtn.mtndetail.mtn!=null && string.isNotBlank(objResMtn.mtndetail.mtn) && objResMtn.mtndetail.mtnUserName!=null && string.isNotBlank(objResMtn.mtndetail.mtnUserName)  && objResMtn.mtndetail.accountNo!=null && string.isNotBlank(objResMtn.mtndetail.accountNo)  )
                { 
                    system.debug('the vision call');
                    boolAccountFlag=true;
                    strMtnNbr = objResMtn.mtndetail.mtn; 
                    strAccountNbr = objResMtn.mtndetail.accountNo;
                    strAccountUniqueId=straccountNbr + strMtnNbr;
                    objAccount = new Account(Name=objResMtn.mtndetail.mtnUserName , CCPM_email__c = objResMtn.mtndetail.emailId,CCPM_accountNumber__c=straccountNbr,CCPM_mobilenumber__c=strMtnNbr);//,CCPM_accountUniqueID__c=straccountNbr + strMtnNbr );
                    objAccount.CCPM_accountUniqueID__c=CCPM_EncryptKey.CCPM_EncryptKey(strAccountUniqueId);
                    objAccount.CCPM_isVisionAccount__c=true;
                    system.debug('the vision'+objResMtn.dnsflags);
                    if(objResMtn.dnsflags!=null && objResMtn.dnsflags.teleMarketInd!=null && objResMtn.dnsflags.teleMarketInd== CCPM_staticConstants.strNoFlag)
                    {
                        objAccount.CCPM_hasOptedOutOfCall__c =true;   
                    }
                    else if(objResMtn.dnsflags!=null && objResMtn.dnsflags.teleMarketInd!=null && objResMtn.dnsflags.teleMarketInd==CCPM_staticConstants.strYesFlag)
                    {
                        objAccount.CCPM_hasOptedOutOfCall__c=false;
                    }
                    if(objResMtn.dnsflags!=null && objResMtn.dnsflags.txtMsgInd!=null && objResMtn.dnsflags.txtMsgInd== CCPM_staticConstants.strNoFlag)
                    {
                        objAccount.CCPM_SMSOptOut__c =true;   
                    }
                    else if(objResMtn.dnsflags!=null && objResMtn.dnsflags.txtMsgInd!=null && objResMtn.dnsflags.txtMsgInd==CCPM_staticConstants.strYesFlag)
                    {
                        objAccount.CCPM_SMSOptOut__c=false;
                    }
                    if(objResMtn.dnsflags!=null && objResMtn.dnsflags.emailInd!=null && objResMtn.dnsflags.emailInd== CCPM_staticConstants.strNoFlag)
                    {
                        objAccount.CCPM_hasOptedOutOfEmail__c =true;   
                    }
                    else if(objResMtn.dnsflags!=null && objResMtn.dnsflags.emailInd!=null && objResMtn.dnsflags.emailInd==CCPM_staticConstants.strYesFlag)
                    {
                        objAccount.CCPM_hasOptedOutOfEmail__c=false;
                    }
                    //system.debug('the objaccount is'+objAccount);
                    //if the Account is not null map it to the key
                    if(objAccount!=null)
                    {
                        mapAccountSearch.put(CCPM_staticConstants.strVisionAccount ,objAccount);
                    }   
                }
                else
                {  
                    boolNoAccountFlag=true;
                    //system.debug('account not found'); 
                    mapAccountSearch.put(CCPM_staticConstants.strNoAccount ,objAccount);
                }
            }catch(Exception e )
            {
                CCPM_LogMessageUtility.logMessage(e,'CCPM_getProspectAccountInformationVision',
                                                  ' method to call out vision using mtn ',
                                                  'Exception thrown while trying to fetch Account details from the UI page in Execute Method',true);
                boolFlag=true;
                mapAccountSearch.put(CCPM_staticConstants.strsysDown,objAccount);
                //system.debug('the catch is executed');
            }finally
            {
                //system.debug('the mapsearch finally is'+mapAccountSearch);
                if((boolFlag==false && boolAccountFlag == false && boolNoAccountFlag==false) || (Test.isRunningTest()))
                {
                    mapAccountSearch.put(CCPM_staticConstants.strException,objAccount);
                    return mapAccountSearch;
                }
            }      
        }
        //system.debug('the map is'+mapAccountSearch);
        return mapAccountSearch;           
        
    }
}