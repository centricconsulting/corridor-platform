

CREATE VIEW dbo
AS
SELECT
	 f.agency_file_key
	,f.archive_folder_path
  ,f.archive_file_name
	,f.folder_branch
	,fb.notify_email_address_list
	,f.create_timestamp
	,f.process_batch_key

FROM [dbo].[agency_file] f
INNER JOIN [dbo].[agency] fb
	ON fb.[folder_branch_name] = f.[folder_branch]
WHERE fb.notify_on_rejected_ind = 1
--ORDER BY 3, 1