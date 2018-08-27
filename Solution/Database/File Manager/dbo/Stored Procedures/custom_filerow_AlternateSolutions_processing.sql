
CREATE PROCEDURE [dbo].[custom_filerow_AlternateSolutions_processing] (@agency_file_key as int, @file_name as varchar(200))
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
		OR LEN(column06) < 9
	)

-- Visit Type Warning
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Record Rejected - Blank Visit Type', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND (column17 IS NULL OR RTRIM(column17) = '')

-- Visit Type Error
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Invalid Visit Type:' + column16, create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND LEN(column17) < 3


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

-- Create new columns in agency file row

-- Product Suffix
UPDATE agency_file_row
SET column40 = 'Product_Suffix'
WHERE agency_file_key = @agency_file_key
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
	SELECT 'ROC/RECERT', 'ROC' -- ROC/RECERT are always handled as ROCs
	UNION ALL
	SELECT 'RECERT', 'RECERT'
	UNION ALL
	SELECT 'RESUMPTION OF CARE', 'ROC'
) Product_Suffix_Lookup
ON agency_file_row.column17 = Product_Suffix_Lookup.Visit_Type
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index

-- SOC/RECERT custom product handling - SOCs
UPDATE agency_file_row
SET column40 = 'SOC'
FROM agency_file_row
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND column17 = 'SOC/RECERT'
-- If SOE and SOC date match, they are a SOC
AND column07 = column08

-- SOC/RECERT custom product handling - RECERTs
UPDATE agency_file_row
SET column40 = 'RECERT'
FROM agency_file_row
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND column17 = 'SOC/RECERT'
-- If SOE and SOC date do not match, they are a RECERT
AND column07 != column08

-- Product Suffix errors
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Record Rejected - Invalid product:' + column17, create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND column40 IS NULL

-- custom logic

-- Worker's comp payors
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Record Rejected - Worker''s Comp', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND 
(
	column14 LIKE 'WC %'
	OR column14 LIKE 'INDIGENT%'
)

-- Episode Status
UPDATE agency_file_row
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + @file_name + ', MRN:' + column06 + ', Record Rejected - Episode Status not CURRENT/PENDING/DISCHARGED', create_agency_medical_record_ind = 0, notification_sent_ind = 0
WHERE agency_file_key = @agency_file_key
AND process_dtm IS NULL
AND row_index > @header_row_index
AND column21 != 'PENDING'
AND column21 != 'CURRENT'
AND column21 != 'DISCHARGED'