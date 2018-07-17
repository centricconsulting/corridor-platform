
CREATE PROCEDURE dbo.set_sfc_default_fields(@process_batch_key int)
AS

UPDATE agency_medical_record
SET agency_medical_record.sfc_Status__c = agency.sfc_Status__c, agency_medical_record.sfc_Ready_for_Coding_send_ind = agency.sfc_Ready_for_Coding_send_ind
FROM agency_medical_record
INNER JOIN agency
ON agency_medical_record.agency_key = agency.agency_key
WHERE agency_medical_record.process_batch_key = @process_batch_key

UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Invalid HHCP Default Status for Agency', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND salesforce_send_ind = 1
AND sfc_Status__c IS NULL