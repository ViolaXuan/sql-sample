--a.Display a list of all property names and their property id’s for Owner Id: 1426. 
SELECT P.Name AS PropertyName,p.Id AS PropertyID
FROM [dbo].[OwnerProperty] O
INNER JOIN [dbo].[Property] P
ON P.Id=O.PropertyId
WHERE O.OwnerId='1426'


--b.Display the current home value for each property in question a). 
SELECT P.Name AS PropertyName,p.Id AS PropertyID,V.[Value] AS CurrentPropertyValue
,P.[UpdatedOn],V.IsActive
FROM [dbo].[OwnerProperty] O
INNER JOIN [dbo].[Property] P
ON P.Id=O.PropertyId
INNER JOIN [dbo].[PropertyHomeValue] V
ON V.[PropertyId]=P.[Id]
WHERE O.OwnerId='1426'
AND V.[HomeValueTypeId]='1'
AND V.[IsActive]='1'
ORDER BY P.Id ASC

--c.For each property in question a), return the following:                                                                      
--1.Using rental payment amount, rental payment frequency,tenant start date and tenant end date to write a query 
--that returns the sum of all payments from start date to end date. 

--2.Display the yield


WITH a_Property 
AS(SELECT P.Name AS PropertyName,p.Id AS PropertyID
FROM [dbo].[OwnerProperty] O
INNER JOIN [dbo].[Property] P
ON P.Id=O.PropertyId
WHERE O.OwnerId='1426')
SELECT TP.PropertyId,a_Property.PropertyName,TP.StartDate,TP.EndDate,48 * [PaymentAmount] AS PaymentAmount
FROM a_Property 
INNER JOIN [dbo].[TenantProperty] TP
ON a_Property.PropertyID=TP.PropertyId
WHERE a_Property.PropertyID='5597'

WITH a_Property 
AS(SELECT P.Name AS PropertyName,p.Id AS PropertyID
FROM [dbo].[OwnerProperty] O
INNER JOIN [dbo].[Property] P
ON P.Id=O.PropertyId
WHERE O.OwnerId='1426')
SELECT TP.PropertyId,a_Property.PropertyName,TP.StartDate,TP.EndDate,24 * [PaymentAmount] AS PaymentAmount
FROM a_Property 
INNER JOIN [dbo].[TenantProperty] TP
ON a_Property.PropertyID=TP.PropertyId
WHERE a_Property.PropertyID='5637'

WITH a_Property 
AS(SELECT P.Name AS PropertyName,p.Id AS PropertyID
FROM [dbo].[OwnerProperty] O
INNER JOIN [dbo].[Property] P
ON P.Id=O.PropertyId
WHERE O.OwnerId='1426')
SELECT TP.PropertyId,a_Property.PropertyName,TP.StartDate,TP.EndDate,12 * [PaymentAmount] AS PaymentAmount
FROM a_Property 
INNER JOIN [dbo].[TenantProperty] TP
ON a_Property.PropertyID=TP.PropertyId
WHERE a_Property.PropertyID='5638'




WITH a_Property 
AS(SELECT P.Name AS PropertyName,p.Id AS PropertyID
FROM [dbo].[OwnerProperty] O
INNER JOIN [dbo].[Property] P
ON P.Id=O.PropertyId
WHERE O.OwnerId='1426')
SELECT TP.PropertyId,a_Property.PropertyName,FORMAT(TP.StartDate,'yyyy-MM-dd') AS StartDate,FORMAT(TP.EndDate,'yyyy-MM-dd') AS EndDate,
CASE 
  WHEN TP.[PaymentFrequencyId] = 1 THEN CONVERT(DECIMAL(10,2),TP.PaymentAmount*DATEDIFF(week,StartDate,EndDate))
  WHEN TP.[PaymentFrequencyId] = 2 THEN CONVERT(DECIMAL(10,2),TP.PaymentAmount*DATEDIFF(week,StartDate,EndDate)/2)
  WHEN TP.[PaymentFrequencyId] = 3 THEN CONVERT(DECIMAL(10,2),TP.PaymentAmount*DATEDIFF(MONTH,StartDate,EndDate)+1000)
END AS PaymentAmount
FROM a_Property 
INNER JOIN [dbo].[TenantProperty] TP
ON a_Property.PropertyID=TP.PropertyId
WHERE a_Property.PropertyID='5597'
OR a_Property.PropertyID='5637'
OR a_Property.PropertyID='5638'


---Display the yield. 

WITH a_Property 
AS(SELECT P.Name AS PropertyName,p.Id AS PropertyID
FROM [dbo].[OwnerProperty] O
INNER JOIN [dbo].[Property] P
ON P.Id=O.PropertyId
WHERE O.OwnerId='1426')
SELECT TP.PropertyId,a_Property.PropertyName,FORMAT(TP.StartDate,'yyyy-MM-dd') AS StartDate,FORMAT(TP.EndDate,'yyyy-MM-dd') AS EndDate,
CASE 
  WHEN TP.[PaymentFrequencyId] = 1 THEN CONVERT(DECIMAL(10,2),TP.PaymentAmount*DATEDIFF(week,StartDate,EndDate))
  WHEN TP.[PaymentFrequencyId] = 2 THEN CONVERT(DECIMAL(10,2),TP.PaymentAmount*DATEDIFF(week,StartDate,EndDate)/2)
  WHEN TP.[PaymentFrequencyId] = 3 THEN CONVERT(DECIMAL(10,2),TP.PaymentAmount*DATEDIFF(MONTH,StartDate,EndDate)+1000)
END AS PaymentAmount,CONVERT(Decimal(10,10),(PaymentAmount-PE.Amount)/PF.[CurrentHomeValue]*100)AS Yield
FROM a_Property 
INNER JOIN [dbo].[TenantProperty] TP
ON a_Property.PropertyID=TP.PropertyId
INNER JOIN [dbo].[PropertyExpense] PE ON TP.PropertyId=PE.PropertyId
INNER JOIN [dbo].[PropertyHomeValue] PV ON PV.PropertyId=PE.PropertyId
INNER JOIN [dbo].[PropertyFinance] PF ON PF.PropertyId=PV.PropertyId
WHERE a_Property.PropertyID='5597'
OR a_Property.PropertyID='5637'
OR a_Property.PropertyID='5638'

--d.Display all the jobs available
SELECT DISTINCT J.[JobDescription],S.[Status] AS JobsAvailableStatus
FROM [dbo].[Job] J
INNER JOIN [dbo].[JobStatus] S
ON J.[JobStatusId]=S.[Id]
WHERE S.[Status] = 'Open'
AND J.JobDescription IS NOT NULL
ORDER BY J.[JobDescription] ASC

--e.Display all property names, current tenants first and last names and rental payments per week/ fortnight/month for the properties in question a). 
WITH T1426
AS (
SELECT P.Name AS PropertyName,p.Id AS PropertyID
FROM [dbo].[OwnerProperty] O
INNER JOIN [dbo].[Property] P
ON P.Id=O.PropertyId
WHERE O.OwnerId='1426')
SELECT T1426.PropertyName,Per.FirstName AS TenantFristName,Per.LastName AS TenantLastName,TF.Name AS RentalPayments
FROM T1426
INNER JOIN [dbo].[TenantProperty] TP
ON TP.[PropertyId]=T1426.PropertyID
INNER JOIN [dbo].[Tenant] TT
ON TT.Id=TP.TenantId
INNER JOIN [dbo].[Person] Per
ON Per.[Id]=TT.[Id]
INNER JOIN [dbo].[TenantPaymentFrequencies] TF
ON TF.[Id]=TP.[PaymentFrequencyId]
WHERE TT.IsActive='1'


--task 2 
SELECT Pr.FirstName AS CurrentOwner,CONCAT(A.Number,'  ',A.Street) AS PropertyAddress,
CONCAT(P.Bedroom,' Bedroom + ',P.Bathroom,' Bathroom') As PropertyDetails,PRP.[Amount] AS RentalPayment
FROM [dbo].[Address] A
INNER JOIN [dbo].[Property] P ON p.Id=A.AddressId
INNER JOIN [dbo].[OwnerProperty]  OP ON OP.PropertyId=P.Id
INNER JOIN [dbo].[Person] Pr ON Pr.Id=OP.OwnerId
INNER JOIN [dbo].[PropertyRentalPayment] PRP ON PRP.[PropertyId]=P.[Id]
WHERE P.Name = 'Property A'


SELECT PE.[Amount],FORMAT(PE.[Date],'yyyy-MM-dd') AS Date,PE.[Description] AS Expense
FROM [dbo].[PropertyExpense] PE
WHERE PE.[PropertyId]='5643'
