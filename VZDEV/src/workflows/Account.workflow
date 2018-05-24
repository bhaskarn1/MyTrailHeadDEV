<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CCPM_calculateCustomerScore</fullName>
        <description>Field update to update Customer score</description>
        <field>CCPM_customerScore__c</field>
        <formula>IF(ISBLANK(CCPM_channelPreference__c),0, 
IF(CONTAINS(&quot;WEB&quot;, UPPER(CCPM_channelPreference__c)),1, 
IF(CONTAINS(&quot;STORE&quot;, UPPER(CCPM_channelPreference__c)),1, 
IF(CONTAINS(&quot;NO EVENT&quot;, UPPER(CCPM_channelPreference__c)),1, 
0 
)))) 
+ 
IF(CCPM_upgradePropensity__c &gt; 75,1.5, 
IF(CCPM_upgradePropensity__c &gt; 50,1, 
0 
)) 
+ 
IF(CCPM_isOutOfContract__c,1,0) 
+ 
IF(CCPM_isPaymentOverdue__c,0,0.5) 
+ 
IF(CCPM_averageMargin__c &gt; 75,1.5, 
IF(CCPM_averageMargin__c &gt; 50,1, 
0 
))</formula>
        <name>Account: Calculate Customer Score</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPM_updateDoNotSMSFlagToTrue</fullName>
        <description>Sets Do Not SMS Flag = TRUE to be incorporated in &quot;EDW Opt Out&quot; report</description>
        <field>CCPM_doNotSMSFlag__c</field>
        <literalValue>1</literalValue>
        <name>Account: Update Do Not SMS Flag To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPM_updateDoNotSMSToTrue</fullName>
        <description>Sets Do Not SMS = TRUE</description>
        <field>CCPM_SMSOptOut__c</field>
        <literalValue>1</literalValue>
        <name>Account: Update Do Not SMS To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CCPM_calculateCustomerScore</fullName>
        <actions>
            <name>CCPM_calculateCustomerScore</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Rule to calculate score of a Customer</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CCPM_optOutFromSMSByDefault-DO-NOT-DEPLOY-TO-PROD</fullName>
        <actions>
            <name>CCPM_updateDoNotSMSToTrue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Account.CCPM_SMSOptOut__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow set SMS Opt Out flag to TRUE for customers in DEV, SAT &amp; UAT</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CCPM_setDoNotSMSFlagToTrue</fullName>
        <actions>
            <name>CCPM_updateDoNotSMSFlagToTrue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.CCPM_SMSOptOut__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Workflow rule to set &apos;Do Not SMS Flag&apos; to true when &apos;Do Not SMS&apos; is set to TRUE</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
