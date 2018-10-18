CREATE TABLE [dbo].[Problem_Monitoring] (
    [ProblemID]                  INT           IDENTITY (1, 1) NOT NULL,
    [MRN]                        VARCHAR (200) NULL,
    [AssessmentDate]             DATETIME      NULL,
    [sfc_Agency__c]              NVARCHAR (18) NULL,
    [Agency]                     VARCHAR (MAX) NULL,
    [sfc_Status__c]              VARCHAR (200) NULL,
    [create_timestamp]           DATETIME      CONSTRAINT [DF_Problem_Monitoring_create_timestamp] DEFAULT (getdate()) NOT NULL,
    [modify_timestamp]           DATETIME      CONSTRAINT [DF_Problem_Monitoring_modify_timestamp] DEFAULT (getdate()) NOT NULL,
    [problem_resolved_timestamp] DATETIME      NULL,
    [update_ready_ind]           BIT           CONSTRAINT [DF_Problem_Monitoring_update_hhcp_ready_ind] DEFAULT ((0)) NOT NULL,
    [update_status]              VARCHAR (25)  NULL,
    [update_status_details]      VARCHAR (MAX) NULL,
    [update_timestamp]           DATETIME      NULL,
    CONSTRAINT [PK_Problem_Monitoring] PRIMARY KEY CLUSTERED ([ProblemID] ASC)
);

