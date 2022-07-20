
/* ANSWERING BUSINEES QUESTION*/

/*
1 - What is the total Revenue of the company in 2021?
2 - What is the total Revenue Performance YoY?
3 - What is the MoM Revenue Performance?
4 - What is the Total Revenue Vs Target performance for the Year?
5 - What is the Revenue Vs Target performance Per Month?
*/
select * from dbo.ipi_account_lookup$
select * from dbo.ipi_Calendar_lookup$
select * from dbo.ipi_Opportunities_Data$
select * from dbo.['Marketing Raw Data$']
select * from dbo.['Revenue Raw Data$']
select * from dbo.['Targets Raw Data$']

--1 - What is the total Revenue of the company in 2021 wrt to the month ID?


select  Month_ID, sum(Revenue) as Total_revenue_FY21 from dbo.['Revenue Raw Data$']
where Month_ID 
in 
(select Distinct Month_ID from dbo.ipi_Calendar_lookup$ 
where [Fiscal Year] = 'FY21')
group by Month_ID

--2 - What is the total Revenue Performance YoY?

-- get the total Revenue in 2020 and 2021
-- but we only have 6 months of data in 2021 for revenue

select DISTINCT Month_ID- 12 from dbo.['Revenue Raw Data$'] where Month_ID in (
select distinct Month_ID from dbo.ipi_Calendar_lookup$
where [Fiscal Year] = 'FY21')	--this query will give the fy20 first 6 months monthID



-- actual query
SELECT a.Total_revenue_FY21, b.Total_revenue_FY20, a.Total_revenue_FY21- b.Total_revenue_FY20 as YOY_diff,
a.Total_revenue_FY21/ b.Total_revenue_FY20 -1 as Percentage_diff 
from
(
select  sum(Revenue) as Total_revenue_FY21 from dbo.['Revenue Raw Data$']
where Month_ID 
in 
(select Distinct Month_ID from dbo.ipi_Calendar_lookup$ 
where [Fiscal Year] = 'FY21')
) a,

(
select  sum(Revenue) as Total_revenue_FY20 from dbo.['Revenue Raw Data$']
where Month_ID 
in 
(select DISTINCT Month_ID- 12 from dbo.['Revenue Raw Data$'] where Month_ID in (
select distinct Month_ID from dbo.ipi_Calendar_lookup$
where [Fiscal Year] = 'FY21'))
) b

--3 - What is the recent MoM Revenue Performance?
-- compare months
select a.Total_revenue_this_month, b.Total_revenue_last_month, a.Total_revenue_this_month-b.Total_revenue_last_month as diff_in_dollar,
a.Total_revenue_this_month/b.Total_revenue_last_month - 1 as Percentage_MOM_diff

from (
--this month
select 
SUM(Revenue)as Total_revenue_this_month from dbo.['Revenue Raw Data$']
where Month_ID in (select MAX(month_id) from dbo.['Revenue Raw Data$'])
group by Month_ID )a,

(
--last month
select --Month_ID,
SUM(Revenue) as Total_revenue_last_month from dbo.['Revenue Raw Data$']
where Month_ID in (select MAX(month_id)-1 from dbo.['Revenue Raw Data$'])
group by Month_ID) b

--4 - What is the Total Revenue Vs Target performance for the Year?

select a.total_target, b.total_revenue, b.total_revenue-a.total_target as diff_in_Revenue_vs_Target,
b.total_revenue/a.total_target -1 as percent_diff
from 
(
select --distinct Month_ID,
round(SUM(Target),2) as total_target from dbo.['Targets Raw Data$']
where Month_ID in (
(select distinct Month_ID from dbo.['Revenue Raw Data$'] where Month_ID in 
(select distinct Month_ID from 
dbo.ipi_Calendar_lookup$
where [Fiscal Year] = 'FY21'))
)
--group by Month_ID
) a,
(
select --distinct Month_ID, 
SUM(Revenue) as total_revenue from dbo.['Revenue Raw Data$']
where Month_ID in (
select distinct Month_ID from 
dbo.ipi_Calendar_lookup$
where [Fiscal Year] = 'FY21')
--group by Month_ID
) b


--5 - What is the Revenue Vs Target performance Per Month?
select c.[Fiscal Month],a.Month_ID,a.total_target, b.total_revenue, round(b.total_revenue-a.total_target,2) as diff_in_Revenue_vs_Target,
b.total_revenue/a.total_target -1 as percent_diff
from

(
select distinct Month_ID,
round(SUM(Target),2) as total_target from dbo.['Targets Raw Data$']
where Month_ID in (
(select distinct Month_ID from dbo.['Revenue Raw Data$'] where Month_ID in 
(select distinct Month_ID from 
dbo.ipi_Calendar_lookup$
where [Fiscal Year] = 'FY21'))
)
group by Month_ID
) a
LEFT JOIN
(
select distinct Month_ID, 
SUM(Revenue) as total_revenue from dbo.['Revenue Raw Data$']
where Month_ID in (
select distinct Month_ID from 
dbo.ipi_Calendar_lookup$
where [Fiscal Year] = 'FY21')
group by Month_ID
) b

on a.Month_ID = b.Month_ID

LEFT JOIN 
(select distinct Month_ID, [Fiscal Month] from 
dbo.ipi_Calendar_lookup$) c

on a.Month_ID = c.Month_ID
