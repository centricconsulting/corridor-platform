
CREATE PROCEDURE [dbo].[custom_medicalrecord_Trinity_processing] (@process_batch_key int)
AS

DECLARE @agency_key int
SET @agency_key = 2

SELECT agency_medical_record_key FROM agency_medical_record
WHERE start_of_care_date != start_of_episode_date
AND process_batch_key = @process_batch_key
AND agency_key = @agency_key