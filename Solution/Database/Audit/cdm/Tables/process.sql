CREATE TABLE [cdm].[process] (
    [process_uid]                 VARCHAR (200) NOT NULL,
    [channel_uid]                 VARCHAR (200) NOT NULL,
    [context]                     VARCHAR (200) NOT NULL,
    [completed_process_batch_key] INT           NULL,
    [completed_sequence_val]      BIGINT        NULL,
    [completed_sequence_dtm]      DATETIME      NULL,
    [initiate_dtm]                DATETIME      NULL,
    [conclude_dtm]                DATETIME      NULL,
    [tags]                        VARCHAR (200) NULL,
    CONSTRAINT [process_pk] PRIMARY KEY CLUSTERED ([process_uid] ASC, [channel_uid] ASC)
);





