CREATE TABLE [dbo].[Kindred_Audit_List] (
    [MRN]            VARCHAR (9)   NOT NULL,
    [AssessmentDate] DATE          NOT NULL,
    [Agency]         VARCHAR (200) NOT NULL,
    [FormStatus]     VARCHAR (200) NOT NULL,
    CONSTRAINT [PK_Kindred_Audit_List] PRIMARY KEY CLUSTERED ([MRN] ASC, [AssessmentDate] ASC, [Agency] ASC)
);

