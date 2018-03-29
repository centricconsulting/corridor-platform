IF NOT EXISTS (SELECT 1 FROM dbo.file_format_attribute)
BEGIN

INSERT INTO [dbo].[file_format_attribute] (
 [file_format_code]
,[attribute_name]
,[column_position]
,[extract_regex]
,[create_timestamp]
,[modify_timestamp]
,[process_batch_key]
)
VALUES
  (N'HCHB.1.0', N'Arrival Date', 1, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Patient Last Name', 2, '^([^,])', GETDATE(), GETDATE(), 0)   --'^([^,])+'
, (N'HCHB.1.0', N'Patient First Name', 2, '[^,]+$', GETDATE(), GETDATE(), 0)    --[^,]*$
, (N'HCHB.1.0', N'MRN', 3, NULL, GETDATE(), GETDATE(), 0)					--^([A-Z]{3})
, (N'HCHB.1.0', N'Agency Location Alias', 3, '^([A-Z]{3})', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'SOC Date', 4, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'SOE Date', 5, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Event', 6, NULL, GETDATE(), GETDATE(), 0) 
, (N'HCHB.1.0', N'Payor Type', 8, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Payor Source', 9, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Task', 11, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Responsible Position', 12, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Stage', 13, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Agency Location', 15, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Visit Type', 16, NULL, GETDATE(), GETDATE(), 0)

;

END
GO