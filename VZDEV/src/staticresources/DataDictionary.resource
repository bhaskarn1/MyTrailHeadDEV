//Scenario 1: Receiving telesales appointment GIVEN that a lead or a prospect clicks on the Click to connect link from the SMS they receive after they have abandoned a cart THEN on the Click to Connect screen they choose the Complete Order over Phone Option either by typing the response in the chat bar at the bottom or selecting the button AND on clicking the option the user sees the following two options: 1. Call 1-866-298-2013 2. We'll call back when it's right for you AND by choosing Option 2 the customer is able to set up an appointment for a later day/time AND this appointment information is sent to salesforce AND the ownership of this record is then assigned to Sales queue AND the status changes to "Qualified- Appointment Scheduled" AND the appointment is reflected on the lead 

//Scenario 2: Receiving Retail appointment GIVEN that a lead or a prospect clicks on the Click to connect link from the SMS they receive after they have abandoned a cart THEN on the Click to Connect screen they choose the Complete Order online Option either by typing the response in the chat bar at the bottom or selecting the button AND selects one of the stores displayed and time slots available to confirm appointment on Click to Connect AND this appointment information is sent to salesforce AND the ownership of this record is then assigned to the Store Manager of store selected AND the status changes to "Qualified- Appointment Scheduled" AND the appointment is reflected on the lead  

 //Scenario 3: A lead cart or prospect cart status is Contacted  GIVEN a lead/prospect cart is marked "eligible" WHEN the initial SMS has been sent to the lead THEN the lead status is updated to "Contacted" and this is a read only status

 //Scenario 4: A lead cart or prospect cart status is Contacted  GIVEN a lead or prospect cart is marked "eligible" WHEN the initial SMS has been sent to with the click to connect link AND the customer clicks on the click to connect link THEN the lead status is remains "Contacted" and this is a read only status

 //Scenario 5: A lead cart or prospect cart status is Contacted while he is making selections on the Click to connect platform GIVEN a lead or prospect cart is marked "eligible" WHEN the initial SMS has been sent to with the click to connect link AND the customer clicks on the click to connect link AND chooses any of the options on the landing page THEN the lead status is remains "Contacted" and this is a read only status   //Scenario 6: A lead cart or prospect cart converts using click to connect GIVEN a lead or prospect cart is marked "eligible" WHEN the initial SMS has been sent to with the click to connect link AND the customer clicks on the click to connect link AND chooses any of the options on the landing page AND eventually converts THEN the converted cart update is received by salesforce AND the lead status is changes to Converted

 //Scenario 7: A lead has Responded "e" or "E"  after the initial or Follow up SMS GIVEN a lead is marked "contacted" AND the lead has received an initial or follow up sms with C2C link WHEN the lead responds "e" or "E"  THEN the lead will be marked as "Responded" and the sub-status will be "Cart-Disinterested"  

 //Scenario 8: SFDC has sent the customer a double opt out SMS GIVEN a lead is marked as "Responded" and the sub-status "Cart-Disinterested" WHEN the 'Double opt out SMS sent?' flag is 'TRUE' THEN the lead will be kept in "Responded" and the sub-status will be "Cart-Disinterested"   

//Scenario 9: A lead has Responded anything other than "e" or "E" after the initial or follow up sms with c2c link SMS GIVEN a lead is marked "Contacted" AND the lead has received an initial SMS click to connect link WHEN the lead responds anything other than "e" or "E"  THEN the lead will be marked as 'Responded' and Sub Status 'Action Required'   
//Scenario 10: A lead has Responded "X" to the double opt out SMS GIVEN a lead is marked "Responded" and sub-status is "Cart Disinterested" AND the lead has received an double opt out SMS WHEN the lead responds "X"  THEN the lead will be marked as "Responded" and the sub-status will be "Opted-Out"  
 //Scenario 11: A lead has Responded anything other than "X" to the double opt out SMS GIVEN a lead is marked "Contacted" AND the lead has received an initial SMS click to connect link WHEN the lead responds anything other than "X" THEN the lead will be marked as Responded and the sub-status will be "Action Required"   
//Scenario 12: A lead has Responded anything other than "X" or "E" - rep's options  GIVEN a lead is marked "Responded" and "Action Required" WHEN the Store User reviews the leads response THEN the store user is able to select the status of Qualified and the sub-status from one of the following options; In Discussion Appointment Scheduled Needs Store Reassignment Service Issue Disinterested  AND able to send Pre-defined SMS 
 //Scenario 13: A lead has Expired GIVEN a lead has been created in Salesforce WHEN a lead sits in Salesforce for over 30 days AND the lead status has not been updated? for over 30 days AND the lead status does not equal Converted, Dismissed or Expired THEN the lead status is marked as "Expired" and this is a read only status 






CCPM_endpoint_x__c = https://sfdc-uat.verizonwireless.com/SFDCServices/dvs;	
CCPM_clientCertName_x__c =vzwretailcalloutnonprod
CCPM_EncryptedKey__c = 6159644412316563;
CCPM_EncryptionAlgorithm__c = AES128;
CCPM_iphoneXUrl__c =https://www.verizonwireless.com/user/<ecode>/apple-iphone-x/sms/;

in UAT certificate should be exported from AT

for prod charlie will upload the certificate