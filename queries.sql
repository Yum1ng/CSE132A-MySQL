/*Yuming Qiao
  A99011577
  cs132ack*/
.mode columns
.headers on

create table sailor 
	(sname char primary key,  
	rating int);

create table boat 
	(bname char primary key, 
	color char, 
	rating int);

create table reservation 
	(sname char references sailor, 
    bname char references boat, 
	day int, 
	start int, 
	finish int,
	primary key(sname,bname,start,finish),
	check (finish > start)
	);

insert into sailor values ('Brutus', 1);
insert into sailor values  ('Andy', 8);
insert into sailor values ('Horatio', 7);
insert into sailor values ('Rusty', 8);
insert into sailor values ('Bob', 1);

insert into boat values ('SpeedQueen', 'white', 9);
insert into boat values ('Interlake', 'red', 8);
insert into boat values ('Marine', 'blue', 7);
insert into boat values ('Bay', 'red', 3);

insert into reservation values ('Andy', 'Interlake', 'Monday', 10, 14);
insert into reservation values ('Andy', 'Marine', 'Saturday', 14, 16);
insert into reservation values ('Andy', 'Bay', 'Wednesday', 8, 12);
insert into reservation values ('Rusty', 'Bay', 'Sunday', 9, 12);
insert into reservation values ('Rusty', 'Interlake', 'Wednesday', 13, 20);
insert into reservation values ('Rusty', 'Interlake', 'Monday', 9, 11);
insert into reservation values ('Bob', 'Bay', 'Monday', 9 , 12);
insert into reservation values ('Andy', 'Bay', 'Wednesday', 9, 10);
insert into reservation values ('Horatio', 'Marine', 'Tuesday', 15, 19);
--insert into reservation values ('Bob', 'Marine', 'Tuesday', 15, 19);

--1.b--
SELECT * from sailor;
SELECT * from boat;
select * from reservation;

-- List all pairs of sailors and boats they are qualified to sail
select sname, bname from sailor, boat where sailor.rating >= boat.rating;

--1.c List, for each sailor, the number of boats they are qualified to sail
select sname, sum(case when sailor.rating >= boat.rating then 1 else 0 end)
from sailor, boat
group by sname;

--3. List the sailors with the lowest rating. MIN
select sname 
from sailor
where sailor.rating = (select MIN(sailor.rating) from sailor);

--List the sailors with the lowest rating. NO MIN
select s.sname
from sailor s
where s.rating not in
(select t.rating 
from sailor t, sailor m
where t.rating > m.rating);

--4  List the sailors who have at least one reservation and only reserved red boats--
select sname 
from reservation
where sname not in(
	select r.sname
	from reservation r
	where r.bname not in(
		select bname
		from boat 
		where boat.color = "red"
	)
)
group by sname;

--5  List the sailors who reserved no red boat--
select sname
from sailor s
where (s.sname not in(select sname from reservation)) ||
(
	s.sname in(
		select sname from reservation
		where sname not in(
			select r.sname
			from reservation r
			where r.bname in(
			select bname
			from boat 
			where boat.color = "red"
			)
		)
	)
);


--6 List the sailors who reserved every red boat NOT IN
select sailor.sname
from sailor   
where sname not in
(select sname
from sailor, boat
where boat.color = 'red' And sname not in 
(select sname
from reservation
where reservation.sname = sailor.sname AND reservation.bname = boat.bname
));

--List the sailors who reserved every red boat NOT EXISTS
select sailor.sname
from sailor   
where not exists
(select *
from boat
where boat.color = 'red' And not exists
(select *
from reservation
where reservation.sname = sailor.sname AND reservation.bname = boat.bname
));

--List the sailors who reserved every red boat COUNT
select sailor.sname
from sailor   
where
(select count(*)
from boat
where boat.color = 'red' And 
(select count(*)
from reservation
where reservation.sname = sailor.sname AND reservation.bname = boat.bname
)=0)=0;

--7  For each reserved boat, list the average rating of sailors having reserved that boat--
create view aver as 
select s.rating, s.sname, r.bname 
from sailor s, reservation r, boat b
where s.sname = r.sname and r.bname = b.bname
group by r.bname, s.sname
;

select bname, avg(rating) as average
from aver
group by bname;

--7.d Formulate and run a query to verify that there are no conflicting reservations
select r1.bname, r1.day, r1.sname as sname1, r1.start as start1, r1.finish as
finish1, r2.sname as sname2, r2.start as start2, r2.finish as finish2
from reservation r1, reservation r2
where ((r1.start < r2.finish or r2.start < r1.finish) and (r1.start <> r2.start
and r1.finish <> r2.finish) and r1.bname = r2.bname and r1.day = r2.day
--!-- filter out and compress 2 -> 1
and r1.sname >= r2.sname and (r1.start < r2.start or 
	(r1.start = r2.start and r1.finish < r2.finish)))
or
((r1.start < r2.finish or r2.start < r1.finish) and (r1.start = r2.start
and r1.finish = r2.finish) and r1.bname = r2.bname and r1.day = r2.day
and r1.sname > r2.sname);

--7.e  Change all red boats to blue and all blue boats to red
update boat
set color = 'qym'
where color = 'red';
update boat
set color = 'red'
where color = 'blue';
update boat
set color = 'blue'
where color = 'qym';

--7.d  Delete all sailors who are not qualified to sail any boat, together with their reservations
delete from sailor 
where sailor.rating <
(select MIN(rating)
from boat);

--7.e list all table again
select * from boat;
select * from sailor;
select * from reservation;






