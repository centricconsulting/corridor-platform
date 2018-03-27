USE [$(FileManagementDB_Name)]
GO


TRUNCATE TABLE [dbo].[file_format_rule_translate]

INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'agency_location_alias', N'COH', N'Trinity Corp - COH - Columbus - Mount Carmel Home Care', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'agency_location_alias', N'SIH', N'Trinity Corp - SIH - Silver Spring - Holy Cross Home Care', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'agency_location_alias', N'ANH', N'Trinity Corp - ANH - Ann Arbor - St Joseph Mercy Home Care', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'agency_location_alias', N'WEH', N'Trinity Corp - WEH - West Springfield - Mercy Home Care', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'agency_location_alias', N'OAH', N'Trinity Corp - OAH - Oakland St. Joseph Mercy Home Care', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'agency_location_alias', N'LIH', N'Trinity Corp - LIH - Livingston St. Joseph Mercy Home Care', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'agency_location_alias', N'LIL', N'Trinity Corp - LIL - Livingston St. Joseph Mercy Home Care', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'agency_location_alias', N'CTH', N'Trinity Corp - CTH - TH of NE Home Health - CT', GETDATE(), GETDATE(), 0)


INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'payor_type', N'MEDICARE', N'Extended OASIS Review.SOC', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'payor_type', N'MEDICARE MANAGED EPISODIC PAYORS', N'Extended OASIS Review.SOC', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'payor_type', N'MEDICARE MANAGED FFS', N'Extended OASIS Review.SOC', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'payor_type', N'MEDICAID MANAGED', N'Primary OASIS Review.SOC', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'payor_type', N'MEDICAID', N'Primary OASIS Review.SOC', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'payor_type', N'NON MEDICARE EPISODIC PAYORS', N'Primary OASIS Review.SOC', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'payor_type', N'COMMERCIAL INSURANCE', N'Coding Only.SOC', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'payor_type', N'CHARITY', N'Coding Only.SOC', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'payor_type', N'SELF-PAY', N'Coding Only.SOC', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'payor_type', N'OTHER', N'Coding Only.SOC', GETDATE(), GETDATE(), 0)
INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'payor_type', N'BLUE CROSS COMMERCIAL', N'Coding Only.SOC', GETDATE(), GETDATE(), 0)

INSERT [dbo].[file_format_rule_translate]  VALUES (N'HCHB Spec 1', N'event', N'DISCHARGE', N'Discharge Review', GETDATE(), GETDATE(), 0)




GO

--TRUNCATE TABLE [dbo].[agency_alias]

--INSERT [dbo].[agency_alias]  VALUES (N'TRINITY', N'Trinity Corp - COH - Columbus - Mount Carmel Home Care', N'COH')
--INSERT [dbo].[agency_alias]  VALUES (N'TRINITY', N'Trinity Corp - SIH - Silver Spring - Holy Cross Home Care', N'SIH')
--INSERT [dbo].[agency_alias]  VALUES (N'TRINITY',  N'Trinity Corp - ANH - Ann Arbor - St Joseph Mercy Home Care', N'ANH')
--INSERT [dbo].[agency_alias]  VALUES (N'TRINITY',  N'Trinity Corp - WEH - West Springfield - Mercy Home Care', N'WEH')
--INSERT [dbo].[agency_alias]  VALUES (N'TRINITY',  N'Trinity Corp - OAH - Oakland St. Joseph Mercy Home Care', N'OAH')
--INSERT [dbo].[agency_alias]  VALUES (N'TRINITY',  N'Trinity Corp - LIH - Livingston St. Joseph Mercy Home Care', N'LIH')
--GO


