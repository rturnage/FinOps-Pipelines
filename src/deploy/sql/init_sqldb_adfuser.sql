/********************************************************************
* The DATAFACTORYMSI variable needs to be set on the command line
* when executing this script via SQLCMD or Invoke-SQLCMD
* If running from SSMS, then uncomment and amend the line at the top of the script
* e.g
*		:setvar  DATAFACTORYMSI [mynewdatafactory]
*
* v1 Users - Separate User creation into separate script as this needs an AAD Admin
*/
-- IF RUNNING FROM SSMS, UNCOMMENT THE LINE BELOW AND SET SSMS TO SQLCMD MODE
-- :setvar  DATAFACTORYMSI [mynewdatafactory]

DROP USER IF EXISTS [$(DATAFACTORYMSI)];
CREATE USER [$(DATAFACTORYMSI)] FROM EXTERNAL PROVIDER
go

ALTER ROLE CostManagementDataLoader ADD MEMBER [$(DATAFACTORYMSI)];
go
