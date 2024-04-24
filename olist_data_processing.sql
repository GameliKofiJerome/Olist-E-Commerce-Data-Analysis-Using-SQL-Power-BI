-- **DATA PREPROCESSING**
-- For more concise querying, the olist_products table is updated to include the column 'product_category_name_english' 
-- to join the same column from the 'product_category_name_translation' table.


-- updating the 'olist_products' table to add new column 'product_category_name_english'
ALTER TABLE olist_products 
ADD product_category_name_english varchar(255);

-- Populating the 'product_category_name_english' column with values from the 'product_category_name_translation' table
UPDATE olist_products AS op
        JOIN
    product_category_name_translation AS pcnt ON op.product_category_name = pcnt.product_category_name 
SET 
    op.product_category_name_english = pcnt.product_category_name_english;
    
    
-- updating the empty spaces in 'product_category_name' and null values in 'product_category_name_translation' to 'N/A'
-- checking for all empty or null values in 'olist_product'.
SELECT 
    *
FROM
    olist_products AS op
WHERE
    product_category_name = '';
-- Output: The above query returned a total of 610 rows of null values.

UPDATE olist_products as op
SET 
   op.product_category_name = 'N/A'
WHERE
   op.product_category_name = '';


UPDATE olist_products AS op
SET 
   op.product_category_name_english = 'N/A'
WHERE
   op.product_category_name_english IS NULL;

SELECT 
    op.product_category_name,
    op.product_category_name_english
FROM
    olist_products AS op
WHERE
    product_category_name_english = 'N/A';
-- Output: 623 rows having 'N/A' values were returned


-- selecting all 'portateis_cozinha_e_preparadores_de_alimentos' values in the olist_products table
-- updating values by setting 'portateis_cozinha_e_preparadores_de_alimentos' = portable kitchens and food preparers
SELECT 
    op.product_category_name, op.product_category_name_english
FROM
    olist_products AS op
WHERE
    product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos';
    
UPDATE olist_products 
SET 
    product_category_name_english = 'portable kitchens and food preparers'
WHERE
    product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos';

UPDATE olist_products 
SET 
    product_category_name_english = 'pc_gamer'
WHERE
    product_category_name = 'pc_gamer';