/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class UpdateInboundItem {
    @InvocableVariable(label='ITR Context' description='Optional ITR Context to set for this ITR Message. If not specified, ITR Context will not be modified.' required=false)
    global String ITRContext;
    @InvocableVariable(label='Object Id' description='Identifier for ITR Message object to be updated.' required=true)
    global Id ObjectId;
    @InvocableVariable(label='Queue Name' description='Optional Queue Name to set for this ITR Message.  If not specified, Queue Name will not be modified.' required=false)
    global String QueueName;
    global UpdateInboundItem() {

    }
}
