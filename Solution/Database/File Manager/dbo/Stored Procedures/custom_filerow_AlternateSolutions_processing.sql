CREATE PROCEDURE [dbo].[custom_filerow_AlternateSolutions_processing] (@agency_file_key as int, @file_name as varchar(200))
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

-- validate important columns

-- MRN
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', Invalid MRN#', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NOT NULL
AND row_index > @header_row_index
AND (
		(column06 IS NULL OR RTRIM(column06) = '')
		OR LEN(column06) < 14
	)


-- Visit Type
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Invalid Visit Type', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NOT NULL
AND row_index > @header_row_index
AND (
		(column16 IS NULL OR RTRIM(column16) = '')
		OR LEN(column16) < 3
	)

-- Branch
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Invalid Branch', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NOT NULL
AND row_index > @header_row_index
AND (
		(column02 IS NULL OR RTRIM(column02) = '')
		OR LEN(column02) < 3
	)

-- Assessment Date / SOE Date
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Invalid Assessment Date / SOE Date', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NOT NULL
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
AND process_dtm IS NOT NULL
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
	SELECT 'ROC/RECERT', 'ROC'
	UNION ALL
	SELECT 'RECERT', 'RECERT'
	UNION ALL
	SELECT 'RESUMPTION OF CARE', 'ROC'
) Product_Suffix_Lookup
ON agency_file_row.column16 = Product_Suffix_Lookup.Visit_Type
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NOT NULL
AND row_index > @header_row_index