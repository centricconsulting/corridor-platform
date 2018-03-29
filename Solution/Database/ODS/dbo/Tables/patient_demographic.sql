﻿CREATE TABLE [dbo].[patient_demographic]
(
	[agency]					VARCHAR(100)	NULL, 
	[agency_location]			VARCHAR(100)	NULL,
	[agency_location_alias]		VARCHAR(50)		NULL,
	[team]						VARCHAR(20)		NULL,		 
	[patient_lastname]			VARCHAR(50)		NULL,		
	[patient_firstname]			VARCHAR(50)		NULL,
	[mrn]						VARCHAR(50)		NULL,		
	[oasis_visit_type]			VARCHAR(50)		NULL,		
	[visit_type]				VARCHAR(50)		NULL,		 
	[assessment_dt]				DATE			NULL,		--visit_dt
	[responsible_position]		VARCHAR(50)		NULL,
	[arrival_dt]				DATE			NULL,		 
	[soe_dt]					DATE			NULL,		
	[soc_dt]					DATE			NULL,		 
	[rec_dt]					DATE			NULL,		 
	[roc_dt]					DATE			NULL,		
	[hospice_dt]				DATE			NULL,		
	[discharge_dt]				DATE			NULL,		 
	[payor_type]				VARCHAR(50)		NULL,		
	[payor_source]				VARCHAR(50)		NULL,		
	[secondary_payor_type]		VARCHAR(50)		NULL,		
	[secondary_payor_source]	VARCHAR(50)		NULL,		
	[clinician_firstname]		VARCHAR(50)		NULL,		
	[clinician_lastname]		VARCHAR(50)		NULL,		
	[event]						VARCHAR(50)		NULL,		
	[stage]						VARCHAR(50)		NULL,		
	[task]						VARCHAR(50)		NULL,
	[status]					VARCHAR(50)		NULL,	
	[prepared_for_coding_dt]	DATE			NULL,
	[agency_file_row_key] INT NOT NULL,
	[create_timestamp]			DATETIME		NOT NULL,
  [process_batch_key]					INT             NOT NULL,

)
