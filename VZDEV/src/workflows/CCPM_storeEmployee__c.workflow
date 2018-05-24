<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CCPM_populateUniqueID</fullName>
        <description>Set Unique ID at Store Employee = &quot;U:&quot; &amp; CCPM_employee__c &amp; &quot;-S:&quot; &amp; CCPM_Store__c</description>
        <field>CCPM_uniqueID__c</field>
        <formula>&quot;U:&quot; &amp; CCPM_employee__c &amp; &quot;-S:&quot; &amp; CCPM_Store__c</formula>
        <name>Store Employee:Populate Unique ID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CCPM_setUniqueStoreEmployeeIdentifier</fullName>
        <actions>
            <name>CCPM_populateUniqueID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Workflow rule to set Unique ID field in Store Employee with combination of User ID and Store ID to ensure that an employee can only be added to store once. Format of Unique ID : &quot;U:&quot; &amp; CCPM_employee__c &amp; &quot;-S:&quot; &amp; CCPM_Store__c</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
