IF NOT EXISTS (SELECT 1 FROM dbo.file_format_attribute)
BEGIN

INSERT INTO [dbo].[file_format_attribute] (
 [file_format_code]
,[attribute_name]
,[column_index]
,[extract_regex]
,[required_ind]
,[transform_default_ind]
,[create_timestamp]
,[modify_timestamp]
,[process_batch_key]
)
VALUES
  (N'HCHB.1.0', N'Medical Record Number', 3, NULL,1,0, GETDATE(), GETDATE(), 0)					--^([A-Z]{3})
, (N'HCHB.1.0', N'Assessment Date', 1,  NULL,1,0, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Patient Last Name', 2, '^([^,])',1,0, GETDATE(), GETDATE(), 0)   --'^([^,])+'
, (N'HCHB.1.0', N'Patient First Name', 2, '[^,]+$',0,0, GETDATE(), GETDATE(), 0)    --[^,]*$
, (N'HCHB.1.0', N'Agency Location Alias', 3, '^([A-Z]{3})',1,1, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Start Of Care Date', 4, NULL,1,1, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Start Of Episode Date', 5, NULL,0,1, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Event', 6, NULL,0,1, GETDATE(), GETDATE(), 0) 
, (N'HCHB.1.0', N'Payor Type', 8, NULL,1,1, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Payor Source', 9, NULL,0,1, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Task', 11, NULL,0,1, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Responsible Position', 12, NULL,0,1, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Stage', 13, NULL,0,1, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Agency Location', 15, NULL,1,1, GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Visit Type', 16, NULL,1,1, GETDATE(), GETDATE(), 0)

;

END
GO