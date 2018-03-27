CREATE TABLE dbo.[file_format]
(
	[file_format_key]		INT IDENTITY(1,1)   NOT NULL,
	[file_format_code]      VARCHAR(20)			NULL,
	[file_format_version]   INT					NULL,
	[file_format_desc]      VARCHAR(200)		NULL,
	[file_format_comment]	VARCHAR(2000)		NOT NULL,
	[create_timestamp]		DATETIME			NOT NULL,
	[modify_timestamp]		DATETIME			NOT NULL,
	[batch_key]				INT					NOT NULL,

	 CONSTRAINT [dbo_file_format_pk] PRIMARY KEY CLUSTERED ([file_format_key] ASC)
)
GO

--CREATE UNIQUE INDEX dbo_file_format_u1 ON file_format ([file_format_code])
--GO