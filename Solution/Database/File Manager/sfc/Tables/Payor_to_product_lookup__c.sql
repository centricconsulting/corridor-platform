CREATE TABLE [sfc].[Payor_to_product_lookup__c] (
    [Commercial_Payor__c] VARCHAR (5)     NULL,
    [CreatedById]         NCHAR (18)      NULL,
    [CreatedDate]         DATETIME2 (7)   NULL,
    [Id]                  NCHAR (18)      NOT NULL,
    [IsDeleted]           VARCHAR (5)     NOT NULL,
    [LastModifiedById]    NCHAR (18)      NULL,
    [LastModifiedDate]    DATETIME2 (7)   NULL,
    [LastReferencedDate]  DATETIME2 (7)   NULL,
    [LastViewedDate]      DATETIME2 (7)   NULL,
    [Name]                NVARCHAR (80)   NULL,
    [OwnerId]             NCHAR (18)      NOT NULL,
    [Category__c]         NVARCHAR (128)  NULL,
    [Parent_Agency__c]    NCHAR (18)      NULL,
    [Parent_Agency_ID__c] NVARCHAR (1300) NULL,
    [Payment_System__c]   NVARCHAR (255)  NULL,
    [Payor__c]            NVARCHAR (128)  NULL,
    [Payor_Type__c]       NVARCHAR (128)  NULL,
    [Product_Name__c]     NVARCHAR (128)  NULL,
    [SystemModstamp]      DATETIME2 (7)   NULL
);



