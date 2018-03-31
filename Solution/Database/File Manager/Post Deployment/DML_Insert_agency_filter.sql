IF NOT EXISTS (SELECT 1 FROM [dbo].[agency_filter])
BEGIN

INSERT INTO [dbo].[agency_filter] (
	[agency_name],
	[attribute_name],
	[attribute_value],
	[filter_action_flag],
	[create_timestamp],
	[modify_timestamp],
	[process_batch_key]
)
VALUES
  ('Trinity','Agency Location Alias','Trinity Corp - COH - Columbus - Mount Carmel Home Care','Include', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0)
, ('Trinity','Agency Location Alias','Trinity Corp - SIH - Silver Spring - Holy Cross Home Car','Include', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0)

END