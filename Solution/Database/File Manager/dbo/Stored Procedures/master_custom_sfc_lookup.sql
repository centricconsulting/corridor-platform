

CREATE PROCEDURE [dbo].[master_custom_sfc_lookup] (@process_batch_key int)
AS
/*
master_custom_sfc_lookup
by Scott Stover
Centric Consulting
5/16/2018
*/

-- Parameter validation
If (@process_batch_key IS NULL OR @process_batch_key < 1)
	RAISERROR ('An invalid process_batch_key was received', 18 , 1)
--   State 18 will force a failure of the stored procedure

DECLARE @sfc_lookup_sp_name varchar(50) -- current stored procedure we're calling
DECLARE @agency_key int
DECLARE @proc_exec_sql nvarchar(4000) -- dynamically generated call to the stored procedure

-- Cursor through unknown list of stored procedures
DECLARE sfc_lookup_procs CURSOR FOR
	-- This query pulls the list of custom stored procedures for agencies with files that
	--  are currently processing.	
	SELECT sfc_lookup_sp_name, agency_key FROM agency WHERE agency_key IN
	(
		-- Gets a distinct list of agencies (agency_key ids) for records that are currently
		--  being processed.
		SELECT DISTINCT agency_key
		FROM agency_medical_record
		WHERE process_batch_key = @process_batch_key
	)

-- Cursor operations
OPEN sfc_lookup_procs
FETCH NEXT FROM sfc_lookup_procs INTO @sfc_lookup_sp_name, @agency_key

WHILE @@FETCH_STATUS = 0
BEGIN
	-- Build the custom call to the agency stored procedure.  They will always be sent
	--  one argument - the batch_process_key
	SET @proc_exec_sql = 'EXEC ' + @sfc_lookup_sp_name + ' ' + CAST(@agency_key as nvarchar(20)) + ', ' + CAST(@process_batch_key as nvarchar(20))
	
	EXEC sp_executesql @proc_exec_sql
	
	FETCH NEXT FROM sfc_lookup_procs INTO @sfc_lookup_sp_name, @agency_key
END

-- Clean up cursor
CLOSE sfc_lookup_procs
DEALLOCATE sfc_lookup_procs