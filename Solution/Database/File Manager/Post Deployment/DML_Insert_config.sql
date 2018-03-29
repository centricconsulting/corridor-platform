IF NOT EXISTS (SELECT 1 FROM dbo.config WHERE config_key = 0)
BEGIN

INSERT INTO dbo.config (
  config_key
, received_folder_path
, accepted_folder_path
, rejected_folder_path
, create_timestamp
, modify_timestamp
, process_batch_key
)
SELECT
 0 AS config_key
, 'F:\Received' AS received_folder_path
, 'F:\Accepted' AS accepted_folder_path
, 'F:\Rejected' AS rejected_folder_path
, CURRENT_TIMESTAMP AS create_timestamp
, CURRENT_TIMESTAMP AS modify_timestamp
, 0
;

END

SET IDENTITY_INSERT dbo.config OFF
GO





