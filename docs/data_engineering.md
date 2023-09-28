# Data Engineering

## Column Statistics

Use Dax Studio to find the Column Statistics for all imported table:

* Import tables to PowerBI and Save
* Open Dax Studio and connect to PowerBI
* Run Column Statistics

```
EVALUATE COLUMNSTATISTICS()
```

## Exporting Helpful Files

```sql
-- File tags_col.csv
Select
[Tags]
,Upper(JSON_VALUE( CONCAT('{',Lower([Tags]),'}'), '$.tag_name')) AS tag_name
FROM [costmanagement].[AmortizedCost_Last_30_days]
where Lower([Tags]) like '%tag_name_pattern%'
group by [Tags]

```
