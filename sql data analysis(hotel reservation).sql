show databases;
create database day23;
use day23;
show tables;

select *  from booking_history;
desc booking_history;

select *  from customers_large;
desc customers_large;

select *  from hotels_large;
desc hotels_large;

select *  from reservations_large;
desc reservations_large;

select *  from rooms_large;
desc rooms_large;



-- 1) check is that any room avilable in required specific date range

SELECT  room_id,hotel_name,room_type,availability FROM rooms_large 
INNER JOIN hotels_large  ON rooms_large.hotel_id = hotels_large.hotel_id
WHERE rooms_large.availability = "yes" and room_type="single"
AND rooms_large.room_id NOT IN (SELECT reservations_large.room_id FROM reservations_large 
WHERE reservations_large.check_in BETWEEN '2024-09-01' AND '2024-09-02'
or reservations_large.check_out between '2024-10-01' and '2024-10-02');





-- 2)calculate total revenue by room type across all hotels

select room_type,sum(res.total_price)as total_revenue 
from rooms_large 
join reservations_large res on rooms_large.room_id=res.room_id
group by room_type
order by total_revenue desc;



-- 3)who spent most on reservations
select customers_large.customer_id,customers_large.first_name,customers_large.last_name,
sum(reservations_large.total_price)as total_spent
from customers_large 
join reservations_large  on customers_large.customer_id=reservations_large.customer_id
group by customers_large.customer_id
order by total_spent desc 
limit 3;


-- 4) FIND CUSTOMERS WHO MADE RESERVATIONS IN MULTIPL CITIES.

SELECT reservations_large.customer_id,customers_large.first_name,customers_large.last_name,
COUNT(DISTINCT hotels_large.city) AS city_count
FROM reservations_large 
JOIN hotels_large  ON reservations_large.hotel_id = hotels_large.hotel_id
JOIN customers_large  ON reservations_large.customer_id = customers_large.customer_id
GROUP BY reservations_large.customer_id, customers_large.first_name, customers_large.last_name
HAVING COUNT(DISTINCT hotels_large.city) > 1
order by city_count desc;



-- 5) find hotels with maximum reservations cancelled

SELECT hotels_large.hotel_id,hotels_large.hotel_name,hotels_large.city,hotels_large.country,
COUNT(booking_history.history_id) AS canceled_reservations
FROM booking_history 
JOIN reservations_large  ON booking_history.reservation_id = reservations_large.reservation_id
JOIN hotels_large  ON reservations_large.hotel_id = hotels_large.hotel_id
WHERE booking_history.status = 'Cancelled' 
GROUP BY hotels_large.hotel_id, hotels_large.hotel_name, hotels_large.city, hotels_large.country
ORDER BY canceled_reservations desc;


-- 6)IDENTIFY THE CUSTOMERS WHO MOST TIME IN HOTELS
SELECT reservations_large.customer_id,customers_large.first_name,customers_large.last_name,hotels_large.hotel_name,
DATEDIFF(reservations_large.check_out, reservations_large.check_in) AS stay_duration
FROM reservations_large 
JOIN customers_large  ON reservations_large.customer_id = customers_large.customer_id
JOIN hotels_large  ON reservations_large.hotel_id = hotels_large.hotel_id
WHERE DATEDIFF(reservations_large.check_out, reservations_large.check_in) > 90
ORDER BY stay_duration desc;


-- 7) Identify the most RESERVATIONS booked time of month.
SELECT MONTH(reservations_large.booking_date) AS month_name,
COUNT(reservations_large.reservation_id) AS total_bookings
FROM reservations_large
GROUP BY MONTH(reservations_large.booking_date)
ORDER BY total_bookings desc;


-- create view for query

create or replace view first_query as
SELECT  room_id,hotel_name,room_type,availability FROM rooms_large 
INNER JOIN hotels_large  ON rooms_large.hotel_id = hotels_large.hotel_id
WHERE rooms_large.availability = "yes" and room_type="single"
AND rooms_large.room_id NOT IN (SELECT reservations_large.room_id FROM reservations_large 
WHERE reservations_large.check_in BETWEEN '2024-09-01' AND '2024-09-02'
or reservations_large.check_out between '2024-10-01' and '2024-10-02');

-- call the view (create as like same just create the view and name it and then copy the query and paste it in the view and then call the query)
select * from first_query;




