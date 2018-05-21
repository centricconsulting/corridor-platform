CREATE TABLE [sfc].[DM_Agency__c] (
    [Id]                 NVARCHAR (200)  NOT NULL,
    [Name]               NVARCHAR (200)  NOT NULL,
    [Unique_Name__c]     NVARCHAR (200)  NULL,
    [Billing_Company__c] NVARCHAR (2000) NULL,
    [Status__c]          NVARCHAR (2000) NULL,
    [Agency_Alias__c]    NVARCHAR (128)  NULL,
    [Parent_ID__c]       NVARCHAR (1300) NULL,
    [create_timestamp]   DATETIME        NOT NULL,
    [modify_timestamp]   DATETIME        NOT NULL,
    [process_batch_key]  INT             NOT NULL,
    CONSTRAINT [sfc_DM_Agency__c_pk] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
