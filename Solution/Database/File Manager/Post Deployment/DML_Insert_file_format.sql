IF NOT EXISTS (SELECT 1 FROM dbo.file_format)
BEGIN

INSERT INTO [dbo].[file_format] (
 [file_format_code]
,[file_format_version]
,[file_format_desc]
,[file_format_comment]
,[create_timestamp]
,[modify_timestamp]
,[process_batch_key]
)
VALUES 
  (N'HCHB Spec 1', 1, N'version 1', 'Initial version HCHB specifications', GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 0', 0, N'Test version', 'Test version HCHB specifications', GETDATE(), GETDATE(), 0)
, (N'Demo Spec 1', 1, N'version 1;','Initial version Demographic specifications', GETDATE(), GETDATE(), 0)
;

END

