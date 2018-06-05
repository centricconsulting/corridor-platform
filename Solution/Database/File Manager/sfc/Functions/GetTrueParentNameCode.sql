

CREATE FUNCTION [sfc].[GetTrueParentNameCode] (@currentNameCode varchar(40))
RETURNS varchar(40)
AS
BEGIN

DECLARE @parentNameCode varchar(40)

SELECT @parentNameCode = Parent_ID__c
FROM sfc.DM_Agency__c WHERE Unique_Name__c = @currentNameCode

IF (@parentNameCode IS NOT NULL)
	SET @parentNameCode = sfc.GetTrueParentNameCode(@parentNameCode)
ELSE
	SET @parentNameCode = @currentNameCode

RETURN @parentNameCode
END