﻿
/* ################################################################################

OBJECT: cdm.process_batch_initiate_internal

DESCRIPTION: Given a Data Management Process UID this procedure initiates a new process batch, automatically
  applying the Internal Sequence Indicator = 1.

PARAMETERS:

  @process_uid  = Text that uniquely identifies the Data Management process.

  @channel_uid = The channel through which this data came into the system. Typically not specified. May be
    used when data comes in on file feeds (channel = file name) or when there are multiple source system instances
    loaded through a single workflow.

  @scope = Text that may be used for analysis of process data, often used to group processes.
 
  @workflow_name = Name of the workflow (encapsulated code) that executes the process.
 
  @workflow_guid VARCHAR(100) = Unique identifier of the workflow (encapsulated code) that executes the process.
 
  @workflow_version VARCHAR(20) = Version of the workflow (encapsulated code) that executes the process.
  
  @limit_process_uid VARCHAR(50) Optional = Identifier of a Data Management Process whose End Sequence Key is used to limit the
    returned End Sequence Key of the primary process.  The lesser of the two End Sequence Keys is returned.

  @comments VARCHAR(200) Optional = Comments to be applied to the new process batch.
  
OUTPUT PARAMETERS: None.
  
RETURN VALUE:

  batch_key INT = Key identifying the new process batch.

RETURN DATASET:

  NOTE: Only a single record will be returned.

  batch_key INT = Key identifying the new process batch.
  initiate_dtm DATETIME = Datetime the process batch was initiated.
  initiate_dtm_text CHAR(23) = Text representation of the Initiated Datetime, having the format CONVERT(char(23),<<datetime>>,121)
  begin_sequence_val BIGINT = Integer value representing the start of the range to be considered in processing the batch.
  begin_sequence_dtm DATETIME = Datetime value representing the start of the range to be considered in processing the batch.
  begin_sequence_dtm_text CHAR(23) = Text representation of the Start Sequence Datetime, having the format CONVERT(char(23),<<datetime>>,121)
  end_sequence_val BIGINT = Integer value representing the end of the range to be considered in processing the batch.
  end_sequence_dtm DATETIME = Datetime value representing the end of the range to be considered in processing the batch.
  end_sequence_dtm_text CHAR(23) = Text representation of the End Sequence Datetime, having the format CONVERT(char(23),<<datetime>>,121)
  
HISTORY:

  Date        Name            Version  Description
  ---------------------------------------------------------------------------------
  2010-12-31  Jeff Kanel      1.0      Created by Centric Consulting, LLC

################################################################################ */

CREATE PROCEDURE cdm.process_batch_initiate_internal
  @process_uid VARCHAR(100)
, @workflow_name VARCHAR(200)    
, @workflow_guid VARCHAR(100)
, @workflow_version VARCHAR(20)
, @limit_process_uid VARCHAR(100) = NULL
, @comments VARCHAR(2000) = NULL
, @channel_uid VARCHAR(100) = NULL
, @limit_channel_uid VARCHAR(100) = NULL
, @scope VARCHAR(200) = NULL
AS
BEGIN

  EXEC cdm.process_batch_initiate 
    @process_uid = @process_uid
  , @channel_uid = @channel_uid
  , @workflow_name = @workflow_name
  , @workflow_guid = @workflow_guid
  , @workflow_version = @workflow_version
  , @internal_sequence_ind = 1
  , @increment_sequence_ind = 1
  , @current_sequence_val = NULL
  , @current_sequence_dtm = NULL
  , @limit_process_uid = @limit_process_uid
  , @limit_channel_uid = @limit_channel_uid
  , @scope = @scope
  ;
  
END