################################################### Data Understanding & Validation (Basic but mandatory)##########################################

#Q.1 Fetch all rows
select *
from ecommerce_shipping.ecommerce_shipping_data;

# Q.2 Count records
select count(*)
from ecommerce_shipping.ecommerce_shipping_data;

# Q.3 Distinct IDs
select count(distinct ORDER_ID)
from ecommerce_shipping.ecommerce_shipping_data;

# Q.4 Duplicate IDs
SELECT ORDER_ID, COUNT(*) AS cnt
FROM ecommerce_shipping.ecommerce_shipping_data
GROUP BY ORDER_ID
HAVING COUNT(*) > 1;

# Q.5 Find rows where important columns are NULL
SELECT *
FROM ecommerce_shipping.ecommerce_shipping_data
WHERE Warehouse_block IS NULL
   OR Mode_of_Shipment IS NULL
   OR Weight_in_gms IS NULL
   OR Customer_rating IS NULL;
 
 # Q.6 Find percentage of missing values per column
SELECT 
   SUM(Warehouse_block IS NULL)/COUNT(*)*100 AS wh_null_pct,
   SUM(Mode_of_Shipment IS NULL)/COUNT(*)*100 AS ship_null_pct,
   SUM(Customer_rating IS NULL)/COUNT(*)*100 AS rating_null_pct
FROM ecommerce_shipping.ecommerce_shipping_data;
   

##############################################Descriptive Aggregation & GROUP BY (Core Skill)####################################

# Q.1 WAREHOUSE DISTRIBUTION
select Warehouse_block,count(*) as Total_Shipping
from ecommerce_shipping.ecommerce_shipping_data;

# Q.2 SHIPMENT MODE USAGE
select Mode_of_Shipment,count(*)
from ecommerce_shipping.ecommerce_shipping_data
group by Mode_of_Shipment;

# Q.3 CUSTOMER RATING ANALYSIS
select Customer_rating,count(*)
from ecommerce_shipping.ecommerce_shipping_data
group by Customer_rating;

# Q.4 ONTIME V/S DELAYED COUNT
select Reached_on_Time_Y_N, count(*)
from ecommerce_shipping.ecommerce_shipping_data
group by Reached_on_Time_Y_N;

# Q.5 AVERAGE DISCOUNT BY DELIVERY STATUS
select Reached_on_Time_Y_N,avg(Discount_offered)
from ecommerce_shipping.ecommerce_shipping_data
group by Reached_on_Time_Y_N;

# Q.6 WAREHOUSE EFFICIENCY
select Warehouse_block, avg(Customer_rating)
from ecommerce_shipping.ecommerce_shipping_data
group by Warehouse_block;

# Q.7 AVERAGE WEIGHT COMPARISON
select avg(Weight_in_gms) as avg_weight_ontime
from ecommerce_shipping.ecommerce_shipping_data
where Reached_on_Time_Y_N;

# Q.8  DELAY PERCENTAGE PER CUSTOMER CARE CALLS
select Customer_care_calls, 
       avg( case 
       when Reached_on_Time_Y_N=1
       then 1 else 0
       end)*100 as Delay_Percentage
 from ecommerce_shipping.ecommerce_shipping_data
 group by Customer_care_calls;

#################################################KPI & Performance Analysis (Business Thinking)#######################################
#################################################Delivery Performance Analysis########################################################

# Q.1 DELAY PERCENTAGE PER SHIPMENT MODE
SELECT Mode_of_Shipment,
       SUM(CASE WHEN Reached_on_Time_Y_N = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS delay_percentage
FROM ecommerce_shipping.ecommerce_shipping_data
GROUP BY Mode_of_Shipment;

# Q.2 On-time percentage overall
SELECT 
    AVG(CASE WHEN Reached_on_Time_Y_N = 1 THEN 1 ELSE 0 END) * 100 
        AS ontime_percentage
FROM ecommerce_shipping.ecommerce_shipping_data;

# Q.3 Delay % by warehouse
SELECT Warehouse_block,
       AVG(CASE WHEN Reached_on_Time_Y_N = 0 THEN 1 ELSE 0 END) * 100 
           AS delay_percentage
FROM ecommerce_shipping.ecommerce_shipping_data
GROUP BY Warehouse_block;

############################################### Weight & Shipment Impact ######################################

# Q1. Does heavier weight cause delay?
SELECT Reached_on_Time_Y_N,
       AVG(Weight_in_gms) AS avg_weight
FROM ecommerce_shipping.ecommerce_shipping_data
GROUP BY Reached_on_Time_Y_N;

# Q2. Shipment mode with highest average weight

SELECT Mode_of_Shipment,
       AVG(Weight_in_gms) AS avg_weight
FROM ecommerce_shipping.ecommerce_shipping_data
GROUP BY Mode_of_Shipment
ORDER BY avg_weight DESC;

############################################# Customer Experience #####################################
# Q.1 Average customer rating for delayed vs on-time
SELECT Reached_on_Time_Y_N,
       AVG(Customer_rating) AS avg_rating
FROM ecommerce_shipping.ecommerce_shipping_data
GROUP BY Reached_on_Time_Y_N;

# Q.2 Do more customer care calls mean delay?
SELECT Customer_care_calls,
       AVG(CASE WHEN Reached_on_Time_Y_N = 0 THEN 1 ELSE 0 END) * 100 
           AS delay_percentage
FROM ecommerce_shipping.ecommerce_shipping_data
GROUP BY Customer_care_calls
ORDER BY Customer_care_calls;

########################################## Discount & Cost Strategy##########################################
# Q.1 Average discount by shipment mode
SELECT Mode_of_Shipment,
       AVG(Discount_offered) AS avg_discount
FROM ecommerce_shipping.ecommerce_shipping_data
GROUP BY Mode_of_Shipment;

# Q.2 Are higher discounts linked to delays?
SELECT Reached_on_Time_Y_N,
       AVG(Discount_offered) AS avg_discount
FROM ecommerce_shipping.ecommerce_shipping_data
GROUP BY Reached_on_Time_Y_N;

########################################### Ranking & Top-N Problems (Very Popular in Interviews) ########################

# Q.1 Top 3 warehouses
SELECT Warehouse_block,
       AVG(CASE WHEN Reached_on_Time_Y_N = 0 THEN 1 ELSE 0 END) * 100 
           AS delay_percentage
FROM ecommerce_shipping.ecommerce_shipping_data
GROUP BY Warehouse_block
ORDER BY delay_percentage DESC
LIMIT 3;

# Q.2 Shipment mode most prone to delay
SELECT Mode_of_Shipment,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN Reached_on_Time_Y_N = 0 THEN 1 ELSE 0 END) AS delayed_orders
FROM ecommerce_shipping.ecommerce_shipping_data
GROUP BY Mode_of_Shipment
ORDER BY delayed_orders DESC;

################################################### Window-Function Style Questions (Advanced)#####################################

# Q.1 Rank shipment modes by delay percentage
SELECT Mode_of_Shipment,
       AVG(CASE WHEN Reached_on_Time_Y_N = 0 THEN 1 ELSE 0 END) * 100 AS delay_pct,
       RANK() OVER (ORDER BY 
            AVG(CASE WHEN Reached_on_Time_Y_N = 0 THEN 1 ELSE 0 END) DESC) AS rnk
FROM ecommerce_shipping.ecommerce_shipping_data
GROUP BY Mode_of_Shipment;

# Q.2 Warehouse performance vs overall average
WITH overall AS (
    SELECT AVG(CASE WHEN Reached_on_Time_Y_N = 1 THEN 1 ELSE 0 END) AS avg_ontime
    FROM ecommerce_shipping.ecommerce_shipping_data
)
SELECT w.Warehouse_block,
       AVG(CASE WHEN w.Reached_on_Time_Y_N = 1 THEN 1 ELSE 0 END) AS warehouse_ontime,
       o.avg_ontime
FROM ecommerce_shipping.ecommerce_shipping_data w
CROSS JOIN overall o
GROUP BY w.Warehouse_block;

# Q.3 Rank warehouses by on-time %

SELECT Warehouse_block,
       AVG(Reached_on_Time_Y_N=1)*100 AS ontime_pct,
       RANK() OVER (ORDER BY AVG(Reached_on_Time_Y_N=1) DESC) AS rnk
FROM ecommerce_shipping.ecommerce_shipping_data
GROUP BY Warehouse_block;

# Q.4 Shipment mode vs overall avg (no GROUP collapse)
SELECT *,
       AVG(Reached_on_Time_Y_N=0) OVER() * 100 AS overall_delay_pct
FROM ecommerce_shipping.ecommerce_shipping_data;

# Q.5 Running % of delayed orders
SELECT ORDER_ID,
       SUM(Reached_on_Time_Y_N=0)
         OVER(ORDER BY ORDER_ID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
/ COUNT(*) OVER() * 100 AS running_delay_pct
FROM ecommerce_shipping.ecommerce_shipping_data;

############################################# SUBQUERY-Based Interview Questions####################################
# Q.1 Find shipments heavier than overall average
SELECT *
FROM ecommerce_shipping.ecommerce_shipping_data
WHERE Weight_in_gms >
      (SELECT AVG(Weight_in_gms)
       FROM ecommerce_shipping.ecommerce_shipping_data);


# Q.2 Warehouses performing worse than average delay
SELECT Warehouse_block,
       AVG(Reached_on_Time_Y_N=0)*100 AS delay_pct
FROM ecommerce_shipping.ecommerce_shipping_data
GROUP BY Warehouse_block
HAVING delay_pct >
       (SELECT AVG(Reached_on_Time_Y_N=0)*100
        FROM ecommerce_shipping.ecommerce_shipping_data);

###################################### CTE-Based Advanced Questions##########################
# Q.1 Warehouse delay vs overall benchmark 
WITH overall AS (
   SELECT AVG(Reached_on_Time_Y_N=0)*100 AS avg_delay
   FROM ecommerce_shipping.ecommerce_shipping_data
)
SELECT Warehouse_block,
       AVG(Reached_on_Time_Y_N=0)*100 AS warehouse_delay,
       avg_delay
FROM ecommerce_shipping.ecommerce_shipping_data, overall
GROUP BY Warehouse_block;

# Q.2 Customer call buckets + delay
WITH bucket AS (
  SELECT *,
     CASE
        WHEN Customer_care_calls <= 2 THEN 'Low'
        WHEN Customer_care_calls <= 5 THEN 'Medium'
        ELSE 'High'
     END AS call_group
  FROM ecommerce_shipping.ecommerce_shipping_data
)
SELECT call_group,
       AVG(Reached_on_Time_Y_N=0)*100 AS delay_pct
FROM bucket
GROUP BY call_group;



 
 
 
 






