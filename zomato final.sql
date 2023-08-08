create database zomato1;
use zomato1;

CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 
INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
        (3,'04-21-2017');

CREATE TABLE users(userid integer,signup_date date); 
INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');


CREATE TABLE sales(userid integer,created_date date,product_id integer); 
INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

CREATE TABLE product(product_id integer,product_name text,price integer);
INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signuo;
select * from users;


-- 1) what is total amount each customer spent in zomato..??--

select s.userid,sum(p.price) as Total_Amount from 
sales s
inner join
product p
on s.product_id = p.product_id
group by s.userid

--2) how many days has each customer visited zomato..??--

select s.userid, count(distinct s.created_date) as Total_Days
from sales s
group by s.userid

--3) what was the first product purchased by each customer?
select * 
from
(
select *,
dense_rank() over (partition by userid order by created_date) RN
from sales) T
where RN=1

-- 4) What is most purchased item in a menu & how many times its purchased by all customers ?
select userid, count(product_id) as cnt_product 
from
sales where product_id =(select top 1 product_id from sales group by product_id order by count(product_id) desc)
group by userid

--5) which item was most popular for each customer??
with cte 
as
(select  userid, product_id, count(product_id) over (partition by userid,product_id ) as cnt 
from 
sales),cte1
as
(
select *, row_number() over(partition by userid order by cnt desc) as rn1
from CTE
)
select * from cte1 where rn1=1

--6)which item was purchased by customer aster they become a member?
with cte
as
(
select u.userid,u.signup_date,s.[product_id],s.created_date from 
sales s
inner join users u
on s.userid = u.userid
and created_date >= u.signup_date
)
select * from
(
select *,row_number() over(partition by userid order by created_date ) rn from cte
) T
where rn=1

--7) which item was purchased just before customer became a member?

with cte
as
(
select u.userid,u.signup_date,s.[product_id],s.created_date from 
sales s
inner join users u
on s.userid = u.userid
and created_date <= u.signup_date
)
select * from
(
select *,row_number() over(partition by userid order by created_date ) rn from cte
) T
where rn=1

--8) what is total amount spent for each member after they become a member?

with cte
as
(
select u.userid,u.signup_date,s.[product_id],s.created_date from 
sales s
inner join users u
on s.userid = u.userid
and created_date >= u.signup_date
)
select T.userid, count(T.created_date), sum(price)  from
(
select userid,signup_date,p.product_id,created_date,P.price from cte c inner join product p
on c.product_id = p.product_id
) as T
group by userid






