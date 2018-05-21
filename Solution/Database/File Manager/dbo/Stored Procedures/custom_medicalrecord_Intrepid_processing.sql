CREATE PROCEDURE [dbo].[custom_medicalrecord_Intrepid_processing] (@process_batch_key int)
AS

DECLARE @agency_key int
SELECT @agency_key = agency_key FROM
agency WHERE agency_name = 'Intrepid'

SELECT agency_medical_record_key FROM agency_medical_record
INNER JOIN agency_file_row ON
agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
WHERE agency_key = @agency_key
AND agency_medical_record.process_batch_key = @process_batch_key
AND
(
	(column06 != 'Submitted with Signature' AND column06 != 'Submitted to Case Manager')
	OR (oasis_visit_type != 'Coding Only SOC' AND oasis_visit_type != 'Coding Only ROC')
)