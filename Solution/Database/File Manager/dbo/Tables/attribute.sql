CREATE TABLE [dbo].[attribute]
(
	[attribute_key]			INT IDENTITY(1,1) NOT NULL,
	[attribute_name]		VARCHAR(50) NOT NULL,
	[attribute_data_type]	VARCHAR(50) NOT NULL,
	[attribute_max_length]	INT NULL,
	[create_timestamp]		DATETIME NOT NULL,
	[modify_timestamp]		DATETIME NOT NULL,
	[process_batch_key]				INT NOT NULL,
	CONSTRAINT [dbo_attribute_pk] PRIMARY KEY CLUSTERED ([attribute_key] ASC)
) ON [PRIMARY]

GO

CREATE UNIQUE INDEX dbo_attribute_u1 ON attribute ([attribute_name])
GO