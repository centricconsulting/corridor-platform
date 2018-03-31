IF NOT EXISTS (SELECT 1 FROM [dbo].[file_format_translate])
BEGIN

INSERT INTO [dbo].[file_format_translate] (
 [file_format_code]
,[attribute_name]
,[attribute_value]
,[translated_value]
,[create_timestamp]
,[modify_timestamp]
,[process_batch_key]
)
VALUES
  (N'HCHB.1.0', N'Agency Location Alias', N'COH', N'Trinity Corp - COH - Columbus - Mount Carmel Home Care', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Agency Location Alias', N'SIH', N'Trinity Corp - SIH - Silver Spring - Holy Cross Home Care', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Agency Location Alias', N'ANH', N'Trinity Corp - ANH - Ann Arbor - St Joseph Mercy Home Care', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Agency Location Alias', N'WEH', N'Trinity Corp - WEH - West Springfield - Mercy Home Care', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Agency Location Alias', N'OAH', N'Trinity Corp - OAH - Oakland St. Joseph Mercy Home Care', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Agency Location Alias', N'LIH', N'Trinity Corp - LIH - Livingston St. Joseph Mercy Home Care', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Agency Location Alias', N'LIL', N'Trinity Corp - LIL - Livingston St. Joseph Mercy Home Care', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Agency Location Alias', N'CTH', N'Trinity Corp - CTH - TH of NE Home Health - CT', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Payor Type', N'MEDICARE', N'Extended OASIS Review.SOC', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Payor Type', N'MEDICARE MANAGED EPISODIC PAYORS', N'Extended OASIS Review.SOC', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Payor Type', N'MEDICARE MANAGED FFS', N'Extended OASIS Review.SOC', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Payor Type', N'MEDICAID MANAGED', N'Primary OASIS Review.SOC', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Payor Type', N'MEDICAID', N'Primary OASIS Review.SOC', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Payor Type', N'NON MEDICARE EPISODIC PAYORS', N'Primary OASIS Review.SOC', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Payor Type', N'COMMERCIAL INSURANCE', N'Coding Only.SOC', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Payor Type', N'CHARITY', N'Coding Only.SOC', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Payor Type', N'SELF-PAY', N'Coding Only.SOC', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Payor Type', N'OTHER', N'Coding Only.SOC', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Payor Type', N'BLUE CROSS COMMERCIAL', N'Coding Only.SOC', GETDATE(), GETDATE(), 0)
, (N'HCHB.1.0', N'Event', N'DISCHARGE', N'Discharge Review', GETDATE(), GETDATE(), 0)
;

END
GO

