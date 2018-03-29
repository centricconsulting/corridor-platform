CREATE TABLE [dbo].[file_validation](
    [file_key]          VARCHAR (500)  NOT NULL,
    [row_index]         INT            NOT NULL,
    [column_index]      INT            NOT NULL,
    [row_disposition]   VARCHAR (200)  NULL,
    [column_label]      VARCHAR (200)  NULL,
    [severity]          VARCHAR (20)   NULL,
    [scope]             VARCHAR (20)   NULL,
    [message]           VARCHAR (2000) NOT NULL,
    --[process_batch_key] INT            NOT NULL
);
