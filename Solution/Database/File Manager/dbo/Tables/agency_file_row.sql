CREATE TABLE [dbo].[agency_file_row]
(		
	[agency_file_row_key]	INT IDENTITY(1,1)  NOT NULL,	
	[agency_file_key]		INT NOT NULL,
  [row_index] INT NOT NULL,
  [column_header_ind] BIT NOT NULL,

  [column01]   VARCHAR(200)  NULL,
  [column02]   VARCHAR(200)  NULL,
  [column03]   VARCHAR(200)  NULL,
  [column04]   VARCHAR(200)  NULL,
  [column05]   VARCHAR(200)  NULL,
  [column06]   VARCHAR(200)  NULL,
  [column07]   VARCHAR(200)  NULL,
  [column08]   VARCHAR(200)  NULL,
  [column09]   VARCHAR(200)  NULL,
  [column10]   VARCHAR(200)  NULL,
  [column11]   VARCHAR(200)  NULL,
  [column12]   VARCHAR(200)  NULL,
  [column13]   VARCHAR(200)  NULL,
  [column14]   VARCHAR(200)  NULL,
  [column15]   VARCHAR(200)  NULL,
  [column16]   VARCHAR(200)  NULL,
  [column17]   VARCHAR(200)  NULL,
  [column18]   VARCHAR(200)  NULL,
  [column19]   VARCHAR(200)  NULL,
  [column20]   VARCHAR(200)  NULL,
  [column21]   VARCHAR(200)  NULL,
  [column22]   VARCHAR(200)  NULL,
  [column23]   VARCHAR(200)  NULL,
  [column24]   VARCHAR(200)  NULL,
  [column25]   VARCHAR(200)  NULL,
  [column26]   VARCHAR(200)  NULL,
  [column27]   VARCHAR(200)  NULL,
  [column28]   VARCHAR(200)  NULL,
  [column29]   VARCHAR(200)  NULL,
  [column30]   VARCHAR(200)  NULL,
  [column31]   VARCHAR(200)  NULL,
  [column32]   VARCHAR(200)  NULL,
  [column33]   VARCHAR(200)  NULL,
  [column34]   VARCHAR(200)  NULL,
  [column35]   VARCHAR(200)  NULL,
  [column36]   VARCHAR(200)  NULL,
  [column37]   VARCHAR(200)  NULL,
  [column38]   VARCHAR(200)  NULL,
  [column39]   VARCHAR(200)  NULL,
  [column40]   VARCHAR(200)  NULL,

  -- PROCESS = loading ODS visit table
  [process_dtm]				DATETIME		NULL,
  [process_success_ind]  BIT NULL,
  [process_error_message] VARCHAR(2000) NULL,

	[create_timestamp]		DATETIME			NULL,
	[modify_timestamp]		DATETIME			NULL,
	[process_batch_key]				INT					NULL,
  CONSTRAINT dbo_agency_file_row_pk PRIMARY KEY (agency_file_row_key)
)
GO

CREATE UNIQUE INDEX dbo_agency_file_row_u1 ON dbo.agency_file_row (agency_file_key, row_index);
GO
