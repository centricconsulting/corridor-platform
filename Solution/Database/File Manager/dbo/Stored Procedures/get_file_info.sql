
CREATE PROCEDURE [dbo].[get_file_info] (@file_path as nvarchar(1000), @received_root_folder varchar(1000))
AS

/*
Stored procedure get_file_info
by Scott Stover
Centric Consulting
4/2018

This procedure takes in the fully qualified file path of the Excel file as well
as the root folder for all received files, connects to it, determines various
information about the file, and returns it.  One of the tasks it completes is to
calculate a hash for the file.  This process requires reading and aggregating all
the rows.  When this is done, the rows are saved in the temporary table tmp.FileImportStaging.
Other tasks downstream will use this table to read the rows into the database.

This procedure is called by the Get File Info task in Process Source Files.dtsx in the Corridor
Platform solution.

A note about temp tables:  Rather than using the #temp table methodology, we create a tmp schema in
this database.  This has no performance impact, and it will allow us to run multiple copies of this
database simultaneously (such as test and production) without them interefering with each other's temp
tables.
*/

-- It's possible the path is passed in with double backslashes depending on the source of the variable.
--  To simplify processing, we condense them to one here.
SET @file_path = REPLACE(@file_path, '\\', '\')

-- Create a temporary linked server to the Excel file --
--  A linked server allows us to pull the data without having an exact specification
--  of source columns
DECLARE @linkedServerName sysname = 'TempFileManagerExcelTEST'

-- Clean up old linked server if it's still there
IF exists(SELECT null FROM sys.servers WHERE [name] = @linkedServerName)
	EXEC sp_dropserver @linkedServerName, 'droplogins'

-- Create the linked server
-- Note: ACE 12.0 works with .xls and .xlsx files and must be installed on the server for this to work.
exec sp_addlinkedserver
@server = @linkedServerName,
@srvproduct = 'ACE 12.0',
@provider = 'Microsoft.ACE.OLEDB.12.0',
@datasrc = @file_path,
@provstr = 'Excel 12.0; HDR=No; IMEX=1; ImportMixedTypes=Text'
/*
HDR=No (header row) means it will pull in the first row as a data row, regardless of whether it 
contains field names.

ImportMixedTypes=Text means it will treat any column being imported with mixed data types as text.

IMEX =1 (Import Export mode) sets it to import mode.  By combining this setting with HDR=No and
ImportMixedTypes=Text, we insure that all fields are pulled in as text.
*/

-- Set the current user to use as a remote login for the linked server
DECLARE @suser_sname NVARCHAR(256) = SUSER_SNAME()
EXEC sp_addlinkedsrvlogin @linkedServerName, 'false', @suser_sname, NULL, NULL

-- Next, we're going to pull in the list of sheets in the Excel file.  It will be stored in a temp
--  table.

-- Clean up temp table if it's still there
if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'SheetInfo' AND TABLE_SCHEMA = 'tmp')
	drop table tmp.SheetInfo

-- Pull the sheet info into the temp table from the linked server using OPENROWSET
SELECT * INTO tmp.SheetInfo FROM OPENROWSET('SQLNCLI', 'Server=(local);Trusted_Connection=yes;','EXEC sp_tables_ex TempFileManagerExcelTEST');

-- We only pull the first sheet name - others will be disregarded
DECLARE @SheetName as varchar(200)
SELECT TOP 1 @SheetName = TABLE_NAME
FROM tmp.SheetInfo

-- Clean up sheet info temp table
DROP TABLE tmp.SheetInfo

-- Next, we are going to re-create the rows from the linked server sheet into the tmp.FileImportStaging
-- table.  By using SELECT INTO, it creates a table matching the source data without having to define it.

-- Clean up file import staging table if it still exists
if exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = 'FileImportStaging' AND TABLE_SCHEMA = 'tmp') drop table tmp.FileImportStaging

-- Import the rows from the Excel file into the file import staging table
--  This will automatically pull all the columns from the named sheet
DECLARE @StagingLoadSQL as varchar(MAX)

-- Load the rows into FileImportStaging
-- Note: We add a row_index identity field and a column header indicator field in addition to all
--  the Excel fields
SET @StagingLoadSQL = 'SELECT *, IDENTITY(INT,1,1) AS row_index, 0 as column_header_ind INTO tmp.FileImportStaging FROM ' + @linkedServerName + '...[' + @SheetName + ']'
EXEC(@StagingLoadSQL)

-- Remove the Linked Server now that it is no longer needed
IF exists(SELECT null FROM sys.servers WHERE [name] = @linkedServerName)
	EXEC sp_dropserver @linkedServerName, 'droplogins'

-- We use the imported rows to generate a checksum aggregate, which we will use to generate a unique
--  hash for the file in the next step.
DECLARE @CSumAgg bigint
SELECT @CSumAgg = CHECKSUM_AGG(CHECKSUM(*)) FROM tmp.FileImportStaging

-- Use the table checksum to generate an MD5 hash
DECLARE @file_hash varchar(4000)
SET @file_hash = CONVERT(varchar(200), HASHBYTES('MD5', CONVERT(varchar(4000),@CSumAgg)),2 )

-- NOTE: Even though we are done using the tmp.FileImportStaging table, it does not get cleaned
--  up as it is used further downstream in the process.

-- Generate a GUID for the file
DECLARE @file_guid varchar(4000)
SET @file_guid = REPLACE(NEWID(),'-', '')

-- Get the file name without the path
DECLARE @file_name varchar(2000)
SET @file_name = RIGHT(@file_path, CHARINDEX('\', REVERSE(@file_path)) -1)

-- Get the folder name without the file
DECLARE @folder_path varchar(2000)
SET @folder_path = LEFT(@file_path, LEN(@file_path) - CHARINDEX('\', REVERSE(@file_path)))

-- Get the folder branch used to pull the file
DECLARE @folder_branch varchar(2000)
if @folder_path LIKE @received_root_folder + '%'
	SET @folder_branch = RIGHT(@folder_path, LEN(@folder_path) - LEN(@received_root_folder) - 1)
else
	SET @folder_branch = @file_path

-- Uses OLE Automation objects to get the date the file was created and last modified

-- NOTE: OLE Automation must be enabled on the SQL Server for this to work.
DECLARE @OAResult int, @OAobject int, @OAobjfile int
DECLARE @file_created_dtm datetime
DECLARE @file_modified_dtm datetime

-- Generate the FS object
EXEC @OAResult=sp_OAcreate 'Scripting.FileSystemObject',@OAobject OUT
-- Get the file using the FS object
if @OAResult=0 EXEC sp_OAmethod @OAobject, 'GetFile', @OAobjfile OUT, @file_path
-- Use the file to get the date created and last modified attributes
if @OAResult=0 EXEC @OAResult=sp_OAGetProperty @OAobjfile, 'DateCreated', @file_created_dtm OUT
if @OAResult=0 EXEC @OAResult=sp_OAGetProperty @OAobjfile, 'DateLastModified', @file_modified_dtm OUT
-- Clean up the FS object
EXEC sp_OADestroy @OAobject

-- Calculate what we will name the file once archived
DECLARE @archive_file_name varchar(3000)
SET @archive_file_name = 
-- Filename without extension
REVERSE(RIGHT(REVERSE(@file_name), LEN(@file_name) - CHARINDEX('.', REVERSE(@file_name))))
-- File Guid
+ '_' + @file_guid
-- Extension
+ REVERSE(LEFT(REVERSE(@file_name), CHARINDEX('.', REVERSE(@file_name))))

-- RETURN THE RESULTS
SELECT @file_hash file_hash
, @file_guid file_guid
, @file_name file_name
, @folder_path folder_path
, @folder_branch folder_branch
, @file_created_dtm file_created_dtm
, @file_modified_dtm file_modified_dtm
, @archive_file_name archive_file_name