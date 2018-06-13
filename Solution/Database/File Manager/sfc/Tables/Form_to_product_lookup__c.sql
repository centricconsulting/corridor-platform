CREATE TABLE [sfc].[Form_to_product_lookup__c] (
    [CreatedById]         NCHAR (18)      NULL,
    [CreatedDate]         DATETIME2 (7)   NULL,
    [Form__c]             NVARCHAR (128)  NULL,
    [Id]                  NCHAR (18)      NOT NULL,
    [IsDeleted]           VARCHAR (5)     NULL,
    [LastModifiedById]    NCHAR (18)      NULL,
    [LastModifiedDate]    DATETIME2 (7)   NULL,
    [Name]                NVARCHAR (80)   NULL,
    [OwnerId]             NCHAR (18)      NULL,
    [Parent_Agency__c]    NCHAR (18)      NULL,
    [Parent_Agency_ID__c] NVARCHAR (1300) NULL,
    [Product_Code__c]     NVARCHAR (128)  NULL,
    [SystemModstamp]      DATETIME2 (7)   NULL
);



