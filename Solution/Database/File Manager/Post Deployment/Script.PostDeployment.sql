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


:r .\DML_Insert_agency.sql

:r .\DML_Insert_file_format_rule_translate.sql

:r .\DML_Insert_attribute.sql

:r .\DML_Insert_file_format.sql

:r .\DML_Insert_file_format_attribute.sql

:r .\seed_config.sql









