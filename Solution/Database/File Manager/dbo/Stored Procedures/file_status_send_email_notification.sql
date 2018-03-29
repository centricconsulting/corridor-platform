CREATE PROCEDURE [dbo].[file_status_send_email_notification]
	@file_key		INT = NULL
AS
	
/****** Declare Variables ******/
DECLARE @strSQL			NVARCHAR(MAX) 	
DECLARE @tableHTML		NVARCHAR(MAX) 
DECLARE @MailSubject	NVARCHAR (100)
DECLARE @emailGroup		NVARCHAR(300)
DECLARE @fileName		NVARCHAR(2000)
DECLARE @fileStatus		NVARCHAR(20)
DECLARE @strRejected	NVARCHAR(1000) 
DECLARE @strFolderName	NVARCHAR(1000) 
DECLARE @receiptDate	DATETIME
DECLARE @fileStart		INT = 1
DECLARE @fileCount		INT = 0
DECLARE @recordCount	INT = 0
DECLARE @Debug			BIT = 0
DECLARE @folderName		NVARCHAR(100)
		--,@file_key	NVARCHAR(2000)  = NULL--'Stonhard' --Used for testing

/****** SET VARIABLE DEFAULTS *****/
SET @tableHTML		= COALESCE(@tableHTML, '')
SET @folderName		= COALESCE(@folderName, '')
SET @strFolderName	= COALESCE(@strFolderName, '')
SET @strRejected	= COALESCE(@strRejected, 'Please see the error log below, correct the error(s) and resubmit the file.  The EDW does not accept any data from files with critical errors.')

/****** Execute sp_send_dbmail to send the created HTML email ******/

IF OBJECT_ID ( 'tempdb..#tmp_email_status_report' ) IS NOT NULL DROP TABLE #tmp_email_status_report;

CREATE TABLE #tmp_email_status_report 
 ( 
 FileName					VARCHAR(2000), 
 folder_name				VARCHAR(2000),
 file_created_dtm			DATETIME,
 file_status				VARCHAR(20) , 
 notification_sent_ind		BIT,
 notify_email_address_list	VARCHAR(4000),
 default_file_format_code	VARCHAR(200),
 fileNum					INT,
 );
 

SET  @strSQL = N'
INSERT INTO #tmp_email_status_report    
SELECT COALESCE(f.[file_name], ''NO FILE'') ''file_name''
      ,COALESCE(f.[folder_branch_name], ''NO FOLDER'')  folder_branch_name   --agency_branch
      ,COALESCE(f.[file_created_dtm], ''1900-01-01'') file_created_dtm		--receipt_dtm
      ,''Completed'' file_status
	  ,f.notification_sent_ind 
	  ,COALESCE(fb.notify_email_address_list, ''ROOT'') notify_email_address_list  
	  ,fb.default_file_format_code
	  ,DENSE_RANK() OVER (ORDER BY f.[file_name] DESC) fileNum 
  FROM [dbo].[agency_file] f
  JOIN [dbo].[agency] fb ON f.folder_branch_name = fb.folder_branch_name
  WHERE f.notification_sent_ind = 0
  AND f.agency_file_key = '+ CONVERT(VARCHAR(10), @file_key) 

IF @Debug = 1
	PRINT @strSQL
ELSE
	EXECUTE sp_executesql @strSQL 


/****** Handle email counts ******/	  
SELECT @recordCount = COUNT(*) 
	, @fileCount = COUNT(DISTINCT FileName)
FROM  #tmp_email_status_report


/***** QUERIES USEDD FOR TESTING *****/	
--SELECT @recordCount 'Record Count', @fileCount 'File Count', @emailGroup 'Email Group'
--SELECT * FROM  #tmp_email_status_report 


BEGIN
/****** Create the body of the HTML email ******/
/****** Set the header and table structure in the HTML email ******/


WHILE @fileStart <= @fileCount
BEGIN
	/****** Handle for Null File Name and status ******/	
	SELECT @fileName = [FileName], @fileStatus = file_status, @receiptDate = file_created_dtm, @emailGroup = notify_email_address_list, @folderName = default_file_format_code
	FROM  #tmp_email_status_report
	WHERE fileNum = @fileStart
	  --AND [scope] = 'FILE'

	/***** QUERIES USEDD FOR TESTING *****/	
	--SELECT @fileName 'File Name', @fileStatus 'Status', @receiptDate 'Receipt Date', @strRejected 'Rejected String', @emailGroup 'Email List'

	/***** HANDLE FOR O RECORDS IN FILE *****/	
	IF @recordCount < 1
	BEGIN
		SET @tableHTML =  @tableHTML +
		N'<p>'+CONVERT(NVARCHAR(3), COALESCE(@recordCount, 0))+' Records were loaded.</p>' 

		SET @emailGroup = (SELECT notify_email_address_list FROM [dbo].[agency] WHERE default_file_format_code = 'ROOT')
	END 
	ELSE
	BEGIN		
		SET @strFolderName = ' for group ' + @folderName
		SET @tableHTML = @tableHTML + N'<p>Thank you for submitting file <b>'+@fileName+'</b> </p>' +
		N'<p>File '+@fileName+' received '+CONVERT(NVARCHAR(10),@receiptDate)+'  has been '+ @fileStatus + @strFolderName +'.</p>' 
	END


--PERFORM BELOW ONLY IF REJECTED
	--IF @fileStatus = 'REJECTED'
	--BEGIN
	--	SET @tableHTML = @tableHTML +
	--	N'<P>' +@strRejected +'</p>' +
	--	N'<table border="3">' +
	--	N'<tr><th>File Summary</th>' +

		/****** Result of SQL Query to populate data in HTML email ******/

		--CAST
		--( 
		--  ( 
		--	SELECT   
		--	td = ErrorMessage, ' '
		--	FROM
		--	(
		--		SELECT *, 1 AS sequence FROM #tmp_email_status_report WHERE fileNum = @fileStart AND scope = 'File' AND (ErrorMessage NOT LIKE '%FILE Hash:%' ) AND (ErrorMessage NOT LIKE '%FILE Name:%')
		--	) AS email_report
		--	ORDER BY file_created_dtm DESC, folder_name ASC, FileName DESC
		--	FOR XML PATH ('tr'), TYPE 
		--  ) AS NVARCHAR (MAX)
		--) +
		--N'</table>'  +
	
		--N'<table border="3">' +
		--N'<tr><th>Type Count</th><th>Name</th>' +

		--/****** Result of SQL Query to populate data in HTML email ******/

		--CAST
		--( 
		--  ( 
		--	SELECT   
		--	td = typeCNT, ' ',
		--	td = row_disposition, ' '
		--	FROM
		--	(
		--		SELECT COUNT(row_disposition) typeCNT, row_disposition, fileNum, scope
		--		FROM #tmp_email_status_report 
		
		--		GROUP BY scope, fileNum, row_disposition
		--		HAVING fileNum = @fileStart AND scope = 'File' 
		--	) AS email_report
		--	FOR XML PATH ('tr'), TYPE 
		--  ) AS NVARCHAR (MAX)
		--) +
		--N'</table>'  +
		
		--N'<p>' + 
		--N'<table border="3">' +
		--N'<tr><th>Column Name</th><th>Error Message</th><th>Error Count</th><th>Row Disposition</th><th>Severity</th><th>First Occurance of Error</th>' +

		----/****** Result of SQL Query to populate data in HTML email ******/

		--CAST
		--( 
		--  ( 
		--	SELECT 
		--	td = column_label, ' ',
		--	td = ErrorMessage, ' ',
		--	td = errorCNT, ' ',
		--	td = row_disposition, ' ',
		--	td = severity, ' ',
		--	td = first_error_row, ' '
	
		--	FROM
		--	(
		--		SELECT *, 1 AS sequence FROM #tmp_email_status_report WHERE fileNum = @fileStart AND scope = 'Column'
		--	) AS email_report
		--	ORDER BY file_created_dtm DESC, folder_name ASC, FileName DESC
		--	FOR XML PATH ('tr'), TYPE 
		--  ) AS NVARCHAR (MAX)
		--) +
		--N'</table>'  
		--END

SET @tableHTML = @tableHTML + N'<p>Thanks, Data Services Team .</p>' ;

/****** Create the subject of the HTML email ******/
/****** Set the Server Description ******/
IF @folderName IS NOT NULL
	SET @MailSubject = @folderName+ ' File Load has Completed Execution on '  
ELSE
	SET @MailSubject = 'File Load has Completed Execution on '  

SET @MailSubject = @MailSubject +
CASE 
WHEN @@servername = 'SFDATASQL' THEN 'Corridor-ODS Server'
END
+ ' as of ' + CONVERT ( VARCHAR (50) , GETDATE() )  ;

/***** QUERIES USEDD FOR TESTING *****/	

/****** End of the subject of the HTML email ******/


EXEC msdb.dbo.sp_send_dbmail 
@profile_name = 'FileNotificationEmail', --Account Name: 'FileNotificationEmail'
@recipients = @emailGroup, --'jeff.faseun@centricconsulting.com',
@subject = @MailSubject,
@body = @tableHTML,
@body_format = 'HTML'			

UPDATE	[dbo].[agency_file]
SET		[notification_sent_ind] = 1
WHERE	agency_file_key IN (SELECT agency_file_key  FROM #tmp_email_status_report WHERE fileNum = @fileStart)-- AND [scope] = 'FILE')



--PRINT @tableHTML
/****** Loop through files ******/
SET @fileStart = @fileStart + 1

END





END
GO