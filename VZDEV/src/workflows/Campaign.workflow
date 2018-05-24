<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CCPM_updateUniqueNameOnCampaign</fullName>
        <field>CCPM_uniqueName__c</field>
        <formula>IF( RecordType.Name = &apos;Event Type&apos;, Name,  IF(RecordType.Name = &apos;Other Lead Type&apos;,   TEXT(CCPM_leadType__c ) , &quot;&quot;) )</formula>
        <name>Update Unique Name On Campaign</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CCPM Insert Value into Unique Name for Event Messages</fullName>
        <actions>
            <name>CCPM_updateUniqueNameOnCampaign</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Event Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.RecordTypeId</field>
            <operation>equals</operation>
            <value>Other Lead Type</value>
        </criteriaItems>
        <criteriaItems>
            <field>Campaign.IsActive</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
