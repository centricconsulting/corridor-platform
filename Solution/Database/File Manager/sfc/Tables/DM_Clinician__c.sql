CREATE TABLE [sfc].[DM_Clinician__c] (
    [Agency__c]             NCHAR (18)      NULL,
    [Agency_Name_for_IT__c] NVARCHAR (1300) NULL,
    [Clinician_Graduate__c] VARCHAR (5)     NULL,
    [First_Name__c]         NVARCHAR (255)  NULL,
    [Full_Name__c]          NVARCHAR (1300) NULL,
    [Id]                    NCHAR (18)      NOT NULL,
    [Last_Name__c]          NVARCHAR (255)  NULL,
    [Name]                  NVARCHAR (80)   NULL,
    [Status__c]             NVARCHAR (255)  NULL,
    [process_batch_key]     INT             NULL,
    [create_timestamp]      DATETIME        NULL,
    [modify_timestamp]      DATETIME        NULL
);

