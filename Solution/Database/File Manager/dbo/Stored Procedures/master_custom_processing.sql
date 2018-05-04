
CREATE PROCEDURE [dbo].[master_custom_processing] (@modify_process_batch_key int)
AS
/*
master_custom_processing
by Scott Stover
Centric Consulting
4/19/2018

This procedure takes in the current modify_process_batch_key from the SSIS workflow
immediately after inserting records into agency_medical record located in
Process Agency Medical Records.dtsx.

For all files currently being processed (determined by batch key), it executes custom
stored procedures for each agency.  These stored procedures return a list of
agency_medical_record_key numbers to be excluded.  The list is built up cumulatively and
then all records matching those IDs are updated to be excluded from Salesforce:

salesforce_send_ind = 0

All records by default have salesforce_send_ind set to 1.
*/

-- Parameter validation
If (@modify_process_batch_key IS NULL OR @modify_process_batch_key < 1)
	RAISERROR ('An invalid process_batch_key was received', 18 , 1)
--   State 18 will force a failure of the stored procedure

-- This table variable holds the list of amr keys to exclude
DECLARE @amr_keys_to_exclude TABLE
(
	agency_medical_record_key int
)

/*
In this section, we're going to loop through all of the agency custom processing stored
procedures and add anything they return to the @amr_keys_to_exclude table variable.
*/
DECLARE @medical_record_sp_name varchar(50) -- current stored procedure we're calling
DECLARE @proc_exec_sql nvarchar(100) -- dynamically generated call to the stored procedure

-- Cursor through unknown list of stored procedures
DECLARE amr_exclude_procs CURSOR FOR
	-- This query pulls the list of custom stored procedures for agencies with files that
	--  are currently processing.	
	SELECT medical_record_sp_name FROM agency WHERE agency_key IN
	(
		-- Gets a distinct list of agencies (agency_key ids) for records that are currently
		--  being processed.
		SELECT DISTINCT agency_key
		FROM agency_medical_record
		WHERE modify_process_batch_key = @modify_process_batch_key
	)
	-- If this value is NULL for an agency, then they do not have any custom processing and will
	--  be skipped by design.
	AND medical_record_sp_name IS NOT NULL

-- Cursor operations
OPEN amr_exclude_procs
FETCH NEXT FROM amr_exclude_procs INTO @medical_record_sp_name

WHILE @@FETCH_STATUS = 0
BEGIN
	-- Build the custom call to the agency stored procedure.  They will always be sent
	--  one argument - the batch_process_key
	SET @proc_exec_sql = 'EXEC ' + @medical_record_sp_name + ' ' + CAST(@modify_process_batch_key as nvarchar(20))
	
	-- Execute the stored procedure and add the results (records to exclude) to the
	--  @amr_keys_to_exclude table variable.
	INSERT INTO @amr_keys_to_exclude
	EXEC sp_executesql @proc_exec_sql
	
	FETCH NEXT FROM amr_exclude_procs INTO @medical_record_sp_name
END

-- Clean up cursor
CLOSE amr_exclude_procs
DEALLOCATE amr_exclude_procs

-- Finally, we update the agency_medical_record salesforce_send_ind to 0
--  for any records that the above procedures have indicated need to be excluded
UPDATE agency_medical_record
SET salesforce_send_ind = 0 WHERE
agency_medical_record_key IN
(
	SELECT agency_medical_record_key FROM @amr_keys_to_exclude
)