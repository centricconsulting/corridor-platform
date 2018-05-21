﻿CREATE PROCEDURE [dbo].[custom_filerow_Intrepid_processing] (@agency_file_key as int, @file_name as varchar(200))
AS

-- Get the header row index
DECLARE @header_row_index int
SELECT @header_row_index = row_index
FROM agency_file_row
WHERE agency_file_key = @agency_file_key
AND column_header_ind = 1

-- validate important columns

-- MRN
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', Invalid MRN#', create_agency_medical_record_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND (
		(column03 IS NULL OR RTRIM(column03) = '')
		OR ISNUMERIC(column03) = 0
	)

-- OASIS Visit Type
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Invalid OASIS Visit Type', create_agency_medical_record_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND (
		(column04 IS NULL OR RTRIM(column04) = '')
		OR LEN(column04) < 5
	)


-- Assessment Date / Schedule Date
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Invalid Assessment / Schedule Date', create_agency_medical_record_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND (
		(column05 IS NULL OR RTRIM(column05) = '')
		OR ISDATE(column05) = 0
	)

-- Status
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Invalid Status', create_agency_medical_record_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND (
		(column06 IS NULL OR RTRIM(column06) = '')
	)

-- update new columns

-- Custom OASIS Visit Type Validation
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Record rejected - Not RESUMPTION or START OF CARE', create_agency_medical_record_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND column04 NOT LIKE '%Resumption%'
AND column04 NOT LIKE '%Start of care%'

-- Custom Status Validation
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Record Rejected - Not "Submitted with Signature" or "Submitted to Case Manager"', create_agency_medical_record_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND column06 != 'Submitted with Signature'
AND column06 != 'Submitted to Case Manager'