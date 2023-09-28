# Database Troubleshoot

Database Configurations

| Service Tier | Compute Tier | Hardware Config | Max vCores | Memory | Notes |
|--------------|--------------|-----------------|------------|------------|-------|
| General Purpose | Serverless | Standard-series (Gen5) | 16 | 6GB Min, 48G Max | Queries use Row execution mode and fail to use column index. Takes over 10hr to Summarize 30 days.|
| Premium |  | DTU 500 |  |  | Queries use Batch execution mode and column index. Takes about 30min to Summarize 15 days. <br> Data Facotry Ingest Job transfers @ 5.8 MB/s with CPU at 100%. ~30min for Two Files: Actuals 12.81 GB, Amortized 12.83 GB.  |
| Business VCore Business Critical: Standard-series (Gen5), 12 vCores | | | | | Able to load 4 files in parallel at 11.017 MB/s |
| Business VCOre Business Critical: Standard-serries (Gen5), 2 vCore | | | | | Runs out of tempdb sapce on `UpdateActualCostSummaryTable` for 2month period |


## General Table Info

```sql

-- Calculates the size of the database.
SELECT SUM(CAST(FILEPROPERTY(name, 'SpaceUsed') AS bigint) * 8192.) / 1024 / 1024 AS DatabaseSizeInMB
, SUM(CAST(FILEPROPERTY(name, 'SpaceUsed') AS bigint) * 8192.) / 1024 / 1024 / 1024 AS DatabaseSizeInGB
FROM sys.database_files
WHERE type_desc = 'ROWS';
GO

/**********************
DB Shrink
***********************/

-- Check Log Sizes
DBCC SQLPERF(LOGSPACE)
GO
-- Check if can shrink DB
SELECT  name ,
    log_reuse_wait ,
    log_reuse_wait_desc
FROM sys.databases AS D
GO
-- Shrink DB
-- DBCC SHRINKDATABASE (0);

-- Display Space Used by Table
SELECT
  t.object_id,
  OBJECT_NAME(t.object_id) ObjectName,
  sum(u.total_pages) * 8 Total_Reserved_kb,
  sum(u.used_pages) * 8 Used_Space_kb,
  u.type_desc,
  max(p.rows) RowsCount
FROM
  sys.allocation_units u
  JOIN sys.partitions p on u.container_id = p.hobt_id
  JOIN sys.tables t on p.object_id = t.object_id
GROUP BY
  t.object_id,
  OBJECT_NAME(t.object_id),
  u.type_desc
ORDER BY
  Used_Space_kb desc,
  ObjectName;
GO

-- Show row count, size of data and index
sp_spaceused 'costmanagement.ActualCost';
GO
sp_spaceused 'costmanagement.AmortizedCost';
GO
sp_spaceused 'costmanagement.ActualCostSummary';
GO
sp_spaceused 'costmanagement.AmortizedCostSummary';
GO

select min(date) as min_date, max(date) as max_date from [costmanagement].[ActualCost];
GO
select min(date) as min_date, max(date) as max_date from [costmanagement].[ActualCostSummary];
GO
select min(date) as min_date, max(date) as max_date from [costmanagement].[AmortizedCost];
GO
select min(date) as min_date, max(date) as max_date from [costmanagement].[AmortizedCostSummary];
GO

-- Show cost per month
select DATEADD(month, DATEDIFF(month, 0, [Date]), 0) AS StartOfMonth, sum(CostInBillingCurrency) from [costmanagement].[ActualCost] group by DATEADD(month, DATEDIFF(month, 0, [Date]), 0) order by StartOfMonth
GO
select DATEADD(month, DATEDIFF(month, 0, [Date]), 0) AS StartOfMonth, sum(CostInBillingCurrency) from [costmanagement].[ActualCostSummary] group by DATEADD(month, DATEDIFF(month, 0, [Date]), 0) order by StartOfMonth
GO
select DATEADD(month, DATEDIFF(month, 0, [Date]), 0) AS StartOfMonth, sum(CostInBillingCurrency) from [costmanagement].[ActualCost_Last_30_days] group by DATEADD(month, DATEDIFF(month, 0, [Date]), 0) order by StartOfMonth
GO
select DATEADD(month, DATEDIFF(month, 0, [Date]), 0) AS StartOfMonth, sum(CostInBillingCurrency) from [costmanagement].[AmortizedCost] group by DATEADD(month, DATEDIFF(month, 0, [Date]), 0) order by StartOfMonth
GO
select DATEADD(month, DATEDIFF(month, 0, [Date]), 0) AS StartOfMonth, sum(CostInBillingCurrency) from [costmanagement].[AmortizedCostSummary] group by DATEADD(month, DATEDIFF(month, 0, [Date]), 0) order by StartOfMonth
GO
select DATEADD(month, DATEDIFF(month, 0, [Date]), 0) AS StartOfMonth, sum(CostInBillingCurrency) from [costmanagement].[AmortizedCost_Last_30_days] group by DATEADD(month, DATEDIFF(month, 0, [Date]), 0) order by StartOfMonth
GO
```

## Monitoring and Tuning

## Check Conditions

Query system resources on the Database and server.

```sql

-- Show the resource limits on the server
SELECT *
FROM sys.dm_user_db_resource_governance
ORDER BY database_name;

-- Monitor resource use
USE <replace with database>
GO
SELECT
    AVG(avg_cpu_percent) AS 'Average CPU use in percent',
    MAX(avg_cpu_percent) AS 'Maximum CPU use in percent',
    AVG(avg_data_io_percent) AS 'Average data IO in percent',
    MAX(avg_data_io_percent) AS 'Maximum data IO in percent',
    AVG(avg_log_write_percent) AS 'Average log write use in percent',
    MAX(avg_log_write_percent) AS 'Maximum log write use in percent',
    AVG(avg_memory_usage_percent) AS 'Average memory use in percent',
    MAX(avg_memory_usage_percent) AS 'Maximum memory use in percent'
FROM sys.dm_db_resource_stats;
GO



-- The sys.resource_stats view in the master database has additional information
-- that can help you monitor the performance of your database at its specific
-- service tier and compute size.
USE master
GO
SELECT TOP 10
	start_time
	, end_time
	, database_name
	, sku
	, storage_in_megabytes
	, CAST(storage_in_megabytes as bigint) / 1024 as storage_in_gigabyte
	, avg_cpu_percent
	, avg_data_io_percent
	, avg_log_write_percent
	, max_worker_percent
	, max_session_percent
	, dtu_limit
	, xtp_storage_percent
	, avg_login_rate_percent
	, avg_instance_cpu_percent
	, avg_instance_memory_percent
	, cpu_limit
	, allocated_storage_in_megabytes
	, CAST(allocated_storage_in_megabytes as bigint) / 1024 as allocated_storage_in_gigabytes
FROM sys.resource_stats
WHERE database_name = '<REPLACE_WITH_DB_NAME>'
ORDER BY start_time DESC;

-- Ave CPU over last 1 hour
USE master
GO
DECLARE @s datetime;
DECLARE @e datetime;
SET @s= DateAdd(hh,-1,GetUTCDate());
SET @e= GETUTCDATE();

SELECT database_name, AVG(avg_cpu_percent) AS Average_CPU_Utilization
FROM sys.resource_stats
WHERE start_time BETWEEN @s AND @e
GROUP BY database_name
GO
```

## CPU Performance

If CPU consumption is above 80% for extended periods of time, consider the following troubleshooting steps:

If issue is occurring right now, there are two possible scenarios:
- Many individual queries that cumulatively consume high CPU
- Long running queries that consume CPU are still running

```sql
-- Many Individual Queries
PRINT '-- top 10 Active CPU Consuming Queries (aggregated)--';
SELECT TOP 10 GETDATE() runtime, *
FROM (SELECT query_stats.query_hash, SUM(query_stats.cpu_time) 'Total_Request_Cpu_Time_Ms', SUM(logical_reads) 'Total_Request_Logical_Reads', MIN(start_time) 'Earliest_Request_start_Time', COUNT(*) 'Number_Of_Requests', SUBSTRING(REPLACE(REPLACE(MIN(query_stats.statement_text), CHAR(10), ' '), CHAR(13), ' '), 1, 256) AS "Statement_Text"
    FROM (SELECT req.*, SUBSTRING(ST.text, (req.statement_start_offset / 2)+1, ((CASE statement_end_offset WHEN -1 THEN DATALENGTH(ST.text)ELSE req.statement_end_offset END-req.statement_start_offset)/ 2)+1) AS statement_text
          FROM sys.dm_exec_requests AS req
                CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS ST ) AS query_stats
    GROUP BY query_hash) AS t
ORDER BY Total_Request_Cpu_Time_Ms DESC;

-- Long Running Queries
PRINT '--top 10 Active CPU Consuming Queries by sessions--';
SELECT TOP 10
  req.session_id
  , req.start_time
  , cpu_time 'cpu_time_ms'
  , OBJECT_NAME(ST.objectid, ST.dbid) 'ObjectName'
  , SUBSTRING(REPLACE(REPLACE(SUBSTRING(ST.text, (req.statement_start_offset / 2)+1, ((CASE statement_end_offset WHEN -1 THEN DATALENGTH(ST.text)ELSE req.statement_end_offset END-req.statement_start_offset)/ 2)+1), CHAR(10), ' '), CHAR(13), ' '), 1, 512) AS statement_text
FROM sys.dm_exec_requests AS req
    CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) AS ST
ORDER BY cpu_time DESC;
GO

```

If the issue occurred in the past and you want to do root cause analysis, use Query Store. Users with database access can use T-SQL to query Query Store data. Query Store default configurations use a granularity of 1 hour. Use the following query to look at activity for high CPU consuming queries. This query returns the top 15 CPU consuming queries. Remember to change `rsi.start_time >= DATEADD(hour, -2, GETUTCDATE()`:

```sql
-- Top 15 CPU consuming queries by query hash
-- note that a query  hash can have many query id if not parameterized or not parameterized properly
-- it grabs a sample query text by min
WITH AggregatedCPU AS (SELECT q.query_hash, SUM(count_executions * avg_cpu_time / 1000.0) AS total_cpu_millisec, SUM(count_executions * avg_cpu_time / 1000.0)/ SUM(count_executions) AS avg_cpu_millisec, MAX(rs.max_cpu_time / 1000.00) AS max_cpu_millisec, MAX(max_logical_io_reads) max_logical_reads, COUNT(DISTINCT p.plan_id) AS number_of_distinct_plans, COUNT(DISTINCT p.query_id) AS number_of_distinct_query_ids, SUM(CASE WHEN rs.execution_type_desc='Aborted' THEN count_executions ELSE 0 END) AS Aborted_Execution_Count, SUM(CASE WHEN rs.execution_type_desc='Regular' THEN count_executions ELSE 0 END) AS Regular_Execution_Count, SUM(CASE WHEN rs.execution_type_desc='Exception' THEN count_executions ELSE 0 END) AS Exception_Execution_Count, SUM(count_executions) AS total_executions, MIN(qt.query_sql_text) AS sampled_query_text
                       FROM sys.query_store_query_text AS qt
                            JOIN sys.query_store_query AS q ON qt.query_text_id=q.query_text_id
                            JOIN sys.query_store_plan AS p ON q.query_id=p.query_id
                            JOIN sys.query_store_runtime_stats AS rs ON rs.plan_id=p.plan_id
                            JOIN sys.query_store_runtime_stats_interval AS rsi ON rsi.runtime_stats_interval_id=rs.runtime_stats_interval_id
                       WHERE rs.execution_type_desc IN ('Regular', 'Aborted', 'Exception')AND rsi.start_time>=DATEADD(HOUR, -2, GETUTCDATE())
                       GROUP BY q.query_hash), OrderedCPU AS (SELECT query_hash, total_cpu_millisec, avg_cpu_millisec, max_cpu_millisec, max_logical_reads, number_of_distinct_plans, number_of_distinct_query_ids, total_executions, Aborted_Execution_Count, Regular_Execution_Count, Exception_Execution_Count, sampled_query_text, ROW_NUMBER() OVER (ORDER BY total_cpu_millisec DESC, query_hash ASC) AS RN
                                                              FROM AggregatedCPU)
SELECT OD.query_hash, OD.total_cpu_millisec, OD.avg_cpu_millisec, OD.max_cpu_millisec, OD.max_logical_reads, OD.number_of_distinct_plans, OD.number_of_distinct_query_ids, OD.total_executions, OD.Aborted_Execution_Count, OD.Regular_Execution_Count, OD.Exception_Execution_Count, OD.sampled_query_text, OD.RN
FROM OrderedCPU AS OD
WHERE OD.RN<=15
ORDER BY total_cpu_millisec DESC;
```

Find currently running queries with CPU usage and execution plans by executing the following query. CPU time is returned in milliseconds.

```sql
SELECT
    req.session_id,
    req.status,
    req.start_time,
    req.cpu_time AS 'cpu_time_ms',
    req.logical_reads,
    req.dop,
    s.login_name,
    s.host_name,
    s.program_name,
    object_name(st.objectid,st.dbid) 'ObjectName',
    REPLACE (REPLACE (SUBSTRING (st.text,(req.statement_start_offset/2) + 1,
        ((CASE req.statement_end_offset    WHEN -1    THEN DATALENGTH(st.text)
        ELSE req.statement_end_offset END - req.statement_start_offset)/2) + 1),
        CHAR(10), ' '), CHAR(13), ' ') AS statement_text,
    qp.query_plan,
    qsx.query_plan as query_plan_with_in_flight_statistics
FROM sys.dm_exec_requests as req
JOIN sys.dm_exec_sessions as s on req.session_id=s.session_id
CROSS APPLY sys.dm_exec_sql_text(req.sql_handle) as st
OUTER APPLY sys.dm_exec_query_plan(req.plan_handle) as qp
OUTER APPLY sys.dm_exec_query_statistics_xml(req.session_id) as qsx
ORDER BY req.cpu_time desc;
GO
```

Once you identify the problematic queries, it's time to tune those queries to reduce CPU utilization. If you don't have time to tune the queries, you may also choose to upgrade the SLO of the database to work around the issue.

For more information about handling CPU performance problems in Azure SQL Database, see [Diagnose and troubleshoot high CPU on Azure SQL Database](https://learn.microsoft.com/en-us/azure/azure-sql/database/high-cpu-diagnose-troubleshoot?view=azuresql).

## Define slow I/O performance

Performance monitor counters are used to determine slow I/O performance. These counters measure how fast the I/O subsystem services each I/O request on average in terms of clock time. The specific [Performance monitor](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/perfmon) counters that measure I/O latency in Windows are `Avg Disk sec/ Read`, `Avg. Disk sec/Write`, and `Avg. Disk sec/Transfer` (cumulative of both reads and writes).

In SQL Server, things work the same way. Commonly, you look at whether SQL Server reports any I/O bottlenecks measured in clock time (milliseconds). SQL Server makes I/O requests to the OS by calling the Win32 functions such as `WriteFile()`, `ReadFile()`, `WriteFileGather()`, and `ReadFileScatter()`. When it posts an I/O request, SQL Server times the request and reports the duration of the request using [wait types](https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-wait-stats-transact-sql?view=sql-server-ver16). SQL Server uses wait types to indicate I/O waits at different places in the product. The I/O related waits are:

- PAGEIOLATCH_SH / PAGEIOLATCH_EX
- WRITELOG
- IO_COMPLETION
- ASYNC_IO_COMPLETION
- BACKUPIO

If these waits exceed 10-15 milliseconds consistently, I/O is considered a bottleneck.

## Methodology

1) Is SQL Server reporting slow I/O?
2) Do Perfmon Counters indicate I/O latency


###  Is SQL Server reporting slow I/O?

SQL Server may report I/O latency in several ways:

- I/O wait types
- DMV sys.dm_db_resource_stats
- Error log or Application Event log

**I/O wait types**

Determine if there's I/O latency reported by SQL Server wait types. The values `PAGEIOLATCH_*`, `WRITELOG`, and `ASYNC_IO_COMPLETION` and the values of several other less common wait types should generally stay below 10-15 milliseconds per I/O request. If these values are greater consistently, an I/O performance problem exists and requires further investigation. The following query may help you gather this diagnostic information on your system:

```sql
DECLARE @Counter INT
DECLARE @MSG VARCHAR(200)
DECLARE @WAIT_TYPE VARCHAR(30)
DECLARE @WAIT_TIME INT
SET @Counter=1
WHILE ( @Counter <= 10)
BEGIN

  SET @Counter  = @Counter  + 1

	SELECT @WAIT_TYPE = a.wait_type, @WAIT_TIME = a.wait_time_ms
	from (
		SELECT
		r.session_id, r.wait_type, r.wait_time as wait_time_ms
		FROM sys.dm_exec_requests as r
		JOIN sys.dm_exec_sessions as s
		ON r.session_id = s.session_id
		WHERE wait_type in ('PAGEIOLATCH_SH', 'PAGEIOLATCH_EX', 'WRITELOG', 'IO_COMPLETION', 'ASYNC_IO_COMPLETION', 'BACKUPIO')
		AND is_user_process = 1
	) as a

	SELECT @Msg = @WAIT_TYPE + ' waitTime: ' + CAST(@WAIT_TIME AS VARCHAR(10))
	RAISERROR (@Msg, 0, 1) WITH NOWAIT

	WAITFOR DELAY '00:00:02';

END
```

**File stats in sys.dm_db_resource_stats**

Use the following query to identify data and log IO usage. If the data or log IO is above 80%, it means users have used the available IO for the Azure SQL Database service tier.

```sql
SELECT
  max(avg_data_io_percent) as max_avg_data_io_percent
  , max(avg_log_write_percent) as max_avg_log_write_percent
FROM sys.dm_db_resource_stats;
GO

SELECT end_time, avg_data_io_percent, avg_log_write_percent
FROM sys.dm_db_resource_stats
ORDER BY end_time DESC;
GO
```

If the IO limit has been reached, you have two options:

- Option 1: Upgrade the compute size or service tier
- Option 2: Identify and tune the queries consuming the most IO.

For option 2, you can use the following query against Query Store for buffer-related IO to view the last two hours of tracked activity:

```sql
-- top queries that waited on buffer
-- note these are finished queries
WITH Aggregated AS (
  SELECT q.query_hash, SUM(total_query_wait_time_ms) total_wait_time_ms, SUM(total_query_wait_time_ms / avg_query_wait_time_ms) AS total_executions, MIN(qt.query_sql_text) AS sampled_query_text, MIN(wait_category_desc) AS wait_category_desc
  FROM sys.query_store_query_text AS qt
        JOIN sys.query_store_query AS q ON qt.query_text_id=q.query_text_id
        JOIN sys.query_store_plan AS p ON q.query_id=p.query_id
        JOIN sys.query_store_wait_stats AS waits ON waits.plan_id=p.plan_id
        JOIN sys.query_store_runtime_stats_interval AS rsi ON rsi.runtime_stats_interval_id=waits.runtime_stats_interval_id
  WHERE wait_category_desc='Buffer IO' AND rsi.start_time>=DATEADD(HOUR, -2, GETUTCDATE())
  GROUP BY q.query_hash), Ordered AS (
    SELECT query_hash, total_executions, total_wait_time_ms, sampled_query_text, wait_category_desc, ROW_NUMBER() OVER (ORDER BY total_wait_time_ms DESC, query_hash ASC) AS RN
    FROM Aggregated)

SELECT OD.query_hash, OD.total_executions, OD.total_wait_time_ms, OD.sampled_query_text, OD.wait_category_desc, OD.RN
FROM Ordered AS OD
WHERE OD.RN<=15
ORDER BY total_wait_time_ms DESC;
GO
```

If the wait type is `WRITELOG`, use the following query to view total log IO by statement:

```sql
-- Top transaction log consumers
-- Adjust the time window by changing
-- rsi.start_time >= DATEADD(hour, -2, GETUTCDATE())
WITH AggregatedLogUsed
AS (SELECT q.query_hash,
           SUM(count_executions * avg_cpu_time / 1000.0) AS total_cpu_millisec,
           SUM(count_executions * avg_cpu_time / 1000.0) / SUM(count_executions) AS avg_cpu_millisec,
           SUM(count_executions * avg_log_bytes_used) AS total_log_bytes_used,
           MAX(rs.max_cpu_time / 1000.00) AS max_cpu_millisec,
           MAX(max_logical_io_reads) max_logical_reads,
           COUNT(DISTINCT p.plan_id) AS number_of_distinct_plans,
           COUNT(DISTINCT p.query_id) AS number_of_distinct_query_ids,
           SUM(   CASE
                      WHEN rs.execution_type_desc = 'Aborted' THEN
                          count_executions
                      ELSE
                          0
                  END
              ) AS Aborted_Execution_Count,
           SUM(   CASE
                      WHEN rs.execution_type_desc = 'Regular' THEN
                          count_executions
                      ELSE
                          0
                  END
              ) AS Regular_Execution_Count,
           SUM(   CASE
                      WHEN rs.execution_type_desc = 'Exception' THEN
                          count_executions
                      ELSE
                          0
                  END
              ) AS Exception_Execution_Count,
           SUM(count_executions) AS total_executions,
           MIN(qt.query_sql_text) AS sampled_query_text
    FROM sys.query_store_query_text AS qt
        JOIN sys.query_store_query AS q
            ON qt.query_text_id = q.query_text_id
        JOIN sys.query_store_plan AS p
            ON q.query_id = p.query_id
        JOIN sys.query_store_runtime_stats AS rs
            ON rs.plan_id = p.plan_id
        JOIN sys.query_store_runtime_stats_interval AS rsi
            ON rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
    WHERE rs.execution_type_desc IN ( 'Regular', 'Aborted', 'Exception' )
          AND rsi.start_time >= DATEADD(HOUR, -2, GETUTCDATE())
    GROUP BY q.query_hash),
     OrderedLogUsed
AS (SELECT query_hash,
           total_log_bytes_used,
           number_of_distinct_plans,
           number_of_distinct_query_ids,
           total_executions,
           Aborted_Execution_Count,
           Regular_Execution_Count,
           Exception_Execution_Count,
           sampled_query_text,
           ROW_NUMBER() OVER (ORDER BY total_log_bytes_used DESC, query_hash ASC) AS RN
    FROM AggregatedLogUsed)
SELECT OD.total_log_bytes_used,
       OD.number_of_distinct_plans,
       OD.number_of_distinct_query_ids,
       OD.total_executions,
       OD.Aborted_Execution_Count,
       OD.Regular_Execution_Count,
       OD.Exception_Execution_Count,
       OD.sampled_query_text,
       OD.RN
FROM OrderedLogUsed AS OD
WHERE OD.RN <= 15
ORDER BY total_log_bytes_used DESC;
GO
```

**Error Log**

Query the sys.event_log

```sql
SELECT database_name, start_time, end_time, event_category,
	event_type, event_subtype, event_subtype_desc, severity,
	event_count, description
FROM sys.event_log
WHERE start_time >= DATEADD(day,-3,GETDATE())
    AND end_time <= GETDATE();
GO
```

###  Do Counters indicate I/O latency?

Check Azure Portal

```sql
SELECT * FROM sys.dm_user_db_resource_governance
GO

-- Check resource_stats. Ave CPU over last 3 hours
DECLARE @s datetime;
DECLARE @e datetime;
SET @s= DateAdd(hh,-3,GetUTCDate());
SET @e= GETUTCDATE();

SELECT database_name, AVG(avg_cpu_percent) AS Average_CPU_Utilization
FROM sys.resource_stats
WHERE start_time BETWEEN @s AND @e
GROUP BY database_name
GO
```

### Causes

Query issues: SQL Server is saturating disk volumes with I/O requests and is pushing the I/O subsystem beyond capacity, which causes I/O transfer rates to be high. In this case, the solution is to find the queries that are causing a high number of logical reads (or writes) and tune those queries to minimize disk I/O-using appropriate indexes is the first step to do that. Also, keep statistics updated as they provide the query optimizer with sufficient information to choose the best plan. Also, incorrect database design and query design can lead to an increase in I/O issues. Therefore, redesigning queries and sometimes tables may help with improved I/O.

* Tune Queries
* Increase Memory
* Stagger Backups
* Autogrow Checkpoint


***Identify ***
```sql

-- sp_WhoIsACtive to Monitor Activity
EXECUTE [dbo].[sp_WhoIsActive]
  @show_sleeping_spids = 1
  , @show_system_spids = 0
  , @show_own_spid = 0
  , @get_full_inner_text = 0
  , @get_plans = 1
GO

/**************************
* Show Query Performance
**************************/

-- Information about the top five queries ranked by average CPU time.
SELECT TOP 5 query_stats.query_hash AS "Query Hash",
    SUM(query_stats.total_worker_time) / SUM(query_stats.execution_count) AS "Avg CPU Time",
     MIN(query_stats.statement_text) AS "Statement Text"
FROM
    (SELECT QS.*,
        SUBSTRING(ST.text, (QS.statement_start_offset/2) + 1,
            ((CASE statement_end_offset
                WHEN -1 THEN DATALENGTH(ST.text)
                ELSE QS.statement_end_offset END
            - QS.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats AS QS
CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) as ST) as query_stats
GROUP BY query_stats.query_hash
ORDER BY 2 DESC;
GO

-- Check
Select * from sys.dm_exec_requests where status NOT IN ('sleeping', 'background') order by status;
GO

SELECT * FROM sys.dm_exec_sql_text(<sql_handle>);
GO

-- Check where the database is waiting

WITH Waits AS
 (
 SELECT
   wait_type,
   wait_time_ms / 1000. AS wait_time_s,
   100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
   ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
 FROM sys.dm_db_wait_stats
 WHERE wait_type
   NOT IN
     ('CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE',
   'SLEEP_TASK', 'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR',
   'CLR_AUTO_EVENT', 'CLR_MANUAL_EVENT')
   ) -- filter out additional irrelevant waits

SELECT W1.wait_type,
 CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s,
 CAST(W1.pct AS DECIMAL(12, 2)) AS pct,
 CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
FROM Waits AS W1
 INNER JOIN Waits AS W2 ON W2.rn <= W1.rn
GROUP BY W1.rn,
 W1.wait_type,
 W1.wait_time_s,
 W1.pct
HAVING SUM(W2.pct) - W1.pct < 95; -- percentage threshold;




-- Different query to see wait stats. Last updated October 1, 2021
WITH [Waits] AS
    (SELECT
        [wait_type],
        [wait_time_ms] / 1000.0 AS [WaitS],
        ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
        [signal_wait_time_ms] / 1000.0 AS [SignalS],
        [waiting_tasks_count] AS [WaitCount],
        100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
        ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
    FROM sys.dm_db_wait_stats
    WHERE [wait_type] NOT IN (
        -- These wait types are almost 100% never a problem and so they are
        -- filtered out to avoid them skewing the results. Click on the URL
        -- for more information.
        N'BROKER_EVENTHANDLER', -- https://www.sqlskills.com/help/waits/BROKER_EVENTHANDLER
        N'BROKER_RECEIVE_WAITFOR', -- https://www.sqlskills.com/help/waits/BROKER_RECEIVE_WAITFOR
        N'BROKER_TASK_STOP', -- https://www.sqlskills.com/help/waits/BROKER_TASK_STOP
        N'BROKER_TO_FLUSH', -- https://www.sqlskills.com/help/waits/BROKER_TO_FLUSH
        N'BROKER_TRANSMITTER', -- https://www.sqlskills.com/help/waits/BROKER_TRANSMITTER
        N'CHECKPOINT_QUEUE', -- https://www.sqlskills.com/help/waits/CHECKPOINT_QUEUE
        N'CHKPT', -- https://www.sqlskills.com/help/waits/CHKPT
        N'CLR_AUTO_EVENT', -- https://www.sqlskills.com/help/waits/CLR_AUTO_EVENT
        N'CLR_MANUAL_EVENT', -- https://www.sqlskills.com/help/waits/CLR_MANUAL_EVENT
        N'CLR_SEMAPHORE', -- https://www.sqlskills.com/help/waits/CLR_SEMAPHORE

        -- Maybe comment this out if you have parallelism issues
        N'CXCONSUMER', -- https://www.sqlskills.com/help/waits/CXCONSUMER

        -- Maybe comment these four out if you have mirroring issues
        N'DBMIRROR_DBM_EVENT', -- https://www.sqlskills.com/help/waits/DBMIRROR_DBM_EVENT
        N'DBMIRROR_EVENTS_QUEUE', -- https://www.sqlskills.com/help/waits/DBMIRROR_EVENTS_QUEUE
        N'DBMIRROR_WORKER_QUEUE', -- https://www.sqlskills.com/help/waits/DBMIRROR_WORKER_QUEUE
        N'DBMIRRORING_CMD', -- https://www.sqlskills.com/help/waits/DBMIRRORING_CMD
        N'DIRTY_PAGE_POLL', -- https://www.sqlskills.com/help/waits/DIRTY_PAGE_POLL
        N'DISPATCHER_QUEUE_SEMAPHORE', -- https://www.sqlskills.com/help/waits/DISPATCHER_QUEUE_SEMAPHORE
        N'EXECSYNC', -- https://www.sqlskills.com/help/waits/EXECSYNC
        N'FSAGENT', -- https://www.sqlskills.com/help/waits/FSAGENT
        N'FT_IFTS_SCHEDULER_IDLE_WAIT', -- https://www.sqlskills.com/help/waits/FT_IFTS_SCHEDULER_IDLE_WAIT
        N'FT_IFTSHC_MUTEX', -- https://www.sqlskills.com/help/waits/FT_IFTSHC_MUTEX

       -- Maybe comment these six out if you have AG issues
        N'HADR_CLUSAPI_CALL', -- https://www.sqlskills.com/help/waits/HADR_CLUSAPI_CALL
        N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', -- https://www.sqlskills.com/help/waits/HADR_FILESTREAM_IOMGR_IOCOMPLETION
        N'HADR_LOGCAPTURE_WAIT', -- https://www.sqlskills.com/help/waits/HADR_LOGCAPTURE_WAIT
        N'HADR_NOTIFICATION_DEQUEUE', -- https://www.sqlskills.com/help/waits/HADR_NOTIFICATION_DEQUEUE
        N'HADR_TIMER_TASK', -- https://www.sqlskills.com/help/waits/HADR_TIMER_TASK
        N'HADR_WORK_QUEUE', -- https://www.sqlskills.com/help/waits/HADR_WORK_QUEUE

        N'KSOURCE_WAKEUP', -- https://www.sqlskills.com/help/waits/KSOURCE_WAKEUP
        N'LAZYWRITER_SLEEP', -- https://www.sqlskills.com/help/waits/LAZYWRITER_SLEEP
        N'LOGMGR_QUEUE', -- https://www.sqlskills.com/help/waits/LOGMGR_QUEUE
        N'MEMORY_ALLOCATION_EXT', -- https://www.sqlskills.com/help/waits/MEMORY_ALLOCATION_EXT
        N'ONDEMAND_TASK_QUEUE', -- https://www.sqlskills.com/help/waits/ONDEMAND_TASK_QUEUE
        N'PARALLEL_REDO_DRAIN_WORKER', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_DRAIN_WORKER
        N'PARALLEL_REDO_LOG_CACHE', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_LOG_CACHE
        N'PARALLEL_REDO_TRAN_LIST', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_TRAN_LIST
        N'PARALLEL_REDO_WORKER_SYNC', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_WORKER_SYNC
        N'PARALLEL_REDO_WORKER_WAIT_WORK', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_WORKER_WAIT_WORK
        N'PREEMPTIVE_OS_FLUSHFILEBUFFERS', -- https://www.sqlskills.com/help/waits/PREEMPTIVE_OS_FLUSHFILEBUFFERS
        N'PREEMPTIVE_XE_GETTARGETSTATE', -- https://www.sqlskills.com/help/waits/PREEMPTIVE_XE_GETTARGETSTATE
        N'PVS_PREALLOCATE', -- https://www.sqlskills.com/help/waits/PVS_PREALLOCATE
        N'PWAIT_ALL_COMPONENTS_INITIALIZED', -- https://www.sqlskills.com/help/waits/PWAIT_ALL_COMPONENTS_INITIALIZED
        N'PWAIT_DIRECTLOGCONSUMER_GETNEXT', -- https://www.sqlskills.com/help/waits/PWAIT_DIRECTLOGCONSUMER_GETNEXT
        N'PWAIT_EXTENSIBILITY_CLEANUP_TASK', -- https://www.sqlskills.com/help/waits/PWAIT_EXTENSIBILITY_CLEANUP_TASK
        N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', -- https://www.sqlskills.com/help/waits/QDS_PERSIST_TASK_MAIN_LOOP_SLEEP
        N'QDS_ASYNC_QUEUE', -- https://www.sqlskills.com/help/waits/QDS_ASYNC_QUEUE
        N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
            -- https://www.sqlskills.com/help/waits/QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP
        N'QDS_SHUTDOWN_QUEUE', -- https://www.sqlskills.com/help/waits/QDS_SHUTDOWN_QUEUE
        N'REDO_THREAD_PENDING_WORK', -- https://www.sqlskills.com/help/waits/REDO_THREAD_PENDING_WORK
        N'REQUEST_FOR_DEADLOCK_SEARCH', -- https://www.sqlskills.com/help/waits/REQUEST_FOR_DEADLOCK_SEARCH
        N'RESOURCE_QUEUE', -- https://www.sqlskills.com/help/waits/RESOURCE_QUEUE
        N'SERVER_IDLE_CHECK', -- https://www.sqlskills.com/help/waits/SERVER_IDLE_CHECK
        N'SLEEP_BPOOL_FLUSH', -- https://www.sqlskills.com/help/waits/SLEEP_BPOOL_FLUSH
        N'SLEEP_DBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_DBSTARTUP
        N'SLEEP_DCOMSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_DCOMSTARTUP
        N'SLEEP_MASTERDBREADY', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERDBREADY
        N'SLEEP_MASTERMDREADY', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERMDREADY
        N'SLEEP_MASTERUPGRADED', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERUPGRADED
        N'SLEEP_MSDBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_MSDBSTARTUP
        N'SLEEP_SYSTEMTASK', -- https://www.sqlskills.com/help/waits/SLEEP_SYSTEMTASK
        N'SLEEP_TASK', -- https://www.sqlskills.com/help/waits/SLEEP_TASK
        N'SLEEP_TEMPDBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_TEMPDBSTARTUP
        N'SNI_HTTP_ACCEPT', -- https://www.sqlskills.com/help/waits/SNI_HTTP_ACCEPT
        N'SOS_WORK_DISPATCHER', -- https://www.sqlskills.com/help/waits/SOS_WORK_DISPATCHER
        N'SP_SERVER_DIAGNOSTICS_SLEEP', -- https://www.sqlskills.com/help/waits/SP_SERVER_DIAGNOSTICS_SLEEP
        N'SQLTRACE_BUFFER_FLUSH', -- https://www.sqlskills.com/help/waits/SQLTRACE_BUFFER_FLUSH
        N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', -- https://www.sqlskills.com/help/waits/SQLTRACE_INCREMENTAL_FLUSH_SLEEP
        N'SQLTRACE_WAIT_ENTRIES', -- https://www.sqlskills.com/help/waits/SQLTRACE_WAIT_ENTRIES
        N'VDI_CLIENT_OTHER', -- https://www.sqlskills.com/help/waits/VDI_CLIENT_OTHER
        N'WAIT_FOR_RESULTS', -- https://www.sqlskills.com/help/waits/WAIT_FOR_RESULTS
        N'WAITFOR', -- https://www.sqlskills.com/help/waits/WAITFOR
        N'WAITFOR_TASKSHUTDOWN', -- https://www.sqlskills.com/help/waits/WAITFOR_TASKSHUTDOWN
        N'WAIT_XTP_RECOVERY', -- https://www.sqlskills.com/help/waits/WAIT_XTP_RECOVERY
        N'WAIT_XTP_HOST_WAIT', -- https://www.sqlskills.com/help/waits/WAIT_XTP_HOST_WAIT
        N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', -- https://www.sqlskills.com/help/waits/WAIT_XTP_OFFLINE_CKPT_NEW_LOG
        N'WAIT_XTP_CKPT_CLOSE', -- https://www.sqlskills.com/help/waits/WAIT_XTP_CKPT_CLOSE
        N'XE_DISPATCHER_JOIN', -- https://www.sqlskills.com/help/waits/XE_DISPATCHER_JOIN
        N'XE_DISPATCHER_WAIT', -- https://www.sqlskills.com/help/waits/XE_DISPATCHER_WAIT
        N'XE_TIMER_EVENT' -- https://www.sqlskills.com/help/waits/XE_TIMER_EVENT
        )
    AND [waiting_tasks_count] > 0
    )
SELECT
    MAX ([W1].[wait_type]) AS [WaitType],
    CAST (MAX ([W1].[WaitS]) AS DECIMAL (16,2)) AS [Wait_S],
    CAST (MAX ([W1].[ResourceS]) AS DECIMAL (16,2)) AS [Resource_S],
    CAST (MAX ([W1].[SignalS]) AS DECIMAL (16,2)) AS [Signal_S],
    MAX ([W1].[WaitCount]) AS [WaitCount],
    CAST (MAX ([W1].[Percentage]) AS DECIMAL (5,2)) AS [Percentage],
    CAST ((MAX ([W1].[WaitS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgWait_S],
    CAST ((MAX ([W1].[ResourceS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgRes_S],
    CAST ((MAX ([W1].[SignalS]) / MAX ([W1].[WaitCount])) AS DECIMAL (16,4)) AS [AvgSig_S],
    CAST ('https://www.sqlskills.com/help/waits/' + MAX ([W1].[wait_type]) as XML) AS [Help/Info URL]
FROM [Waits] AS [W1]
INNER JOIN [Waits] AS [W2] ON [W2].[RowNum] <= [W1].[RowNum]
GROUP BY [W1].[RowNum]
HAVING SUM ([W2].[Percentage]) - MAX( [W1].[Percentage] ) < 95; -- percentage threshold
GO


-- Reset stats
DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR);
GO

-- Shrink DB
Use CostManagementDev
DBCC SHRINKDATABASE (N'CostManagementDemoDB');

```


## TempDB Log Monitoring

```sql
-- Determining the Amount of Space Used  / free
SELECT
	 [Source] = 'database_files'
	,[TEMPDB_max_size_MB] = SUM(max_size) * 8 / 1027.0
	,[TEMPDB_current_size_MB] = SUM(size) * 8 / 1027.0
	,[FileCount] = COUNT(FILE_ID)
FROM tempdb.sys.database_files
WHERE type = 0 --ROWS

SELECT
	 [Source] = 'dm_db_file_space_usage'
	,[free_space_MB] = SUM(U.unallocated_extent_page_count) * 8 / 1024.0
	,[used_space_MB] = SUM(U.internal_object_reserved_page_count + U.user_object_reserved_page_count + U.version_store_reserved_page_count) * 8 / 1024.0
    ,[internal_object_space_MB] = SUM(U.internal_object_reserved_page_count) * 8 / 1024.0
    ,[user_object_space_MB] = SUM(U.user_object_reserved_page_count) * 8 / 1024.0
    ,[version_store_space_MB] = SUM(U.version_store_reserved_page_count) * 8 / 1024.0
FROM tempdb.sys.dm_db_file_space_usage U

-- Obtaining the space consumed currently in each session
SELECT
	 [Source] = 'dm_db_session_space_usage'
	,[session_id] = Su.session_id
	,[login_name] = MAX(S.login_name)
	,[database_id] = MAX(S.database_id)
	,[database_name] = MAX(D.name)
	,[elastic_pool_name] = MAX(DSO.elastic_pool_name)
	,[internal_objects_alloc_page_count_MB] = SUM(internal_objects_alloc_page_count) * 8 / 1024.0
	,[user_objects_alloc_page_count_MB] = SUM(user_objects_alloc_page_count) * 8 / 1024.0
FROM tempdb.sys.dm_db_session_space_usage SU
LEFT JOIN sys.dm_exec_sessions S
        ON SU.session_id = S.session_id
LEFT JOIN sys.database_service_objectives DSO
        ON S.database_id = DSO.database_id
LEFT JOIN sys.databases D
	ON S.database_id = D.database_id
WHERE internal_objects_alloc_page_count + user_objects_alloc_page_count > 0
GROUP BY Su.session_id
ORDER BY [user_objects_alloc_page_count_MB] desc, Su.session_id;


-- Obtaining the space consumed in all currently running tasks in each session
SELECT
	 [Source] = 'dm_db_task_space_usage'
	,[session_id] = SU.session_id
	,[login_name] = MAX(S.login_name)
	,[database_id] = MAX(S.database_id)
	,[database_name] = MAX(D.name)
	,[elastic_pool_name] = MAX(DSO.elastic_pool_name)
	,[internal_objects_alloc_page_count_MB] = SUM(SU.internal_objects_alloc_page_count) * 8 / 1024.0
	,[user_objects_alloc_page_count_MB] = SUM(SU.user_objects_alloc_page_count) * 8 / 1024.0
FROM tempdb.sys.dm_db_task_space_usage SU
LEFT JOIN sys.dm_exec_sessions S
        ON SU.session_id = S.session_id
LEFT JOIN sys.database_service_objectives DSO
        ON S.database_id = DSO.database_id
LEFT JOIN sys.databases D
	ON S.database_id = D.database_id
WHERE internal_objects_alloc_page_count + user_objects_alloc_page_count > 0
GROUP BY SU.session_id
ORDER BY [user_objects_alloc_page_count_MB] desc, session_id;
```


## Copy Database

```sql
USE MASTER

CREATE DATABASE $(DATABASE_NAME_DEV) AS COPY OF $(SERVER_NAME_PROD).$(DATABASE_NAME_PROD);
CREATE DATABASE $(DATABASE_NAME_QA) AS COPY OF $(SERVER_NAME_PROD).$(DATABASE_NAME_PROD);
GO
```

## User Login

```sql
-- List Users in DB
select name as username,
       create_date,
       modify_date,
       type_desc as type,
       authentication_type_desc as authentication_type
from sys.database_principals
where type not in ('A', 'G', 'R', 'X')
      and sid is not null
order by username;


-- Create New Admin
-- Create Login, User, and assign Role
Use Master;
GO
DROP LOGIN CostOptAdmin;
CREATE LOGIN CostOptAdmin WITH PASSWORD = '$(COST_OPT_ADMIN_PASSWORD)';
GO
ALTER ROLE ##MS_DatabaseManager# ADD MEMBER CostOptAdmin
ALTER ROLE ##MS_LoginManager# ADD MEMBER CostOptAdmin
ALTER ROLE ##MS_DatabaseConnector# ADD MEMBER CostOptAdmin


-- Create new User
-- Create Login, User, and assign Role
Use Master;
GO
DROP LOGIN CostOptUser;
CREATE LOGIN CostOptUser WITH PASSWORD = '$(COST_OPT_USER_PASSWORD)';
GO


USE '$(DATABASE_NAME)';
GO
DROP USER IF EXISTS CostOptUser;
CREATE USER CostOptUser for LOGIN CostOptUser WITH DEFAULT_SCHEMA='$(DATABASE_SCHEMA)';

ALTER ROLE db_owner ADD MEMBER CostOptUser
-- ALTER ROLE db_datawriter ADD MEMBER CostOptUser
-- ALTER ROLE db_datareader ADD MEMBER CostOptUser
```

# References
- SQL Wait Statistics https://www.sqlskills.com/help/waits/
- https://sqlperformance.com/2014/02/sql-performance/knee-jerk-waits-sos-scheduler-yield
- Monitoring Microsoft Azure SQL Database performance using dynamic management views https://learn.microsoft.com/en-us/azure/azure-sql/database/monitoring-with-dmvs?view=azuresql
- Identify Query Performance https://learn.microsoft.com/en-us/azure/azure-sql/database/identify-query-performance-issues?view=azuresql
- Azure SQL DB and TempDB Usage Tracking https://techcommunity.microsoft.com/t5/azure-database-support-blog/azure-sql-db-and-tempdb-usage-tracking/ba-p/1573220
- Azure SQL DB Authz https://learn.microsoft.com/en-us/azure/azure-sql/database/logins-create-manage?view=azuresql
