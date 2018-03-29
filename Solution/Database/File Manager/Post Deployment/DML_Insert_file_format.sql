IF NOT EXISTS (SELECT 1 FROM dbo.file_format)
BEGIN

INSERT INTO [dbo].[file_format] (
 [file_format_code]
,[file_format_desc]
,[file_format_comment]
,[create_timestamp]
,[modify_timestamp]
,[process_batch_key]
)
VALUES 
  (N'HCHB.1.0', 'HCHB File Format Specification 1.0', NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB.2.0', 'HCHB File Format Specification 2.0', NULL, GETDATE(), GETDATE(), 0)
, (N'KINDRED.1.0', 'Kindred File Format Specification 1.0', NULL, GETDATE(), GETDATE(), 0)
;

END

