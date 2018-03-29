CREATE TABLE [cdm].[process_batch_error] (
    [process_batch_key] INT            NOT NULL,
    [error_type_cd]     VARCHAR (20)   NULL,
    [error_scope]       VARCHAR (200)  NULL,
    [error_number]      INT            NULL,
    [error_message]     VARCHAR (2000) NULL,
    [error_dtm]         DATETIME       DEFAULT (getdate()) NULL,
    [comments]          VARCHAR (2000) NULL
);

