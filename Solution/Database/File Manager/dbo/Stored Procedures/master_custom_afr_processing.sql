

CREATE PROCEDURE [dbo].[master_custom_afr_processing] (@agency_key int, @agency_file_key int, @file_name varchar(200))
AS
/*
master_custom_amr_processing
by Scott Stover
Centric Consulting
5/16/2018

*/

-- Parameter validation
--  RAISERROR ('An invalid process_batch_key was received', 18 , 1)
--   State 18 will force a failure of the stored procedure

DECLARE @file_row_sp_name varchar(50) -- current stored procedure we're calling
DECLARE @proc_exec_sql nvarchar(4000) -- dynamically generated call to the stored procedure

SELECT @file_row_sp_name = file_row_sp_name FROM agency WHERE agency_key = @agency_key

if @file_row_sp_name IS NOT NULL
	BEGIN
		SET @proc_exec_sql = 'EXEC ' + @file_row_sp_name + ' ' + CAST(@agency_file_key as nvarchar(20)) + ', ''' + @file_name + ''''
		EXEC sp_executesql @proc_exec_sql
	END