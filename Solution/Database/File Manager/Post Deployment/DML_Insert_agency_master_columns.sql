USE [corridor_file_manager]
GO

TRUNCATE TABLE [dbo].[agency_master_column]

INSERT [dbo].[agency_master_column]  VALUES (N'agency', N'VARCHAR(100)')
INSERT [dbo].[agency_master_column]  VALUES (N'branch', N'CHAR(5)')
INSERT [dbo].[agency_master_column]  VALUES (N'team', N'VARCHAR(20)')
INSERT [dbo].[agency_master_column]  VALUES (N'patient_lastname', N'VARCHAR(50)')
INSERT [dbo].[agency_master_column]  VALUES (N'patient_firstname', N'VARCHAR(50)')
INSERT [dbo].[agency_master_column]  VALUES (N'MRN', N'VARCHAR(50)')
INSERT [dbo].[agency_master_column]  VALUES (N'oasis_visit_type', N'VARCHAR(50)')
INSERT [dbo].[agency_master_column]  VALUES (N'visit_type', N'VARCHAR(50)')
INSERT [dbo].[agency_master_column]  VALUES (N'visit_dt', N'DATE')
INSERT [dbo].[agency_master_column]  VALUES (N'responsible_position', N'VARCHAR(50)')
INSERT [dbo].[agency_master_column]  VALUES (N'arrival_dt', N'DATE')
INSERT [dbo].[agency_master_column]  VALUES (N'SOE_dt', N'DATE')
INSERT [dbo].[agency_master_column]  VALUES (N'SOC_dt', N'DATE')
INSERT [dbo].[agency_master_column]  VALUES (N'REC_dt', N'DATE')
INSERT [dbo].[agency_master_column]  VALUES (N'ROC_dt', N'DATE')
INSERT [dbo].[agency_master_column]  VALUES (N'hospice_dt', N'DATE')
INSERT [dbo].[agency_master_column]  VALUES (N'discharge_dt', N'DATE')
INSERT [dbo].[agency_master_column]  VALUES (N'payor_type', N'VARCHAR(50)')
INSERT [dbo].[agency_master_column]  VALUES (N'payor_source', N'VARCHAR(50)')
INSERT [dbo].[agency_master_column]  VALUES (N'secondary_payor_type', N'VARCHAR(50)')
INSERT [dbo].[agency_master_column]  VALUES (N'secondary_payor_source', N'VARCHAR(50)')
INSERT [dbo].[agency_master_column]  VALUES (N'clinician_lastname', N'VARCHAR(50)')
INSERT [dbo].[agency_master_column]  VALUES (N'clinician_firstname', N'VARCHAR(50)')
INSERT [dbo].[agency_master_column]  VALUES (N'event', N'VARCHAR(50)')
INSERT [dbo].[agency_master_column]  VALUES (N'stage', N'VARCHAR(50)')
INSERT [dbo].[agency_master_column]  VALUES (N'task', N'VARCHAR(50)')
GO
