/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class LiveTextChatController {
    global static void associateRecords(Id objectId, String chId) {

    }
    @RemoteAction
    global static LiveText__SMS_Text__c createSMSTextRecord(String message, String conversationId) {
        return null;
    }
    @RemoteAction
    global static String getMessagePayloadResponse(String message, Integer messageId, String conversationId, String originatingNumber, String supportNumber, Boolean isFirstOutboundMessage) {
        return null;
    }
    @RemoteAction
    global static LiveText__SMS_Text__c getSMSTextRecord(String smsTextRecord) {
        return null;
    }
    @RemoteAction
    global static List<LiveText__Conversation_Header__c> insertConversationHeaderLinkObject(LiveText.LiveTextChatController.ConversationInitialization ci) {
        return null;
    }
    @RemoteAction
    global static List<LiveText__Conversation_Header__c> insertConversationHeader(String supportNumber, String originatingNumber, String conversationType, String message) {
        return null;
    }
    @RemoteAction
    global static String sendSMS2(SObject smsObject, String smsText) {
        return null;
    }
    @RemoteAction
    global static String validatePhoneNumbers(String channelId, String recipientId) {
        return null;
    }
global class ConversationInitialization {
    global ConversationInitialization() {

    }
}
global class CustomObjectManualLinkingWrapper {
    global CustomObjectManualLinkingWrapper() {

    }
}
global class MessagePayload {
    global MessagePayload() {

    }
}
}
