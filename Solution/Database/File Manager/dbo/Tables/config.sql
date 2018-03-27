CREATE TABLE [dbo].[config]
(
	[config_key]			INT IDENTITY(1,1) NOT NULL,
	[received_folder_path]	VARCHAR(200) NOT NULL,
	[accepted_folder_path]	VARCHAR(200) NOT NULL,
	[rejected_folder_path]	VARCHAR(200) NOT NULL,
	[create_timestamp]		DATETIME NOT NULL,
	[modify_timestamp]		DATETIME NOT NULL,
	[batch_key]				INT NOT NULL,
	CONSTRAINT [dbo_config_pk] PRIMARY KEY CLUSTERED ([config_key] ASC)

)
