/* ANSWERING BUSINEES QUESTION*/
/*
6 - What is the best performing product in terms of revenue this year?
7 - What is the product performance Vs Target for the month?
8 - Which account is performing the best in terms of revenue?
9 - Which account is performing the best in terms of revenue vs Target?
10 - Which account is performing the worst in terms of meeting targets for the year?
11 - Which opportunity has the highest potential and what are the details?
12 - Which account generates the most revenue per marketing spend for this month?

*/

select * from dbo.ipi_account_lookup$
select * from dbo.ipi_Calendar_lookup$
select * from dbo.ipi_Opportunities_Data$
select * from dbo.['Marketing Raw Data$']
select * from dbo.['Revenue Raw Data$']
select * from dbo.['Targets Raw Data$']


--6 - What is the best performing product in terms of revenue this year? fy21

select Product_category, SUM(Revenue) as Revenue
from dbo.['Revenue Raw Data$']
where Month_ID in 
(select distinct Month_ID from dbo.ipi_Calendar_lookup$ where [Fiscal Year]='FY21')
group by Product_Category


--7 - What is the product performance Vs Target for the month?
--which products are achieving target which are not?
Select a.product_category,a.month_id, Revenue, Target, Revenue / Target - 1 as Revenue_vs_Target
from

	(
	select Product_category,month_ID, SUM(Revenue) as Revenue
	from dbo.['Revenue Raw Data$']
	where Month_ID in 
	(select MAX(month_ID) from dbo.['Revenue Raw Data$'] )
	group by Product_Category, Month_ID
	)a	
	left join
	(
	select Product_category,month_ID, SUM(Target) as Target
	from dbo.['Targets Raw Data$']
	where Month_ID in 
	(select MAX(month_ID) from dbo.['Revenue Raw Data$'] )
	group by Product_Category, Month_ID
	)b
	on a.Month_ID = b.Month_ID and a.Product_Category = b.Product_Category

--8 - Which account is performing the best in terms of revenue?

select a.Account_no, b.[New Account Name], total_Revenue
from 
(
	select Account_No, SUM(Revenue) total_Revenue from dbo.['Revenue Raw Data$']
	group by Account_No

	

) a

left join
(
select * from dbo.ipi_account_lookup$
)
b
on a.Account_No = b.[ New Account No ]

Order by total_Revenue desc


--9 - Which account is performing the best in terms of revenue vs Target?
select * from dbo.['Revenue Raw Data$']
select * from dbo.['Targets Raw Data$']
select * from dbo.ipi_account_lookup$

select isnull(a.Account_no,b.Account_No) as Acc_no,c.[New Account Name], Total_Revenue, Total_Target, Total_Revenue-Total_Target as diff,Total_Revenue/ nullif(Total_Target,0)-1 as Percent_diff
from
	(
	select Account_No, SUM(Revenue) as Total_Revenue
	from dbo.['Revenue Raw Data$']
	where Month_ID in (select distinct Month_ID from dbo.ipi_Calendar_lookup$
	where [Fiscal Year] = 'FY21' )
	group by Account_No
	) a
	full join
	(
	select Account_No, SUM(Target) as Total_Target
	from dbo.['Targets Raw Data$']
	where Month_ID in (select distinct Month_ID from dbo.ipi_Calendar_lookup$
	where [Fiscal Year] = 'FY21' )
	group by Account_No
	) b
	on a.Account_No = b.Account_No

	left join
	(
	select * from dbo.ipi_account_lookup$) c
	on a.Account_No = c.[ New Account No ]
order by Total_Revenue/ nullif(Total_Target,0)-1 desc

--10 - Which account is performing the worst in terms of meeting targets for the year?
select isnull(a.Account_no,b.Account_No) as Acc_no,c.[New Account Name], Total_Revenue, Total_Target, isnull(Total_Revenue,0)/ nullif(isnull(Total_Target,0),0)-1 as Percent_diff
from
	(
	select Account_No, SUM(Revenue) as Total_Revenue
	from dbo.['Revenue Raw Data$']
	where Month_ID in (select distinct Month_ID from dbo.ipi_Calendar_lookup$
	where [Fiscal Year] = 'FY21' )
	group by Account_No
	) a
	full join
	(
	select Account_No, SUM(Target) as Total_Target
	from dbo.['Targets Raw Data$']
	where Month_ID in (select distinct Month_ID from dbo.ipi_Calendar_lookup$
	where [Fiscal Year] = 'FY21' )
	group by Account_No
	) b
	on a.Account_No = b.Account_No

	left join
	(
	select * from dbo.ipi_account_lookup$) c
	on a.Account_No = c.[ New Account No ]
order by Total_Revenue/ nullif(Total_Target,0)-1 

--11 - Which opportunity has the highest potential and what are the details? fy21
select TOP 1* from dbo.ipi_Opportunities_Data$
where [Est Completion Month ID] in (
select Month_ID from dbo.ipi_Calendar_lookup$ where [Fiscal Year] = 'FY21')
order by [Est Opportunity Value] desc

select * from dbo.ipi_Calendar_lookup$
select * from dbo.ipi_account_lookup$
select * from dbo.['Marketing Raw Data$']

--12 - Which account generates the most revenue per marketing spend for this month? fy21

/*
select  account_no, SUM([ Marketing Spend ]) as sum_of_market_spend 
from dbo.['Marketing Raw Data$']
where Month_ID in
( select max(Month_ID) from dbo.['Marketing Raw Data$'])
group by Account_No
order by SUM([ Marketing Spend ]) desc

select distinct month_id from dbo.['Marketing Raw Data$']
order by Month_ID desc
*/
---

select isnull(a.Account_no,b.Account_No) as Acc_no,c.[New Account Name], Total_Revenue, total_marketing_spend, isnull(Total_Revenue,0)/ nullif(isnull(total_marketing_spend,0),0)-1 as Percent_diff
from 
(
select Account_No, SUM(Revenue) as Total_Revenue
	from dbo.['Revenue Raw Data$']
	where Month_ID in (select distinct Month_ID from dbo.ipi_Calendar_lookup$
	where [Fiscal Year] = 'FY21' )
	group by Account_No
	) a 
full join
(
select Account_No, SUM([ Marketing Spend ]) as total_marketing_spend
	from dbo.['Marketing Raw Data$']
	where Month_ID in (select distinct Month_ID from dbo.ipi_Calendar_lookup$
	where [Fiscal Year] = 'FY21' )
	group by Account_No
	
	) b

on a.Account_No = b.Account_No
left join
	(
	select * from dbo.ipi_account_lookup$) c
	on a.Account_No = c.[ New Account No ]

order by isnull(Total_Revenue,0)/ nullif(isnull(total_marketing_spend,0),0)-1 desc