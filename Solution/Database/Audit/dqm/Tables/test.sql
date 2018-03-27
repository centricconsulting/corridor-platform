CREATE TABLE [dqm].[test] (
    [test_uid]                  VARCHAR (200)  NOT NULL,
    [scenario_uid]              VARCHAR (200)  NOT NULL,
    [test_dtm]                  DATETIME       DEFAULT (getdate()) NULL,
    [modularity]                INT            NULL,
    [modulus]                   INT            NULL,
    [failure_case_ct]           INT            NULL,
    [success_case_ct]           INT            NULL,
    [case_failure_rate]         FLOAT (53)     NULL,
    [allowed_case_failure_rate] FLOAT (53)     NULL,
    [failure_flag]              CHAR (1)       NULL,
    [error_flag]                CHAR (1)       NULL,
    [test_error_message]        VARCHAR (2000) NULL,
    [expected_error_message]    VARCHAR (2000) NULL,
    [actual_error_message]      VARCHAR (2000) NULL,
    [test_index]                INT            IDENTITY (0, 1) NOT NULL,
    [test_case_purge_dtm]       DATETIME       NULL,
    [create_dtm]                DATETIME       DEFAULT (getdate()) NULL,
    CONSTRAINT [test_pk] PRIMARY KEY CLUSTERED ([test_uid] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [test_u1]
    ON [dqm].[test]([test_index] ASC);

