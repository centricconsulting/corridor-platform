
CREATE PROCEDURE dbo.flag_duplicate_assessments (@process_batch_key int)
AS

UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + [file_name] + ',MRN:' + InitialGrouping.medical_record_number + ', Record Rejected - Duplicate Record in the same batch', salesforce_send_ind = 0, notification_sent_ind = 0
FROM
(
	SELECT MIN(agency_medical_record_key) FirstInstanceID, COUNT(agency_medical_record_key) CountOfRecords, medical_record_number, assessment_date, sfc_Agency__c FROM agency_medical_record
	WHERE process_batch_key = @process_batch_key
	GROUP BY medical_record_number, assessment_date, sfc_Agency__c
) InitialGrouping
INNER JOIN agency_medical_record
ON InitialGrouping.assessment_date = agency_medical_record.assessment_date
AND InitialGrouping.medical_record_number = agency_medical_record.medical_record_number
AND InitialGrouping.sfc_Agency__c = agency_medical_record.sfc_Agency__c
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE CountOfRecords > 1
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL


UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'WARNING', process_error_message = 'FILE:' + [file_name] + ',MRN:' + agency_medical_record.medical_record_number + ', Record Rejected - Duplicate Record from previous batch', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN
(
	SELECT *
	FROM agency_medical_record
	WHERE process_batch_key = @process_batch_key
) AMRCurrentBatch
ON agency_medical_record.agency_medical_record_key = AMRCurrentBatch.agency_medical_record_key
INNER JOIN
(
	SELECT *
	FROM agency_medical_record
	WHERE process_batch_key != @process_batch_key
	AND process_success_ind = 1
) AMRPreviousBatches
ON AMRCurrentBatch.assessment_date = AMRPreviousBatches.assessment_date
AND AMRCurrentBatch.medical_record_number = AMRPreviousBatches.medical_record_number
AND AMRCurrentBatch.sfc_Agency__c = AMRPreviousBatches.sfc_Agency__c
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
AND agency_medical_record.salesforce_send_ind = 1
AND agency_medical_record.process_dtm IS NULL