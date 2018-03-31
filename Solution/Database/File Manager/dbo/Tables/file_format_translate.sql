CREATE TABLE [dbo].[file_format_translate](
	[file_format_translate_key] [int] IDENTITY(1,1) NOT NULL,

	[file_format_code] [varchar](20) NOT NULL,
	[attribute_name] [varchar](200) NOT NULL,
	[attribute_value] [varchar](200) NOT NULL,

	[translated_value] [varchar](200) NOT NULL,
	[create_timestamp] [datetime] NOT NULL,
	[modify_timestamp] [datetime] NOT NULL,
	[process_batch_key] [int] NOT NULL,
 CONSTRAINT [dbo_file_format_translate_pk] PRIMARY KEY CLUSTERED 
(
	[file_format_translate_key] ASC
))
GO

CREATE UNIQUE INDEX [dbo_file_format_translate_u1] ON
dbo.file_format_translate (file_format_code, attribute_name, attribute_value);
GO


