CREATE PROCEDURE [dbo].[send_File_Manager_notification](@notification_message as varchar(max), @notification_to as varchar(2000), @notification_subject as varchar(200) )
AS
EXEC msdb.dbo.sp_send_dbmail 
@profile_name = 'FileNotificationEmail',
@recipients = @notification_to,
@subject = @notification_subject,
@body = @notification_message,
@body_format = 'HTML'