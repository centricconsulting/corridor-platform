
CREATE PROCEDURE [dbo].[custom_sfclookup_Graham] (@agency_key as int, @process_batch_key as int)
AS

DECLARE @TrueParentAgencyID varchar(40)

-- Get Salesforce Parent Agency ID
SELECT @TrueParentAgencyID = agency_code_salesforce
FROM agency
WHERE agency_key = @agency_key

-- Get agency code
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
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Record Rejected - Inactive Location in HHCP: "' + agency_location, salesforce_send_ind = 0, notification_sent_ind = 0
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
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find Agency Location "' + agency_location + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND sfc_Agency__c IS NULL

-- Discharge Product Lookup
UPDATE agency_medical_record
SET sfc_Product_Rate__c = sfc.DM_Agency_Product_Rate__c.Id
FROM agency_medical_record
INNER JOIN sfc.DM_Agency_Product_Rate__c
ON agency_medical_record.sfc_Agency__c = sfc.DM_Agency_Product_Rate__c.Agency__c
AND agency_medical_record.visit_type = sfc.DM_Agency_Product_Rate__c.Product_Name_for_IT__c
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND visit_type = 'Discharge Review'

-- Non-discharge Extended OASIS Product Lookup
UPDATE agency_medical_record
SET sfc_Product_Rate__c = sfc.DM_Agency_Product_Rate__c.Id
FROM agency_medical_record
INNER JOIN sfc.DM_Agency_Product_Rate__c
ON agency_medical_record.sfc_Agency__c = sfc.DM_Agency_Product_Rate__c.Agency__c
AND ('Extended OASIS Review ' + agency_medical_record.visit_type) = sfc.DM_Agency_Product_Rate__c.Product_Name_for_IT__c
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND visit_type != 'Discharge Review'
AND payor_type IN
(
	SELECT 'MANAGED MEDICAID'
	UNION ALL
	SELECT 'MEDICAID'
	UNION ALL
	SELECT 'Medicare'
	UNION ALL
	SELECT 'Medicare PPS Commercial'
	UNION ALL
	SELECT 'Managed Medicare'
	UNION ALL
	SELECT 'Managed Medicare Advantage HMO'
	UNION ALL
	SELECT 'Managed Medicare Advantage PPO'
)

-- Non-discharge Coding Only Lookup
UPDATE agency_medical_record
SET sfc_Product_Rate__c = sfc.DM_Agency_Product_Rate__c.Id
FROM agency_medical_record
INNER JOIN sfc.DM_Agency_Product_Rate__c
ON agency_medical_record.sfc_Agency__c = sfc.DM_Agency_Product_Rate__c.Agency__c
AND ('Coding Only ' + agency_medical_record.visit_type) = sfc.DM_Agency_Product_Rate__c.Product_Name_for_IT__c
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND visit_type != 'Discharge Review'
AND payor_type NOT IN
(
	SELECT 'MANAGED MEDICAID'
	UNION ALL
	SELECT 'Medicare'
	UNION ALL
	SELECT 'Medicare PPS Commercial'
	UNION ALL
	SELECT 'Managed Medicare'
	UNION ALL
	SELECT 'Managed Medicare Advantage HMO'
	UNION ALL
	SELECT 'Managed Medicare Advantage PPO'
)

-- Generic product rate error message
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find product rate for Location "' + agency_location + '" and visit type "' + visit_type + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND sfc_Product_Rate__c IS NULL


/*
-- ETL Variables error messages
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find ETL Variables for Location "' + agency_location + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
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

-- Either "Payor Dependent" product or "Coding Only"

-- Payor Dependent product lookup
UPDATE agency_medical_record
SET sfc_Product_Rate__c = Product_Rate_Lookup.Id
FROM agency_medical_record
INNER JOIN
(
	SELECT agency_medical_record_key, Product_Name__c + ' ' + visit_type Calculated_Product
	FROM agency_medical_record
	INNER JOIN sfc.Agency_ETL_variables__c ETL_Variables
	ON agency_medical_record.sfc_Agency__c = ETL_Variables.Agency_Location__c
	INNER JOIN agency_file_row
	ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
	INNER JOIN sfc.Payor_to_product_lookup__c Payor_Lookup
	ON agency_file_row.column14 = Payor_Lookup.Payor__c
	WHERE General_Product_Type__c = 'Payor Dependent'
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

-- Payor Dependent Product lookup error
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find Payor Dependent product "' + Product_Lookup.Calculated_Product + '" for location "' + agency_location + '" and payor "' + column14 + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN
(
	SELECT agency_medical_record_key, ISNULL(Product_Name__c + ' ', '') + visit_type Calculated_Product
	FROM agency_medical_record
	INNER JOIN sfc.Agency_ETL_variables__c ETL_Variables
	ON agency_medical_record.sfc_Agency__c = ETL_Variables.Agency_Location__c
	INNER JOIN agency_file_row
	ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
	LEFT OUTER JOIN
	(
		SELECT * FROM sfc.Payor_to_product_lookup__c
		WHERE Parent_Agency__c = @TrueParentAgencyID
	) Payor_Lookup
	ON agency_file_row.column14 = Payor_Lookup.Payor__c
	WHERE General_Product_Type__c = 'Payor Dependent'
	AND agency_key = @agency_key
	AND agency_medical_record.process_batch_key = @process_batch_key
) Product_Lookup
ON agency_medical_record.agency_medical_record_key = Product_Lookup.agency_medical_record_key
WHERE salesforce_send_ind = 1
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND sfc_Product_Rate__c IS NULL


-- Non-payor dependent (Coding Only) product lookup
UPDATE agency_medical_record
SET sfc_Product_Rate__c = Product_Rate_Lookup.Id
FROM agency_medical_record
INNER JOIN
(
	-- Must trim product name to account for "Hospice"
	SELECT agency_medical_record_key, RTRIM(General_Product_Type__c + ' ' + visit_type) Calculated_Product
	FROM agency_medical_record
	INNER JOIN sfc.Agency_ETL_variables__c ETL_Variables
	ON agency_medical_record.sfc_Agency__c = ETL_Variables.Agency_Location__c
	INNER JOIN agency_file_row
	ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
	WHERE General_Product_Type__c != 'Payor Dependent'
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


-- Non-payor dependent (Coding Only) Product lookup error
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find product "' + Product_Lookup.Calculated_Product + '" for location "' + agency_location + '" and visit type "' + column17 + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
INNER JOIN
(
	-- Must trim product name to account for "Hospice"
	SELECT agency_medical_record_key, RTRIM(General_Product_Type__c + ' ' + visit_type) Calculated_Product
	FROM agency_medical_record
	INNER JOIN sfc.Agency_ETL_variables__c ETL_Variables
	ON agency_medical_record.sfc_Agency__c = ETL_Variables.Agency_Location__c
	INNER JOIN agency_file_row
	ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
	WHERE General_Product_Type__c != 'Payor Dependent'
	AND agency_key = @agency_key
	AND agency_medical_record.process_batch_key = @process_batch_key
) Product_Lookup
ON agency_medical_record.agency_medical_record_key = Product_Lookup.agency_medical_record_key
WHERE salesforce_send_ind = 1
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND sfc_Product_Rate__c IS NULL

GO


*/