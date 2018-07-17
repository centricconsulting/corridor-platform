CREATE TABLE [dbo].[agency] (
    [agency_key]                    INT            IDENTITY (1, 1) NOT NULL,
    [agency_name]                   VARCHAR (100)  NOT NULL,
    [agency_code_salesforce]        VARCHAR (40)   NULL,
    [default_file_format_code]      VARCHAR (20)   NULL,
    [folder_branch]                 VARCHAR (200)  NULL,
    [notify_email_address_list]     VARCHAR (4000) NULL,
    [notify_on_rejected_ind]        BIT            NOT NULL,
    [notify_on_accepted_ind]        BIT            NOT NULL,
    [create_timestamp]              DATETIME       NOT NULL,
    [modify_timestamp]              DATETIME       NOT NULL,
    [process_batch_key]             INT            NOT NULL,
    [medical_record_sp_name]        VARCHAR (50)   NULL,
    [file_row_sp_name]              VARCHAR (50)   NULL,
    [sfc_lookup_sp_name]            VARCHAR (50)   NULL,
    [sfc_Status__c]                 NVARCHAR (10)  NULL,
    [sfc_Ready_for_Coding_send_ind] BIT            CONSTRAINT [DF_agency_sfc_Ready_for_Coding_send_ind] DEFAULT ((1)) NULL,
    CONSTRAINT [agency_pk] PRIMARY KEY CLUSTERED ([agency_key] ASC)
);






GO

CREATE UNIQUE INDEX dbo_agency_u1 ON dbo.agency (agency_name);
GO

CREATE UNIQUE INDEX dbo_agency_u2 ON dbo.agency ([folder_branch]);
GO

