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

SET DEADLOCK_PRIORITY HIGH;

	DROP TABLE IF EXISTS #Q1RequestObjectIds ;
	DROP TABLE IF EXISTS #Q1RequestObject_Records ;

	CREATE TABLE #Q1RequestObjectIds 
	(
		Q1RequestObjectId	UNIQUEIDENTIFIER PRIMARY KEY
	);

	CREATE TABLE #Q1RequestObject_Records (
		Q1RequestObjectId				UNIQUEIDENTIFIER NOT NULL,
		Q1RequestObjectIsCompressed		BIT				NOT	NULL,
		Q1RequestObject					NVARCHAR(max)	NULL,	
		Q1RequestObjectCompressed		VARBINARY(max)	NULL,
		Q1RequestObjectCompressionLevel SMALLINT		NULL,
		Q1RequestObjectCompressedSize	BIGINT			NULL,	
		Q1RequestObjectOriginalSize		BIGINT			NULL,
		Q1RequestObjectCompressedHash	VARBINARY(16)	NULL,
		Q1RequestObjectOriginalHash		VARBINARY(16)	NULL,
		MID								BIGINT			NOT NULL,
		EID								BIGINT			NOT NULL,
		CreatedDate						DATETIME		NOT NULL,
		Q1RequestObjectSourceMachine	NVARCHAR(128)	NULL
	) WITH(DATA_COMPRESSION=ROW);

	/*---------Gather Q1RequestObjectId's-----------*/
	INSERT INTO #Q1RequestObjectIds
	SELECT Q1RequestObjectId FROM (
		SELECT Q1RequestObjectId FROM InteractionStudio.RequestQueue RQ WITH (NOLOCK)
		UNION
		SELECT Q1RequestObjectId FROM InteractionStudio.ActivityWaitQueue WITH (NOLOCK) WHERE StatusFlags=1 AND Q1RequestObjectId IS NOT NULL
		UNION
		SELECT Q1RequestObjectId FROM InteractionStudio.ActivityWaitQueue_Staging WITH (NOLOCK) WHERE Q1RequestObjectId IS NOT NULL
	) AS A;
	/*--------------------------------------------*/

	/*Get all Records from Q1RequestObject*/
	INSERT INTO #Q1RequestObject_Records
	SELECT 
		Q1.Q1RequestObjectId, Q1.Q1RequestObjectIsCompressed, Q1.Q1RequestObject, Q1.Q1RequestObjectCompressed, 
		Q1.Q1RequestObjectCompressionLevel, Q1.Q1RequestObjectCompressedSize, Q1.Q1RequestObjectOriginalSize, 
		Q1.Q1RequestObjectCompressedHash, Q1.Q1RequestObjectOriginalHash, Q1.MID, Q1.EID, Q1.CreatedDate, 
		Q1.Q1RequestObjectSourceMachine
	FROM #Q1RequestObjectIds Q1_TEMP WITH (NOLOCK)
	INNER JOIN InteractionStudio.Q1RequestObject Q1 WITH (NOLOCK) ON Q1.Q1RequestObjectId = Q1_TEMP.Q1RequestObjectId;

	BEGIN TRY
		WHILE EXISTS (SELECT TOP 1 NULL FROM #Q1RequestObject_Records)
		BEGIN
			INSERT INTO InteractionStudio.Q1RequestObject_temp
			(Q1RequestObjectId, Q1RequestObjectIsCompressed, Q1RequestObject, Q1RequestObjectCompressed, 
			Q1RequestObjectCompressionLevel, Q1RequestObjectCompressedSize, Q1RequestObjectOriginalSize, 
			Q1RequestObjectCompressedHash, Q1RequestObjectOriginalHash, MID, EID, CreatedDate, 
			Q1RequestObjectSourceMachine)
			SELECT
				Q1RequestObjectId, Q1RequestObjectIsCompressed, Q1RequestObject, Q1RequestObjectCompressed, 
				Q1RequestObjectCompressionLevel, Q1RequestObjectCompressedSize, Q1RequestObjectOriginalSize, 
				Q1RequestObjectCompressedHash, Q1RequestObjectOriginalHash, MID, EID, CreatedDate, 
				Q1RequestObjectSourceMachine
			FROM (
				DELETE TOP (10000) 
				FROM #Q1RequestObject_Records
				OUTPUT 
				deleted.Q1RequestObjectId, deleted.Q1RequestObjectIsCompressed, deleted.Q1RequestObject, deleted.Q1RequestObjectCompressed, 
				deleted.Q1RequestObjectCompressionLevel, deleted.Q1RequestObjectCompressedSize, deleted.Q1RequestObjectOriginalSize, 
				deleted.Q1RequestObjectCompressedHash, deleted.Q1RequestObjectOriginalHash, deleted.MID, deleted.EID, deleted.CreatedDate, 
				deleted.Q1RequestObjectSourceMachine
			) AS A;
		END
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH;
	GO
/*####################################################################
$$Sproc:  Copy active records Q1RequestObject to _temp table
$$Author: Jithendra Renati
$$History:  
			2021-10-27 - JRenati	Created
#####################################################################*/