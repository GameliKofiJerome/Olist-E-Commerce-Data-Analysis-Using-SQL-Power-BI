-- Q1. WHAT IS THE TOTAL REVENUE GENERATED BY OLIST, AND HOW HAS IT CHANGED OVER TIME?
-- SOLUTION STEPS:
-- LETS FOUND OUT THE TIMEFRAME IN WHICH THE DATA WAS CAPTURED.
SELECT 
    MIN(olist_orders.order_purchase_timestamp) AS start_date,
    MAX(olist_orders.order_purchase_timestamp) AS end_date
FROM
    olist_orders;
-- OUTPUT: THE RECORDED TIMEFRAME IS FROM "2016-09-04 21:15:19" TO "2018-10-17 17:30:18".

-- LETS CHECK THE NUMBER/COUNT OF ORDERS IN THE DATASET WITH RESPECT TO ORDER STATUS.
SELECT 
    olist_orders.order_status, COUNT(*) AS valid_orders
FROM
    olist_orders
WHERE
    order_delivered_customer_date IS NOT NULL
GROUP BY order_status;
-- OUTPUT: THERE ARE A TOTAL OF 8 UNIQUE ORDER STATUSES IN THE DATASET 
-- (DELIVERED, UNAVAILABLE, SHIPPED, CANCELED, INVOICED, PROCESSING, APPROVED, CREATED).

-- TO GET THE TOTAL REVENUE, WE WILL FOCUS ON ORDERS THAT HAVE AN ORDER_STATUS OF 'DELIVERED'.
SELECT 
    ROUND(SUM(opa.payment_value), 0) AS total_revenue
FROM
    olist_orders AS oo
        INNER JOIN
    olist_payments AS opa ON oo.order_id = opa.order_id
WHERE
    oo.order_status = 'delivered'
        AND order_delivered_customer_date IS NOT NULL;
-- OUTPUT: TOTAL REVENUE: $15,422,462

-- FOR THE REVENUE TREND, I WILL START WITH YEARLY, QUARTERLY, AND THEN MONTHLY
	-- YEARLY REVENUE TREND --
    SELECT 
    YEAR(oo.order_purchase_timestamp) AS yearly_sales,
    ROUND(SUM(opa.payment_value), 0) AS Revenue
FROM
    olist_orders AS oo
        INNER JOIN
    olist_payments AS opa ON oo.order_id = opa.order_id
WHERE
    oo.order_status = 'delivered'
        AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY yearly_sales
ORDER BY yearly_sales;

	-- QUARTERLY REVENUE TREND --
    SELECT 
    YEAR(oo.order_purchase_timestamp) AS yearly_sales,
    QUARTER(oo.order_purchase_timestamp) AS quarterly_sales,
    ROUND(SUM(opa.payment_value), 0) AS Revenue
FROM
    olist_orders AS oo
        INNER JOIN
    olist_payments AS opa ON oo.order_id = opa.order_id
WHERE
    oo.order_status = 'delivered'
        AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY yearly_sales , quarterly_sales
ORDER BY yearly_sales , quarterly_sales;
    
    -- MONTHLY REVENUE TREND --
    SELECT 
    YEAR(oo.order_purchase_timestamp) AS yearly_sales,
    MONTH(oo.order_purchase_timestamp) AS monthly_sales,
    QUARTER(oo.order_purchase_timestamp) AS quarterly_sales,
    ROUND(SUM(opa.payment_value), 0) AS Revenue
FROM
    olist_orders AS oo
        INNER JOIN
    olist_payments AS opa ON oo.order_id = opa.order_id
WHERE
    oo.order_status = 'delivered'
        AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY yearly_sales , monthly_sales, quarterly_sales
ORDER BY yearly_sales ASC;
-- OUTPUT: THE 11TH MONTH OF 2017, NOVEMBER RECORDED THE HIGHEST REVENUE.


-- Q2. HOW MANY ORDERS WERE PLACED ON OLIST, AND HOW DOES THIS VARY BY MONTH OR SEASON?
-- SOLUTION STEPS:
-- FIRST I WILL GET THE TOTAL NUMBER OF ORDERS PLACED, WILL OMIT CANCELED ORDERS
SELECT 
    COUNT(*) AS total_orders
FROM
    olist_orders
WHERE
    olist_orders.order_status <> 'canceled'
        AND olist_orders.order_delivered_customer_date IS NOT NULL;
-- OUTPUT: A TOTAL OF 98,816 ORDERS WERE PLACED ON OLIST.

-- LETS SEE THE TOTAL NUMBER OF ORDERS PLACED FOR EVERY QUARTER AND MONTH IN A GIVEN YEAR
-- SOLUTION STEPS:
SELECT 
    YEAR(order_purchase_timestamp) AS order_year,
    QUARTER(order_purchase_timestamp) AS order_quarter,
    MONTH(order_purchase_timestamp) AS order_month,
    COUNT(*) AS total_orders
FROM
    olist_orders
WHERE
    order_status <> 'canceled'
        AND order_delivered_customer_date IS NOT NULL
GROUP BY 
		order_year, 
		order_quarter,
        order_month
ORDER BY 
		order_year,
        order_quarter,
        order_month;


-- QUESTIONS 3 AND 10 BOTH SEEK TO ANSWER THE SAME QUESTION.
-- THE SECOND PART OF QUESTION 10 WHICH LOOKS AT THE SALES PERFORMANCE OF PRODUCTS WILL BE ANSWERED SEPARATELY.
-- Q3. WHAT ARE THE MOST POPULAR PRODUCT CATEGORIES ON OLIST? HOW DO THEIR SALES VOLUMES COMPARE TO EACH OTHER?
-- Q10. WHAT ARE THE TOP-SELLING PRODUCTS ON OLIST, AND HOW HAVE THEIR SALES TREND CHANGED OVER TIME?
-- SOLUTION STEPS:
-- LETS FOUND THE TOTAL NUMBER OF PRODUCTS ORDERED ON OLIST BASED ON ORDER_ID
SELECT 
    COUNT(oi.product_id) AS total_num_products
FROM
    olist_items AS oi
        JOIN
    olist_orders AS oo ON oi.order_id = oo.order_id
WHERE
    oo.order_status <> 'canceled'
        AND oo.order_delivered_customer_date IS NOT NULL;
-- OUTPUT: THE TOTAL NUMBER OF PRODUCTS ORDERED ON OLIST IS 112,108.

-- FOR THE MOST POPULAR PRODUCTS/ TOP SELLING PRODUCTS, WE WILL LOOK AT THE PERCENTAGE PROPORTION OF EACH PRODUCT AND WILL ALSO USE A CROSS JOIN
-- SOLUTION STEPS:
SELECT 
    op.product_category_name_english AS product_name,
    COUNT(oo.order_id) AS num_of_orders,
    ROUND((COUNT(oo.order_id) / total_orders.total_num_orders) * 100,
            2) AS percentage
FROM
    olist_orders AS oo
        JOIN
    olist_items AS oi ON oo.order_id = oi.order_id
        JOIN
    (SELECT 
        product_id, product_category_name_english
    FROM
        olist_products) AS op ON oi.product_id = op.product_id
        CROSS JOIN
    (SELECT 
        COUNT(oo.order_id) AS total_num_orders
    FROM
        olist_orders AS oo
    JOIN olist_items AS oi ON oo.order_id = oi.order_id
    JOIN olist_products AS op ON oi.product_id = op.product_id
    WHERE
        oo.order_status <> 'canceled'
            AND oo.order_delivered_customer_date IS NOT NULL) AS total_orders
WHERE
    oo.order_status <> 'canceled'
        AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY 
		product_name,
        total_num_orders
ORDER BY percentage DESC;

-- ALTERNATE SOLUTION: 
-- USING A CTE TO CALCULATE THE TOTAL NUMBER OF ORDERS
WITH total_orders AS (
    SELECT 
        COUNT(oo.order_id) AS total_num_orders
    FROM
        olist_orders AS oo
    JOIN olist_items AS oi ON oo.order_id = oi.order_id
    JOIN olist_products AS op ON oi.product_id = op.product_id
    WHERE
        oo.order_status <> 'canceled'
            AND oo.order_delivered_customer_date IS NOT NULL
)
SELECT 
    op.product_category_name_english AS product_name,
    COUNT(oo.order_id) AS num_of_orders,
    ROUND((COUNT(oo.order_id) / total_orders.total_num_orders) * 100, 2) AS percentage
FROM
    olist_orders AS oo
        JOIN
    olist_items AS oi ON oo.order_id = oi.order_id
        JOIN
    olist_products AS op ON oi.product_id = op.product_id
        CROSS JOIN
    total_orders
WHERE
    oo.order_status <> 'canceled'
	AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY 
	product_name, 
    total_num_orders
ORDER BY percentage DESC;
-- OUTPUT: THE MOST POPULAR / TOP SELLING PRODUCT CATEGORIES ON OLIST ARE BED_BATH_TABLE, HEALTH_BEAUTY AND SPORTS_LEISURE.
-- THIS IS IN RESPECT TO NUMBER OF ORDERS AND PERCENTAGE PROPORTION.

-- TO SEE THE PRODUCTS PERFORMANCE DURING THE 3-YEAR PERIOD, I ADDED THEIR RANKING IN DESCENDING ORDER.
-- SOLUTION STEPS:
SELECT 
	YEAR(oo.order_purchase_timestamp) AS order_year,
	op.product_category_name_english AS product_name,
	COUNT(oo.order_id) AS num_of_orders,
	RANK() OVER(ORDER BY count(oo.order_id) DESC) AS ranking
FROM 
	olist_orders AS oo
JOIN 
	olist_items AS oi ON oo.order_id = oi.order_id
JOIN 
	(SELECT 
		product_id, 
		product_category_name_english 
	FROM olist_products AS op) AS op ON oi.product_id = op.product_id
WHERE 
	oo.order_status <> 'canceled'
	AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY 
		product_name, order_year
ORDER BY ranking;

-- ALTERNATE SOLUTION 1:
-- USING A CTE NAMED ORDER_COUNTS TO CALCULATE THE NUMBER OF ORDERS FOR EACH PRODUCT CATEGORY AND YEAR, 
-- SIMILAR TO THE MAIN QUERY'S GROUPING LOGIC.
WITH order_counts AS (
	SELECT 
		YEAR(oo.order_purchase_timestamp) AS order_year,
		COUNT(oo.order_id) AS num_of_orders,
		op.product_category_name_english AS product_name
    FROM 
		olist_orders AS oo
    JOIN 
		olist_items AS oi ON oo.order_id = oi.order_id
    JOIN 
		olist_products AS op ON oi.product_id = op.product_id
    WHERE 
		oo.order_status <> 'canceled'
		AND oo.order_delivered_customer_date IS NOT NULL
    GROUP BY 
		order_year, 
		product_name
)
SELECT 
	order_year, 
    product_name, 
    num_of_orders,
	RANK() OVER(ORDER BY num_of_orders DESC) AS ranking
FROM order_counts
ORDER BY ranking;
-- OUTPUT: FROM THE RANKINGS, THE TOP PERFORMING PRODUCTS FOR THE 3 YEAR PERIOD ARE HEALTH_BEAUTY, BED_BATH_TABLE, COMPUTERS_ACCESSORIES 
-- AND SPORTS_LEISURE.

-- ALTERNATE SOLUTION 2:
-- HERE WE GROUP PRODUCTS WITH RESPECT TO THE YEAR (2016, 2017, 2018) AND RANKED THE PRODUCTS BY THE NUMBER OF ORDERS FROM HIGHEST TO LOWEST
-- TO KNOW THE TOP PEFORMING PRODUCTS IN EACH YEAR.
SELECT 
	YEAR(oo.order_purchase_timestamp) AS order_year,
	op.product_category_name_english AS product_name,
	COUNT(oo.order_id) AS num_of_orders,
	RANK() OVER(PARTITION BY YEAR(oo.order_purchase_timestamp) ORDER BY COUNT(oo.order_id) DESC) AS ranking
FROM 
	olist_orders AS oo
JOIN 
	olist_items AS oi ON oo.order_id = oi.order_id
JOIN 
	(SELECT 
		product_id, 
		product_category_name_english 
	FROM olist_products) AS op ON oi.product_id = op.product_id
WHERE 
	oo.order_status <> 'canceled'
	AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY 
	order_year, product_name
ORDER BY 
	order_year, ranking;
-- OUTPUT: 
-- IN 2016, THE BEST PERFORMING PRODUCTS WERE FURNITURE_DECOR, HEALTH_BEAUTY, PERFUMERY, TOYS AND COMPUTERS_ACCESSORIES.
-- IN 2017, THE BEST PERFORMING PRODUCTS WERE BED_BATH_TABLE, FURNITURE_DECOR, SPORTS_LEISURE, HEALTH_BEAUTY AND COMPUTERS_ACCESSORIES.
-- IN 2018, THE BEST PERFORMING PRODUCTS WERE HEALTH_BEAUTY, BED_BATH_TABLE, COMPUTERS_ACCESSORIES, SPORTS_LEISURE AND FURINTURE_DECOR.


-- Q4. WHAT IS THE AVERAGE ORDER VALUE (AOV) ON OLIST? HOW DOES THIS VARY BY PRODUCT CATEGORY OR PAYMENT METHOD?
-- SOLUTION STEPS:
-- AOV IS A CRUCIAL METRIC IN UNDERSTANDING THE OVERALL PERFORMANCE OF PRODUCTS COMPARED TO THE COST PER ORDER(CPO).
-- IT ALLOWS A BUSINESS TO DETERMINE THE PERFORMANCE OF EACH PRODUCT.
-- AOV = TOTAL REVENUE / TOTAL ORDERS
-- CPO = TOTAL COST OF PRODUCT / TOTAL ORDERS

SELECT 
    ROUND(SUM(opa.payment_value) / COUNT(DISTINCT oo.order_id),
            2) AS AOV,
    ROUND(SUM(oi.cost) / COUNT(DISTINCT oo.order_id),
            2) AS CPO,
    ROUND((SUM(opa.payment_value) - SUM(oi.cost)) / COUNT(DISTINCT oo.order_id),
            2) AS profit_per_order
FROM
    olist_orders AS oo
        JOIN
    (SELECT 
        opa.order_id, SUM(opa.payment_value) AS payment_value
    FROM
        olist_payments AS opa
    JOIN olist_orders AS oo ON oo.order_id = opa.order_id
    WHERE
        oo.order_status <> 'canceled'
            AND oo.order_delivered_customer_date IS NOT NULL
    GROUP BY opa.order_id) AS opa ON oo.order_id = opa.order_id
        JOIN
    (SELECT 
        oi.order_id, SUM(oi.price + oi.freight_value) AS cost
    FROM
        olist_items AS oi
    JOIN olist_orders AS oo ON oo.order_id = oi.order_id
    WHERE
        oo.order_status <> 'canceled'
            AND oo.order_delivered_customer_date IS NOT NULL
    GROUP BY oi.order_id) AS oi ON oo.order_id = oi.order_id;
    
-- ALTERNATE SOLUTION:
-- USING CTES (PAYMENT_TOTALS AND COST_TOTALS) TO CALCULATE THE TOTAL PAYMENT AND TOTAL COST FOR EACH ORDER.
-- THE MAIN QUERY THEN CALCULATES THE AOV, CPO, AND PROFIT PER ORDER USING THE TOTALS CALCULATED IN THE CTES, SIMILAR TO THE MAIN QUERY'S LOGIC.
WITH payment_totals AS(
	select 
		oo.order_id,
		sum(opa.payment_value) as total_payment
    from 
		olist_orders as oo
    join olist_payments as opa on oo.order_id = opa.order_id
    where 
		oo.order_status <> 'canceled'
		and oo.order_delivered_customer_date is not null
    GROUP BY 
		oo.order_id
),
cost_totals as (
	select 
		oo.order_id,
		sum(oi.price + oi.freight_value) as total_cost
    from 
		olist_orders as oo
    join olist_items as oi on oo.order_id = oi.order_id
    where 
		oo.order_status <> 'canceled'
		and oo.order_delivered_customer_date is not null
    GROUP BY 
		oo.order_id
)
select 
	round(sum(total_payment) / count(oo.order_id), 2) as AOV,
	round(sum(total_cost) / count(oo.order_id), 2) as CPO,
	round(sum(total_payment) / count(oo.order_id) - sum(total_cost) / count(oo.order_id), 2) as profit_per_order
from 
	olist_orders as oo
join 
	payment_totals as pt on oo.order_id = pt.order_id
join 
	cost_totals as ct on oo.order_id = ct.order_id;
-- OUTPUT: AVERAGE ORDER VALUE (AOV) IS 160.28, THE COST PER ORDER (CPO) IS ALSO 160.25 AND THE PROFIT_PER_ORDER IS 0.03


-- HOW DOES THE AVERAGE ORDER VALUE (AOV) VARY BY PRODUCT CATEGORY?
-- SOLUTION STEPS:
SELECT 
    op.product_category_name_english AS product_name,
    ROUND(SUM(opa.payment_value) / COUNT(DISTINCT oo.order_id), 0) AS AOV,
    COUNT(DISTINCT oo.order_id) AS num_orders
FROM
    olist_orders AS oo
        JOIN olist_items AS oi ON oo.order_id = oi.order_id
        JOIN olist_products AS op ON oi.product_id = op.product_id
        JOIN olist_payments AS opa ON oo.order_id = opa.order_id
WHERE
    oo.order_status <> 'canceled'
        AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY 
    op.product_category_name_english
ORDER BY 
	AOV DESC; # SHOWS THE PRODUCT CATEGORIES WITH THE HIGHEST AVERAGE ORDER VALUE.
-- num_orders DESC; # SHOWS THE AVERAGE ORDER VALUE WITH RESPECT TO THE NUMBER OF ORDERS PER PRODUCT CATEGORY (HIGHEST TO LOWEST).
-- OUTPUT: THE PRODUCT CATEGORY WITH THE HIGHEST AOV IS COMPUTERS WITH AN AOV OF 1542.    

-- HOW DOES THE AVERAGE ORDER VALUE (AOV) VARY BY PAYMENT TYPE?
-- SOLUTION STEPS:
SELECT 
    opa.payment_type,
    ROUND(SUM(opa.payment_value) / COUNT(DISTINCT oo.order_id),
            0) AS AOV
FROM
    olist_orders AS oo
        JOIN
    olist_payments AS opa ON oo.order_id = opa.order_id
WHERE
    oo.order_status <> 'canceled'
        AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY opa.payment_type
ORDER BY AOV DESC;
-- OUTPUT: CREDIT_CARD PAYMENTS HAD THE HIGHEST AVERAGE ORDER VALUE WITH 164, FOLLOWED BY BOLETO WITH AN AVERAGE ORDER VALUE OF 145, 
-- DEBIT_CARD WITH 142 AND THEN VOUCHER PAYMENTS WITH AN AOV OF 94.


-- Q5. HOW MANY SELLERS ARE ACTIVE ON OLIST, AND HOW DOES THIS NUMBER CHANGEOVER TIME?
-- SOLUTION STEPS:
-- HERE, AN ACTIVE SELLER WILL BE A SELLER WHO ADDED A NEW LISTING IN THE LAST 30 DAYS
SELECT 
    COUNT(DISTINCT seller_id) AS unique_sellers
FROM
    olist_sellers;
-- OUTPUT: THERE ARE 3095 UNIQUE SELLERS ON OLIST

-- OF THE ABOVE NUMBER LETS FIND OUT THE NUMBER OF ACTIVE SELLERS
-- SOLUTION STEPS:
select count(seller_id) as num_active_sellers
from (
	select seller_id,
    (datediff(Max(order_purchase_timestamp), Max(previous_order_date))) as days_between_orders
    from(
			select oi.seller_id, oo.order_id, oo.order_purchase_timestamp,
            LAG(oo.order_purchase_timestamp, 1)
            over(partition by oi.seller_id order by oo.order_purchase_timestamp) as previous_order_date
            from olist_orders as oo
            join olist_items as oi on oi.order_id = oo.order_id
            join olist_sellers as os on oi.seller_id = os.seller_id
            where oo.order_status <> 'canceled'
            and oo.order_delivered_customer_date is not null
            order by oi.seller_id, oo.order_purchase_timestamp desc
		) as pre_order_date
        group by seller_id
        having
        datediff(Max(order_purchase_timestamp), Max(previous_order_date)) <=30
        and
        datediff(Max(order_purchase_timestamp), Max(previous_order_date)) is not null
        order by 
        Max(order_purchase_timestamp), Max(previous_order_date)
) as active_seller;
-- OUTPUT: THE NUMBER OF ACTIVE SELLERS ON OLIST IS 1948 FOR THE PERIOD THIS DATA WAS CAPTURED.

-- HOW HAS THE NUMBER OF ACTIVE SELLERS ON OLIST CHANGED OVER TIME?
-- SOLUTION STEPS:
-- WE WILL LOOK AT THIS TREND WITH RESPECT TO YEAR, QUARTER AND MONTH
SELECT 
    the_year, 
    the_quarter, 
    the_month,
    COUNT(DISTINCT seller_id) as active_seller_count
FROM (
    SELECT 
        seller_id,
        YEAR(order_purchase_timestamp) as the_year,
        QUARTER(order_purchase_timestamp) as the_quarter,
        MONTH(order_purchase_timestamp) as the_month
    FROM (
        SELECT 
            oi.seller_id,
            oo.order_purchase_timestamp,
            LAG(oo.order_purchase_timestamp, 1) OVER (PARTITION BY oi.seller_id ORDER BY oo.order_purchase_timestamp) AS previous_order_date
        FROM
            olist_orders as oo
        JOIN 
            olist_items as oi ON oi.order_id = oo.order_id
        JOIN 
            olist_sellers as os ON oi.seller_id = os.seller_id
        WHERE
            oo.order_status <> 'canceled'
            AND oo.order_delivered_customer_date IS NOT NULL
    ) as pre_order_date
    GROUP BY
        seller_id, 
        the_year, 
        the_quarter, 
        the_month
    HAVING
        DATEDIFF(MAX(order_purchase_timestamp), MAX(previous_order_date)) <= 30
        AND MAX(order_purchase_timestamp) IS NOT NULL
) as sub
GROUP BY 
    the_year, the_quarter, the_month
ORDER BY
    the_year, the_quarter, the_month;
-- OUTPUT: 
-- THE MONTH OF AUGUST IN THE THIRD QUARTER OF THE 2018 RECORDED THE HIGHEST NUMBER OF ACTIVE SELLERS WITH A TOTAL NUMBER OF 1038.


-- Q6. WHAT IS THE DISTRIBUTION OF SELLER RATINGS ON OLIST, AND HOW DOES THIS IMPACT SALES PERFORMANCE?
-- THE OLIST_REVIEW TABLE HAS 99,224 ROWS AND THERE ARE 555 UNIQUE ORDER_IDS THAT HAVE MORE THAN ONE REVIEW.
-- SOLUTION STEPS:
SELECT 
    review_score,
    COUNT(*) AS num_of_reviews,
    ROUND((COUNT(*) / (SELECT 
                    COUNT(*)
                FROM
                    olist_reviews) * 100),
            2) AS review_percentage
FROM
    olist_reviews
GROUP BY review_score
ORDER BY review_score DESC;
-- OUTPUT: 57.78% OF CUSTOMERS WERE HIGHLY SATISFIED WITH THE ONLINE SHOPPING PLATFORM GIVING A REVIEW RATING OF 5.
-- 11.51% GAVE THE PLATFORM A RATING OF 1.

-- HOW HAS BEEN THE IMPACT OF THESE RATINGS ON SALES PERFORMANCE ON THE OLIST PLATFORM?
-- SOLUTION STEPS:
-- TO JOIN THE CORRECT ROWS IN THE TABLES, VIEWS FOR REVIEW AND PAYMENT TABLES WERE CREATED AND JOINED
-- REVIEW VIEW TABLE:
CREATE OR REPLACE VIEW review AS
    SELECT 
        order_id, ROUND(AVG(review_score), 0) AS review_score
    FROM
        olist_reviews
    WHERE
        order_id IN (SELECT 
                order_id
            FROM
                olist_orders
            WHERE
                order_status <> 'canceled'
                    AND order_delivered_customer_date IS NOT NULL)
    GROUP BY order_id;

-- PAYMENT VIEW TABLE:
CREATE OR REPLACE VIEW payment AS
    SELECT 
        order_id, ROUND(SUM(payment_value), 2) AS payment_value
    FROM
        olist_payments
    WHERE
        order_id IN (SELECT 
                order_id
            FROM
                olist_orders
            WHERE
                order_status <> 'canceled'
                    AND order_delivered_customer_date IS NOT NULL)
    GROUP BY order_id;

-- LETS JOIN THE TWO VIEWS TO GET THE TOTAL REVENUE WITH RESPCT TO EACH REVIEW SCORE
SELECT 
    r.review_score,
    COALESCE(ROUND(SUM(p.payment_value), 0), 0) as total_payment_value,
    ROUND((COALESCE(ROUND(SUM(p.payment_value), 0), 0) / SUM(SUM(p.payment_value)) OVER()) * 100, 2) as percentage
FROM 
    review as r
JOIN 
    payment as p 
    ON r.order_id = p.order_id
GROUP BY 
    r.review_score
ORDER BY 
    r.review_score DESC;
-- OUTPUT: THE REVIEW SCORE OF 5 RECORDED THE HIGHEST REVENUE OF 8,902,341 AND THE HIGHEST PERCENTAGE PROPORTION OF 56.63%


-- Q7. HOW MANY CUSTOMERS HAVE MADE REPEATED PURCHASES ON OLIST? WHAT PERCENTAGE OF TOTAL SALES DO THEY ACCOUNT FOR?
-- SOLUTION STEPS:
with return_customers as (
	select oc.customer_unique_id as rep_customer,
	count(distinct oo.order_id) as num_rep_customers
	from 
		olist_orders as oo
	join 
		olist_customers as oc on oo.customer_id = oc.customer_id
	where oo.order_status <> 'canceled'
	and oo.order_delivered_customer_date is not null
	group by rep_customer
	having count(oo.order_id) > 1
)
select count(*) as num_return_customers
from return_customers;
-- OUTPUT: WE HAD A TOTAL OF 2924 REPEAT CUSTOMERS ON THE OLIST PLATFORM.

-- LETS FIND THE TOTAL REVENUE FROM THESE REPEAT CUSTOMERS ON THE OLIST PLATFORM
WITH repeat_customers AS (
    SELECT 
        oc.customer_unique_id AS rep_customers,
        SUM(opa.payment_value) AS total_revenue
    FROM
        olist_orders AS oo
    JOIN 
		olist_customers AS oc ON oo.customer_id = oc.customer_id
    JOIN 
		olist_payments AS opa ON oo.order_id = opa.order_id
    WHERE
        oo.order_status <> 'canceled'
        AND oo.order_delivered_customer_date IS NOT NULL
    GROUP BY rep_customers
    HAVING COUNT(DISTINCT oo.order_id) > 1
)
SELECT ROUND(SUM(total_revenue), 0) AS revenue_rep_customers
FROM repeat_customers;
-- OUTPUT: THE TOTAL REVENUE REALISED FROM REPEAT CUSTOMERS ON THE OLIST PLATFORM IS 899,381.

-- LETS DETERMINE THE PERCENTAGE OF REPEAT CUSTOMERS REVENUE IN COMPARATION TO TOTAL REVENUE ON THE OLIST PLATFORM.
-- SOLUTION STEPS:
SELECT 
    ROUND((SUM(CASE
                WHEN
                    oc.customer_unique_id IN (SELECT 
                            oc.customer_unique_id
                        FROM
                            olist_orders AS oo
                                JOIN
                            olist_customers AS oc ON oo.customer_id = oc.customer_id
                        WHERE
                            oo.order_status <> 'canceled'
                                AND oo.order_delivered_customer_date IS NOT NULL
                        GROUP BY oc.customer_unique_id
                        HAVING COUNT(oo.order_id) > 1)
                THEN
                    opa.payment_value
                ELSE 0
            END) / SUM(opa.payment_value)) * 100,
            2) AS percent_rep_customer_rev
FROM
    olist_orders AS oo
        JOIN
    olist_customers AS oc ON oo.customer_id = oc.customer_id
        JOIN
    olist_payments AS opa ON oo.order_id = opa.order_id
WHERE
    oo.order_status <> 'canceled'
        AND oo.order_delivered_customer_date IS NOT NULL;
-- OUTPUT: THE PERCENTAGE OF TOTAL REVENUE FROM REPEAT CUSTOMERS ON THE OLIST PLATFORM WAS FOUND TO BE JUST 5.67%.


-- Q8. WHAT IS THE AVERAGE CUSTOMER RATING FOR PRODUCTS SOLD ON OLIST? HOW DOES THIS AFFECT SALES PERFORMANCE?
-- LETS FIND OUT THE AVERAGE REVIEW SCORE OR RATING FROM ORDERS MADE ON OLIST
-- SOLUTION STEPS:
SELECT 
    ROUND(AVG(ore.review_score), 1) AS avg_review
FROM
    olist_orders AS oo
        JOIN
    olist_reviews AS ore ON oo.order_id = ore.order_id
WHERE
    oo.order_status <> 'canceled'
        AND oo.order_delivered_customer_date IS NOT NULL;
-- OUTPUT: THE AVERAGE REVIEW SCORE IS 4.1

-- LETS FIND OUT HOW THE AVERAGE REVIEW SCORES AFFECT SALES PERFORMANCE WITH RESPECT TO THE NUMBER OF PRODUCT ORDERS
-- SOLUTION STEPS:
WITH ProductOrders AS (
    SELECT 
        oi.order_id,
        op.product_id,
        op.product_category_name_english AS product_name
    FROM 
        olist_items AS oi
    JOIN 
        olist_orders AS oo ON oi.order_id = oo.order_id
    JOIN 
        olist_products AS op ON oi.product_id = op.product_id
    WHERE 
        oo.order_status <> 'canceled'
        AND oo.order_delivered_customer_date IS NOT NULL
),
ProductReviews AS (
    SELECT 
        oo.order_id,
        AVG(ore.review_score) AS avg_review_score
    FROM 
        olist_reviews AS ore
    JOIN 
        olist_orders AS oo ON ore.order_id = oo.order_id
    WHERE 
        oo.order_status <> 'canceled'
        AND oo.order_delivered_customer_date IS NOT NULL
    GROUP BY 
        oo.order_id
)
SELECT 
    product_name,
    ROUND(AVG(pr.avg_review_score), 1) AS avg_review_score,
    COUNT(po.order_id) AS num_of_orders,
    RANK() OVER (ORDER BY COUNT(po.order_id) DESC) AS product_rank
FROM 
    ProductOrders AS po
JOIN 
    ProductReviews AS pr ON po.order_id = pr.order_id
GROUP BY 
    product_name
ORDER BY 
    product_rank;
-- OUTPUT: SALES PERFORMANCE ON OLIST HAS BEEN POSITIVE WITH MAJORITY OF PRODUCT SALES HAVING AN APPROXIMATE AVERAGE REVIEW SCORE OF 4.


-- Q9. WHAT IS THE NUMBER OF CANCELED ORDERS ON OLIST, AND WHAT IS THE PERCENTAGE OF ALL CANCELED ORDERS?
-- SOLUTION STEPS:
SELECT 
	order_status,
	count(order_id) as num_order,
	round(100 * count(order_id) / sum(count(order_id)) over(), 2) as percentage
FROM 
	olist_orders as oo
GROUP BY
	order_status;
-- OUTPUT: THE TOTAL NUMBER OF CANCELED ORDERS IS 625 ACCOUNTING FOR 0.63% OF ALL ORDERS ON THE PLATFORM


-- Q11. WHICH PAYMENT METHODS ARE MOST COMMONLY USED BY OLIST CUSTOMERS, AND HOW DOES THIS VARY BY PRODUCT CATEGORY OR GEOGRAPHIC REGION?
-- PAYMENT METHOD COMMONLY USED
-- SOLUTION STEPS:
SELECT 
    payment_type,
    COUNT(*) AS total_num_payments,
    ROUND((COUNT(*) / total_payments.total_count) * 100,
            2) AS percentage
FROM
    olist_payments AS opa
JOIN
    olist_orders AS oo ON oo.order_id = opa.order_id
JOIN
    (SELECT 
        COUNT(*) AS total_count
    FROM
        olist_payments) AS total_payments
WHERE
    oo.order_status <> 'canceled'
        AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY payment_type , 
		 total_payments.total_count;
-- OUTPUT: CREDIT CARD PAYMENTS WERE THE HIGHEST WITH A TOTAL OF 76,351 MAKING UP 73.49% OF ALL PAYMENT TYPES ON THE OLIST PLATFORM.

-- LETS LOOK AT HOW THESE PAYMENT METHODS VARIED BY PRODUCT CATEGORIES.
-- SOLUTION STEPS:
SELECT 
    op.product_category_name_english AS product_name,
    opa.payment_type,
    COUNT(*) AS num_of_orders,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS num_of_orders_rank
FROM 
    olist_orders AS oo
JOIN 
    olist_items AS oi ON oi.order_id = oo.order_id
JOIN 
    olist_products AS op ON oi.product_id = op.product_id
JOIN 
    olist_payments AS opa ON opa.order_id = oo.order_id
WHERE 
    oo.order_status <> 'canceled'
    AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY 
    product_name, payment_type
ORDER BY 
    num_of_orders DESC;
-- OUTPUT: FOR THE TOP 10 PRODUCT CATEGORIES WITH RESPECT TO NUMBER OF ORDERS, CREDIT CARD PAYMENT METHOD WAS THE MOST USED.

-- LETS LOOK AT NUMBER OF ORDERS BY GEOLOCATION AND THE PAYMENT METHODS MOST USED BY CUSTOMERS IN THESE LOCATIONS
-- SOLUTION STEPS:
select oc.customer_city as city,
	   opa.payment_type as payment_type,
       count(distinct opa.order_id) as num_of_orders,
       rank() over (order by count(distinct opa.order_id) desc) as order_num_rank
from 
	olist_payments as opa
join 
	olist_orders as oo on oo.order_id = opa.order_id
join 
	olist_customers as oc on oc.customer_id = oo.customer_id
where 
	oo.order_status <> 'canceled'
	and oo.order_delivered_customer_date is not null
group by 
	payment_type, city
order by 
	num_of_orders desc;
-- OUTPUT: THE HIGHEST AMOUNT OF ORDERS CAME FROM SAO PAULO WITH A TOTAL OREDER NUMBER OF 12,088 AND FOR THESE ORDERS
-- CREDIT CARD PAYMENT METHOD WAS USED.


-- Q12. WHICH PRODUCT CATEGORIES HAVE THE HIGHEST PROFIT MARGINS?
-- SOLUTION STEPS:
SELECT 
    op.product_category_name_english AS product_name,
    COUNT(DISTINCT oo.order_id) AS num_orders,
    ROUND(SUM(opa.payment_value), 2) AS total_payment,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_cost,
    ROUND(SUM(opa.payment_value - (oi.price + oi.freight_value)), 2) AS total_profit,
    ROUND(((SUM(opa.payment_value) - SUM(oi.price + oi.freight_value)) / SUM(opa.payment_value)) * 100, 2) AS profit_margin_percentage
FROM
    olist_orders AS oo
        JOIN olist_items AS oi ON oo.order_id = oi.order_id
        JOIN olist_products AS op ON oi.product_id = op.product_id
        JOIN olist_payments AS opa ON oo.order_id = opa.order_id
WHERE
    oo.order_status <> 'canceled'
        AND oo.order_delivered_customer_date IS NOT NULL
GROUP BY
    op.product_category_name_english
ORDER BY
    total_profit DESC;
-- OUTPUT: COMPUTER_ACCESSORIES RECORDED THE HIGHEST PROFIT OF $484,417.65 ACCOUNTING FOR 30.82% OF TOTAL PROFITS ON OLIST.
-- ALTHOUGH THIS CATEGORY DID NOT HAVE THE HIGHEST NUMBER OF ORDERS.
-- ALTHOUGH BED_BATH_TABLE RECORDED THE HIGHEST NUMBER OF ORDERS 9399, IT RECORDED THE THIRD HIGHEST PROFIT MARGIN PERCENTAGE OF 23.51%


-- Q13. WHICH GEOLOCATION HAS HIGH CUSTOMER DENSITY? CALCULATE CUSTOMER RETENTION RATE (CRR) ACCORDING TO GEOLOCATIONS.
-- SOLUTION STEPS:
with return_customers as (
	select 
		oc.customer_state as state,
        count(oc.customer_unique_id) as ret_customers
	from 
		olist_customers as oc
	where 
		oc.customer_unique_id in (
			select 
				unique_id 
			from (
				select 
					oc.customer_unique_id as unique_id,
                    count(DISTINCT oo.order_id)
				from 
					olist_orders as oo 
				join olist_customers as oc on oc.customer_id = oo.customer_id
                where	
					oo.order_status <> 'canceled' 
                    and oo.order_delivered_customer_date is not null
				group by 
					oc.customer_unique_id 
				having 	
					count(oo.order_id) > 1
				order by 
					count(DISTINCT oo.order_id) desc
            ) as rep_customers
	)
	group by 
		oc.customer_state
        ),
total_customers as (
	select 
		oc.customer_state as state,
        count(oc.customer_unique_id) as tot_customer
	from 
		olist_customers as oc
    join olist_orders as oo on
		oo.customer_id = oc.customer_id 
	where 
		oo.order_status <> 'canceled'
        and oo.order_delivered_customer_date is not null
	group by 
		oc.customer_state
)
select 
	rc.state as state,
    tc.tot_customer as number_of_customers,
    rc.ret_customers as num_rep_customers,
    round((ret_customers / tot_customer) * 100, 2) as CRR
from 
	return_customers as rc
join total_customers as tc on
	rc.state = tc.state
group by 
	state
order by 
    CRR DESC,
-- number_of_customers DESC;
-- OUTPUT: SAO PAULO (SP) HAD THE HIGHST CUSTOMER DENSITY OF 41419, OUT OF WHICH 2678 WERE REPEAT CUSTOMERS AND RECORDED A CRR OF 6.47%
-- THE STATE WITH THE HIGHEST CUSTOMER RETENTION RATE IS ACRE (AC) WITH A CRR OF 9.88%, WITH 81 CUSTOMERS AND ONLY 8 REPEAT CUSTOMERS

