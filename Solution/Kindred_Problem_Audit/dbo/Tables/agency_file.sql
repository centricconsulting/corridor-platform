CREATE TABLE [dbo].[agency_file] (
    [agency_file_key]       INT            IDENTITY (100, 1) NOT NULL,
    [agency_key]            INT            NOT NULL,
    [file_path]             VARCHAR (1000) NOT NULL,
    [file_name]             VARCHAR (200)  NOT NULL,
    [folder_path]           VARCHAR (1000) NOT NULL,
    [folder_branch]         VARCHAR (200)  NULL,
    [file_guid]             VARCHAR (50)   NOT NULL,
    [archive_folder_path]   VARCHAR (1000) NULL,
    [archive_file_name]     VARCHAR (200)  NULL,
    [process_dtm]           DATETIME       NULL,
    [process_success_ind]   BIT            NULL,
    [process_error_message] VARCHAR (100)  NULL,
    [notification_sent_ind] BIT            CONSTRAINT [DF_agency_file_notification_sent_ind] DEFAULT ((0)) NULL,
    [create_timestamp]      DATETIME       NOT NULL,
    [modify_timestamp]      DATETIME       NOT NULL,
    [process_batch_key]     INT            NOT NULL,
    CONSTRAINT [dbo_agency_file_pk] PRIMARY KEY CLUSTERED ([agency_file_key] ASC)
);

