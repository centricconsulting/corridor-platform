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
, (N'Agency Location Alias', 'Text', 5, GETDATE(), GETDATE(), 0)
, (N'Team', 'Text', 20, GETDATE(), GETDATE(), 0)
, (N'Patient Last Name', 'Text', 50, GETDATE(), GETDATE(), 0)
, (N'Patient First Name', 'Text', 50, GETDATE(), GETDATE(), 0)
, (N'MRN', 'Text', 50, GETDATE(), GETDATE(), 0)
, (N'OASIS Visit Type', 'Text', 50, GETDATE(), GETDATE(), 0)
, (N'Visit Type', 'Text', 50, GETDATE(), GETDATE(), 0)
, (N'Assessment Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'Responsible Position', 'Text', 50, GETDATE(), GETDATE(), 0)
, (N'Arrival Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'SOE Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'SOC Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'REC Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'ROC Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'Hospice Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'Discharge Date', 'Timestamp', NULL, GETDATE(), GETDATE(), 0)
, (N'Payor Type', 'Text', 50, GETDATE(), GETDATE(), 0)
, (N'Payor Source', 'Text', 50, GETDATE(), GETDATE(), 0)
, (N'Secondary Payor Type', 'Text', 50, GETDATE(), GETDATE(), 0)
, (N'Secondary Payor Source', 'Text', 50, GETDATE(), GETDATE(), 0)
, (N'Clinician First Name', 'Text', 50, GETDATE(), GETDATE(), 0)
, (N'Clinician Last Name', 'Text', 50, GETDATE(), GETDATE(), 0)
, (N'Event', 'Text', 50, GETDATE(), GETDATE(), 0)
, (N'Stage', 'Text', 50, GETDATE(), GETDATE(), 0)
, (N'Task', 'Text', 50, GETDATE(), GETDATE(), 0)

END
GO
