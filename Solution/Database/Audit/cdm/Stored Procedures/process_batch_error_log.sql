﻿
/* ################################################################################

OBJECT: cdm.process_batch_error_log

DESCRIPTION: Logs an error associated with a Process Batch Key.

PARAMETERS:

  @process_batch_key INT = Key identifying the new process batch.

  @error_scope VARCHAR(200) = Scope of executing code where the error was raised.

  @error_type_cd VARCHAR(20) = Text value indicating the type of error.  E=Critical Error, W=Warning, etc.
 
  @error_number INT = Number of the error reported.

  @error_message VARCHAR(2000) = Description of the error reported.

  @comments VARCHAR(2000) Optional = Comments related to the error.
  
OUTPUT PARAMETERS: None.
  
RETURN VALUE: None.

RETURN DATASET: None.
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2010-12-31  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE cdm.process_batch_error_log
  @process_batch_key INT
, @error_scope VARCHAR(200)
, @error_type_cd VARCHAR(20)
, @error_number INTEGER
, @error_message VARCHAR(2000)
, @comments VARCHAR(2000) = NULL
AS 
BEGIN

  BEGIN TRANSACTION;
  
  INSERT INTO cdm.process_batch_error (
    process_batch_key
  , error_scope
  , error_type_cd
  , error_number
  , error_message
  , comments
  ) values (
    @process_batch_key
  , @error_scope
  , @error_type_cd
  , @error_number
  , @error_message
  , @comments
  );
  
  COMMIT TRANSACTION;

END;