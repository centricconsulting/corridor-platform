/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/


/*
############################################################
Populate the source table.
############################################################
*/

TRUNCATE TABLE dbo.source

INSERT INTO dbo.source (
  source_key
, source_uid
, source_name
, source_desc
, batch_key
)
SELECT x.* FROM (

SELECT 
  @unk_key AS source_key
, 'ODS' AS source_uid
, 'Operational Data Store' AS source_name
, 'Corridor Operational Data Store' AS source_desc
, @process_batch_key AS process_batch_key
UNION ALL SELECT 100, 'AF', 'Agency Files','Corridor Files received from Agencies', 0
UNION ALL SELECT 101, 'CA', 'Corridor Apps','Corridor internal operations applications', 0
UNION ALL SELECT 102, 'SF', 'Salesforce','Corridor ERP / CRM application', 0
UNION ALL SELECT 103, 'GOV', 'GOV', 'Corridor governance reference (master) data', 0
) x
WHERE
NOT EXISTS (
	SELECT 1 FROM dbo.source m WHERE m.source_key = x.source_key
)