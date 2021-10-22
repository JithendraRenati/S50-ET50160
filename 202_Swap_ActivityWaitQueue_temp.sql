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


IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'ActivityWaitQueue_temp' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'ActivityWaitQueue_temp does not exist', 1;
	RETURN;
END;

IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'ActivityWaitQueue' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'ActivityWaitQueue does not exist', 1;
	RETURN;
END;

DECLARE @max_QueueId BIGINT = 1;
SELECT @max_QueueId = IDENT_CURRENT ('InteractionStudio.ActivityWaitQueue');
SELECT @max_QueueId = ISNULL(@max_QueueId, 1) + 1000000;			-- + 1M for safety to avoid collission
	
DBCC CHECKIDENT ('InteractionStudio.ActivityWaitQueue_temp', RESEED, @max_QueueId);

EXEC sp_rename 'InteractionStudio.ActivityWaitQueue' , 'ActivityWaitQueue_old';
EXEC sp_rename 'InteractionStudio.ActivityWaitQueue_temp' , 'ActivityWaitQueue';

IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'ActivityWaitQueue_old' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'ActivityWaitQueue_old does not exist', 1;
	RETURN;
END;

IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = N'ActivityWaitQueue' AND schema_id = SCHEMA_ID(N'InteractionStudio'))
BEGIN;
	THROW 60000, 'ActivityWaitQueue does not exist', 1;
	RETURN;
END;

/*####################################################################
$$Sproc:  Swap AWQ table with a temp table and rename 
$$Author: Varun Batra
$$History:  
			2021-10-22 - JRenati	Created
#####################################################################*/