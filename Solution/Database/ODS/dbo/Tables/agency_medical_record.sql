CREATE TABLE [dbo].agency_medical_record (
  [agency]	VARCHAR(100)	NOT NULL, 
  [medical_record_number]	 VARCHAR(50) NOT NULL,
  [assessment_date]	DATE	NOT NULL,	

  [visit_type]	VARCHAR(50)		NULL,			
  [agency_location]			VARCHAR(100)	NULL,
  [agency_location_alias]		VARCHAR(50)		NULL,
  [team]						VARCHAR(20)		NULL,		 
  [patient_last_name]			VARCHAR(50)		NULL,		
  [patient_first_name]			VARCHAR(50)		NULL,
  [oasis_visit_type]			VARCHAR(50)		NULL,			
	
  [responsible_position]		VARCHAR(50)		NULL,	
  [arrival_date]				DATE			NULL,	
  [start_of_care_date]					DATE			NULL,		
  [start_episodte_date]					DATE			NULL,		 
  [recertification_date]					DATE			NULL,		 
  [resumption_of_care_date]					DATE			NULL,		
  [hospice_date]				DATE			NULL,		
  [discharge_date]				DATE			NULL,		 
  [payor_type]				VARCHAR(50)		NULL,		
  [payor_source]				VARCHAR(50)		NULL,		
  [secondary_payor_type]		VARCHAR(50)		NULL,		
  [secondary_payor_source]	VARCHAR(50)		NULL,		
  [clinician_first_name]		VARCHAR(50)		NULL,		
  [clinician_last_name]		VARCHAR(50)		NULL,		
  [event]						VARCHAR(50)		NULL,		
  [stage]						VARCHAR(50)		NULL,		
  [task]						VARCHAR(50)		NULL,
  [episode_identifier]  VARCHAR(200) NULL,
  [create_agency_file_row_key] INT NOT NULL,
  [modify_agency_file_row_key] INT NOT NULL,
  [create_date]			DATETIME		NOT NULL,
  [modify_date]			DATETIME		NOT NULL,
  [process_batch_key]			INT NOT NULL,

  CONSTRAINT patient_demographic_pk PRIMARY KEY (
    agency, [medical_record_number], [assessment_date]
  )
)
GO