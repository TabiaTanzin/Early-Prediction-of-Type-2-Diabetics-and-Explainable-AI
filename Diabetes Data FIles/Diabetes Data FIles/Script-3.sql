create table diabetes_rgp_data_2 as 
select 
	distinct t1.user_id, age, gender, t2.pulse, --t3.blood_pressure, t4.glucose, t5.height, t6.weight,
	--round(cast(case when t5.height is not null then (t6.weight/(t5.height * t5.height)) end as numeric), 2) as bmi, 
	family_diabetes, hypertensive, family_hypertension, diabetic
from diabetes_rgp_data t1
inner join
(
	select user_id, 
	"input" as pulse
	from diabetes_rgp_data
	where meas_type_code = 'PULSE_RATE'
	and "input" is not null
) t2 on t1.user_id = t2.user_id;

create table diabetes_rgp_data_3 as
select t1.*, t3.blood_pressure
from diabetes_rgp_data_2 t1
inner join
(
	select user_id, 
	"input" as blood_pressure
	from diabetes_rgp_data
	where meas_type_code = 'BP' and attr_code = 'DIASTOLIC'
	and "input" is not null
) t3 on t1.user_id = t3.user_id;

create table diabetes_rgp_data_4 as
select t1.*, t4.glucose
from diabetes_rgp_data_3 t1
inner join
(
	select user_id, 
	"input" as glucose
	from diabetes_rgp_data
	where meas_type_code = 'BLOOD_SUGAR'
	and "input" is not null
) t4 on t1.user_id = t4.user_id;


create table diabetes_rgp_data_5 as
select t1.*, t5.height
from diabetes_rgp_data_4 t1
inner join
(
	select user_id, 
	"input"/100::float as height
	from diabetes_rgp_data
	where meas_type_code = 'BMI' and attr_code = 'HEIGHT'
	and "input" is not null
) t5 on t1.user_id = t5.user_id;


create table diabetes_rgp_data_6 as
select t1.*, t6.weight
from diabetes_rgp_data_5 t1
inner join
(
	select user_id, 
	"input" as weight
	from diabetes_rgp_data
	where meas_type_code = 'BMI' and attr_code = 'WEIGHT'
	and "input" is not null
) t6 on t1.user_id = t6.user_id
;


select count(distinct user_id)
from diabetes_rgp_data drd 
where diabetic = 'True';



select distinct meas_type_code, attr_code
from diabetes_rgp_data drd;

select distinct age
from diabetes_rgp_data
where user_id = '2027'
;


create table diabetes_rgp_data_7 as
select user_id, age, gender, pulse, blood_pressure, glucose, height, weight,
		bmi, family_diabetes, hypertensive, family_hypertension, diabetic
from
(
	select
		distinct user_id, age, gender, pulse, blood_pressure, round(glucose::numeric, 2) as glucose, height, round(weight::numeric, 2) as weight,
		round(cast(case when height is not null then (weight/(height * height)) end as numeric), 2) as bmi, 
		family_diabetes, hypertensive, family_hypertension, diabetic,
		rank()over(partition by user_id order by pulse, blood_pressure, glucose, height, weight desc) r
	from diabetes_rgp_data_6
) t1
where t1.r = 1
order by user_id;



select count(distinct user_id) 
from diabetes_rgp_data_4
where diabetic = 'True';


select *
from diabetes_rgp_data_7
limit 1
where age >= 40;


select count(distinct user_id)
from diabetes_rgp_data drd
where "input" is not null
and meas_type_code = 'BP' and attr_code = 'DIASTOLIC'