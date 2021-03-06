﻿CREATE TABLE [dbo].[agency_medical_record] (
    [agency_medical_record_key]      INT             IDENTITY (1, 1) NOT NULL,
    [agency_key]                     INT             NOT NULL,
    [agency_file_row_key]            INT             NOT NULL,
    [medical_record_number]          VARCHAR (200)   NOT NULL,
    [assessment_date]                DATETIME        NOT NULL,
    [visit_type]                     VARCHAR (200)   NULL,
    [agency_location]                VARCHAR (200)   NULL,
    [agency_location_alias]          VARCHAR (200)   NULL,
    [team]                           VARCHAR (200)   NULL,
    [patient_last_name]              VARCHAR (200)   NULL,
    [patient_first_name]             VARCHAR (200)   NULL,
    [oasis_visit_type]               VARCHAR (200)   NULL,
    [responsible_position]           VARCHAR (200)   NULL,
    [arrival_date]                   DATETIME        NULL,
    [start_of_care_date]             DATETIME        NULL,
    [start_of_episode_date]          DATETIME        NULL,
    [recertification_date]           DATETIME        NULL,
    [resumption_of_care_date]        DATETIME        NULL,
    [hospice_date]                   DATETIME        NULL,
    [discharge_date]                 DATETIME        NULL,
    [payor_type]                     VARCHAR (200)   NULL,
    [payor_source]                   VARCHAR (200)   NULL,
    [secondary_payor_type]           VARCHAR (200)   NULL,
    [secondary_payor_source]         VARCHAR (200)   NULL,
    [clinician_name]                 VARCHAR (400)   NULL,
    [event]                          VARCHAR (200)   NULL,
    [stage]                          VARCHAR (200)   NULL,
    [task]                           VARCHAR (200)   NULL,
    [episode_identifier]             VARCHAR (200)   NULL,
    [salesforce_send_ind]            BIT             CONSTRAINT [DF_agency_medical_record_salesforce_send_ind] DEFAULT ((1)) NOT NULL,
    [sfc_Agency__c]                  NVARCHAR (18)   NULL,
    [sfc_Product_Rate__c]            NVARCHAR (18)   NULL,
    [sfc_Status__c]                  NVARCHAR (10)   NULL,
    [sfc_Ready_for_Coding_send_ind]  BIT             NULL,
    [sfc_Special_Request__c]         VARCHAR (5)     CONSTRAINT [DF_agency_medical_record_sfc_Special_Request__c] DEFAULT ('false') NULL,
    [sfc_Special_Request_Reason__c]  NVARCHAR (255)  NULL,
    [sfc_Special_Request_Type__c]    NVARCHAR (255)  NULL,
    [sfc_Clinician_Graduate__c]      VARCHAR (5)     CONSTRAINT [DF_agency_medical_record_sfc_Clinician_Graduate__c] DEFAULT ('false') NULL,
    [sfc_Problem_Date__c]            DATETIME2 (7)   NULL,
    [sfc_Problem_Details__c]         NVARCHAR (4000) NULL,
    [sfc_Problem_Reason_Category__c] NVARCHAR (255)  NULL,
    [process_dtm]                    DATETIME        NULL,
    [process_success_ind]            BIT             NULL,
    [process_error_category]         VARCHAR (10)    NULL,
    [process_error_message]          VARCHAR (2000)  NULL,
    [notification_sent_ind]          BIT             CONSTRAINT [DF_agency_medical_record_notification_sent_ind] DEFAULT ((1)) NULL,
    [create_timestamp]               DATETIME        NOT NULL,
    [process_batch_key]              INT             NOT NULL,
    CONSTRAINT [dbo_agency_medical_record_pk] PRIMARY KEY CLUSTERED ([agency_medical_record_key] ASC)
);




















GO

