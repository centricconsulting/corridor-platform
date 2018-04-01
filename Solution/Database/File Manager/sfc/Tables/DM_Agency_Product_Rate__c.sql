CREATE TABLE [sfc].[DM_Agency_Product_Rate__c]
(
	[Id]			NVARCHAR(200) NOT NULL,
	[Name]				NVARCHAR(200) NOT NULL, 
	[Product__c]		NVARCHAR(200) NOT NULL,
	[Agency__c]				NVARCHAR(200), 
	[Product_Name_for_IT__c]		NVARCHAR(2000),
	[Status__c]			NVARCHAR(2000),
	[Effective_Date__c]				DATETIME,
	[Effective_Till__c]				DATETIME  , 

	[create_timestamp]			DATETIME		NOT NULL,
	[modify_timestamp]			DATETIME		NOT NULL,
  [process_batch_key]					INT             NOT NULL,
  CONSTRAINT [sfc_DM_Agency_Product_Rate__c_pk] PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO