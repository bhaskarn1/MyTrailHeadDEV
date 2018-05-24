<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Wiiner_and_Loser_Id</fullName>
        <field>CCPM_mergeUniqueField__c</field>
        <formula>CCPM_existingRecord__c+&quot;_&quot;+CCPM_newRecord__c</formula>
        <name>Update Wiiner and Loser Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Winner and Loser Id</fullName>
        <actions>
            <name>Update_Wiiner_and_Loser_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CCPM_Rule__c.CCPM_active__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
