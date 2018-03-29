CREATE TABLE [sf].[agency_location]
(
	[agency_location_uid]		VARCHAR(50)		NOT NULL,
	[agency_location]			VARCHAR(100)	NOT NULL,
	[agency_company]			VARCHAR(100)	NULL,
	[agency_alias]				VARCHAR(20)		NULL, 
	[agency_name_uid]			VARCHAR(100)	NULL,
	[agency_status]				VARCHAR(20)		NOT NULL,		
	[create_timestamp]			DATETIME		NOT NULL,
  [batch_key]					INT             NOT NULL,
  CONSTRAINT [agency_location_pk] PRIMARY KEY CLUSTERED ([agency_location_uid] ASC)

);
GO

CREATE UNIQUE INDEX [sf_agency_location_u1] ON [sf].[agency_location] ([agency_location],[agency_company],[agency_status])
GO
