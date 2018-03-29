
IF NOT EXISTS (SELECT 1 FROM dbo.agency)
BEGIN

DECLARE @emails VARCHAR(1000) = 'russ.dixon@centricconsulting.com;demily@corridorgroup.com;nick@corridorgroup.com';

INSERT INTO dbo.agency (
 [agency_name]
,[default_file_format_code]
,[folder_branch_name]
,[notify_email_address_list]
,[notify_on_rejected_ind]
,[notify_on_accepted_ind]
,[create_timestamp]
,[modify_timestamp]
,[process_batch_key]
)
VALUES
  (N'Kindred', N'Demo Spec 1', N'Kindred', @emails, 1, 1, GETDATE(), GETDATE(), 0)
, (N'Trinity', N'HCHB Spec 1', N'Trinity', @emails, 1, 1, GETDATE(), GETDATE(), 0)
, (N'Medstar', N'HCHB Spec 1', N'Medstar', @emails, 1, 1, GETDATE(), GETDATE(), 0)
;

END
GO
