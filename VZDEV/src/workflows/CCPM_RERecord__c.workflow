<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Record_Name_Unique_Field</fullName>
        <field>CCPM_recordNameUnique__c</field>
        <formula>Name</formula>
        <name>Update Record Name Unique Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Copy Record name to Unique Field</fullName>
        <actions>
            <name>Update_Record_Name_Unique_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CCPM_RERecord__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
