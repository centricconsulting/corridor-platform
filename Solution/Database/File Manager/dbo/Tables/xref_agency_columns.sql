CREATE TABLE [dbo].[xref_agency_columns]
(
	[agency_group]			VARCHAR(100)	NOT NULL,	
	[column_name]			VARCHAR(50)		NOT NULL,	
	[master_column_name]	VARCHAR(50)		NOT NULL,
	[list_order]			INT				NOT NULL,
    [init_batch_key]		INT            NOT NULL,
    [batch_key]				INT            NOT NULL,
	--[Agency]				VARCHAR(100)	NOT NULL,	
	--[Branch]				CHAR(5)			NULL,		
	--[Team]				VARCHAR(20)		NULL,
)
