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
	DECLARE @ErrorCode INT, @Continue BIT = 1;

	
	DECLARE @ImportedFromAWQStaging BIT = 1;

	IF OBJECT_ID('tempdb.dbo.#ActivityWaitQueue_Batch','U') IS NOT NULL
	BEGIN
		DROP TABLE #ActivityWaitQueue_Batch ;
	END;
    

	--Create the Temp table, with schema same as [InteractionStudio].[ActivityWaitQueue], except all fields are NULLable
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


	WHILE(@Continue = 1)
		BEGIN		
			--cleanup
			TRUNCATE TABLE #ActivityWaitQueue_Batch;

			BEGIN TRANSACTION;

			DELETE TOP (1000) 
			FROM [InteractionStudio].[ActivityWaitQueue_old]	
			OUTPUT
				deleted.QueueID, deleted.DefinitionID, deleted.ActivityID, deleted.InstanceDefinitionID, deleted.InstanceActivityID, deleted.ContactID,
				deleted.ContactKey, deleted.ContactType, deleted.TimesProcessed, deleted.WaitStartDate, deleted.WaitEndDate, deleted.ProcessingID,
				deleted.IsProcessed, deleted.IsLocked, deleted.IsActive, deleted.[Status], deleted.CreateDate, deleted.ModifyDate,
				deleted.MID, deleted.EID, deleted.SourceId, deleted.SourceType, deleted.SourceInstanceID, deleted.ExitCriteriaLastChecked,
				deleted.RequestObject, deleted.WaitingForEventID, 
				deleted.Q1RequestObjectId, deleted.Q1RequestObjectIsOutOfRow, deleted.ImportedFromAWQStaging, deleted.ImportedDate, deleted.AdditionalDetails,
				deleted.EventSource, deleted.WaitEndDatePrePause, deleted.WaitType, deleted.DequeueReason, deleted.DequeueData
			INTO #ActivityWaitQueue_Batch
				(
				QueueID, DefinitionID, ActivityID, InstanceDefinitionID, InstanceActivityID, ContactID,
				ContactKey, ContactType, TimesProcessed, WaitStartDate, WaitEndDate, ProcessingID,
				IsProcessed, IsLocked, IsActive, [Status], CreateDate, ModifyDate,
				MID, EID, SourceId, SourceType, SourceInstanceID, ExitCriteriaLastChecked,
				RequestObject, WaitingForEventID, 
				Q1RequestObjectId, Q1RequestObjectIsOutOfRow, ImportedFromAWQStaging, ImportedDate, AdditionalDetails,
				EventSource, WaitEndDatePrePause, WaitType, DequeueReason, DequeueData
				)
			WHERE StatusFlags=1 AND DefinitionID NOT IN ( 			
				'3C132F6E-ACF5-4331-8047-C5C1545BD56A', 'ACDDC777-6A21-4885-B89A-A11B5CBA8A08', 'EEC6FD83-E1A7-45F0-8A94-D64B1E8099FE', 
				'39E13FE5-7378-4732-BCA3-AA2F244C3DD6', 'E0317234-8AA4-4E14-8425-2AEAE79BC549', '45CCC7E3-A4EA-47E4-9004-96F43114924D', 
				'98993FA0-4084-4EAD-A046-570F8842C44F', '7FA219A8-1D40-4904-A2D9-F35D6BB82D1A', '8D6BA74F-164D-44F4-93F0-B3A32C74201D', 
				'2EDA9B33-41BE-47C5-B007-D5C6FE58A088', '45CEF027-42AA-487B-94F8-4DE646BBFF85', 'FFE1D349-14CF-4C8E-8F9E-1BC8B48FBA75', 
				'9A093556-90E6-4D80-9F62-F0645DF3E361', '3CA4432C-4399-44B3-9E07-7E836AC8D9DA', '484BF5A2-15B7-434D-A56C-473718298E9E', 
				'2143B15A-8C08-4152-9986-8491D8D5739D', '23FDAE67-E9D2-4420-92A4-CDFFF191AEE6', '327B6252-688A-4DC8-8581-2F9A73BE5B55', 
				'2C8711E3-9D1E-45F9-A1D8-7F88789EB838', 'C6419215-EEAA-4A4A-932A-88378D8C1629', '219DF756-8B77-4846-9D39-6D9B813A8A62', 
				'9C361C72-838B-4F33-964C-E654F90D71AC', 'F8F82438-8AF1-447E-AAF8-64157A03B203', 'B08E32D7-61B4-41A0-8826-25D736600D83', 
				'922D47AE-F257-490C-8B6E-4C4BF393CBCD', 'AD56A302-C694-4370-B05F-32B9B94DFE2F', '7D3822CF-3D06-4F17-ADBD-CC4F6025C9C0', 
				'6D764A72-6B12-47CB-A1DE-B778DC38077A', 'D0464256-3014-4CD4-BB5A-226DA97D87A0', 'B9C7724F-0DF5-48BC-8173-B7E48F56ABBB', 
				'37EC85DF-5B96-4996-BCB9-EEF3574A498E', 'FD46F170-F851-4A5F-82A5-03A7B9E3DD72', 'E830D280-D194-4340-B550-6E87A0DAB32F', 
				'309127AC-3251-4E96-BC05-EA7D433F6908', 'D831A428-5D6F-4101-898E-C1F79720606F', '8C32D7D6-3A3A-4043-BBC1-9D5C186339F4', 
				'87949296-479B-4F18-9533-6BA71720126A', '4A5014D9-0C7D-4566-86D2-34952695994B', '0F65BCD6-ED5F-458D-A92B-5F154E4A43A9', 
				'0774120D-A364-4131-8E52-5500B36C61DC', '57EEC663-AED1-485C-B2FE-ABA51D2901AE', '4B776667-38BB-44F7-9C7E-E47CC3A432D7', 
				'D2B4FB9A-BF96-4CC4-9209-C0988D2AC300', '1A1865A0-EB36-4614-B7D8-88A1544F17B8', '2B7042DC-DB94-46E6-96EB-A3FB7E6C40F2', 
				'8E81DCF5-6A33-4DFC-AD4C-9AC68E2666A9', 'FEAE2DE4-5705-4192-8A58-02DF97BE5D74', '202E0FF9-6799-4633-88F1-B6D496B53BAD', 
				'6B9B3B1B-0534-4483-8C27-EBB4B644208E', '8B812EE5-2774-4BC6-9D05-0C07A5BE0D99', 'FFAB74E0-6678-443B-A59E-41077B37D31E', 
				'A97A0B4F-F52F-4035-82A6-596B17EA06B6', 'E3316246-9C7A-43E6-89C0-5D73AC5AD86C', 
				'C8228668-B3B5-4295-BEEF-352B89FD1A9C'
			) ;
	
			INSERT INTO [InteractionStudio].[ActivityWaitQueue]
					([DefinitionID]      ,[ActivityID]      ,[InstanceDefinitionID]      ,[InstanceActivityID]      ,[ContactID]      ,[ContactKey]      ,[ContactType]      ,[TimesProcessed]      ,[WaitStartDate]
					,[WaitEndDate]      ,[ProcessingID]      ,[IsProcessed]      ,[IsLocked]      ,[IsActive]      ,[Status]      ,[CreateDate]      ,[ModifyDate]      ,[MID]      ,[EID]     ,[SourceId]      ,[SourceType]
					,[SourceInstanceID]      ,[ExitCriteriaLastChecked]      ,[WaitingForEventID]      ,[Q1RequestObjectId]      ,[Q1RequestObjectIsOutOfRow]	,[ImportedFromAWQStaging]	,[ImportedDate]		
					,[AdditionalDetails]	,[EventSource]	,[WaitType])	
			SELECT [DefinitionID]      ,[ActivityID]      ,[InstanceDefinitionID]      ,[InstanceActivityID]      ,[ContactID]      ,[ContactKey]      ,[ContactType]      ,[TimesProcessed]      ,[WaitStartDate]
					,[WaitEndDate]      ,[ProcessingID]      ,[IsProcessed]      ,[IsLocked]      ,[IsActive]      ,[Status]      ,[CreateDate]      ,[ModifyDate]      ,[MID]      ,[EID]     ,[SourceId]      ,[SourceType]
					,[SourceInstanceID]      ,[ExitCriteriaLastChecked]      ,[WaitingForEventID]      ,[Q1RequestObjectId]      ,[Q1RequestObjectIsOutOfRow]	,@ImportedFromAWQStaging	, GETDATE()
					,[AdditionalDetails]	,[EventSource]	,[WaitType]
			FROM #ActivityWaitQueue_Batch;

			SELECT @RecordsInserted = @@ROWCOUNT;

			COMMIT TRANSACTION;

			SELECT @TotalRecordsInserted = @TotalRecordsInserted + @RecordsInserted;
			IF (@RecordsInserted = 0)
			BEGIN
				SELECT @Continue = 0;
			END;
		END;
GO



/*####################################################################
$$Sproc:  Migrate from AWQ_old to AWQ
$$Author: Jithendra Renati
$$History:  
			2021-10-22 - JRenati	Created
#####################################################################*/