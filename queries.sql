--считаем общее кол-во покупателей
select  count(*) from customers as customers_count;

--запрос сортирует продавцов на топ 10 по сумме выручки
select
e.first_name || ' ' || e.last_name as seller,
count(s.sales_id) as operations,
sum(s.quantity*p.price) as income
from sales s
left join employees e on e.employee_id = s.sales_person_id
left join products p on s.product_id = p.product_id
group by seller
order by income desc limit 10;

--сортируем продавцов по их средней выручке относительно общей средней выручке по всем продавцам - оставляем тех, у кого средний показатель меньше среднего по всем
with sellers_average as (
select
e.first_name || ' ' || e.last_name as seller,
avg(s.quantity*p.price) as average_income
from sales s
left join employees e on e.employee_id = s.sales_person_id
left join products p on s.product_id = p.product_id
group by seller)
select
seller,
floor(average_income) as average_income
from sellers_average
where average_income < (select avg(average_income) from sellers_average)
order by average_income;

--выручка каждого продавца в зависимости от дня недели
with subtable as (
select
e.first_name || ' ' || e.last_name as seller,
sum(s.quantity*p.price) as income,
to_char(s.sale_date, 'ID') AS number_of_day_week,
to_char(s.sale_date, 'day') AS day_of_week
from sales s
left join employees e on e.employee_id = s.sales_person_id
left join products p on s.product_id = p.product_id
group by seller, number_of_day_week, day_of_week
)
select
seller,
day_of_week,
floor(income) as income
from subtable;

--сортировка по возрастным группа и подсчет общего кол-ва покупателейв каждой возрастной группе
SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        WHEN age > 40 then '40+'
        ELSE '55+'
    END AS age_category,
    COUNT(c.customer_id) AS age_count
FROM customers c
GROUP BY age_category
ORDER BY age_category;

--группировка покупателей и выручке по ним по месяцам
select
to_char(s.sale_date, 'YYYY-MM') as selling_month,
count(c.customer_id) as total_customers,
round(sum(s.quantity*p.price)) as income
from sales s
inner join customers c on s.customer_id = c.customer_id
inner join products p on s.product_id = p.product_id 
group by selling_month
order by selling_month;

--покупатели совершившие первую покупку а акционный период
select distinct on (c.customer_id)
c.first_name || ' ' || c.last_name as customer,
s.sale_date,
e.first_name || ' ' || e.last_name as seller
from sales s
left join customers c on s.customer_id = c.customer_id
left join products p on s.product_id = p.product_id
left join employees e on s.sales_person_id = e.employee_id
where p.price = 0
order by c.customer_id, s.sale_date;