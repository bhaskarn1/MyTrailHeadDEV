<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CCPM_calculateLeadScore</fullName>
        <description>Field update to update lead score</description>
        <field>CCPM_leadScoreFormula__c</field>
        <formula>IF(ISBLANK(CCPM_cartType__c),0, 
IF(CONTAINS(&quot;EUP&quot;,CCPM_cartType__c),1, 
IF(CONTAINS(&quot;AAL&quot;,CCPM_cartType__c),2.5, 
IF(CONTAINS(&quot;CPC&quot;,CCPM_cartType__c),0.5, 
0 
)))) 
+ 
IF(TODAY() - DATEVALUE(CCPM_createdDate__c) &gt; 21, 0, 
IF(TODAY()-DATEVALUE(CCPM_createdDate__c) &gt; 14, 0.5, 
IF(TODAY()-DATEVALUE(CCPM_createdDate__c) &gt; 7, 1, 
IF(TODAY()-DATEVALUE(CCPM_createdDate__c) &gt; -1, 2, 
0 
))))</formula>
        <name>Lead: Calculate Lead Score</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPM_updateLeadStatusToExpire</fullName>
        <description>Update Lead Status to &apos;Expired&apos; 30 days after last interaction</description>
        <field>Status</field>
        <literalValue>Expired</literalValue>
        <name>Update Lead Status to Expire</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPM_updateLeadStatusToExpireV2</fullName>
        <field>Status</field>
        <literalValue>Expired</literalValue>
        <name>Update Lead Status to Expire</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPM_updateProspectCreatedChanelToRetail</fullName>
        <description>Update prospect &quot;Created channel&quot; field value to &quot;Retail&quot;</description>
        <field>CCPM_createdChannel__c</field>
        <formula>&apos;Retail&apos;</formula>
        <name>Update prospect created chanel to retail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPM_updateProspectCreatedChannel</fullName>
        <description>Update prospect &quot;Created channel&quot; field value to &quot;Digital&quot;</description>
        <field>CCPM_createdChannel__c</field>
        <formula>CASE(CCPM_leadChannel__c, &apos;Retail&apos;, &apos;Retail&apos;, 
&apos;Digital&apos;, &apos;Digital&apos;,
&apos; &apos;)</formula>
        <name>Update prospect created channel</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CCPM_updateSendFollowUpSMS</fullName>
        <description>Flag to trigger process builder for Sending follow up SMS</description>
        <field>CCPM_sendFollowUpSMS__c</field>
        <literalValue>1</literalValue>
        <name>Update Send Follow-Up SMS field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CCPM_calculateLeadScore</fullName>
        <actions>
            <name>CCPM_calculateLeadScore</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Rule to calculate score of lead</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CCPM_expireInactiveLeadsAfter30Days</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Lead.CCPM_lastInteraction__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>New,Eligible,Contacted,Responded,Qualified</value>
        </criteriaItems>
        <description>Expire a Lead if they do not engage after 30 days. Criteria for this workflow is 1. Last Interaction date/time is not null and 2. Lead Status is either of the following New,Eligible,Contacted,Responded,Qualified</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CCPM_updateLeadStatusToExpire</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Lead.CCPM_lastInteractionDateTime__c</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CCPM_expireInactiveLeadsAfter30DaysV2</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Lead.CCPM_lastInteraction__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>New,Eligible,Contacted,Responded,Qualified</value>
        </criteriaItems>
        <description>Expire a Lead if they do not engage after 30 days. Criteria for this workflow is 1. Last Interaction date/time is not null and 2. Lead Status is either of the following New,Eligible,Contacted,Responded,Qualified</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CCPM_updateLeadStatusToExpireV2</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Lead.CCPM_lastInteraction__c</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CCPM_expireLeadsWithoutInteractionAfter30Days</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Lead.CCPM_lastInteraction__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>New,Eligible,Contacted,Responded,Qualified</value>
        </criteriaItems>
        <description>Expire a Lead if they do not engage after 30 days from Lead Created Date. Criteria for workflow is 
1. Last Interaction date/time is not null and 
2. Lead Status is either of the following New, Eligible, Contacted, Responded, Qualified</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CCPM_updateLeadStatusToExpire</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Lead.CreatedDate</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CCPM_triggerFollowUpSMS</fullName>
        <active>false</active>
        <description>This workflow rule triggers the process builder for Follow up SMS</description>
        <formula>AND(NOT(CCPM_Account__r.CCPM_SMSOptOut__c), NOT(CCPM_isFollowUpSMSSent__c),CCPM_isInitialSMSSent__c ,NOT( CCPM_isSMSResponseReceived__c ), NOT(CCPM_sendFollowUpSMS__c),  TEXT(Status)!=&quot;Completed&quot;,TEXT(Status)!=&quot;Expired&quot;,TEXT(Status)!=&quot;Rejected&quot;,TEXT(Status)!=&quot;Qualified&quot;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CCPM_updateSendFollowUpSMS</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Lead.CCPM_triggerFollowupSMSDateTime__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CCPM_updateProspectCreatedChannelToDigital</fullName>
        <actions>
            <name>CCPM_updateProspectCreatedChannel</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>(1 OR 2)</booleanFilter>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Prospect Cart</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Cart</value>
        </criteriaItems>
        <description>Update prospect &quot;Created Channel&quot; field value to &quot;Digital&quot; when prospect cart was created digitally and  &quot;Created Channel&quot; has blank value.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CCPM_updateProspectCreatedChannelToRetail</fullName>
        <actions>
            <name>CCPM_updateProspectCreatedChanelToRetail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.RecordTypeId</field>
            <operation>equals</operation>
            <value>Prospect</value>
        </criteriaItems>
        <description>Update prospect &quot;Created Channel&quot; field value to &quot;Retail&quot; when Sales Rep/Manager created the prospect.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
