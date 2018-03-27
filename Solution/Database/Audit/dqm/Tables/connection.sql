CREATE TABLE [dqm].[connection] (
    [connection_uid] VARCHAR (200)  NOT NULL,
    [jdbc_driver]    VARCHAR (200)  NULL,
    [jdbc_url]       VARCHAR (2000) NULL,
    [username]       VARCHAR (200)  NULL,
    [password]       VARCHAR (200)  NULL,
    [timeout_sec]    INT            DEFAULT ((-1)) NULL,
    [create_dtm]     DATETIME       DEFAULT (getdate()) NULL,
    CONSTRAINT [connection_pk] PRIMARY KEY CLUSTERED ([connection_uid] ASC)
);



