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
	SET DEADLOCK_PRIORITY HIGH;
	
	IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[InteractionStudio].[ActivityWaitQueue_staging_old]') AND [name] = N'IX_ActivityWaitQueue_staging_old_MID')
	BEGIN
		CREATE NONCLUSTERED INDEX [IX_ActivityWaitQueue_staging_old_MID] 
		ON [InteractionStudio].[ActivityWaitQueue_staging_old] ([MID])
			WITH (ONLINE=ON, DATA_COMPRESSION=PAGE, MAXDOP = 8);
	END
	GO

	DROP TABLE IF EXISTS #ActivityWaitQueue_Staging_Batch ;
 
	CREATE TABLE #ActivityWaitQueue_Staging_Batch
	(
		ActivityWaitQueue_staging_Id UNIQUEIDENTIFIER,
		DefinitionID UNIQUEIDENTIFIER,
		ActivityID UNIQUEIDENTIFIER ,
		InstanceDefinitionID UNIQUEIDENTIFIER ,
		InstanceActivityID UNIQUEIDENTIFIER ,
		ContactID BIGINT  ,
		ContactKey NVARCHAR(200) ,
		ContactType TINYINT  ,
		TimesProcessed INT,
		WaitStartDate DATETIME ,
		WaitEndDate DATETIME ,
		ProcessingID UNIQUEIDENTIFIER ,
		IsProcessed BIT  ,
		IsLocked BIT  ,
		IsActive BIT  ,
		Status TINYINT  ,
		CreateDate DATETIME ,
		ModifyDate DATETIME ,
		MID BIGINT ,
		EID BIGINT ,
		SourceId UNIQUEIDENTIFIER ,
		SourceType SMALLINT ,
		SourceInstanceID UNIQUEIDENTIFIER ,
		ExitCriteriaLastChecked DATETIME ,
		WaitingForEventID UNIQUEIDENTIFIER ,
		Q1RequestObjectId UNIQUEIDENTIFIER ,
		Q1RequestObjectIsOutOfRow BIT ,	
		AdditionalDetails NVARCHAR(250) ,
		EventSource	SMALLINT ,
		WaitType SMALLINT
	)
	WITH(DATA_COMPRESSION=ROW);

	BEGIN TRY
		DECLARE @TotalRecordsInserted INT = 0, @RecordsInserted INT = 0;

		INSERT INTO #ActivityWaitQueue_Staging_Batch
		(
			[ActivityWaitQueue_staging_Id]
			,[DefinitionID], [ActivityID],[InstanceDefinitionID],[InstanceActivityID]
			,[ContactID],[ContactKey],[ContactType],[TimesProcessed],[WaitStartDate]
			,[WaitEndDate],[ProcessingID],[IsProcessed],[IsLocked],[IsActive]
			,[Status],[CreateDate],[ModifyDate],[MID],[EID]  ,[SourceId],[SourceType]
			,[SourceInstanceID],[ExitCriteriaLastChecked],[WaitingForEventID],[Q1RequestObjectId],[Q1RequestObjectIsOutOfRow]
			,[AdditionalDetails],[EventSource],[WaitType]
		)
		SELECT 
			[ActivityWaitQueue_staging_Id],
			DefinitionID, ActivityID, InstanceDefinitionID, InstanceActivityID, 
			ContactID, ContactKey, ContactType, TimesProcessed, WaitStartDate, 
			WaitEndDate, ProcessingID, IsProcessed, IsLocked, IsActive, 
			Status, CreateDate, ModifyDate, MID, EID, SourceId, SourceType, 
			SourceInstanceID, ExitCriteriaLastChecked, WaitingForEventID, Q1RequestObjectId, Q1RequestObjectIsOutOfRow, 
			AdditionalDetails, EventSource, WaitType
		FROM [InteractionStudio].[ActivityWaitQueue_staging_old] WITH (NOLOCK)
		WHERE MID != 510004599 OPTION (RECOMPILE);

		WHILE EXISTS (SELECT TOP 1 NULL FROM #ActivityWaitQueue_Staging_Batch)
		BEGIN		
		
			INSERT INTO [InteractionStudio].[ActivityWaitQueue]
					([DefinitionID],[ActivityID],[InstanceDefinitionID],[InstanceActivityID],[ContactID],[ContactKey],[ContactType],[TimesProcessed],[WaitStartDate]
					,[WaitEndDate],[ProcessingID],[IsProcessed],[IsLocked],[IsActive],[Status],[CreateDate],[ModifyDate],[MID],[EID]  ,[SourceId],[SourceType]
					,[SourceInstanceID],[ExitCriteriaLastChecked],[WaitingForEventID],[Q1RequestObjectId],[Q1RequestObjectIsOutOfRow]	,[ImportedFromAWQStaging]	,[ImportedDate]		
					,[AdditionalDetails]	,[EventSource]	,[WaitType])	
			SELECT [DefinitionID],[ActivityID],[InstanceDefinitionID],[InstanceActivityID],
					[ContactID],[ContactKey],[ContactType],[TimesProcessed],[WaitStartDate]
					,[WaitEndDate],[ProcessingID],[IsProcessed],[IsLocked],[IsActive],[Status],[CreateDate],[ModifyDate],[MID],[EID]  ,[SourceId],[SourceType]
					,[SourceInstanceID],[ExitCriteriaLastChecked],[WaitingForEventID],[Q1RequestObjectId],[Q1RequestObjectIsOutOfRow], 1 AS ImportedFromAWQStaging, GETDATE()
					,[AdditionalDetails],[EventSource],[WaitType]
			FROM (
				DELETE TOP (10000) 
				FROM #ActivityWaitQueue_Staging_Batch
				OUTPUT
				deleted.DefinitionID, deleted.ActivityID, deleted.InstanceDefinitionID, deleted.InstanceActivityID, deleted.ContactID,
				deleted.ContactKey, deleted.ContactType, deleted.TimesProcessed, deleted.WaitStartDate, deleted.WaitEndDate, deleted.ProcessingID,
				deleted.IsProcessed, deleted.IsLocked, deleted.IsActive, deleted.[Status], deleted.CreateDate, deleted.ModifyDate,
				deleted.MID, deleted.EID, deleted.SourceId, deleted.SourceType, deleted.SourceInstanceID, deleted.ExitCriteriaLastChecked,
				deleted.WaitingForEventID, deleted.Q1RequestObjectId, deleted.Q1RequestObjectIsOutOfRow, 
				deleted.AdditionalDetails, deleted.EventSource, deleted.WaitType) AS A;

			SELECT @RecordsInserted = @@ROWCOUNT;
			SELECT @TotalRecordsInserted = @TotalRecordsInserted + @RecordsInserted;
			
		END;

		SELECT @TotalRecordsInserted AS 'TotalRecordsInserted';

		DELETE
		FROM [InteractionStudio].[ActivityWaitQueue_staging_old]
		WHERE MID != 510004599 OPTION (RECOMPILE);
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