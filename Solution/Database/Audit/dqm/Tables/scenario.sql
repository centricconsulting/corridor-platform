CREATE TABLE [dqm].[scenario] (
    [scenario_uid]                VARCHAR (200)  NOT NULL,
    [scenario_desc]               VARCHAR (2000) NULL,
    [tag_list]                    VARCHAR (2000) NULL,
    [grain_list]                  VARCHAR (2000) NULL,
    [modulus]                     INT            DEFAULT ((1)) NULL,
    [expected_connection_uid]     VARCHAR (200)  NULL,
    [expected_command]            VARCHAR (MAX)  NULL,
    [actual_connection_uid]       VARCHAR (200)  NULL,
    [actual_command]              VARCHAR (MAX)  NULL,
    [case_failure_record_limit]   INT            DEFAULT ((10000)) NOT NULL,
    [case_success_record_limit]   INT            DEFAULT ((0)) NOT NULL,
    [allowed_case_failure_rate]   FLOAT (53)     DEFAULT ((0.0)) NOT NULL,
    [flexible_null_equality_flag] CHAR (1)       NULL,
    [active_flag]                 CHAR (1)       DEFAULT ('Y') NOT NULL,
    [create_dtm]                  DATETIME       DEFAULT (getdate()) NULL,
    CONSTRAINT [scenario_pk] PRIMARY KEY CLUSTERED ([scenario_uid] ASC)
);



