

CREATE PROCEDURE [dbo].[custom_filerow_LifeCare_processing] (@agency_file_key as int, @file_name as varchar(200))
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
AND process_dtm IS NULL
AND (
		(column03 IS NULL OR RTRIM(column03) = '')
		OR LEN(column03) < 1
	)

-- OASIS Visit Type
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Invalid OASIS Visit Type', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND process_dtm IS NULL
AND (
		(column04 IS NULL OR RTRIM(column04) = '')
		OR LEN(column04) < 5
	)


-- Assessment Date / Schedule Date
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Invalid Assessment / Schedule Date', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND process_dtm IS NULL
AND (
		(column05 IS NULL OR RTRIM(column05) = '')
		OR ISDATE(column05) = 0
	)

-- Agency Location
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Invalid Agency Location', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND process_dtm IS NULL
AND (
		(column10 IS NULL OR RTRIM(column10) = '')
	)

-- update new columns

-- Custom Status Validation
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Record Rejected - Not "Submitted with Signature" or "Submitted to Case Manager"', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND process_dtm IS NULL
AND column06 != 'Submitted with Signature'
AND column06 != 'Submitted to Case Manager'

-- Reject transfers
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Record Rejected - Transfer', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND process_dtm IS NULL
AND column04 LIKE '%Transfer%'

-- Reject death records
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Record Rejected - Death', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND process_dtm IS NULL
AND column04 LIKE '%Death%'

-- Non SOC charts with assessment date before 6/25/2018 should be rejected
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Record Rejected - Non-SOC before 6/25/2018', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND process_dtm IS NULL
AND CAST(column05 as date) < '6/25/2018'
AND column04 NOT LIKE '%Start of Care%'

-- Non SOC charts w assessment date before 7/16/2018 of certain locations should be rejected
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Record Rejected - Non-SOC before 7/16/2018 - Location: ' + column10, create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND process_dtm IS NULL
AND CAST(column05 as date) < '7/16/2018'
AND column04 NOT LIKE '%Start of Care%'
AND column10 IN
(
SELECT 'BeyondFaith - Ft.Worth'
UNION ALL
SELECT 'Haven - Dallas1'
UNION ALL
SELECT 'Haven - Dallas'
UNION ALL
SELECT 'Haven - Ft.Worth'
)

-- Charts w assessment date before 7/23/2018 of certain locations should be rejected
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column03 + ', Record Rejected - Assessment date before 7/23/2018 - Location: ' + column10, create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND process_dtm IS NULL
AND CAST(column05 as date) < '7/23/2018'
AND column10 IN
(
SELECT 'Complete - Broward'
UNION ALL
SELECT 'Complete Home Care of the Palm Beaches, LLC'
)