CREATE PROCEDURE [dbo].[load_agency_file_rows] (@agency_file_key int, @process_batch_key int) AS

DECLARE @file_format_header_row as int

SET @file_format_header_row = 6

/*
Stored procedure load_agency_file_rows

Created by Scott Stover
Centric Consulting
5/2018

This procedure takes in the key for the agency file record currently being processed
and the index of the header row (containing column names) and imports the rows for that file
into agency_file_row from tmp.FileImportStaging.  The file rows are already populated in
tmp.FileImportStaging from the original raw file as a result of the get_file_info stored procedure, so
we build on that rather than re-importing from scratch.

Additional columns were added to tmp.FileImportStaging by the Prep Records for Load task prior to this
step.

This procedure is called by the Load Agency File Rows task in Process Source Files.dtsx in the Corridor
Platform solution.
*/

-- Get the number of raw columns from the FileImportStaging table
DECLARE @ColumnCount int
-- We subtract 2 from the column count because we added two static columns to the table
SELECT @ColumnCount = COUNT(COLUMN_NAME) - 2 FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FileImportStaging' AND TABLE_SCHEMA='tmp'

-- We have a maximum of 40 data columns in the table structure, enforce it here
if (@ColumnCount > 40) SET @ColumnCount = 40

-- Update and identify the header row.  row_index was created in the previous prep records step.
--   It is an integer identity column.
UPDATE tmp.FileImportStaging
	SET column_header_ind = 1
	WHERE row_index = @file_format_header_row

-- Loop through the columns of the staging table to help build out the SQL we need to generate
DECLARE @Count int
DECLARE @ColumnNames varchar(max)
DECLARE @FieldSelection varchar(max)
DECLARE @DataRowsInsertSQL varchar(max)

SET @Count = 1
SET @ColumnNames = ''
SET @FieldSelection = ''

/* For each column, we update the @ColumnNames variable, which builds out a list similar to the table
in agency_file_row.  Fields are named COLUMNXX where XX is the column index.  Single digit numbers
include the leading zero.
Additionally, we update the @FieldSelection list, which is a list of column names in the
tmp.FileImportStaging table used for the SELECT clause in SQL.
*/
WHILE @Count<=@ColumnCount
    BEGIN
		SET @ColumnNames = @ColumnNames + ', COLUMN' + RIGHT('00' + CAST(@Count as varchar(4)), 2)
	    SET @FieldSelection = @FieldSelection + ', [' + ISNULL((SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'FileImportStaging' AND TABLE_SCHEMA='tmp' AND ORDINAL_POSITION = @Count), '') + ']'
	    SET @Count = @Count + 1
	END

-- Build the SQL

-- Add static control columns to column names and field selection strings
SET @ColumnNames = 'agency_file_key, row_index, column_header_ind, process_batch_key, create_timestamp, modify_timestamp' + @ColumnNames
SET @FieldSelection = CAST(@agency_file_key as varchar(6)) + ', row_index, column_header_ind, ' + CAST(@process_batch_key as varchar(10)) + ', GETDATE(), GETDATE()' + @FieldSelection

-- Build the final INSERT statement
SET @DataRowsInsertSQL = 'INSERT INTO agency_file_row (' + @ColumnNames + ') SELECT ' + @FieldSelection + ' FROM tmp.FileImportStaging'

-- Insert the data rows
EXEC (@DataRowsInsertSQL)

-- Return status
SELECT GETDATE() file_process_dtm, '' file_process_error_message, 1 file_process_success_flag