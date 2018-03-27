USE [$(FileManagementDB_Name)]
GO

TRUNCATE TABLE [dbo].[file_format]

INSERT [dbo].[file_format]  VALUES (N'HCHB Spec 1', 1, N'version 1', 'Initial version HCHB specifications', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format]  VALUES (N'HCHB Spec 0', 0, N'Test version', 'Test version HCHB specifications', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format]  VALUES (N'Demo Spec 1', 1, N'version 1;','Initial version Demographic specifications', GETDATE(), GETDATE(), 0)

GO
