USE [$(FileManagementDB_Name)]
GO

TRUNCATE TABLE [dbo].[agency]

INSERT [dbo].[agency]  VALUES (N'Kindred', N'Demo Spec 1', N'Kindred', N'jeff.faseun@centricconsulting.com;', 1, 1, GETDATE(), GETDATE(), 0)
INSERT [dbo].[agency]  VALUES (N'Trinity', N'HCHB Spec 1', N'Trinity', N'jeff.faseun@centricconsulting.com;', 1, 1, GETDATE(), GETDATE(), 0)  --russ.dixon@centricconsulting.com;demily@corridorgroup.com;nick@corridorgroup.com;
INSERT [dbo].[agency]  VALUES (N'Medstar', N'HCHB Spec 1', N'Medstar', N'jeff.faseun@centricconsulting.com;', 1, 1, GETDATE(), GETDATE(), 0)
GO

/***** NOTE: NO FILES SHOULD BE IN ROOT DIRECTORY. ROOT DIRECTORY DOES NOT HAVE A SPEC ASSOCIATED WITH IT *****/
--INSERT [dbo].[agency]  VALUES (N'ROOT', N'HCHB Spec 1', N'', N'jeff.faseun@centricconsulting.com;', 1, 1, GETDATE(), GETDATE(), 0) --ROOT