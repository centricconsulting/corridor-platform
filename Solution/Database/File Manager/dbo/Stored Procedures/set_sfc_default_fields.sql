

CREATE PROCEDURE [dbo].[set_sfc_default_fields](@process_batch_key int)
AS

/*
Stored procedure set_sfc_default_fields
by Scott Stover
Centric Consulting
9/2018

This procedure takes in the process batch key for agency_medical_record rows that
are currently being processed and sets any default Salesforce / HH CodePro fields
taht need to be set.  These defaults are defined by the agency tablle.

This procedure is called by the Set Default Salesforce Fields for AMRs in Process
Agency Medical Records.dtsx in the Corridor Platform solution.  It is the last step
in the control flow of the package.

- Revision 10/2018 -
Each field is checked and updated independently in case it is overridden by custom logic.

*/

-- sfc_Status__c
UPDATE agency_medical_record
SET agency_medical_record.sfc_Status__c = agency.sfc_Status__c
FROM agency_medical_record
INNER JOIN agency
ON agency_medical_record.agency_key = agency.agency_key
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.sfc_Status__c IS NULL

-- sfc_sfc_Ready_for_Coding_send_ind
UPDATE agency_medical_record
SET agency_medical_record.sfc_Ready_for_Coding_send_ind = agency.sfc_Ready_for_Coding_send_ind
FROM agency_medical_record
INNER JOIN agency
ON agency_medical_record.agency_key = agency.agency_key
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.sfc_Ready_for_Coding_send_ind IS NULL

-- Error message will check all fields that need default values
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_category = 'ERROR', process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Invalid HHCP Default Status for Agency', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND salesforce_send_ind = 1
AND
(
	sfc_Status__c IS NULL
	OR
	sfc_Ready_for_Coding_send_ind IS NULL
)