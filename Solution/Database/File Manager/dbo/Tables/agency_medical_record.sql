CREATE TABLE [dbo].agency_medical_record (
  [agency_medical_record_key]  INT NOT NULL IDENTITY(1,1) ,

  [agency_key]	INT NOT NULL, 
  [medical_record_number]	 VARCHAR(200) NOT NULL,
  [assessment_date]	DATETIME	NOT NULL,	

  [visit_type]	VARCHAR(200)		NULL,			
  [agency_location]			VARCHAR(200)	NULL,
  [agency_location_alias]		VARCHAR(200)		NULL,
  [team]						VARCHAR(200)		NULL,		 
  [patient_last_name]			VARCHAR(200)		NULL,		
  [patient_first_name]			VARCHAR(200)		NULL,
  [oasis_visit_type]			VARCHAR(200)		NULL,			
	
  [responsible_position]		VARCHAR(200)		NULL,	
  [arrival_date]				DATETIME			NULL,	
  [start_of_care_date]					DATETIME			NULL,		
  [start_of_episode_date]					DATETIME			NULL,		 
  [recertification_date]					DATETIME			NULL,		 
  [resumption_of_care_date]					DATETIME			NULL,		
  [hospice_date]				DATETIME			NULL,		
  [discharge_date]				DATETIME			NULL,		 
  [payor_type]				VARCHAR(200)		NULL,		
  [payor_source]				VARCHAR(200)		NULL,		
  [secondary_payor_type]		VARCHAR(200)		NULL,		
  [secondary_payor_source]	VARCHAR(200)		NULL,		
  [clinician_first_name]		VARCHAR(200)		NULL,		
  [clinician_last_name]		VARCHAR(200)		NULL,		
  [event]						VARCHAR(200)		NULL,		
  [stage]						VARCHAR(200)		NULL,		
  [task]						VARCHAR(200)		NULL,
  [episode_identifier]  VARCHAR(200) NULL,
  [create_agency_file_row_key] INT NOT NULL,
  [modify_agency_file_row_key] INT NOT NULL,

  -- PROCESS = loading SFC visit table
  [process_dtm]				   DATETIME		NULL,
  [process_success_ind]  BIT NULL,
  [process_error_message] VARCHAR(2000) NULL,

  [create_timestamp]			DATETIME		NOT NULL,
  [modify_timestamp]			DATETIME		NOT NULL,
  [create_process_batch_key]			INT NOT NULL,
  [modify_process_batch_key]			INT NOT NULL,

  CONSTRAINT dbo_agency_medical_record_pk PRIMARY KEY ([agency_medical_record_key])
)
GO

CREATE UNIQUE INDEX dbo_agency_medical_record_u1 ON
  dbo.agency_medical_record (agency_key, [medical_record_number], [assessment_date])