CREATE PROCEDURE [dbo].[get_File_Manager_notification] (@agency_file_key as int, @process_success as bit)
AS
/*
get_File_Manager_notification
by Scott Stover
Centric Consulting
3/30/2018

This procedure takes in the agency_file_key and process_success_ind from the control flow in
Manage Source Files.dtsx - Retrieve Notification Info task and returns
all the information needed to send the email notification to users
*/

-- General Message Variables
DECLARE @crlf varchar(2) =  CHAR(13) + CHAR(10) -- CRLF - used for line breaks in the message
DECLARE @notification_to as varchar(2000) -- Notification message destination
DECLARE @notification_subject as varchar(78) -- Notification message subject (RFC recommends 78 chars)
DECLARE @notification as varchar(2000) -- Notification message contents
DECLARE @send_notification_flag as bit -- Flag that determines whether notification gets sent

-- Retrieve important fields from agency and agency_file tables

--  IMPORTANT: Cleaning up the nulls here makes building the message easier
DECLARE @agency_name as varchar(100)
DECLARE @notify_email_address_list as varchar(4000)
DECLARE @notify_on_accepted_ind as bit
DECLARE @notify_on_rejected_ind as bit
DECLARE @file_format_code as varchar(20)
DECLARE @source_file_path as varchar(1000)
DECLARE @process_error_message as varchar(100)
DECLARE @archive_folder_path as varchar(1201)
SELECT
	@agency_name = agency.agency_name,
	@notify_email_address_list = ISNULL(agency.notify_email_address_list, ''),
	@notify_on_accepted_ind = agency.notify_on_accepted_ind,
	@notify_on_rejected_ind = agency.notify_on_rejected_ind,
	@file_format_code = agency_file.file_format_code,
	@source_file_path = agency_file.file_path,
	@process_error_message = ISNULL(agency_file.process_error_message, ''),
	@archive_folder_path = ISNULL(agency_file.archive_folder_path, '') + '\' + ISNULL(agency_file.archive_file_name, '')
FROM agency
INNER JOIN agency_file ON agency.agency_key = agency_file.agency_key
WHERE agency_file.agency_file_key = @agency_file_key

-- This field cannot be null in the database, so a null value indicates no record was returned,
-- therefore, we must assume an invalied agency_file_key was passed.
IF @source_file_path IS NULL RAISERROR ('An invalid agency_file_key was received', 18 , 1)
--   State 18 will force a failure of the stored procedure

-- Retrieve the number of rows imported from the file
DECLARE @imported_file_rows as int
SELECT @imported_file_rows = COUNT(*) FROM agency_file_row WHERE agency_file_key = @agency_file_key AND column_header_ind = 0

-- BUILD THE NOTIFICATION MESSAGE

-- IMPORTANT: This is destined for an SSIS Send Mail Task, which does NOT support HTML email

-- First, we check to see if the notification is turned on for accepted/rejected
IF (@process_success = 1 AND @notify_on_accepted_ind = 0) OR (@process_success = 0 AND @notify_on_rejected_ind = 0)
	-- If notification turned off, @notification_to will be blank
	BEGIN
		SET @send_notification_flag = 0
		SET @notification_to = ''
		SET @notification_subject = 'DO NOT SEND - Notification turned off'
		SET @notification = ''
	END
ELSE -- If the notification is enabled
	
	SET @send_notification_flag = 1
	SET @notification_to = @notify_email_address_list -- Populate the "to" address

	IF @process_success = 1
		-- Build success message
		BEGIN
			SET @notification_subject = 'File Import Notification: Success'
			SET @notification = 'File Import Success' + @crlf + @crlf
			SET @notification = @notification + 'Agency: ' + @agency_name + @crlf
			SET @notification = @notification + 'Source file: ' + @source_file_path + @crlf
			SET @notification = @notification + 'File Format Code: ' + @file_format_code + @crlf
			SET @notification = @notification + 'Number of rows processed: ' + CAST(@imported_file_rows as varchar(8)) + @crlf
			SET @notification = @notification + 'File archived to: ' + @archive_folder_path + @crlf + @crlf
			SET @notification = @notification + 'This is an automated message.  Please do not reply to it.'
		END
	ELSE -- Process failed / file rejected
		-- Build failure message
		BEGIN
			SET @notification_subject = 'File Import Notification: Failed'
			SET @notification = 'File Import Failure' + @crlf + @crlf
			SET @notification = @notification + 'Agency: ' + @agency_name + @crlf
			SET @notification = @notification + 'Source file: ' + @source_file_path + @crlf
			SET @notification = @notification + 'File Format Code: ' + @file_format_code + @crlf
			SET @notification = @notification + 'File archived to: ' + @archive_folder_path + @crlf
			SET @notification = @notification + 'Error Message: ' + @process_error_message + @crlf + @crlf
			SET @notification = @notification + 'This is an automated message.  Please do not reply to it.'
		END

-- TEST CODE --
SET @notification_to = 'scott.stover@centricconsulting.com'
-- END TEST CODE --

-- Return a result set that contains the "to" address, message subject and notification message
SELECT @notification_to notification_to, @notification_subject notification_subject, @notification notification_message, @send_notification_flag send_notification