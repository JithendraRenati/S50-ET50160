SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET QUOTED_IDENTIFIER ON;
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

	DECLARE @TotalRecordsInserted INT = 0, @RecordsInserted INT = 0;

	DROP TABLE IF EXISTS #ActivityWaitQueue_Batch ;
    
	CREATE TABLE #ActivityWaitQueue_Batch
    (
		QueueID BIGINT ,
        DefinitionID UNIQUEIDENTIFIER ,
        ActivityID UNIQUEIDENTIFIER ,
        InstanceDefinitionID UNIQUEIDENTIFIER ,
        InstanceActivityID UNIQUEIDENTIFIER ,
        ContactID BIGINT ,
        ContactKey NVARCHAR(200) ,
        ContactType TINYINT ,
		TimesProcessed INT NULL ,
        WaitStartDate DATETIME ,
        WaitEndDate DATETIME ,
        ProcessingID UNIQUEIDENTIFIER ,
        IsProcessed BIT ,
        IsLocked BIT ,
        IsActive BIT ,
        Status TINYINT ,
        CreateDate DATETIME ,
        ModifyDate DATETIME ,
        MID BIGINT ,
        EID BIGINT ,
		SourceId UNIQUEIDENTIFIER NULL,
		SourceType SMALLINT NULL,
		SourceInstanceID UNIQUEIDENTIFIER NULL,
		ExitCriteriaLastChecked DATETIME NULL,
		RequestObject NVARCHAR(max) NULL,
		WaitingForEventID UNIQUEIDENTIFIER NULL,
		Q1RequestObjectId UNIQUEIDENTIFIER NULL,
		Q1RequestObjectIsOutOfRow BIT NULL ,
		ImportedFromAWQStaging BIT NULL,
		ImportedDate DATETIME NULL,
		AdditionalDetails NVARCHAR(250) NULL,
		EventSource	SMALLINT NULL,
		WaitEndDatePrePause DATETIME NULL,
		WaitType SMALLINT NULL,
		DequeueReason NVARCHAR(200) NULL,
		DequeueData NVARCHAR(4000) NULL 
    )
	WITH(DATA_COMPRESSION=ROW);

	BEGIN TRY
		INSERT INTO #ActivityWaitQueue_Batch
		(
			QueueID, DefinitionID, ActivityID, InstanceDefinitionID, InstanceActivityID, ContactID,
			ContactKey, ContactType, TimesProcessed, WaitStartDate, WaitEndDate, ProcessingID,
			IsProcessed, IsLocked, IsActive, [Status], CreateDate, ModifyDate,
			MID, EID, SourceId, SourceType, SourceInstanceID, ExitCriteriaLastChecked,
			RequestObject, WaitingForEventID, 
			Q1RequestObjectId, Q1RequestObjectIsOutOfRow, ImportedFromAWQStaging, ImportedDate, AdditionalDetails,
			EventSource, WaitEndDatePrePause, WaitType, DequeueReason, DequeueData
		)
		SELECT 
			QueueID, DefinitionID, ActivityID, InstanceDefinitionID, InstanceActivityID, ContactID,
			ContactKey, ContactType, TimesProcessed, WaitStartDate, WaitEndDate, ProcessingID,
			IsProcessed, IsLocked, IsActive, [Status], CreateDate, ModifyDate,
			MID, EID, SourceId, SourceType, SourceInstanceID, ExitCriteriaLastChecked,
			RequestObject, WaitingForEventID, 
			Q1RequestObjectId, Q1RequestObjectIsOutOfRow, ImportedFromAWQStaging, ImportedDate, AdditionalDetails,
			EventSource, WaitEndDatePrePause, WaitType, DequeueReason, DequeueData
		FROM [InteractionStudio].[ActivityWaitQueue_old] WITH (NOLOCK)
		WHERE StatusFlags=1 AND MID != 510004599 OPTION (RECOMPILE);

		WHILE EXISTS (SELECT TOP 1 NULL FROM #ActivityWaitQueue_Batch)
		BEGIN		
		
			INSERT INTO [InteractionStudio].[ActivityWaitQueue]
					([DefinitionID]      ,[ActivityID]      ,[InstanceDefinitionID]      ,[InstanceActivityID]      ,[ContactID]      ,[ContactKey]      ,[ContactType]      ,[TimesProcessed]      ,[WaitStartDate]
					,[WaitEndDate]      ,[ProcessingID]      ,[IsProcessed]      ,[IsLocked]      ,[IsActive]      ,[Status]      ,[CreateDate]      ,[ModifyDate]      ,[MID]      ,[EID]     ,[SourceId]      ,[SourceType]
					,[SourceInstanceID]      ,[ExitCriteriaLastChecked]      ,[WaitingForEventID]      ,[Q1RequestObjectId]      ,[Q1RequestObjectIsOutOfRow]	,[ImportedFromAWQStaging]	,[ImportedDate]		
					,[AdditionalDetails]	,[EventSource]	,[WaitType])	
			SELECT [DefinitionID]      ,[ActivityID]      ,[InstanceDefinitionID]      ,[InstanceActivityID]      ,[ContactID]      ,[ContactKey]      ,[ContactType]      ,[TimesProcessed]      ,[WaitStartDate]
					,[WaitEndDate]      ,[ProcessingID]      ,[IsProcessed]      ,[IsLocked]      ,[IsActive]      ,[Status]      ,[CreateDate]      ,[ModifyDate]      ,[MID]      ,[EID]     ,[SourceId]      ,[SourceType]
					,[SourceInstanceID]      ,[ExitCriteriaLastChecked]      ,[WaitingForEventID]      ,[Q1RequestObjectId]      ,[Q1RequestObjectIsOutOfRow]	, ImportedFromAWQStaging	, ImportedDate
					,[AdditionalDetails]	,[EventSource]	,[WaitType]
			FROM (
				DELETE TOP (1000) 
				FROM #ActivityWaitQueue_Batch
				OUTPUT
				deleted.QueueID, deleted.DefinitionID, deleted.ActivityID, deleted.InstanceDefinitionID, deleted.InstanceActivityID, deleted.ContactID,
				deleted.ContactKey, deleted.ContactType, deleted.TimesProcessed, deleted.WaitStartDate, deleted.WaitEndDate, deleted.ProcessingID,
				deleted.IsProcessed, deleted.IsLocked, deleted.IsActive, deleted.[Status], deleted.CreateDate, deleted.ModifyDate,
				deleted.MID, deleted.EID, deleted.SourceId, deleted.SourceType, deleted.SourceInstanceID, deleted.ExitCriteriaLastChecked,
				deleted.RequestObject, deleted.WaitingForEventID, 
				deleted.Q1RequestObjectId, deleted.Q1RequestObjectIsOutOfRow, deleted.ImportedFromAWQStaging, deleted.ImportedDate, deleted.AdditionalDetails,
				deleted.EventSource, deleted.WaitEndDatePrePause, deleted.WaitType, deleted.DequeueReason, deleted.DequeueData) AS A;

			SELECT @RecordsInserted = @@ROWCOUNT;
			SELECT @TotalRecordsInserted = @TotalRecordsInserted + @RecordsInserted;
			
		END;

		SELECT @TotalRecordsInserted AS 'TotalRecordsInserted';

		DELETE
		FROM [InteractionStudio].[ActivityWaitQueue_old] 
		WHERE StatusFlags=1 AND MID != 510004599 OPTION (RECOMPILE);
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH;
GO



/*####################################################################
$$Sproc:  Migrate from AWQ_old to AWQ
$$Author: Jithendra Renati
$$History:  
			2021-10-22 - JRenati	Created
#####################################################################*/