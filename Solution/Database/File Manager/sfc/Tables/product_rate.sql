CREATE TABLE [sfc].[product_rate]
(
	[product_rate_uid]			VARCHAR(50) NOT NULL,
	[product_rate]				VARCHAR(50) NOT NULL, 
	[agency_location_uid]		VARCHAR(50) NOT NULL,
	[product_uid]				VARCHAR(50), 
	[assessment_type_desc]		VARCHAR(50),
	[assessment_type]			VARCHAR(50),
	[rate_status]				VARCHAR(20), 
	[effective_dt]				DATE, 
	[effective_till_dt]			DATE, 	
	[create_timestamp]			DATETIME		NOT NULL,
  [batch_key]					INT             NOT NULL,
  CONSTRAINT [sfc_product_rate_pk] PRIMARY KEY CLUSTERED ([product_rate_uid] ASC)
);
GO

CREATE INDEX [sfc_product_rate_u1] ON [sfc].[product_rate] ([agency_location_uid])
GO
