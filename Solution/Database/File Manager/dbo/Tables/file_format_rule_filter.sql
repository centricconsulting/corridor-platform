CREATE TABLE [dbo].[file_format_rule_filter]
(
	[file_format_rule_filter_key]	INT IDENTITY(1,1) NOT NULL,
	[file_format_code]				VARCHAR(20) NOT NULL,
	[attribute_name]				VARCHAR(200) NOT NULL,
	[attribute_value]				VARCHAR(200) NOT NULL,
	[filter_action_flag]			VARCHAR(20) NOT NULL,
	[create_timestamp]				DATETIME NOT NULL,
	[modify_timestamp]				DATETIME NOT NULL,
	[batch_key]						INT NOT NULL,
	CONSTRAINT [dbo_file_format_rule_filter_pk] PRIMARY KEY CLUSTERED (	[file_format_rule_filter_key] ASC)
) ON [PRIMARY]

GO

--CREATE UNIQUE INDEX dbo_file_format_rule_filter_u1 ON file_format_rule_filter ([file_format_code], [attribute_name], [attribute_value])
--GO