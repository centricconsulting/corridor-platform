CREATE PROCEDURE [dbo].[load_agency_file_rows] (@file_format_header_row int, @agency_file_key int, @process_batch_key int) AS

-- Get the number of raw columns from the FileImportStaging table
DECLARE @ColumnCount int

SELECT @ColumnCount = COUNT(COLUMN_NAME) - 2 FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'FileImportStaging' AND TABLE_SCHEMA='tmp'

-- We have a maximum of 40 data columns in the table structure, enforce it here
if (@ColumnCount > 40) SET @ColumnCount = 40

-- Update and identify the header row
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

WHILE @Count<=@ColumnCount
    BEGIN
		SET @ColumnNames = @ColumnNames + ', COLUMN' + RIGHT('00' + CAST(@Count as varchar(4)), 2)
	    SET @FieldSelection = @FieldSelection + ', [' + ISNULL((SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'FileImportStaging' AND TABLE_SCHEMA='tmp' AND ORDINAL_POSITION = @Count), '') + ']'
	    SET @Count = @Count + 1
	END

-- Build the SQL
SET @ColumnNames = 'agency_file_key, row_index, column_header_ind, process_batch_key, create_timestamp, modify_timestamp' + @ColumnNames

SET @FieldSelection = CAST(@agency_file_key as varchar(6)) + ', row_index, column_header_ind, ' + CAST(@process_batch_key as varchar(10)) + ', GETDATE(), GETDATE()' + @FieldSelection

SET @DataRowsInsertSQL = 'INSERT INTO agency_file_row (' + @ColumnNames + ') SELECT ' + @FieldSelection + ' FROM tmp.FileImportStaging'

-- Insert the data rows
EXEC (@DataRowsInsertSQL)

SELECT GETDATE() file_process_dtm, '' file_process_error_message, 1 file_process_success_flag