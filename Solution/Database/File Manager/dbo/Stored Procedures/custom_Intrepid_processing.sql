

CREATE PROCEDURE [dbo].[custom_Intrepid_processing] (@process_batch_key int)
AS

DECLARE @agency_key int
SELECT @agency_key = agency_key FROM
agency WHERE agency_name = 'Intrepid'

PRINT @agency_key

/*

SELECT agency_medical_record_key FROM agency_medical_record

SELECT * FROM agency_medical_record
WHERE start_of_care_date != start_of_episode_date
--AND modify_process_batch_key = @process_batch_key
AND agency_key = 4

OASIS assessment type
'Submitted with Signature and Submitted to Case Manager.'

Oasis Type, select All SOC’s, and ROC’s.


*/