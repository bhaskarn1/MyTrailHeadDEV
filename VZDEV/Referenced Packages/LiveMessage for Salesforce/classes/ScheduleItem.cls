/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ScheduleItem {
    @InvocableVariable(label='Bypass Opt-in' description='If checked, this message will be sent without verification of opt in.' required=false)
    global Boolean BypassOptinCheck;
    @InvocableVariable(label='Enforce Object Presence' description='If checked and the object specified by ObjectId is is deleted prior to send, the send will fail.' required=false)
    global Boolean EnforceObjectPresence;
    @InvocableVariable(label='LiveText Number' description='Phone number to send the message from.' required=false)
    global String LiveTextNumber;
    @InvocableVariable(label='Message' description='Message to send.' required=true)
    global String Message;
    @InvocableVariable(label='Message Source' description='Optional message source (ITR, etc)' required=false)
    global String MessageSource;
    @InvocableVariable(label='Object Id' description='Identifier for object that triggered this scheduled item.' required=true)
    global Id ObjectId;
    @InvocableVariable(label='Reference Id' description='Reference identifier for this scheduled item.' required=true)
    global String ReferenceId;
    @InvocableVariable(label='Schedule Date' description='Date and time to send the message.' required=false)
    global Datetime ScheduleDate;
    @InvocableVariable(label='To' description='Phone number to send the message to.' required=false)
    global String ToPhoneNumber;
    global ScheduleItem() {

    }
}
