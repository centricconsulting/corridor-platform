-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TruncateFileStaging]
AS
BEGIN
TRUNCATE TABLE [dbo].[agency_file];

TRUNCATE TABLE [dbo].[agency_file_row];

TRUNCATE TABLE [dbo].[agency];



END