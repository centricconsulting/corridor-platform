CREATE PROCEDURE [dbo].[custom_sfclookup_Intrepid] (@agency_key as int, @process_batch_key as int)
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
ON agency_medical_record.agency_location = sfc.DM_Agency__c.[Name]
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

-- Get product rate code
UPDATE agency_medical_record
SET sfc_Product_Rate__c = Id
FROM agency_medical_record
INNER JOIN sfc.DM_Agency_Product_Rate__c
ON agency_medical_record.sfc_Agency__c = sfc.DM_Agency_Product_Rate__c.Agency__c
AND agency_medical_record.oasis_visit_type = sfc.DM_Agency_Product_Rate__c.Product_Name_for_IT__c
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_key = @agency_key
AND salesforce_send_ind = 1
AND process_dtm IS NULL

-- Product rate error messages
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find Product Rate for "' + agency_location + '+' + oasis_visit_type + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND sfc_Product_Rate__c IS NULL