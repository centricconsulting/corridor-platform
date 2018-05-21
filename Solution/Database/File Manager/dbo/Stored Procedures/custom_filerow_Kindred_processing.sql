
CREATE PROCEDURE [dbo].[custom_filerow_Kindred_processing] (@agency_file_key as int, @file_name as varchar(200))
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
SET process_dtm = GETDATE(), process_success_ind = 1, create_agency_medical_record_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index <= @header_row_index

-- Create new columns in agency file row
UPDATE agency_file_row
SET column40 = 'CALCULATED_MRN'
WHERE agency_file_key = @agency_file_key
AND row_index = @header_row_index

-- validate important columns

-- MRN
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', Invalid MRN#', create_agency_medical_record_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND (
		(column02 IS NULL OR RTRIM(column02) = '')
		OR ISNUMERIC(column02) = 0
	)

-- Form
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column02 + ', Invalid Form', create_agency_medical_record_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND (
		(column06 IS NULL OR RTRIM(column06) = '')
		OR LEN(column06) < 5
	)

-- Assessment Date
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column02 + ', Invalid Assessment Date', create_agency_medical_record_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND (
		(column08 IS NULL OR RTRIM(column08) = '')
		OR ISDATE(column08) = 0
	)

-- Insurance
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column02 + ', Invalid Insurance for SOC', create_agency_medical_record_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND column06 LIKE '%Start of Care%'
AND (
		(column04 IS NULL OR RTRIM(column04) = '')
		OR LEN(column04) < 4
	)

-- Agency
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column02 + ', Invalid Agency Name', create_agency_medical_record_ind = 0
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index
AND (
		(column05 IS NULL OR RTRIM(column05) = '')
		OR LEN(column05) < 5
	)

-- update new columns

-- MRN
UPDATE agency_file_row
SET column40 = RIGHT('000000000' + column02, 9)
WHERE agency_file_key = @agency_file_key
AND row_index > @header_row_index