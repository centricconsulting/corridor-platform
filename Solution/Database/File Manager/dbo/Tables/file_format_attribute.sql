CREATE TABLE [dbo].[file_format_attribute]
(
	[file_format_attribute_key]		INT IDENTITY(1,1) NOT NULL,
	[file_format_code]				VARCHAR(20)  NOT NULL,
	[attribute_name]				VARCHAR(200) NOT NULL,
	[column_position]				INT NOT NULL,
	[extract_regex]					VARCHAR(200) NULL,
	[create_timestamp]				DATETIME NOT NULL,
	[modify_timestamp]				DATETIME NOT NULL,
	[process_batch_key]						INT NOT NULL,
	CONSTRAINT [dbo_file_format_attribute_pk] PRIMARY KEY CLUSTERED ([file_format_attribute_key] ASC)
)
GO

CREATE UNIQUE INDEX dbo_file_format_attribute_u1 ON file_format_attribute ([file_format_code], [attribute_name])
GO