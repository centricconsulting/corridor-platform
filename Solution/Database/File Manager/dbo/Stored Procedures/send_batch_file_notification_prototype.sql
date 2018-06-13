CREATE PROCEDURE [dbo].[send_batch_file_notification_prototype]
AS

DECLARE @agency_key int
DECLARE @agency_name varchar(100)
DECLARE @notification_email_address varchar(400)

DECLARE @message varchar(max)
DECLARE @message_subject varchar(78)

SET @message = '<HTML>'

DECLARE agency_cursor CURSOR FOR 

	SELECT DISTINCT agency_medical_record.agency_key agency_key, agency_name, notify_email_address_list
	FROM agency_medical_record
	INNER JOIN agency
	ON agency_medical_record.agency_key = agency.agency_key
	WHERE notification_sent_ind = 0
	UNION
	SELECT DISTINCT agency_file.agency_key, agency_name, notify_email_address_list
	FROM agency_file_row
	INNER JOIN agency_file
	ON agency_file_row.agency_file_key = agency_file.agency_file_key
	INNER JOIN agency
	ON agency_file.agency_key = agency.agency_key
	WHERE agency_file_row.notification_sent_ind = 0

OPEN agency_cursor  
FETCH NEXT FROM agency_cursor INTO @agency_key, @agency_name, @notification_email_address

WHILE @@FETCH_STATUS = 0  
BEGIN 
	SET @message_subject = @agency_name + ' files processed'
	SET @message = @message + '<h3>Batch process errors for ' + @agency_name + ' on ' + CAST(GETDATE() as varchar(30)) + ' (server time)</h3>'
	SET @message = @message + '<table><tr><th>Error Category</th><th>Process Date/Time</th><th>Error Message</th></tr>'
	SELECT @message = @message + '<tr><td>' + process_error_category + '</td><td>' + CAST(process_dtm as varchar(30)) + '</td><td>' + process_error_message + '</td></tr>' FROM
	(
		SELECT 'ERROR' process_error_category, process_dtm, process_error_message
		FROM agency_medical_record
		WHERE process_error_message IS NOT NULL AND
		process_error_message NOT LIKE 'No status is available%'
		AND notification_sent_ind = 0
		AND agency_key = @agency_key
		UNION ALL
		SELECT process_error_category, process_dtm, process_error_message
		FROM agency_file_row
		WHERE process_error_message IS NOT NULL
		AND notification_sent_ind = 0
		AND agency_file_key IN
		(
			SELECT agency_file_key
			FROM agency_file
			WHERE agency_key = @agency_key
		)
		UNION ALL
		SELECT 'WARNING' process_error_category, process_dtm, 'MRN:' + medical_record_number + ', Record rejected by HHCP - Duplicate'
		FROM agency_medical_record
		WHERE process_error_message LIKE 'No status is available%'
		AND notification_sent_ind = 0
		AND agency_key = @agency_key
	) c
	ORDER BY process_error_category, process_dtm
	SET @message = @message + '</table></HTML>'
	EXEC send_File_Manager_notification @message, @notification_email_address, @message_subject
	SET @message = '<HTML>'
	FETCH NEXT FROM agency_cursor INTO @agency_key, @agency_name, @notification_email_address
END

CLOSE agency_cursor  
DEALLOCATE agency_cursor 

UPDATE agency_file_row
SET notification_sent_ind = 1

UPDATE agency_medical_record
SET notification_sent_ind = 1

UPDATE agency_file
SET notification_sent_ind = 1