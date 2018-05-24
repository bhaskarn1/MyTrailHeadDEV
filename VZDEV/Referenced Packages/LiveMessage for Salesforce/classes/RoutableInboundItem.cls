/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class RoutableInboundItem {
    @InvocableVariable(label='Object Id' description='Identifier for ITR Message object to be routed.' required=true)
    global Id ObjectId;
    @InvocableVariable(label='Text Session Status' description='Optional status for conversation. If not specified, conversation will be New' required=false)
    global String Status;
    global RoutableInboundItem() {

    }
}
