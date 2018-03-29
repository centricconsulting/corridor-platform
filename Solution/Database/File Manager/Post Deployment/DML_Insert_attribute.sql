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
  (N'agency', 'DT_STR', 100, GETDATE(), GETDATE(), 0)
, (N'agency_location', 'DT_STR', 100, GETDATE(), GETDATE(), 0)
, (N'agency_location_alias', 'CHAR', 5, GETDATE(), GETDATE(), 0)
, (N'team', 'DT_STR', 20, GETDATE(), GETDATE(), 0)
, (N'patient_lastname', 'DT_STR', 50, GETDATE(), GETDATE(), 0)
, (N'patient_firstname', 'DT_STR', 50, GETDATE(), GETDATE(), 0)
, (N'MRN', 'DT_STR', 50, GETDATE(), GETDATE(), 0)
, (N'oasis_visit_type', 'DT_STR', 50, GETDATE(), GETDATE(), 0)
, (N'visit_type', 'DT_STR', 50, GETDATE(), GETDATE(), 0)
, (N'assessment_dt', 'DT_DBDATE', NULL, GETDATE(), GETDATE(), 0)
, (N'responsible_position', 'DT_STR', 50, GETDATE(), GETDATE(), 0)
, (N'arrival_dt', 'DT_DBDATE', NULL, GETDATE(), GETDATE(), 0)
, (N'SOE_dt', 'DT_DBDATE', NULL, GETDATE(), GETDATE(), 0)
, (N'SOC_dt', 'DT_DBDATE', NULL, GETDATE(), GETDATE(), 0)
, (N'REC_dt', 'DT_DBDATE', NULL, GETDATE(), GETDATE(), 0)
, (N'ROC_dt', 'DT_DBDATE', NULL, GETDATE(), GETDATE(), 0)
, (N'hospice_dt', 'DT_DBDATE', NULL, GETDATE(), GETDATE(), 0)
, (N'discharge_dt', 'DT_DBDATE', NULL, GETDATE(), GETDATE(), 0)
, (N'payor_type', 'DT_STR', 50, GETDATE(), GETDATE(), 0)
, (N'payor_source', 'DT_STR', 50, GETDATE(), GETDATE(), 0)
, (N'secondary_payor_type', 'DT_STR', 50, GETDATE(), GETDATE(), 0)
, (N'secondary_payor_source', 'DT_STR', 50, GETDATE(), GETDATE(), 0)
, (N'clinician_firstname', 'DT_STR', 50, GETDATE(), GETDATE(), 0)
, (N'clinician_lastname', 'DT_STR', 50, GETDATE(), GETDATE(), 0)
, (N'event', 'DT_STR', 50, GETDATE(), GETDATE(), 0)
, (N'stage', 'DT_STR', 50, GETDATE(), GETDATE(), 0)
, (N'task', 'DT_STR', 50, GETDATE(), GETDATE(), 0)

END
GO
