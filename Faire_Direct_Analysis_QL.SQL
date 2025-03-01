﻿
--------Subject: Faire Direct Analysis
--------Author: Qiming (Levitt) Liu
--------Created Date: 03/05/2021
--------Modified Date: 03/05/2021


--------Check on Top 1000 Rows of the Dataset

SELECT TOP 1000 *
FROM FaireDirect
ORDER BY brand_id



----------------------------------------------------------------------------------------------------------------------------------------------
--------Hypothesis #1: Recent Drop in New Retailers Acquired is Because We are Less Effective in Converting Clicks into New Customers.-------- 
----------------------------------------------------------------------------------------------------------------------------------------------


----Calculate Conversion Rate in Each Stage of Faire Direct

--Conversion Over Time vs. Conversion Rate After Seen Drop in Retailers Acquired
--Click to SignUp Rate Shows a Major Drop, from 0.154 to 0.115, ~25%

SELECT 
	COUNT(*) AS Clicks, 
	SUM(CASE WHEN brand_relationship_confirmed_at IS NOT NULL THEN 1 ELSE 0 END) AS SignUps,
	SUM(CASE WHEN retailer_placed_first_order_at IS NOT NULL THEN 1 ELSE 0 END) AS FirstOrders,
        SUM(CASE WHEN retailer_placed_first_confirmed_order_at IS NOT NULL THEN 1 ELSE 0 END) AS ConfirmedOrders,
	CAST(SUM(CASE WHEN brand_relationship_confirmed_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / COUNT(*) AS decimal(4,3)) AS Click_to_SignUp,
	CAST(SUM(CASE WHEN retailer_placed_first_order_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / SUM(CASE WHEN brand_relationship_confirmed_at IS NOT NULL THEN 1 ELSE 0 END) AS decimal(4,3)) AS SignUp_to_FirstOrder,
	CAST(SUM(CASE WHEN retailer_placed_first_confirmed_order_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / SUM(CASE WHEN retailer_placed_first_order_at IS NOT NULL THEN 1 ELSE 0 END) AS decimal(4,3)) AS FirstOrder_to_ConfirmedOrder
FROM dbo.FaireDirect
WHERE brand_relationship_created_at < '2019-05-27'
 
SELECT 
	COUNT(*) AS Clicks, 
	SUM(CASE WHEN brand_relationship_confirmed_at IS NOT NULL THEN 1 ELSE 0 END) AS SignUps,
	SUM(CASE WHEN retailer_placed_first_order_at IS NOT NULL THEN 1 ELSE 0 END) AS FirstOrders,
        SUM(CASE WHEN retailer_placed_first_confirmed_order_at IS NOT NULL THEN 1 ELSE 0 END) AS ConfirmedOrders,
	CAST(SUM(CASE WHEN brand_relationship_confirmed_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / COUNT(*) AS decimal(4,3)) AS Click_to_SignUp,
	CAST(SUM(CASE WHEN retailer_placed_first_order_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / SUM(CASE WHEN brand_relationship_confirmed_at IS NOT NULL THEN 1 ELSE 0 END) AS decimal(4,3)) AS SignUp_to_FirstOrder,
	CAST(SUM(CASE WHEN retailer_placed_first_confirmed_order_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / SUM(CASE WHEN retailer_placed_first_order_at IS NOT NULL THEN 1 ELSE 0 END) AS decimal(4,3)) AS FirstOrder_to_ConfirmedOrder
FROM dbo.FaireDirect
WHERE brand_relationship_created_at >= '2019-05-27'


--Explore If The Drop in Click to SignUp Comes from a Certain Referral Channel.
--Result Shows Consistency across Channels.

SELECT 
	normalized_referer, 
	CAST(SUM(CASE WHEN brand_relationship_confirmed_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / COUNT(*) AS decimal(4,3)) AS Click_to_SignUp
FROM dbo.FaireDirect
WHERE brand_relationship_created_at < '2019-05-27'
GROUP BY normalized_referer
ORDER BY normalized_referer


SELECT 
	normalized_referer, 
	CAST(SUM(CASE WHEN brand_relationship_confirmed_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / COUNT(*) AS decimal(4,3)) AS Click_to_SignUp
FROM FaireDirect
WHERE brand_relationship_created_at >= '2019-05-27'
GROUP BY normalized_referer
ORDER BY normalized_referer


--Explore If Different Type of Business Behave Differently in Recent Decline
--Though Overall Conversion Ratio Between Business Type is Similar Before and After the Decline, Brick & Mortar Stores Have More Problems Completing Sign Up Process, Resulting In Lower Conversion. 

WITH cte AS
(SELECT *, 
		CASE WHEN (retailer_business_type LIKE '%online%' OR retailer_business_type LIKE 'www.%.com' OR retailer_business_type LIKE '%ecommerce%') THEN 'Online' ELSE 'Brick Mortar' END AS Type
FROM FaireDirect)
SELECT 
	Type, 
        COUNT(*) AS Cnt,
	CAST(SUM(CASE WHEN brand_relationship_confirmed_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / COUNT(*) AS decimal(4,3)) AS Click_to_SignUp,
	CAST(SUM(CASE WHEN retailer_placed_first_confirmed_order_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / COUNT(*) AS decimal(4,3)) AS Click_to_Confirm_Order
FROM cte
WHERE brand_relationship_created_at < '2019-05-27'
GROUP BY Type;


WITH cte AS
(SELECT *, 
		CASE WHEN (retailer_business_type LIKE '%online%' OR retailer_business_type LIKE 'www.%.com' OR retailer_business_type LIKE '%ecommerce%') THEN 'Online' ELSE 'Brick Mortar' END AS Type
FROM FaireDirect)
SELECT 
	Type, 
	COUNT(*) AS Cnt,
	CAST(SUM(CASE WHEN brand_relationship_confirmed_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / COUNT(*) AS decimal(4,3)) AS Click_to_SignUp,
	CAST(SUM(CASE WHEN retailer_placed_first_confirmed_order_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / COUNT(*) AS decimal(4,3)) AS Click_to_Confirm_Order
FROM cte
WHERE brand_relationship_created_at >= '2019-05-27'
GROUP BY Type




-------------------------------------------------------------------------------------------------------------------------------------
--------Hypothesis #2: The Activity from Faire Email System Could Explain The Difference in the Drop of New Retailers Acquired.--------
-------------------------------------------------------------------------------------------------------------------------------------

--We can See an Clear Decrease in the Sign Up Ratio from Emails Sent through Our System, from 0.307 to 0.229. For Links outside of Our System the Ratio is Consistent. Same Applies for Overal Conversion Ratio. 

SELECT 
	COUNT(*) AS Cnt,
	CAST(SUM(CASE WHEN brand_relationship_confirmed_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / COUNT(*) AS decimal(4,3)) AS Click_to_SignUp
FROM dbo.FaireDirect
WHERE brand_relationship_created_at >= '2019-05-27' AND outgoing_email_id IS NULL

SELECT 
	COUNT(*) AS Cnt,
	CAST(SUM(CASE WHEN brand_relationship_confirmed_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / COUNT(*) AS decimal(4,3)) AS Click_to_SignUp
FROM dbo.FaireDirect
WHERE brand_relationship_created_at >= '2019-05-27' AND outgoing_email_id IS NOT NULL

SELECT 
	COUNT(*) AS Cnt,
	CAST(SUM(CASE WHEN brand_relationship_confirmed_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / COUNT(*) AS decimal(4,3)) AS Click_to_SignUp
FROM dbo.FaireDirect
WHERE brand_relationship_created_at < '2019-05-27' AND outgoing_email_id IS NULL

SELECT 
	COUNT(*) AS Cnt,
	CAST(SUM(CASE WHEN brand_relationship_confirmed_at IS NOT NULL THEN 1 ELSE 0 END)*1.000 / COUNT(*) AS decimal(4,3)) AS Click_to_SignUp
FROM dbo.FaireDirect
WHERE brand_relationship_created_at < '2019-05-27' AND outgoing_email_id IS NOT NULL


--Whether the Low Conversion Ratio It is Because the Retailers Take Longer Time from Receving Email to Completing Sign Up
--It used to take New Retailers 3 Days from Receiving Emails to Signing Up. Now it Takes Them Over Two Weeks (16 Days) Which Partially Explains the Drop in # Acquired. 
--Note: We Only Consider Majority of Retailers Who Joined after Receving Emails. There are Few that Already Signed Up before.

SELECT AVG(DATEDIFF(DAY, email_sent_at, retailer_signed_up_at)) AS Days_Email_To_SignUp
FROM FaireDirect
WHERE brand_relationship_created_at >= '2019-05-27' AND retailer_signed_up_at IS NOT NULL AND email_sent_at IS NOT NULL AND retailer_signed_up_at >= email_sent_at


SELECT AVG(DATEDIFF(DAY, email_sent_at, retailer_signed_up_at)) AS Days_Email_To_SignUp
FROM FaireDirect
WHERE brand_relationship_created_at < '2019-05-27' AND retailer_signed_up_at IS NOT NULL AND email_sent_at IS NOT NULL AND retailer_signed_up_at >= email_sent_at




----------------------------------------------------------------------------------------------------------------------------------------
--------Hypothesis #3: Drop in Recent Retailers Acquired is Due to Decreasing Number of Brands that Use Faire Direct.-------------------
----------------------------------------------------------------------------------------------------------------------------------------

--Calculate the Number of New Brands Joined Every Month and Percentage of Brands Started to Use Faire Direct.
--Since October 2018, We Can See a Downwarding Trend in the Adoption Ratio. During Recent Months, Both Number of New Brands and Adoption Rate Shows Decrease Which Brings Less Brands and Thier Potential Referrals in The Network.

SELECT 
	YEAR(brand_first_active_at) AS Year, 
	MONTH(brand_first_active_at) AS MONTH, 
	COUNT(DISTINCT brand_id) as Brand_Cnt,
	COUNT(DISTINCT (CASE WHEN brand_adopted_elevate_at IS NOT NULL THEN brand_id ELSE 0 END)) AS Adopted_Brand,
	CAST(COUNT(DISTINCT (CASE WHEN brand_adopted_elevate_at IS NOT NULL THEN brand_id ELSE 0 END))*1.000 / COUNT(DISTINCT brand_id) AS decimal(4,3)) as Adoption_Rate
FROM FaireDirect
WHERE brand_first_active_at IS NOT NULL
GROUP BY YEAR(brand_first_active_at), MONTH(brand_first_active_at)
ORDER BY YEAR(brand_first_active_at), MONTH(brand_first_active_at)


--The Recent Low Adoption Ratio Is It Because the Brands Have Less Retailers in Stockist?
--Results Show a Consistent Stockist Size In Recent Quarter. Besides, Since This is Self-reported Data We Give Less Weight in Making Decisions.

WITH cte AS (SELECT DISTINCT brand_id, brand_first_active_at, brand_stockist_count 
		    FROM FaireDirect
		    WHERE brand_first_active_at IS NOT NULL)
SELECT 
	YEAR(brand_first_active_at) AS Year, 
	DATEPART(QUARTER, brand_first_active_at) AS Quarter, 
	CAST(AVG(brand_stockist_count) AS int) AS Avg_Stockist
FROM cte
GROUP BY YEAR(brand_first_active_at), DATEPART(QUARTER, brand_first_active_at)
ORDER BY YEAR(brand_first_active_at), DATEPART(QUARTER, brand_first_active_at)










