<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Transcript1</fullName>
        <field>Formatted_Transcript_1__c</field>
        <formula>Transcript_Summary_1__c</formula>
        <name>Update Transcript1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Transcript2</fullName>
        <description>copies transcript summary field 2 to transcript 2</description>
        <field>Formatted_Transcript_2__c</field>
        <formula>Transcript_Summary_2__c</formula>
        <name>Update Transcript2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Transcripts</fullName>
        <actions>
            <name>Update_Transcript1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Transcript2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Conversation_Header__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Creates a formatted transcript from the unformatted transcript summary fields</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
