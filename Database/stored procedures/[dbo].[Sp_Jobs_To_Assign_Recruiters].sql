USE [piHIRE1.0_QA]
GO

CREATE OR ALTER PROCEDURE [dbo].[Sp_Jobs_To_Assign_Recruiters]

	@SearchKey nvarchar(max),
	@PerPage int,
	@CurrentPage int,
	@UserId int

AS
BEGIN     

	SET NOCOUNT ON 

	declare @jobIds nvarchar(max);	

	declare @tblPuIds TABLE(id int)
	insert @tblPuIds
	select 
		userPu.ProcessUnit
	from 
		[dbo].[PI_APP_USER_PU_BU] as userPu join 
		[dbo].[PI_HIRE_USERS] as HireUser on userPu.AppUserId = HireUser.ID join
		[dbo].[tbl_param_process_unit_master] as pu on userPu.ProcessUnit = pu.id
	where 
		HireUser.Id = @UserId and userPu.Status !=5
	
	
	
	--CREATE TABLE #Results (JobLocationID int,CityId int, CityName varchar(150), CountryName nvarchar(150),
	--CountryID int, ClientId int, ClientName nvarchar(150),ClosedDate datetime,Id int,
	--JobRole varchar(100),JobTitle nvarchar(500),JobDescription nvarchar(max),
	--StartDate datetime,JobOpeningStatus int,JobOpeningStatusName nvarchar(100),JSCode nvarchar(10),CreatedDate datetime,
	--CreatedBy int,CreatedByName varchar(100),ShortJobDesc nvarchar(1000),isAssigned int)

	--insert into #Results
	--Select 
	--	Job.JobLocationID,city.id as CityId,city.name as CityName,Cuntry.name as CountryName,CountryID,
	--	Job.ClientId,Job.ClientName,Job.ClosedDate,Job.Id as Id,Job.JobRole,Job.JobTitle,Job.JobDescription,
	--	Job.PostedDate as StartDate,Job.JobOpeningStatus,JobStatus.Title as JobOpeningStatusName,JobStatus.JSCode,
	--	Job.CreatedDate,Job.CreatedBy,HireUser.FirstName as CreatedByName,Job.ShortJobDesc,
	--	(select Id from PH_JOB_ASSIGNMENTS as ASSIGNMENT  where ASSIGNMENT.joId =  Job.id 
	--	and ASSIGNMENT.AssignedTo= @UserId and ASSIGNMENT.DeassignDate is null) as isAssigned
	--from 
	--	dbo.PH_JOB_OPENINGS as Job  WITH(NOLOCK)
	--	join  dbo.PH_JOB_OPENINGS_ADDL_DETAILS as jobAddl  WITH(NOLOCK) on Job.Id = jobAddl.JOID 
	--	left join dbo.PH_COUNTRY as Cuntry  WITH(NOLOCK) on Job.CountryID = Cuntry.Id 
	--	left join dbo.PH_CITY as city  WITH(NOLOCK) on Job.JobLocationID = city.Id 
	--	left join dbo.PH_JOB_STATUS_S as JobStatus  WITH(NOLOCK) on Job.JobOpeningStatus = JobStatus.Id 
	--	left join dbo.PI_HIRE_USERS as HireUser WITH(NOLOCK) on Job.CreatedBy = HireUser.Id 
	--where
	--	jobAddl.PUID in (SELECT id from @tblPuIds)
	--	and JobStatus.JSCode not in ('HLD','RJT','CLS') 
	--	and (LEN(COALESCE(@SearchKey,'')) = 0 or (
	--				Job.Id like '%'+@SearchKey+'%' or 
	--				Job.ClientName like '%'+@SearchKey+'%' or 
	--				Job.JobTitle like '%'+@SearchKey+'%' or 
	--				Job.JobRole like '%'+@SearchKey+'%')
	--		)
				
	if(@PerPage > 0)
	BEGIN
		Select 
			Job.JobLocationID,city.id as CityId,city.name as CityName,Cuntry.name as CountryName,CountryID,
			Job.ClientId,Job.ClientName,Job.ClosedDate,Job.Id as Id,Job.JobRole,Job.JobTitle,Job.JobDescription,
			Job.PostedDate as StartDate,Job.JobOpeningStatus,JobStatus.Title as JobOpeningStatusName,JobStatus.JSCode,
			Job.CreatedDate,Job.CreatedBy,HireUser.FirstName as CreatedByName,Job.ShortJobDesc,
			(select Id from PH_JOB_ASSIGNMENTS as ASSIGNMENT  where ASSIGNMENT.joId =  Job.id 
			and ASSIGNMENT.AssignedTo= @UserId and ASSIGNMENT.DeassignDate is null) as isAssigned
		from 
			dbo.PH_JOB_OPENINGS as Job  WITH(NOLOCK)
			join  dbo.PH_JOB_OPENINGS_ADDL_DETAILS as jobAddl  WITH(NOLOCK) on Job.Id = jobAddl.JOID 
			left join dbo.PH_COUNTRY as Cuntry  WITH(NOLOCK) on Job.CountryID = Cuntry.Id 
			left join dbo.PH_CITY as city  WITH(NOLOCK) on Job.JobLocationID = city.Id 
			left join dbo.PH_JOB_STATUS_S as JobStatus  WITH(NOLOCK) on Job.JobOpeningStatus = JobStatus.Id 
			left join dbo.PI_HIRE_USERS as HireUser WITH(NOLOCK) on Job.CreatedBy = HireUser.Id 
		where
			jobAddl.PUID in (SELECT id from @tblPuIds)
			and JobStatus.JSCode not in ('HLD','RJT','CLS') 
			and (LEN(COALESCE(@SearchKey,'')) = 0 or (
						Job.Id like '%'+@SearchKey+'%' or 
						Job.ClientName like '%'+@SearchKey+'%' or 
						Job.JobTitle like '%'+@SearchKey+'%' or 
						Job.JobRole like '%'+@SearchKey+'%')
				)
		order by CreatedDate desc 
		offset @CurrentPage rows fetch next @PerPage rows only;
	END
	else
	BEGIN
		Select 
			Job.JobLocationID,city.id as CityId,city.name as CityName,Cuntry.name as CountryName,CountryID,
			Job.ClientId,Job.ClientName,Job.ClosedDate,Job.Id as Id,Job.JobRole,Job.JobTitle,Job.JobDescription,
			Job.PostedDate as StartDate,Job.JobOpeningStatus,JobStatus.Title as JobOpeningStatusName,JobStatus.JSCode,
			Job.CreatedDate,Job.CreatedBy,HireUser.FirstName as CreatedByName,Job.ShortJobDesc,
			(select Id from PH_JOB_ASSIGNMENTS as ASSIGNMENT  where ASSIGNMENT.joId =  Job.id 
			and ASSIGNMENT.AssignedTo= @UserId and ASSIGNMENT.DeassignDate is null) as isAssigned
		from 
			dbo.PH_JOB_OPENINGS as Job  WITH(NOLOCK)
			join  dbo.PH_JOB_OPENINGS_ADDL_DETAILS as jobAddl  WITH(NOLOCK) on Job.Id = jobAddl.JOID 
			left join dbo.PH_COUNTRY as Cuntry  WITH(NOLOCK) on Job.CountryID = Cuntry.Id 
			left join dbo.PH_CITY as city  WITH(NOLOCK) on Job.JobLocationID = city.Id 
			left join dbo.PH_JOB_STATUS_S as JobStatus  WITH(NOLOCK) on Job.JobOpeningStatus = JobStatus.Id 
			left join dbo.PI_HIRE_USERS as HireUser WITH(NOLOCK) on Job.CreatedBy = HireUser.Id 
		where
			jobAddl.PUID in (SELECT id from @tblPuIds)
			and JobStatus.JSCode not in ('HLD','RJT','CLS') 
			and (LEN(COALESCE(@SearchKey,'')) = 0 or (
						Job.Id like '%'+@SearchKey+'%' or 
						Job.ClientName like '%'+@SearchKey+'%' or 
						Job.JobTitle like '%'+@SearchKey+'%' or 
						Job.JobRole like '%'+@SearchKey+'%')
				)
		order by CreatedDate
	END

	Select 
		Count(*)  as JobsCount
	from 
		dbo.PH_JOB_OPENINGS as Job  WITH(NOLOCK)
		join  dbo.PH_JOB_OPENINGS_ADDL_DETAILS as jobAddl  WITH(NOLOCK) on Job.Id = jobAddl.JOID 
		left join dbo.PH_JOB_STATUS_S as JobStatus  WITH(NOLOCK) on Job.JobOpeningStatus = JobStatus.Id 
	where
		jobAddl.PUID in (SELECT id from @tblPuIds)
		and JobStatus.JSCode not in ('HLD','RJT','CLS') 
		and (LEN(COALESCE(@SearchKey,'')) = 0 or (
					Job.Id like '%'+@SearchKey+'%' or 
					Job.ClientName like '%'+@SearchKey+'%' or 
					Job.JobTitle like '%'+@SearchKey+'%' or 
					Job.JobRole like '%'+@SearchKey+'%')
			)

END



