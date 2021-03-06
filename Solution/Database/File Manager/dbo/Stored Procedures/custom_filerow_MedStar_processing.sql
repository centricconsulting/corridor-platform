﻿









CREATE PROCEDURE [dbo].[custom_filerow_MedStar_processing] (@agency_file_key as int, @file_name as varchar(200))
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

-- MRN This Checks to see if the medical record number is at least 14 characters
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', Invalid MRN#', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND (
		(column06 IS NULL OR RTRIM(column06) = '')
		OR LEN(column06) < 14
	)

-- Visit Type SOC / RECERT both are at least 3 charcters
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Invalid Visit Type', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND (
		(column17 IS NULL OR RTRIM(column17) = '')
		OR LEN(column17) < 3
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

-- Assessment Date / Visit Date
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Invalid Assessment Date / Visit Date', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND (
		(column18 IS NULL OR RTRIM(column18) = '')
		OR ISDATE(column18) = 0
	)


--Team Color 
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Invalid Team Color', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND (
	(column03 IS NULL OR RTRIM(column03) = '')
	OR LEN(column03) < 3
)


	-- Episode Status
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Invalid Episode Status', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND (
(column21 IS NULL OR RTRIM(column21) = '')
OR LEN(column21) < 3
)



-- Product Suffix This add the header for one column, which is one row insert.
UPDATE agency_file_row
SET column40 = 'Product_Suffix'
WHERE agency_file_key = @agency_file_key
AND row_index = @header_row_index



-- update new columns

-- Product Suffix
-- This Finds the Corresponding Lookup between Visit_Type (which is column 17) and Inserts the corresponding value 
-- in Column 40
--UPDATE agency_file_row
--SET column40 = column17
--FROM agency_file_row
--WHERE agency_file_key = @agency_file_key
--AND process_dtm IS NULL
--AND row_index > @header_row_index

-- Product Suffix
UPDATE agency_file_row
SET column40 = Product_Suffix
FROM agency_file_row
INNER JOIN 
(
SELECT 'SOC' Visit_Type, 'SOC' Product_Suffix
UNION ALL
SELECT 'ROC/RECERT', 'RECERT'
UNION ALL
SELECT 'RECERT', 'RECERT'
) Product_Suffix_Lookup
ON agency_file_row.column17 = Product_Suffix_Lookup.Visit_Type
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index



-- Product Suffix errors
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Record Rejected - Invalid product:' + column17, create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND column40 IS NULL


-- Episode Status
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Record Rejected - Episode Status not CURRENT or PENDING', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND column21 != 'PENDING'
AND column21 != 'CURRENT'


--Custom Exclusion OPERATIONS DIRECTOR
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Record Rejected - Responsible Position OPERATIONS DIRECTOR not allowed', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND column09 = 'OPERATIONS DIRECTOR'

-- Episode Status
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Record Rejected - Episode Status not CURRENT/PENDING/DISCHARGED', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND column21 != 'PENDING'
AND column21 != 'CURRENT'
AND column21 != 'DISCHARGED'