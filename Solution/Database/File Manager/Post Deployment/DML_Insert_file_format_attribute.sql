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
  (N'HCHB Spec 1', N'agency', -1, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'agency_location', -1, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'agency_location_alias', 2, '^([A-Z]{3})', GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'team', -1, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'patient_lastname', 1, '^([^,])', GETDATE(), GETDATE(), 0)   --'^([^,])+'
, (N'HCHB Spec 1', N'patient_firstname', 1, '[^,]+$', GETDATE(), GETDATE(), 0)    --[^,]*$
, (N'HCHB Spec 1', N'MRN', 2, NULL, GETDATE(), GETDATE(), 0)					--^([A-Z]{3})
, (N'HCHB Spec 1', N'oasis_visit_type', -1, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'visit_type', 7, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'assessment_dt', 3, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'responsible_position', 11, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'arrival_dt', 0, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'SOE_dt', 4, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'SOC_dt', 3, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'REC_dt', -1, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'ROC_dt', -1, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'hospice_dt', -1, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'discharge_dt', -1, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'payor_type', 7, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'payor_source', 8, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'secondary_payor_type', -1, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'secondary_payor_source', -1, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'clinician_firstname', -1, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'clinician_lastname', -1, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'event', 5, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'stage', 12, NULL, GETDATE(), GETDATE(), 0)
, (N'HCHB Spec 1', N'task', 10, NULL, GETDATE(), GETDATE(), 0)
;

END
GO