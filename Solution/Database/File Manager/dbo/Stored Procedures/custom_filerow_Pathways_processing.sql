
CREATE PROCEDURE [dbo].[custom_filerow_Pathways_processing] (@agency_file_key as int, @file_name as varchar(200))
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

-- force process rows that occur before header row
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 1, create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index <= @header_row_index

-- Create new columns in agency file row
UPDATE agency_file_row
SET column40 = 'CALCULATED_MRN'
WHERE agency_file_key = @agency_file_key
AND row_index = @header_row_index

UPDATE agency_file_row
SET column39 = 'CALCULATED_LastName'
WHERE agency_file_key = @agency_file_key
AND row_index = @header_row_index

UPDATE agency_file_row
SET column38 = 'CALCULATED_FirstName'
WHERE agency_file_key = @agency_file_key
AND row_index = @header_row_index

-- validate important columns

-- MRN
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', Invalid MRN#', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND (
		(column02 IS NULL OR RTRIM(column02) = '')
		OR ISNUMERIC(column02) = 0
	)

-- Assessment
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column02 + ', Invalid Assessment', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND create_agency_medical_record_ind = 1
AND (
		(column06 IS NULL OR RTRIM(column06) = '')
		OR LEN(column06) < 6
	)

-- Patient Name
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column02 + ', Invalid Patient Name', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND create_agency_medical_record_ind = 1
AND (
		(column01 IS NULL OR RTRIM(column01) = '')
		OR LEN(column01) < 2
		OR CHARINDEX(',', column01) = 0
	)

-- Assessment Date
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column02 + ', Invalid Assessment Date', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND create_agency_medical_record_ind = 1
AND (
		(column11 IS NULL OR RTRIM(column11) = '')
		OR ISDATE(column11) = 0
	)


-- update new columns

-- MRN
UPDATE agency_file_row
SET column40 = RIGHT('0000000' + column02, 7)
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND create_agency_medical_record_ind = 1

-- Last Name
UPDATE agency_file_row
SET column39 = LEFT(column01, CHARINDEX(',', column01) - 1)
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND create_agency_medical_record_ind = 1

-- First Name
UPDATE agency_file_row
SET column38 = RIGHT(column01, LEN(column01) - CHARINDEX(',', column01))
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND create_agency_medical_record_ind = 1


-- custom logic

-- Assessment Date must be greater than or equal to 7/5/2018
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column02 + ', Record Rejected - Assessment Date prior to 7/5/2018', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND create_agency_medical_record_ind = 1
AND CAST(column11 as date) >= '7/5/2018'