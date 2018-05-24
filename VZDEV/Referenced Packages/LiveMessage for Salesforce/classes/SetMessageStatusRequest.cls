/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SetMessageStatusRequest {
    @InvocableVariable(label='Error Message' description='Optional error message' required=false)
    global String ErrorMessage;
    @InvocableVariable(label='Message Id' description='Identifier for previously-queued message.' required=true)
    global Id MessageId;
    @InvocableVariable(label='Message Status' description='Status of message - should be one of Queued, Sent, or Error' required=true)
    global String MessageStatus;
    global SetMessageStatusRequest() {

    }
}
