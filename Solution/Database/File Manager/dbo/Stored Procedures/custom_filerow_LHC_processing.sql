CREATE PROCEDURE [dbo].[custom_filerow_LHC_processing] (@agency_file_key as int, @file_name as varchar(200))
AS

-- Get the header row index and agency info
DECLARE @header_row_index int
DECLARE @agency_key int
DECLARE @agency_code_salesforce varchar(50)
SELECT @header_row_index = file_format_header_row, @agency_key = agency.agency_key, @agency_code_salesforce = agency_code_salesforce
FROM [file_format]
INNER JOIN agency
ON [file_format].file_format_code = agency.default_file_format_code
INNER JOIN agency_file
ON agency.agency_key = agency_file.agency_key
WHERE agency_file_key = @agency_file_key

-- force process rows that occur before header row
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 1, create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index <= @header_row_index

-- validate important columns

-- MRN
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', Invalid MRN#', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND (
		(column06 IS NULL OR RTRIM(column06) = '')
		OR LEN(column06) < 14
	)

-- Visit Type
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Invalid Visit Type', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND (
		(column16 IS NULL OR RTRIM(column16) = '')
		OR LEN(column16) < 3
	)

-- Branch
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Invalid Branch', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND (
		(column02 IS NULL OR RTRIM(column02) = '')
		OR LEN(column02) < 3
	)

-- Assessment Date / SOE Date
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Invalid Assessment Date / SOE Date', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND (
		(column07 IS NULL OR RTRIM(column07) = '')
		OR ISDATE(column07) = 0
	)

-- Create new columns in agency file row

-- Product Suffix
UPDATE agency_file_row
SET column40 = 'Product_Suffix'
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index = @header_row_index

-- ROC/RECERT Clone success ind - this column is used to generate numerous error messages
--  with the ROC/RECERT clone process
UPDATE agency_file_row
SET column39 = 'ROC_RECERT_Clone_ind'
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index = @header_row_index

-- update new columns

-- Product Suffix
UPDATE agency_file_row
SET column40 = Product_Suffix
FROM agency_file_row
INNER JOIN 
(
	SELECT 'SOC' Visit_Type, 'SOC' Product_Suffix
	UNION ALL
	SELECT 'ROC/RECERT', 'ROC' -- RECERT clones are handled below
	UNION ALL
	SELECT 'RECERT', 'RECERT'
	UNION ALL
	SELECT 'RESUMPTION OF CARE', 'ROC'
	UNION ALL
	SELECT 'HOSPICE SOC', '' -- Product name is Hospice, which will get populated from the lookup table
) Product_Suffix_Lookup
ON agency_file_row.column16 = Product_Suffix_Lookup.Visit_Type
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index

-- Product Suffix errors
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Record Rejected - Invalid product:' + column16, create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND column40 IS NULL


-- ROC/Recert Clone success indicator
UPDATE agency_file_row
SET column39 = '0'
FROM agency_file_row
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index

-- custom logic

-- Clone ROC/Recert records
--  The cloned records will be listed as RECERT, and the original records treated as ROC
INSERT INTO agency_file_row (agency_file_key, row_index, column_header_ind, column01, column02, column03, column04, column05, column06, column07, column08, column09, column10, column11, column12, column13, column14, column15, column16, column17, column18, column19, column39, column40, create_timestamp, modify_timestamp, process_batch_key)
SELECT @agency_file_key, 100000 + row_index, 0, column01, column02, column03, column04, column05, column06 + '-1', column07, column08, column09, column10, column11, column12, column13, column14, column15, 'RECERT', column17, column18, column19, '1', 'RECERT', GETDATE(), GETDATE(), 0
FROM agency_file_row
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN agency
ON agency_file.agency_key = agency.agency_key
INNER JOIN sfc.DM_Agency__c Agency__c
ON agency_file_row.column02 = Agency__c.Agency_Alias__c
AND agency.agency_code_salesforce = sfc.GetTrueParentAgencyCode(Agency__c.id)
INNER JOIN sfc.Agency_ETL_variables__c ETL_variables
ON Agency__c.Id = ETL_variables.Agency_Location__c
WHERE agency_file_row.agency_file_key = @agency_file_key
AND column16 = 'ROC/RECERT'
AND agency_file_row.process_dtm IS NULL
AND ROC_RECERT_Process__c = 'ROC/RECERT Combo'

-- Update clone success ind for ROC/Recert records
UPDATE agency_file_row
SET column39 = '1'
FROM agency_file_row
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN agency
ON agency_file.agency_key = agency.agency_key
INNER JOIN sfc.DM_Agency__c Agency__c
ON agency_file_row.column02 = Agency__c.Agency_Alias__c
AND agency.agency_code_salesforce = sfc.GetTrueParentAgencyCode(Agency__c.id)
INNER JOIN sfc.Agency_ETL_variables__c ETL_variables
ON Agency__c.Id = ETL_variables.Agency_Location__c
WHERE agency_file_row.agency_file_key = @agency_file_key
AND column16 = 'ROC/RECERT'
AND agency_file_row.process_dtm IS NULL
AND ROC_RECERT_Process__c = 'ROC/RECERT Combo'

-- ROC/RECERT not allowed error
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Record Rejected - ROC/RECERT not allowed for location ' + column02 + ' in HHCP', create_agency_medical_record_ind = 0, notification_sent_ind = 0
FROM agency_file_row
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN agency
ON agency_file.agency_key = agency.agency_key
INNER JOIN sfc.DM_Agency__c Agency__c
ON agency_file_row.column02 = Agency__c.Agency_Alias__c
AND agency.agency_code_salesforce = sfc.GetTrueParentAgencyCode(Agency__c.id)
INNER JOIN sfc.Agency_ETL_variables__c ETL_variables
ON Agency__c.Id = ETL_variables.Agency_Location__c
WHERE agency_file_row.agency_file_key = @agency_file_key
AND column16 = 'ROC/RECERT'
AND column39 = '0'
AND agency_file_row.process_dtm IS NULL
AND ROC_RECERT_Process__c != 'ROC/RECERT Combo'


-- ETL Variables not found error
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Record Rejected - ROC/Recert lookup cannot find ETL Variables for location ' + column02 + ' in HHCP', create_agency_medical_record_ind = 0, notification_sent_ind = 0
FROM agency_file_row
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN agency
ON agency_file.agency_key = agency.agency_key
INNER JOIN sfc.DM_Agency__c Agency__c
ON agency_file_row.column02 = Agency__c.Agency_Alias__c
AND agency.agency_code_salesforce = sfc.GetTrueParentAgencyCode(Agency__c.id)
WHERE agency_file_row.agency_file_key = @agency_file_key
AND column16 = 'ROC/RECERT'
AND column39 = '0'
AND agency_file_row.process_dtm IS NULL

-- Agency not found error
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Record Rejected - ROC/Recert lookup cannot find agency location ' + column02 + ' in HHCP', create_agency_medical_record_ind = 0, notification_sent_ind = 0
FROM agency_file_row
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN agency
ON agency_file.agency_key = agency.agency_key
WHERE agency_file_row.agency_file_key = @agency_file_key
AND column16 = 'ROC/RECERT'
AND column39 = '0'
AND agency_file_row.process_dtm IS NULL