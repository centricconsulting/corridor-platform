
CREATE PROCEDURE dbo.get_attribute_detail 
  @file_format_code VARCHAR(20) AS
BEGIN

   SELECT
    ffa.attribute_name
  , ffa.column_index
  , ffa.extract_regex
  , ffa.required_ind
  , ffa.transform_default_ind
  , a.attribute_data_type
  , a.attribute_max_length
  FROM
  dbo.file_format_attribute ffa
  INNER JOIN dbo.attribute a ON
    a.attribute_name = ffa.attribute_name
  WHERE
  ffa.file_format_code = @file_format_code;

END