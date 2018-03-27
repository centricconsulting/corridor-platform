CREATE TABLE [dbo].[file_row](
    [file_row_key]           INT            IDENTITY (100, 1) NOT NULL,
    [file_key]               INT            NOT NULL,
    [row_index]              INT            NOT NULL,
    [row_type]				 NVARCHAR (200)  NULL,
    [row_text]               NVARCHAR (4000) NULL,
    [contains_data_ind]      BIT            DEFAULT ((0)) NOT NULL,
    [critical_error_count]   INT            DEFAULT ((0)) NOT NULL,
    [processed_ind]          BIT            DEFAULT ((0)) NOT NULL,
    [processed_dtm]          DATETIME       NULL,
    --[init_process_batch_key] INT            NOT NULL,
    --[process_batch_key]      INT            NOT NULL,
    CONSTRAINT [file_row_pk] PRIMARY KEY CLUSTERED ([file_row_key] ASC)
);