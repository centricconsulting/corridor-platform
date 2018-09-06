
CREATE PROCEDURE [dbo].[custom_sfclookup_Trinity] (@agency_key as int, @process_batch_key as int)
AS

/*
-- TEST CODE --
PRINT 'RESET CODE'
DECLARE @agency_key as int
DECLARE @process_batch_key as int
SET @agency_key = 2
SET @process_batch_key = 111865

UPDATE agency_medical_record
SET process_dtm = NULL, process_error_category = NULL, process_error_message = NULL, process_success_ind = NULL, salesforce_send_ind = 1, notification_sent_ind = 1, sfc_Agency__c = NULL, sfc_Product_Rate__c = NULL
WHERE agency_key = @agency_key
AND process_batch_key = @process_batch_key
PRINT 'END RESET CODE'
-- END TEST CODE --
*/

DECLARE @TrueParentAgencyID varchar(40)

-- Get Salesforce Parent Agency ID
PRINT 'Get Salesforce Parent ID'
SELECT @TrueParentAgencyID = agency_code_salesforce
FROM agency
WHERE agency_key = @agency_key

PRINT @TrueParentAgencyID

-- Get agency code
PRINT 'Get sfc Agency ID for all records'
UPDATE agency_medical_record
SET sfc_Agency__c = Id
FROM agency_medical_record
INNER JOIN sfc.DM_Agency__c
ON agency_medical_record.agency_location = sfc.DM_Agency__c.Agency_Alias__c
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_key = @agency_key
AND salesforce_send_ind = 1
AND sfc.GetTrueParentAgencyCode(sfc.DM_Agency__c.id) = @TrueParentAgencyID


-- Inactive Agency Error Message
PRINT 'Error for inactive agency'
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Record Rejected - Inactive Location in HHCP: "' + agency_location, salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN sfc.DM_Agency__c Agency__c
ON agency_medical_record.sfc_Agency__c = Agency__c.Id
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE Agency__c.Status__c != 'Active'
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1

-- Agency error messages
PRINT 'Error for missing agency'
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find Agency Location "' + agency_location + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND sfc_Agency__c IS NULL

-- Get Hospice product rate codes
PRINT 'Get hospice product rates'
UPDATE agency_medical_record
SET sfc_Product_Rate__c = Id
FROM agency_medical_record
INNER JOIN sfc.DM_Agency_Product_Rate__c
ON agency_medical_record.sfc_Agency__c = sfc.DM_Agency_Product_Rate__c.Agency__c
AND agency_medical_record.visit_type = sfc.DM_Agency_Product_Rate__c.Product_Name_for_IT__c
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_key = @agency_key
AND salesforce_send_ind = 1
AND process_dtm IS NULL
AND visit_type = 'HOSPICE'

-- Hospice Product rate error messages
PRINT 'Hospice product rate errors'
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find HOSPICE Product Rate for location "' + agency_location + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND sfc_Product_Rate__c IS NULL
AND visit_type = 'HOSPICE'

-- Reject discharges for clinician graduates
PRINT 'Reject discharges for clinician grads'
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Record Rejected - Discharge for Graduated Clinician', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.DM_Clinician__c
ON agency_medical_record.clinician_name = sfc.DM_Clinician__c.Full_Name__c
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND sfc_Product_Rate__c IS NULL
AND Clinician_Graduate__c = 'true'
AND visit_type = 'DISCHARGE'
AND sfc.DM_Clinician__c.Agency__c = @TrueParentAgencyID

-- Get product rate code for graduated clinicians
PRINT 'Get product rates for graduated clinician assessments'
UPDATE agency_medical_record
SET sfc_Product_Rate__c = sfc.DM_Agency_Product_Rate__c.Id
FROM agency_medical_record
INNER JOIN sfc.DM_Agency_Product_Rate__c
ON agency_medical_record.sfc_Agency__c = sfc.DM_Agency_Product_Rate__c.Agency__c
AND ('Coding Only ' + agency_medical_record.visit_type) = sfc.DM_Agency_Product_Rate__c.Product_Name_for_IT__c
INNER JOIN sfc.DM_Clinician__c
ON agency_medical_record.clinician_name = sfc.DM_Clinician__c.Full_Name__c
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_key = @agency_key
AND salesforce_send_ind = 1
AND sfc_Product_Rate__c IS NULL
AND process_dtm IS NULL
AND Clinician_Graduate__c = 'true'
AND sfc.DM_Clinician__c.Agency__c = @TrueParentAgencyID

-- Graduated Clinician product rate error messages
PRINT 'Graduated clinician product rate errors'
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find Coding Only Product Rate for Location:"' + agency_location + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.DM_Clinician__c
ON agency_medical_record.clinician_name = sfc.DM_Clinician__c.Full_Name__c
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND sfc_Product_Rate__c IS NULL
AND Clinician_Graduate__c = 'true'
AND sfc.DM_Clinician__c.Agency__c = @TrueParentAgencyID

-- Invalid primary payor type for remaining assessments
PRINT 'Invalid primary payor type errors'
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Invalid Payor Type', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE (payor_type = '' or payor_type IS NULL)
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND sfc_Product_Rate__c IS NULL

-- Update secondary payor types for non-discharge assessments
PRINT 'Update secondary payor types for non-discharge assessments'
UPDATE agency_medical_record
SET secondary_payor_type = SecPayor.Payor_Type__c
FROM agency_medical_record
INNER JOIN
(
	SELECT Payor__c, Payor_Type__c
	FROM sfc.Payor_to_product_lookup__c
	WHERE Category__c = 'Secondary Payor'
	AND Parent_Agency__c = @TrueParentAgencyID
) SecPayor
ON agency_medical_record.secondary_payor_source = SecPayor.Payor__c
AND visit_type != 'DISCHARGE'
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND sfc_Product_Rate__c IS NULL


-- Secondary payor type not found - non-discharge assessments
PRINT 'Secondary payor type not found - non-discharge assessments'
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find Payor Type for Secondary Payor Source:"' + secondary_payor_source + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE 
(secondary_payor_type = '' or secondary_payor_type IS NULL)
AND secondary_payor_source IS NOT NULL
AND secondary_payor_source != '' 
AND visit_type != 'DISCHARGE'
AND sfc_Product_Rate__c IS NULL
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL


-- Update secondary payor types for discharge assessments
PRINT 'Update secondary payor types for discharge assessments'
UPDATE agency_medical_record
SET secondary_payor_type = SecPayor.Payor_Type__c
FROM agency_medical_record
INNER JOIN
(
	SELECT Payor__c, Payor_Type__c
	FROM sfc.Payor_to_product_lookup__c
	WHERE Category__c = 'Discharge Payor'
	AND Parent_Agency__c = @TrueParentAgencyID
) SecPayor
ON agency_medical_record.secondary_payor_source = SecPayor.Payor__c
AND visit_type = 'DISCHARGE'
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND sfc_Product_Rate__c IS NULL

-- Secondary payor type not found - discharge assessments
PRINT 'Secondary payor type not found - discharge assessments'
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find Payor Type for Discharge Payor Source:"' + secondary_payor_source + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE (secondary_payor_type = '' or secondary_payor_type IS NULL)
AND secondary_payor_source IS NOT NULL AND secondary_payor_source !='' 
AND visit_type = 'DISCHARGE'
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND sfc_Product_Rate__c IS NULL


-- Reject Discharges that are not Medicare, Medicaid, or VA
PRINT 'Reject Discharges that are not Medicare, Medicaid, or VA'
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Record Rejected - Discharge but not Medicare or Medicaid', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE visit_type = 'DISCHARGE'
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND -- Primary Payor Type Criteria
(
	(
	payor_type NOT LIKE 'MEDIC%' -- NOT Medicare / Medicaid
	AND NOT -- NOT VA
		(
			payor_type = 'OTHER'
			AND
			payor_source LIKE 'VETERANS ADMINISTRATION - THHS%'
		)
	) --  END VA
	-- This payor type explicitly excluded from Medicare
	or payor_type = 'NON MEDICARE EPISODIC PAYORS'
	
)
AND -- Secondary payor type criteria
(
	( -- There's not secondary payor
		secondary_payor_source IS NULL
		OR secondary_payor_source = ''
	)
	OR
	( -- 
		secondary_payor_type NOT LIKE 'MEDIC%'
		AND NOT -- NOT VA
		(
			secondary_payor_type = 'OTHER'
			AND
			secondary_payor_source LIKE 'VETERANS ADMINISTRATION - THHS%'
		)
		OR secondary_payor_type = 'NON MEDICARE EPISODIC PAYORS'
	)
)
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND sfc_Product_Rate__c IS NULL

-- Discharge product rate lookup
PRINT 'Discharge product rate lookup'
UPDATE agency_medical_record
SET sfc_Product_Rate__c = sfc.DM_Agency_Product_Rate__c.Id
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
--INNER JOIN sfc.Payor_to_product_lookup__c
--ON agency_medical_record.payor_source = sfc.Payor_to_product_lookup__c.Payor__c
INNER JOIN sfc.DM_Agency_Product_Rate__c
ON agency_medical_record.sfc_Agency__c = sfc.DM_Agency_Product_Rate__c.Agency__c
WHERE  sfc.DM_Agency_Product_Rate__c.Product_Name_for_IT__c = 'Extended OASIS Review Discharge'
--AND Parent_Agency__c = @TrueParentAgencyID
--AND Category__c = 'Discharge Payor'
AND visit_type = 'DISCHARGE'
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND sfc_Product_Rate__c IS NULL
--AND Parent_Agency__c = @TrueParentAgencyID

-- Discharge product rate lookup warnings
PRINT 'Discharge product rate errors'
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find product rate Extended OASIS Discharge Review for location ' + agency_location + ' in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE visit_type = 'DISCHARGE'
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND sfc_Product_Rate__c IS NULL


-- Product lookups for VA
PRINT 'Product lookup for VA'
UPDATE agency_medical_record
SET sfc_Product_Rate__c = sfc.DM_Agency_Product_Rate__c.Id
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.DM_Agency_Product_Rate__c
ON ('Extended OASIS Review ' + agency_medical_record.visit_type) = sfc.DM_Agency_Product_Rate__c.Product_Name_for_IT__c
AND agency_medical_record.sfc_Agency__c = sfc.DM_Agency_Product_Rate__c.Agency__c
WHERE sfc_Product_Rate__c IS NULL
AND
(
	(
		payor_type = 'OTHER'
		AND payor_source LIKE 'VETERANS ADMINISTRATION - THHS%'
	)
	OR
	(
		secondary_payor_type = 'OTHER'
		AND secondary_payor_source LIKE 'VETERANS ADMINISTRATION - THHS%'
	)
)
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL


-- Product Rate Errors - VA
PRINT 'Product lookup errors for VA'
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find VA product rate Extended OASIS Review ' + visit_type + ' for location ' + agency_location + ' in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.Payor_to_product_lookup__c
ON agency_medical_record.payor_source = sfc.Payor_to_product_lookup__c.Payor__c
WHERE Parent_Agency__c = @TrueParentAgencyID
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND sfc_Product_Rate__c IS NULL
AND
(
	(
		payor_type = 'OTHER'
		AND payor_source LIKE 'VETERANS ADMINISTRATION - THHS%'
	)
	OR
	(
		secondary_payor_type = 'OTHER'
		AND secondary_payor_source LIKE 'VETERANS ADMINISTRATION - THHS%'
	)
)


-------------------------------------------------------------------------

-- Normals - look in primary or secondary payor source - if ANY are medicaid
--  or medicare, use that payor source, if not use primary payor source

-- Product lookups for all remaining assessments with a primary medicare/medicaid payor
PRINT 'Remaining assessments product lookup for primary Medicare/Medicaid'
UPDATE agency_medical_record
SET sfc_Product_Rate__c = sfc.DM_Agency_Product_Rate__c.Id
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.Payor_to_product_lookup__c
ON agency_medical_record.payor_type = sfc.Payor_to_product_lookup__c.Payor_Type__c
INNER JOIN sfc.DM_Agency_Product_Rate__c
ON (sfc.Payor_to_product_lookup__c.Product_Name__c + ' ' + agency_medical_record.visit_type) = sfc.DM_Agency_Product_Rate__c.Product_Name_for_IT__c
AND agency_medical_record.sfc_Agency__c = sfc.DM_Agency_Product_Rate__c.Agency__c
WHERE Parent_Agency__c = @TrueParentAgencyID
AND Category__c = 'Payor Type'
AND sfc_Product_Rate__c IS NULL
AND payor_type LIKE 'MEDIC%'
AND payor_type != 'NON MEDICARE EPISODIC PAYORS'
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL


-- Product Rate Errors - Primary Medicare/Medicaid payor
PRINT 'Remaining assessment product lookup errors for primary Medicare/Medicaid'
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find product rate for ' + sfc.Payor_to_product_lookup__c.Product_Name__c + ' ' + visit_type + ' for location ' + agency_location + ' in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.Payor_to_product_lookup__c
ON agency_medical_record.payor_source = sfc.Payor_to_product_lookup__c.Payor__c
WHERE Parent_Agency__c = @TrueParentAgencyID
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND sfc_Product_Rate__c IS NULL
AND payor_type LIKE 'MEDIC%'
AND payor_type != 'NON MEDICARE EPISODIC PAYORS'
AND Category__c = 'Payor Type'

-- Product lookups for all remaining assessments with a secondary medicare/medicaid payor
PRINT 'Remaining assessments product lookup for secondary Medicare/Medicaid'
UPDATE agency_medical_record
SET sfc_Product_Rate__c = sfc.DM_Agency_Product_Rate__c.Id
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.Payor_to_product_lookup__c
ON agency_medical_record.secondary_payor_source = sfc.Payor_to_product_lookup__c.Payor__c
INNER JOIN sfc.DM_Agency_Product_Rate__c
ON (sfc.Payor_to_product_lookup__c.Product_Name__c + ' ' + agency_medical_record.visit_type) = sfc.DM_Agency_Product_Rate__c.Product_Name_for_IT__c
AND agency_medical_record.sfc_Agency__c = sfc.DM_Agency_Product_Rate__c.Agency__c
WHERE Parent_Agency__c = @TrueParentAgencyID
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND sfc_Product_Rate__c IS NULL
AND secondary_payor_type LIKE 'MEDIC%'
AND secondary_payor_type != 'NON MEDICARE EPISODIC PAYORS'
AND Category__c = 'Secondary Payor'

-- Product Rate Errors for all remaining assessments - Secondary Medicare/Medicaid payor
PRINT 'Remaining assessment product lookup errors for secondary Medicare/Medicaid'
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find product rate for ' + sfc.Payor_to_product_lookup__c.Product_Name__c + ' ' + visit_type + ' for location ' + agency_location + ' in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.Payor_to_product_lookup__c
ON agency_medical_record.secondary_payor_source = sfc.Payor_to_product_lookup__c.Payor__c
WHERE Parent_Agency__c = @TrueParentAgencyID
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND sfc_Product_Rate__c IS NULL
AND secondary_payor_type LIKE 'MEDIC%'
AND secondary_payor_type != 'NON MEDICARE EPISODIC PAYORS'
AND Category__c = 'Secondary Payor'
AND Parent_Agency__c = @TrueParentAgencyID

-- Product rate lookup - non-medicare/medicaid
PRINT 'Product rate lookup - non-medicare/medicaid'
UPDATE agency_medical_record
SET sfc_Product_Rate__c = sfc.DM_Agency_Product_Rate__c.Id
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.Payor_to_product_lookup__c
ON agency_medical_record.payor_type = sfc.Payor_to_product_lookup__c.Payor__c
INNER JOIN sfc.DM_Agency_Product_Rate__c
ON (sfc.Payor_to_product_lookup__c.Product_Name__c + ' ' + agency_medical_record.visit_type) = sfc.DM_Agency_Product_Rate__c.Product_Name_for_IT__c
AND agency_medical_record.sfc_Agency__c = sfc.DM_Agency_Product_Rate__c.Agency__c
WHERE Parent_Agency__c = @TrueParentAgencyID
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL
AND sfc_Product_Rate__c IS NULL
AND Category__c = 'Payor Type'
AND Parent_Agency__c = @TrueParentAgencyID

-- Product Rate Errors - All remaining assessments
PRINT 'Product rate error - any remaining assessment'
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find product rate for visit type ' + visit_type + ' for location ' + agency_location + ' in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE agency_medical_record.process_dtm IS NULL
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND sfc_Product_Rate__c IS NULL