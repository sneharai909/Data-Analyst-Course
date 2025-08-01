#Q1-a 
select distinct employeenumber,firstname,lastname from employees
where jobtitle like "%sales rep%" and
reportsto = 1102;

#Q1-b 
select distinct productline from products
where productline like "%cars";

#Q2
use classicmodels;
select customerNumber, customerName,
case
when country IN("USA", "Canada") then "North America"
when country IN("UK", "France", "Germany") then "Europe"
else
"Other"
end as CustomerSegment
from customers;

#Q3-a 
select productCode, sum(quantityordered) as total_ordered from orderdetails
group by productCode
order by total_ordered desc
limit 10;

#Q3-b 
select monthname(paymentdate) as payment_month,
count(amount) as num_payment from payments
group by payment_month
having num_payment > 20
order by num_payment desc;

#Q4 
create database Customer_Orders;
use Customer_Orders;

create table Customers(
customer_id int primary key auto_increment,
first_name varchar(50) not null,
last_name varchar(50) not null,
email varchar(255) unique,
phone_number varchar(20));

create table Orders(
order_id int primary key auto_increment,
customer_id int,
order_date date,
total_amount decimal(10,2) check(total_amount >0),
foreign key (customer_id)
references Customers(customer_id)
ON Delete Cascade
ON Update Cascade);

#Q5
use classicmodels;
select c.country,count(o.ordernumber) as order_count from customers c 
join orders o 
on c.customernumber=o.customernumber
group by c.country
order by order_count desc
limit 5;

#Q6
create table project(
EmployeeID int primary key auto_increment,
FullName varchar(50) not null,
Gender enum ("Male", "Female"),
ManagerID int);

Insert into project(FullName, Gender, ManagerID)
values ("Pranaya", "Male", 3),
	   ("Priyanka", "Female", 1),
	   ("Preety", "Female", Null),
	   ("Anurag", "Male", 1),
	   ("Sambit", "Male", 1),
	   ("Rajesh", "Male", 3),
	   ("Hina", "Female", 3);
select * from project;

select T1.FullName as ManagerName, T2.FullName as EmpName from project T1
Inner join project T2
on T1.EmployeeID = T2.ManagerID
order by ManagerName;

#Q7
create table facility(
Facility_ID int,
Name varchar(100),
State varchar(100),
Country varchar(100));

describe facility;
alter table facility
modify Facility_ID int primary key auto_increment;
describe facility;

alter table facility
add city varchar(100) not null
after Name;
describe facility;

#Q8
create view product_category_sales as
select pl.productline as productline,
sum(od.quantityordered*od.priceeach) as total_sales,
count(distinct o.ordernumber) as number_of_orders from productlines pl
join products p on pl.productline = p.productline
join orderdetails od on p.productcode = od.productcode
join orders o on od.ordernumber = o.ordernumber
group by pl.productline;

select * from product_category_sales;

#Q9 
Delimiter //
create procedure Get_country_payments (In input_Year int, In input_Country varchar(20))
begin
select 
input_Year as Year,
input_Country as country,
concat(round(sum(p.amount)/1000),"K") as Total_Amount  
from payments p join customers c
on p.customerNumber=c.customerNumber
where 
year(p.paymentdate)=input_Year And
c.country=input_country;
end //
delimiter ;

Call Get_country_payments(2003, 'France');
drop procedure Get_country_payments;

#Q10-a 
select c.customerName, count(o.orderNumber) as Order_count,
rank() over(order by count(o.orderNumber)desc) as order_frequency_rnk from customers c 
left join orders o 
on c.customerNumber=o.customerNumber
group by c.customerName
order by order_frequency_rnk;

#Q10-b 
use classicmodels;
select 
year(orderdate) as "Year",
monthname(orderdate) as "Month",
count(ordernumber) as "Total Orders",
concat(round(((count(ordernumber)-lag(count(ordernumber),1)over())/lag(count(ordernumber),1)over())*100),"%") as "% YoY Change"
from orders
group by Year,Month;

#Q11
select productline,count(productcode) as Total from products
where buyprice>(select avg(buyprice) from products)
group by productline
order by Total desc;

#Q12
use classicmodels;
create table Emp_EH(
EmpID int primary key,
EmpName varchar(50),
emailaddress varchar(50));

delimiter //
create procedure continuehandler1(IN param_EmpID int, IN param_EmpName varchar(50), IN param_emailaddress varchar(50))
begin
declare continue handler for sqlexception select "Error occurred" as message;
insert into Emp_EH
values(param_EmpID, param_EmpName, param_emailaddress);
select * from Emp_EH;
end //

call continuehandler1(1,"ABC","abc123@gmail.com");
call continuehandler1(null,"ABC","abc123@gmail.com");
call continuehandler1(1,"ABC","abc123@gmail.com");

#Q13
use classicmodels;
create table Emp_BIT(
Name varchar(20),
Occupation varchar(20),
Working_date date,
Working_hours int);

insert into Emp_BIT values
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);  
select * from Emp_BIT;
Truncate table Emp_BIT;

delimiter //
create trigger before_insert_Emp_BIT
before insert
on Emp_BIT for each row
begin
if new.working_hours<0 then set
new.working_hours=-(new.working_hours);
end if;
end //

select * from Emp_BIT;

Insert into Emp_BIT values
('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11),
('John','Scientist','2020-10-04',-9),
('Richard','Engineer','2020-10-04',-10);
select * from Emp_BIT;