CREATE TABLE [dqm].[scenario_measure] (
    [scenario_uid]                VARCHAR (200) NOT NULL,
    [measure_name]                VARCHAR (200) NOT NULL,
    [precision]                   INT           NULL,
    [flexible_null_equality_flag] CHAR (1)      NULL,
    [allowed_variance]            FLOAT (53)    NULL,
    [allowed_variance_rate]       FLOAT (53)    NULL,
    [create_dtm]                  DATETIME      DEFAULT (getdate()) NULL,
    CONSTRAINT [scenario_measure_pk] PRIMARY KEY CLUSTERED ([scenario_uid] ASC, [measure_name] ASC)
);



