
CREATE PROCEDURE [dbo].[custom_filerow_LHC_Burst_processing] (@agency_file_key as int, @file_name as varchar(200))
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
		(column01 IS NULL OR RTRIM(column01) = '')
		OR LEN(column01) < 14
	)

-- Visit Type
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column01 + ', Invalid Visit Type / Event', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND (
		(column11 IS NULL OR RTRIM(column11) = '')
		OR LEN(column11) < 3
	)

-- SOE Date
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column01 + ', Invalid SOE Date', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND (
		(column09 IS NULL OR RTRIM(column09) = '')
		OR ISDATE(column09) = 0
	)

-- Assign Date
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column01 + ', Invalid Assign Date', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND (
		(column03 IS NULL OR RTRIM(column03) = '')
		OR ISDATE(column03) = 0
	)

-- Patient Name
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column01 + ', Invalid Patient Name', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND CHARINDEX(',', column02) > 0
AND (
		(column02 IS NULL OR RTRIM(column02) = '')
		OR LEN(column02) < 3
	)


-- Create new columns in agency file row

-- Assessment Date
UPDATE agency_file_row
SET column40 = 'CALC_Assessment_Date'
WHERE agency_file_key = @agency_file_key
AND row_index = @header_row_index

-- Branch Name
UPDATE agency_file_row
SET column39 = 'CALC_Branch'
WHERE agency_file_key = @agency_file_key
AND row_index = @header_row_index

-- Product Suffix
UPDATE agency_file_row
SET column38 = 'Product_Suffix'
WHERE agency_file_key = @agency_file_key
AND row_index = @header_row_index

-- update new columns

-- Product Suffix
UPDATE agency_file_row
SET column38 = Product_Suffix
FROM agency_file_row
INNER JOIN 
(
	SELECT 'Recert' Visit_Type, 'RECERT' Product_Suffix
	UNION ALL
	SELECT 'SOC' Visit_Type, 'SOC' Product_Suffix
	UNION ALL
	SELECT 'Non-episodic SOC' Visit_Type, 'SOC' Product_Suffix
	UNION ALL
	SELECT 'Non-episodic Recert' Visit_Type, 'RECERT' Product_Suffix

) Product_Suffix_Lookup
ON agency_file_row.column11 = Product_Suffix_Lookup.Visit_Type
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index


-- Product Suffix errors
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Record Rejected - Invalid product:' + column11, create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND column38 IS NULL

-- Branch
UPDATE agency_file_row
SET column39 = LEFT(column01, 3)
FROM agency_file_row
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index

-- Assessment Date
UPDATE agency_file_row
SET column40 = column09
FROM agency_file_row
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND column38 = 'SOC'

UPDATE agency_file_row
--SET column40 = column03
SET column40 = column09
FROM agency_file_row
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND column38 = 'RECERT'

-- custom logic