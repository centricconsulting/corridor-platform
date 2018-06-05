﻿CREATE TABLE [dbo].[agency_file_row] (
    [agency_file_row_key]              INT            IDENTITY (1, 1) NOT NULL,
    [agency_file_key]                  INT            NOT NULL,
    [row_index]                        INT            NOT NULL,
    [column_header_ind]                BIT            NOT NULL,
    [column01]                         VARCHAR (MAX)  NULL,
    [column02]                         VARCHAR (MAX)  NULL,
    [column03]                         VARCHAR (MAX)  NULL,
    [column04]                         VARCHAR (MAX)  NULL,
    [column05]                         VARCHAR (MAX)  NULL,
    [column06]                         VARCHAR (MAX)  NULL,
    [column07]                         VARCHAR (MAX)  NULL,
    [column08]                         VARCHAR (MAX)  NULL,
    [column09]                         VARCHAR (MAX)  NULL,
    [column10]                         VARCHAR (MAX)  NULL,
    [column11]                         VARCHAR (MAX)  NULL,
    [column12]                         VARCHAR (MAX)  NULL,
    [column13]                         VARCHAR (MAX)  NULL,
    [column14]                         VARCHAR (MAX)  NULL,
    [column15]                         VARCHAR (MAX)  NULL,
    [column16]                         VARCHAR (MAX)  NULL,
    [column17]                         VARCHAR (MAX)  NULL,
    [column18]                         VARCHAR (MAX)  NULL,
    [column19]                         VARCHAR (MAX)  NULL,
    [column20]                         VARCHAR (MAX)  NULL,
    [column21]                         VARCHAR (MAX)  NULL,
    [column22]                         VARCHAR (MAX)  NULL,
    [column23]                         VARCHAR (MAX)  NULL,
    [column24]                         VARCHAR (MAX)  NULL,
    [column25]                         VARCHAR (MAX)  NULL,
    [column26]                         VARCHAR (MAX)  NULL,
    [column27]                         VARCHAR (MAX)  NULL,
    [column28]                         VARCHAR (MAX)  NULL,
    [column29]                         VARCHAR (MAX)  NULL,
    [column30]                         VARCHAR (MAX)  NULL,
    [column31]                         VARCHAR (MAX)  NULL,
    [column32]                         VARCHAR (MAX)  NULL,
    [column33]                         VARCHAR (MAX)  NULL,
    [column34]                         VARCHAR (MAX)  NULL,
    [column35]                         VARCHAR (MAX)  NULL,
    [column36]                         VARCHAR (MAX)  NULL,
    [column37]                         VARCHAR (MAX)  NULL,
    [column38]                         VARCHAR (MAX)  NULL,
    [column39]                         VARCHAR (MAX)  NULL,
    [column40]                         VARCHAR (MAX)  NULL,
    [process_dtm]                      DATETIME       NULL,
    [process_success_ind]              BIT            NULL,
    [process_error_category]           VARCHAR (10)   NULL,
    [process_error_message]            VARCHAR (2000) NULL,
    [notification_sent_ind]            BIT            CONSTRAINT [DF_agency_file_row_notification_sent_ind] DEFAULT ((1)) NOT NULL,
    [create_agency_medical_record_ind] BIT            CONSTRAINT [DF_agency_file_row_create_agency_medical_record_ind] DEFAULT ((1)) NOT NULL,
    [create_timestamp]                 DATETIME       NULL,
    [modify_timestamp]                 DATETIME       NULL,
    [process_batch_key]                INT            NULL,
    CONSTRAINT [dbo_agency_file_row_pk] PRIMARY KEY CLUSTERED ([agency_file_row_key] ASC)
);






GO

CREATE UNIQUE INDEX dbo_agency_file_row_u1 ON dbo.agency_file_row (agency_file_key, row_index);
GO
