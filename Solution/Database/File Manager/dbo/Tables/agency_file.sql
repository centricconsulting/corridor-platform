CREATE TABLE [dbo].[agency_file](
	[agency_file_key]			INT IDENTITY(100,1) NOT NULL,
    [default_file_format_code]	VARCHAR (20)	NOT NULL,
	[file_name]					VARCHAR(200)	NOT NULL,
	[folder_path]				VARCHAR(1000)	NOT NULL,
	[folder_branch_name]		VARCHAR(200)	NULL,
	[worksheet_name]			VARCHAR(50)		NULL,
	[agency_name]				VARCHAR(100)    NULL,
	[file_hash]					CHAR(32)		NOT NULL,
	[file_created_dtm]			DATETIME		NOT NULL,
	[file_modified_dtm]			DATETIME		NOT NULL,
	[file_size_in_KB]			INT				NULL,
	[process_dtm]				DATETIME		NULL,
	[archive_folder_path]		VARCHAR(1000)	NULL,
	[archive_file_name]			VARCHAR(200)	NULL,
	[notification_sent_ind]		BIT				NULL,	
	[create_timestamp]			DATETIME		NOT NULL,
	[modify_timestamp]			DATETIME		NOT NULL,
	[batch_key]					INT				NOT NULL,
 CONSTRAINT [dbo_agency_file_pk] PRIMARY KEY CLUSTERED (	[agency_file_key] ASC)

);
