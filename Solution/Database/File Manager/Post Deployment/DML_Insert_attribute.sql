IF NOT EXISTS (SELECT 1 FROM dbo.attribute)
BEGIN

INSERT INTO [dbo].[attribute]  (
 [attribute_name]
,[attribute_data_type]
,[attribute_max_length]
,[create_timestamp]
,[modify_timestamp]
,[process_batch_key]
)
VALUES 
  (N'Agency Location', 'Text', 100, GETDATE(), GETDATE(), 0)
, (N'Agency Location Alias', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Team', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Patient Last Name', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Patient First Name', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Medical Record Number', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'OASIS Visit Type', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Visit Type', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Assessment Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'Responsible Position', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Arrival Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'Start Of Episode Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'Start Of Care Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'Recertification Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'Resumption of Care Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'Hospice Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'Discharge Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'Payor Type', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Payor Source', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Secondary Payor Type', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Secondary Payor Source', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Clinician First Name', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Clinician Last Name', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Event', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Stage', 'Text', 200, GETDATE(), GETDATE(), 0)
, (N'Task', 'Text', 200, GETDATE(), GETDATE(), 0)

END
GO
