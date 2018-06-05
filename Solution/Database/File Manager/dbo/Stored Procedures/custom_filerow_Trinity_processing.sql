
CREATE PROCEDURE [dbo].[custom_filerow_Trinity_processing] (@agency_file_key as int, @file_name as varchar(200))
AS

-- Get the header row index
DECLARE @header_row_index int
SELECT @header_row_index = file_format_header_row
FROM [file_format]
INNER JOIN agency
ON [file_format].file_format_code = agency.default_file_format_code
INNER JOIN agency_file
ON agency.agency_key = agency_file.agency_key
WHERE agency_file_key = @agency_file_key


-- validate important columns

-- MRN
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', Invalid MRN#', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND (
		(column03 IS NULL OR RTRIM(column03) = '')
		OR LEN(column03) < 12
	)

-- OASIS Visit Type / Payor Type
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Invalid OASIS Visit Type / Payor Type', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND (
		(column08 IS NULL OR RTRIM(column08) = '')
		OR LEN(column08) < 5
	)

-- Assessment Date / SOE Date
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Invalid Assessment Date / SOE Date', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND (
		(column05 IS NULL OR RTRIM(column05) = '')
		OR ISDATE(column05) = 0
	)

-- SOC Date
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Invalid SOC Date', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND (
		(column04 IS NULL OR RTRIM(column04) = '')
		OR ISDATE(column04) = 0
	)

-- update new columns

-- Compare SOC Date and SOE Date
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 1, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Record rejected because recert', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND (
		(CAST(column04 as datetime) != CAST(column05 as datetime))
		AND process_success_ind IS NULL
	)