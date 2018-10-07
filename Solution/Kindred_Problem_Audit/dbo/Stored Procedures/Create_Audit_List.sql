CREATE PROCEDURE [dbo].[Create_Audit_List]
AS

/*

This procedure takes the latest entries from agency_file_row and creates a specific
audit list to be examined by Kindred's custom processing procedures in the HIMs SSIS process.

*/

DECLARE @FileCount int
SELECT @FileCount = COUNT(*) FROM agency_file

DECLARE @RecordCount int
SELECT @RecordCount = COUNT(*) FROM agency_file_row

-- If there aren't at least 3 files, something has gone wrong.  Do not execute.
if @FileCount >= 3
BEGIN
-- If there are no records, something has gone wrong.  Do not execute.
if @RecordCount > 6
	BEGIN
		-- Clear Previous Entries
		TRUNCATE TABLE Kindred_Audit_List

		INSERT INTO Kindred_Audit_List (MRN, AssessmentDate, Agency, FormStatus)
		SELECT DISTINCT RIGHT('000000000' + column02, 9) MRN, column08 AssessmentDate, column05 Agency, column07 FormStatus FROM agency_file_row
		WHERE
			-- Skip header rows
			row_index > 6
			-- MRN Validation
			AND column02 IS NOT NULL
			AND RTRIM(column02) != ''
			AND ISNUMERIC(column02) = 1
			-- Assessment Date validation
			AND column08 IS NOT NULL
			AND RTRIM(column08) != ''
			AND ISDATE(column08) = 1
			-- Agency validation
			AND column05 IS NOT NULL
			AND RTRIM(column05) != ''
			AND LEN(column05) >= 5
			-- Form Status validation
			AND column07 IS NOT NULL
			AND RTRIM(column07) != ''
			-- Form Status criteria
			AND column07 = 'To Be Corrected'
		
		-- Clear the list so we can reload with a new set of files later
		TRUNCATE TABLE agency_file_row	
	END
	-- Clear the file list so we can reload with a new set of files later
	TRUNCATE TABLE agency_file
END