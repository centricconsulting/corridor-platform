

CREATE FUNCTION [sfc].[GetTrueParentAgencyCode] (@currentAgencyCode varchar(40))
RETURNS varchar(40)
AS
BEGIN

DECLARE @parentAgencyCode varchar(40)
DECLARE @parentNameCode varchar(40)
DECLARE @currentNameCode varchar(40)

SELECT @currentNameCode = Unique_Name__c FROM sfc.DM_Agency__c
WHERE Id = @currentAgencyCode

SET @parentNameCode = sfc.GetTrueParentNameCode(@currentNameCode)

SELECT @parentAgencyCode = Id
FROM sfc.DM_Agency__c
WHERE Unique_Name__c = @parentNameCode

RETURN @parentAgencyCode

END