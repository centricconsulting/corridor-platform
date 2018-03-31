
CREATE PROCEDURE dbo.get_translate_detail 
  @file_format_code VARCHAR(20) AS
BEGIN

   SELECT
    t.attribute_name
  , t.attribute_value
  , t.translated_value
  FROM
  dbo.file_format_translate  t
  WHERE
  t.file_format_code = @file_format_code;

END