BEGIN

	DELETE FROM InteractionStudio.RequestQueue;
	DELETE FROM InteractionStudio.ActivityWaitQueue;
	/*WITH
	L0 AS (SELECT 1 AS c UNION ALL SELECT 1),
	L1 AS (SELECT 1 AS c FROM L0 A CROSS JOIN L0 B),
	L2 AS (SELECT 1 AS c FROM L1 A CROSS JOIN L1 B),
	L3 AS (SELECT 1 AS c FROM L2 A CROSS JOIN L2 B),
	L4 AS (SELECT 1 AS c FROM L3 A CROSS JOIN L3),
	L5 AS (SELECT 1 AS c FROM L4 A CROSS JOIN L4),
	NUMS AS (SELECT 1 AS NUM FROM L5)   */
	INSERT INTO InteractionStudio.ActivityWaitQueue
	(DefinitionID, ActivityID, InstanceDefinitionID, InstanceActivityID, ContactID, ContactKey, ContactType,
	WaitStartDate, WaitEndDate, ProcessingID, IsProcessed, IsLocked, IsActive, [Status], CreateDate, ModifyDate,
	MID, EID, Q1RequestObjectId)
	SELECT TOP 10000000
		/*CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS INT) [ID]
	, CAST(t.RAND_VALUE AS INT) [OTHERKEY]
	, CAST(t.RAND_VALUE AS VARCHAR(100)) [DESCRIPTION]
	, CAST(GETDATE() AS DATETIME) [TIME]
	,*/t.DId AS DefinitionID
	,t.DId AS ActivityID
	, t.DefInsID AS InstanceDefinitionID
	, NEWID() AS InstanceActivityID
	,t.RAND_VALUE AS ContactID
	, CAST(t.RAND_VALUE AS VARCHAR(100)) AS ContactKey
	, 1 AS ContactType 
	, (GETDATE()) AS WaitStartDate
	, (GETDATE()+10) AS WaitEndDate
	, NEWID() AS ProcessingID
	,0 AS IsProcessed
	,0 AS IsLocked
	,1 AS IsActive
	,1 AS [Status]
	,GETDATE() AS CreateDate
	,GETDATE() AS ModifyDate
	, 13644 AS MID
	, 13644 AS EID
	, NEWID() AS ProcessingID
	FROM NUMS CROSS JOIN (SELECT ROUND(1000 * RAND(CHECKSUM(NEWID())), 0) RAND_VALUE, NEWID() AS DId, NEWID() AS AID, NEWID() AS DefInsID) t;

	INSERT INTO InteractionStudio.AsyncActivityResult
	(InstanceDefinitionID, MID, EID, ResultObject, ResultDate, FailedToExpireWaits, ModifiedDate)
	SELECT TOP 1000000
	InstanceDefinitionID, MID, EID, CAST('' AS VARBINARY) AS ResultObject,GETDATE() AS ResultDate,1 AS FailedToExpireWaits,GETDATE() ModifiedDate
	FROM InteractionStudio.ActivityWaitQueue (nolock);
END

--INSERT INTO InteractionStudio.ActivityWaitQueue

BEGIN
	DECLARE @Results GuidVarbinaryTable ;
	INSERT INTO @Results
	SELECT
		TOP 200
		DefInsID, CAST('' AS varbinary)
	FROM NUMS CROSS JOIN (SELECT ROUND(1000 * RAND(CHECKSUM(NEWID())), 0) RAND_VALUE, NEWID() AS DId, NEWID() AS AID, NEWID() AS DefInsID) t;

	EXEC [InteractionStudio].[AsyncActivityResultInsBatch]
	@MID =13644,
	@EID =13644,
	@Results =@Results;
END;

BEGIN
	DECLARE @InstanceDefinitionId AS UNIQUEIDENTIFIER;
	SELECT TOP 1 @InstanceDefinitionId  =InstanceDefinitionId FROM InteractionStudio.AsyncActivityResult (NOLOCK) ORDER BY NEWID();

EXEC [InteractionStudio].[AsyncActivityResultSel]
	@MID =13644,
	@InstanceDefinitionId =@InstanceDefinitionId ;

END;

EXEC [InteractionStudio].[AsyncActivityResultOrphanCleanup];

UPDATE TOP (100000) [InteractionStudio].[AsyncActivityResult]
SET ResultDate = GETDATE()-2