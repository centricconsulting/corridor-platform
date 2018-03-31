CREATE TABLE [dbo].[agency_filter]
(
	[agency_filter_key]	INT IDENTITY(1,1) NOT NULL,

	[agency_name]				VARCHAR(20) NOT NULL,
	[attribute_name]				VARCHAR(200) NOT NULL,
	[attribute_value]				VARCHAR(200) NOT NULL,

	[filter_action_flag]			VARCHAR(20) NOT NULL,
	[create_timestamp]				DATETIME NOT NULL,
	[modify_timestamp]				DATETIME NOT NULL,
	[process_batch_key]						INT NOT NULL,
	CONSTRAINT dbo_agency_filter_pk PRIMARY KEY CLUSTERED (	agency_filter_key ASC)
) ON [PRIMARY]

GO

CREATE UNIQUE INDEX dbo_agency_filter_u1
  ON dbo.agency_filter ([agency_name], [attribute_name], [attribute_value])
GO