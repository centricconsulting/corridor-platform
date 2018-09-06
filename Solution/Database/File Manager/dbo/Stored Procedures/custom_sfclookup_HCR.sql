
CREATE PROCEDURE [dbo].[custom_sfclookup_HCR] (@agency_key as int, @process_batch_key as int)
AS
/*
-- TEST CODE --
PRINT 'RESET CODE'
DECLARE @agency_key as int
DECLARE @process_batch_key as int
SET @agency_key = 19
SET @process_batch_key = 111845

UPDATE agency_medical_record
SET process_dtm = NULL, process_error_category = NULL, process_error_message = NULL, process_success_ind = NULL, salesforce_send_ind = 1, notification_sent_ind = 1, sfc_Agency__c = NULL, sfc_Product_Rate__c = NULL
WHERE agency_key = @agency_key
AND process_batch_key = @process_batch_key
PRINT 'END RESET CODE'
-- END TEST CODE --
*/

DECLARE @TrueParentAgencyID varchar(40)

-- Get Salesforce Parent Agency ID
SELECT @TrueParentAgencyID = agency_code_salesforce
FROM agency
WHERE agency_key = @agency_key

PRINT @TrueParentAgencyID

-- For performance, get parent name in DM_Agency - only works because there's only one
--  layer of parent
DECLARE @HCRParentName varchar(40)

-- Set parent name
SELECT TOP 1 @HCRParentName = Parent_ID__c
FROM sfc.DM_Agency__c
WHERE sfc.GetTrueParentAgencyCode(Id) = @TrueParentAgencyID
AND Parent_ID__c IS NOT NULL

PRINT @HCRParentName

-- Get agency code
UPDATE agency_medical_record
SET sfc_Agency__c = Id
--SELECT * 
FROM agency_medical_record
INNER JOIN
(
	select agency_medical_record_key, 'HCR_' + agency_location AgencyAlias
	from agency_medical_record
	WHERE agency_medical_record.process_batch_key = @process_batch_key
	AND agency_key = @agency_key
	AND salesforce_send_ind = 1
) AC
ON agency_medical_record.agency_medical_record_key = AC.agency_medical_record_key
inner join [sfc].[DM_Agency__c]
ON AC.AgencyAlias = [sfc].[DM_Agency__c].Agency_Alias__c
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_key = @agency_key
AND salesforce_send_ind = 1
AND sfc.DM_Agency__c.Parent_ID__c = @HCRParentName


-- Get agency code
--UPDATE agency_medical_record
--SET sfc_Agency__c = Id
--FROM agency_medical_record
--INNER JOIN 
--(
--select agency_medical_record_key, ('HCR' + '_' + agency_location) AgencyAlias
--from agency_medical_record
--inner join [dbo].[agency_file_row] 
--on agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
--WHERE agency_medical_record.process_batch_key = @process_batch_key
--AND agency_key = @agency_key
--AND salesforce_send_ind = 1
--) Alias
--ON agency_medical_record.agency_medical_record_key = Alias.agency_medical_record_key
--inner join [sfc].[DM_Agency__c] 
--ON Alias.AgencyAlias = [sfc].[DM_Agency__c].Agency_Alias__c
--WHERE agency_medical_record.process_batch_key = @process_batch_key
--AND agency_key = @agency_key
--AND salesforce_send_ind = 1
--AND sfc.GetTrueParentAgencyCode(sfc.DM_Agency__c.id) = @TrueParentAgencyID




-- Inactive Agency Error Message
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Record Rejected - Inactive Location in HHCP: "' + agency_location, salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN sfc.DM_Agency__c Agency__c
ON agency_medical_record.sfc_Agency__c = Agency__c.Id
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE Agency__c.Status__c != 'Active'
AND agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1


-- Agency error messages
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find Agency Location "' + ('HCR_' + agency_location) + '" in HHCP', salesforce_send_ind = 0, notification_sent_ind = 0
FROM agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND sfc_Agency__c IS NULL


-- (Coding Only) product lookup
UPDATE agency_medical_record
SET sfc_Product_Rate__c = [sfc].[DM_Agency_Product_Rate__c].Id
From agency_medical_record
INNER JOIN [sfc].[DM_Agency_Product_Rate__c] 
on  ('Coding Only ' + agency_medical_record.visit_type) =  [sfc].[DM_Agency_Product_Rate__c].Product_Name_for_IT__c 
-- extra parentheses removed
and agency_medical_record.sfc_Agency__c = [sfc].[DM_Agency_Product_Rate__c].Agency__c
where agency_medical_record.process_batch_key = @process_batch_key
AND salesforce_send_ind = 1
AND agency_key = @agency_key

--Error Message For Product Rate That Cannot Be Found
UPDATE agency_medical_record
SET process_dtm = GETDATE(), process_success_ind = 0, process_error_message = 'FILE:' + [file_name] + ', MRN:' + medical_record_number + ', Cannot find Product Rate for "' + agency_location + '" in HHCP. Visit Type: '+ visit_type , salesforce_send_ind = 0, notification_sent_ind = 0
From agency_medical_record
INNER JOIN agency_file_row
ON agency_medical_record.agency_file_row_key = agency_file_row.agency_file_row_key
INNER JOIN agency_file
ON agency_file_row.agency_file_key = agency_file.agency_file_key
WHERE agency_medical_record.process_batch_key = @process_batch_key
AND agency_medical_record.agency_key = @agency_key
AND salesforce_send_ind = 1
AND sfc_Product_Rate__c IS NULL