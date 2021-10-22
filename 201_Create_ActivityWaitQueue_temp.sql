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

--------------------------------------------------------------
--Create this schema if it doesnt exist      
--------------------------------------------------------------
DECLARE @Params NVARCHAR(200);
DECLARE @DerivedSql NVARCHAR(MAX);
DECLARE @SchemaName NVARCHAR(17);
DECLARE @DoesSchemaExist  TINYINT;

SELECT @Params = '', @DoesSchemaExist = 0;
SELECT @SchemaName = 'InteractionStudio';

SELECT @Params = '@DoesSchemaExist TINYINT OUTPUT';
SELECT @DerivedSql = 
    REPLACE (
    '
    IF EXISTS(SELECT * FROM sys.schemas WHERE name = N''{0}'')
    BEGIN
        SET @DoesSchemaExist = 1
    END','{0}', @SchemaName);
   
EXECUTE sp_executesql @DerivedSql, @Params, @DoesSchemaExist OUTPUT;

IF (@DoesSchemaExist = 0)
BEGIN;
    SELECT @DerivedSql = REPLACE('CREATE SCHEMA [{0}] AUTHORIZATION [dbo]','{0}',@SchemaName);
    EXEC sp_executesql @DerivedSql;
END;
GO

IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'ActivityWaitQueue_temp' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
    CREATE TABLE InteractionStudio.ActivityWaitQueue_temp
    (
        QueueID BIGINT NOT NULL IDENTITY,
        DefinitionID UNIQUEIDENTIFIER NOT NULL,
        ActivityID UNIQUEIDENTIFIER NOT NULL,
        InstanceDefinitionID UNIQUEIDENTIFIER NOT NULL,
        InstanceActivityID UNIQUEIDENTIFIER NOT NULL,
        ContactID BIGINT NOT NULL DEFAULT ((0)),
        ContactKey NVARCHAR(200) NULL,
        ContactType TINYINT NOT NULL DEFAULT ((0)),
		TimesProcessed INT NULL  DEFAULT ((0)),
        WaitStartDate DATETIME NOT NULL,
        WaitEndDate DATETIME NULL,
        ProcessingID UNIQUEIDENTIFIER NOT NULL DEFAULT ('00000000-0000-0000-0000-000000000000'),
        Stamp TIMESTAMP NOT NULL,
        IsProcessed BIT NOT NULL DEFAULT ((0)),
        IsLocked BIT NOT NULL DEFAULT ((0)),
        IsActive BIT NOT NULL DEFAULT ((1)),
        Status TINYINT NOT NULL DEFAULT ((1)),
        CreateDate DATETIME NOT NULL DEFAULT (GETDATE()),
        ModifyDate DATETIME NOT NULL DEFAULT (GETDATE()),
        MID BIGINT NOT NULL,
        EID BIGINT NOT NULL,
		SourceId UNIQUEIDENTIFIER NULL,
		SourceType SMALLINT NULL,
		SourceInstanceID UNIQUEIDENTIFIER NULL,
		ExitCriteriaLastChecked DATETIME NULL,
		RequestObject NVARCHAR(max) NULL,
		WaitingForEventID UNIQUEIDENTIFIER NULL,
		StatusFlags AS 
			 [IsProcessed]*POWER(2,2)
			+[IsLocked]*POWER(2,1)
			+[IsActive]
		PERSISTED NOT NULL,
		Q1RequestObjectId UNIQUEIDENTIFIER NULL,
		Q1RequestObjectIsOutOfRow BIT NULL DEFAULT(0),

		ImportedFromAWQStaging BIT NULL,
		ImportedDate DATETIME NULL,
		AdditionalDetails NVARCHAR(250) NULL,
		EventSource	SMALLINT NULL,
		WaitEndDatePrePause DATETIME NULL,
		WaitType SMALLINT NULL,
		DequeueReason NVARCHAR(200) NULL,
		DequeueData NVARCHAR(4000) NULL,
		CONSTRAINT PK_ActivityWaitQueue_temp_QueueID_cl PRIMARY KEY CLUSTERED (QueueID)
	)
	WITH(DATA_COMPRESSION=NONE);
END;
GO
--------------------------------------------------------------
-- DROP INDEXES
--------------------------------------------------------------

--------------------------------------------------------------
-- CREATE INDEXES
--------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('InteractionStudio.ActivityWaitQueue_temp') AND [name] = N'IX_ActivityWaitQueue_temp_MID_ContactKey_IsProcessed_WaitEndDate_DefinitionID_IsActive')
BEGIN
	CREATE NONCLUSTERED INDEX IX_ActivityWaitQueue_temp_MID_ContactKey_IsProcessed_WaitEndDate_DefinitionID_IsActive ON InteractionStudio.ActivityWaitQueue_temp(MID, ContactKey, IsProcessed, WaitEndDate, DefinitionID, IsActive) 
		WITH (ONLINE=ON, DATA_COMPRESSION=ROW, MAXDOP = 8);
END
GO


IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('InteractionStudio.ActivityWaitQueue_temp') AND [name] = N'IX_ActivityWaitQueue_temp_InstanceDefinitionId_Active_NotProcessed')
BEGIN
	CREATE UNIQUE INDEX IX_ActivityWaitQueue_temp_InstanceDefinitionId_Active_NotProcessed ON InteractionStudio.ActivityWaitQueue_temp (InstanceDefinitionId)		
		WHERE  IsActive = 1 AND IsProcessed = 0
		WITH (ONLINE=ON, DATA_COMPRESSION=ROW, MAXDOP = 8);
END
GO

--Creation of IX_ActivityWaitQueue_MID_ContactKey_WaitingForEventID_Status which is a filtered index requires all these options SET appropriately
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[InteractionStudio].[ActivityWaitQueue_temp]') AND [name] = N'IX_ActivityWaitQueue_temp_WaitingForEventID_Status_ContactKey_ActivityId')
BEGIN
	CREATE NONCLUSTERED INDEX [IX_ActivityWaitQueue_temp_WaitingForEventID_Status_ContactKey_ActivityId] 
	ON [InteractionStudio].[ActivityWaitQueue_temp] ([WaitingForEventID], [StatusFlags], [ContactKey], ActivityID)
		WHERE WaitingForEventId IS NOT NULL
		WITH (ONLINE=ON, DATA_COMPRESSION=ROW, MAXDOP = 8);
END
GO


--Index is needed for table InteractionStudio.Q1RequestObject cleanup Job
IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('InteractionStudio.ActivityWaitQueue_temp') AND [name] = 'IX_Q1RequestObjectId_temp')
BEGIN
	CREATE NONCLUSTERED INDEX IX_Q1RequestObjectId_temp 
		ON InteractionStudio.ActivityWaitQueue_temp (Q1RequestObjectId)
		WITH (ONLINE=ON, DATA_COMPRESSION = ROW);
END
GO

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('InteractionStudio.ActivityWaitQueue_temp') 
				AND [name] = N'IX_ActivityWaitQueue_temp_ActivityId_WaitEndDate_MID_StatusFlags')
BEGIN
	CREATE NONCLUSTERED INDEX IX_ActivityWaitQueue_temp_ActivityId_WaitEndDate_MID_StatusFlags
		ON InteractionStudio.ActivityWaitQueue_temp(ActivityId, WaitEndDate, MID)
			INCLUDE (IsLocked, IsProcessed, IsActive)
		WITH (ONLINE=ON, DATA_COMPRESSION=ROW);
END
GO


IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID('InteractionStudio.ActivityWaitQueue_temp') 
				AND [name] = N'IX_ActivityWaitQueue_temp_StatusFlags_WaitEndDate_DefId_MID_INC_TimesP_ECLastChk_IsL_IsP_IsA_WFEventID_Status_Q1ReqObjId')
BEGIN
	CREATE NONCLUSTERED INDEX IX_ActivityWaitQueue_temp_StatusFlags_WaitEndDate_DefId_MID_INC_TimesP_ECLastChk_IsL_IsP_IsA_WFEventID_Status_Q1ReqObjId
		ON InteractionStudio.ActivityWaitQueue_temp(StatusFlags, WaitEndDate, DefinitionID, MID)
			INCLUDE (TimesProcessed, ExitCriteriaLastChecked, IsLocked, IsProcessed, IsActive, WaitingForEventId, [Status], Q1RequestObjectId, Q1RequestObjectIsOutOfRow,WaitType,WaitEndDatePrePause)
		WITH (ONLINE=ON, DATA_COMPRESSION=ROW, MAXDOP = 8);
END
GO


/*####################################################################
$$Table:   InteractionStudio.ActivityWaitQueue_temp
$$Author: Jithendra Renati
$$History:  
                    2021-10-22	JRenati	Temp table
#####################################################################*/
