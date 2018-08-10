

CREATE PROCEDURE [dbo].[custom_sfclookup_Bayada] (@agency_key as int, @process_batch_key as int)
AS

DECLARE @TrueParentAgencyID varchar(40)
DECLARE @CommercialInsuranceDischargeAgencyID varchar(40)

-- Get Salesforce Parent Agency ID
SELECT @TrueParentAgencyID = agency_code_salesforce
FROM agency
WHERE agency_key = @agency_key

-- Get Commerical Insurance Discharge Agency ID
SELECT @CommercialInsuranceDischargeAgencyID = Id
FROM sfc.DM_Agency__c
WHERE sfc.GetTrueParentAgencyCode(Id) = @TrueParentAgencyID
AND Name = 'Bayada Commercial Insurance Discharges'

-- Error records if unable to find commercial insurance dicharge agency ID
If @CommercialInsuranceDischargeAgencyID IS NULL
BEGIN
	UPDATE agency_medical_record
	SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Unable to find Commercial Insurance Discharge Agency ID in HHCP "', salesforce_send_ind = 0, notification_sent_ind = 0
	FROM agency_medical_record
	INNER JOIN agency_file_row
	ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
	INNER JOIN agency_file
	ON agency_file_row.agency_file_key = agency_file.agency_file_key
	INNER JOIN sfc.Payor_to_product_lookup__c
	ON agency_medical_record.payor_source = sfc.Payor_to_product_lookup__c.Payor__c
	WHERE visit_type = 'Discharge Review'
	AND Parent_Agency__c = @TrueParentAgencyID
	AND Commercial_Payor__c = 'true'
	AND agency_medical_record.process_batch_key = @process_batch_key
	AND agency_medical_record.agency_key = @agency_key
	AND salesforce_send_ind = 1
END

-- Set Commercial Insurance Discharge Agency
UPDATE agency_medical_record
SET sfc_Agency__c = @CommercialInsuranceDischargeAgencyID
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.Payor_to_product_lookup__c
ON agency_medical_record.payor_source = sfc.Payor_to_product_lookup__c.Payor__c
WHERE visit_type = 'Discharge Review'
AND Parent_Agency__c = @TrueParentAgencyID
AND Commercial_Payor__c = 'true'
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
/*
-- Set non-commercial insurance agency ID (parent branch ID)
UPDATE agency_medical_record
SET sfc_Agency__c = @TrueParentAgencyID
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.Payor_to_product_lookup__c
ON agency_medical_record.payor_source = sfc.Payor_to_product_lookup__c.Payor__c
WHERE visit_type = 'Discharge Review'
AND Parent_Agency__c = @TrueParentAgencyID
AND Commercial_Payor__c != 'true'
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
*/

-- **************************

-- Discharge payor not found error
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find payor: "' + payor_source + '" for commercial discharge in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.Payor_to_product_lookup__c
ON agency_medical_record.payor_source = sfc.Payor_to_product_lookup__c.Payor__c
WHERE sfc_Agency__c IS NULL
AND visit_type = 'Discharge Review'
AND Commercial_Payor__c = 'true'
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1

-- Get agency code for most records - NON-discharges
UPDATE agency_medical_record
SET sfc_Agency__c = Id
FROM agency_medical_record
INNER JOIN
(
	SELECT *
	FROM sfc.DM_Agency__c
	WHERE sfc.GetTrueParentAgencyCode(sfc.DM_Agency__c.id) = @TrueParentAgencyID
) SFAgency
ON agency_medical_record.agency_location = SFAgency.Agency_Alias__c
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_key = @agency_key
AND salesforce_send_ind = 1
AND sfc_Agency__c IS NULL
--AND visit_type != 'Discharge Review'

-- Inactive Agency Error Message
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
AND agency_medical_record.process_error_message IS NULL

-- ETL Variables error messages
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find ETL Variables for Location "' + agency_location + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.DM_Agency__c SFC_Agency
ON agency_medical_record.agency_location = SFC_Agency.Agency_Alias__c
AND sfc.GetTrueParentAgencyCode(SFC_Agency.id) = @TrueParentAgencyID
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND SFC_Agency.id NOT IN
(
	SELECT Agency_Location__c FROM sfc.Agency_ETL_variables__c
	WHERE sfc.GetTrueParentAgencyCode(Agency_Location__c) = @TrueParentAgencyID
	AND Agency_Location__c IS NOT NULL
)

-- Payor lookup error messages
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find payor "' + payor_source + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND payor_source NOT IN
(
	SELECT Payor__c
	FROM sfc.Payor_to_product_lookup__c
	WHERE Parent_Agency__c = @TrueParentAgencyID
	AND Payor__c IS NOT NULL
)

-- Discharge product lookup
UPDATE agency_medical_record
SET sfc_Product_Rate__c = Id
FROM agency_medical_record
INNER JOIN sfc.DM_Agency_Product_Rate__c
ON agency_medical_record.sfc_Agency__c = sfc.DM_Agency_Product_Rate__c.Agency__c
AND agency_medical_record.visit_type = sfc.DM_Agency_Product_Rate__c.Product_Name_for_IT__c
WHERE visit_type = 'Discharge Review'
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1

-- Discharge product lookup error messages
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find Discharge Review product for location ' + sfc.DM_Agency__c.Name + ' in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.DM_Agency__c
ON agency_medical_record.sfc_Agency__c = sfc.DM_Agency__c.Id
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND visit_type = 'Discharge Review'
AND sfc_Product_Rate__c IS NULL

-- All other product lookups are payor dependent for Bayada

-- Payor Dependent product lookup
UPDATE agency_medical_record
SET sfc_Product_Rate__c = Product_Rate_Lookup.Id
FROM agency_medical_record
INNER JOIN
(
	SELECT agency_medical_record_key, Product_Name__c + ' ' + visit_type Calculated_Product
	FROM agency_medical_record
	INNER JOIN sfc.Payor_to_product_lookup__c Payor_Lookup
	ON agency_medical_record.payor_source = Payor_Lookup.Payor__c
	WHERE visit_type != 'Discharge Review'
	AND Payor_Lookup.Parent_Agency__c = @TrueParentAgencyID
	AND agency_key = @agency_key
	AND agency_medical_record.process_batch_key = @process_batch_key
) Product_Lookup
ON agency_medical_record.agency_medical_record_key = Product_Lookup.agency_medical_record_key
INNER JOIN sfc.DM_Agency_Product_Rate__c Product_Rate_Lookup
ON Product_Lookup.Calculated_Product = Product_Rate_Lookup.Product_Name_for_IT__c
AND agency_medical_record.sfc_Agency__c = Product_Rate_Lookup.Agency__c
WHERE salesforce_send_ind = 1
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key

-- Managed Care disallowed Product warning - payor lookup failed
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Record Rejected - Disallowed product "' + Product_Lookup.Calculated_Product + '" for Managed Care location "' + agency_location + '" ', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.Agency_ETL_variables__c
ON agency_medical_record.sfc_Agency__c = sfc.Agency_ETL_variables__c.Agency_Location__c
INNER JOIN
(
	SELECT agency_medical_record_key, Product_Name__c + ' ' + visit_type Calculated_Product
	FROM agency_medical_record
	INNER JOIN sfc.Payor_to_product_lookup__c Payor_Lookup
	ON agency_medical_record.payor_source = Payor_Lookup.Payor__c
	WHERE visit_type != 'Discharge Review'
	AND Payor_Lookup.Parent_Agency__c = @TrueParentAgencyID
	AND agency_key = @agency_key
	AND agency_medical_record.process_batch_key = @process_batch_key
) Product_Lookup
ON agency_medical_record.agency_medical_record_key = Product_Lookup.agency_medical_record_key
WHERE salesforce_send_ind = 1
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND sfc_Product_Rate__c IS NULL
AND General_Product_Type__c = 'Managed Care Process'
AND LEFT(Calculated_Product, 7) = 'Primary'

-- MCM disallowed Product warning - payor lookup failed
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Record Rejected - Disallowed product "' + Product_Lookup.Calculated_Product + '" for Managed Care location "' + agency_location + '" ', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.Agency_ETL_variables__c
ON agency_medical_record.sfc_Agency__c = sfc.Agency_ETL_variables__c.Agency_Location__c
INNER JOIN
(
	SELECT agency_medical_record_key, Product_Name__c + ' ' + visit_type Calculated_Product
	FROM agency_medical_record
	INNER JOIN sfc.Payor_to_product_lookup__c Payor_Lookup
	ON agency_medical_record.payor_source = Payor_Lookup.Payor__c
	WHERE visit_type != 'Discharge Review'
	AND Payor_Lookup.Parent_Agency__c = @TrueParentAgencyID
	AND agency_key = @agency_key
	AND agency_medical_record.process_batch_key = @process_batch_key
) Product_Lookup
ON agency_medical_record.agency_medical_record_key = Product_Lookup.agency_medical_record_key
WHERE salesforce_send_ind = 1
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND sfc_Product_Rate__c IS NULL
AND General_Product_Type__c = 'MCM Process'
AND LEFT(Calculated_Product, 7) != 'Primary'


-- Payor Dependent Product lookup error
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find Payor Dependent product "' + Product_Lookup.Calculated_Product + '" for location "' + agency_location + '" and payor "' + payor_source + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN
(
	SELECT agency_medical_record_key, Product_Name__c + ' ' + visit_type Calculated_Product
	FROM agency_medical_record
	INNER JOIN sfc.Payor_to_product_lookup__c Payor_Lookup
	ON agency_medical_record.payor_source = Payor_Lookup.Payor__c
	WHERE visit_type != 'Discharge Review'
	AND Payor_Lookup.Parent_Agency__c = @TrueParentAgencyID
	AND agency_key = @agency_key
	AND agency_medical_record.process_batch_key = @process_batch_key
) Product_Lookup
ON agency_medical_record.agency_medical_record_key = Product_Lookup.agency_medical_record_key
WHERE salesforce_send_ind = 1
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND sfc_Product_Rate__c IS NULL

-- MCM Location warning
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Disallowed product "' + Product_Name_for_IT__c + '" for MCM location "' + agency_location + '"', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.DM_Agency_Product_Rate__c
ON agency_medical_record.sfc_Product_Rate__c = sfc.DM_Agency_Product_Rate__c.Id
INNER JOIN sfc.Agency_ETL_variables__c
ON agency_medical_record.sfc_Agency__c = sfc.Agency_ETL_variables__c.Agency_Location__c
AND salesforce_send_ind = 1
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND General_Product_Type__c = 'MCM Process'
AND
	(
		LEFT(Product_Name_for_IT__c, 7) != 'Primary'
		OR visit_type = 'Discharge Review'
	)

-- Managed Care Location Errors
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Disallowed product "' + Product_Name_for_IT__c + '" for Managed Care location "' + agency_location + '"', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN sfc.DM_Agency_Product_Rate__c
ON agency_medical_record.sfc_Product_Rate__c = sfc.DM_Agency_Product_Rate__c.Id
INNER JOIN sfc.Agency_ETL_variables__c
ON agency_medical_record.sfc_Agency__c = sfc.Agency_ETL_variables__c.Agency_Location__c
AND salesforce_send_ind = 1
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND General_Product_Type__c = 'Managed Care Process'
AND
	(
		LEFT(Product_Name_for_IT__c, 7) = 'Primary'
	)