<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Trial - Add Sys Admin to Role for Omni</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>System Administrator</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Workflow rule to add users with the System Administrator profile to the SVP Customer Experience Role.  The Role&apos;s users are members of the All Cases queue through which omni work is pushed.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
