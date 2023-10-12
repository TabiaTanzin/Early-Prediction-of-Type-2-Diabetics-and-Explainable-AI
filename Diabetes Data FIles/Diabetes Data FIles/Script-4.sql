
create table diabetes_data_pksf_final as
select distinct t1.user_id, t1.age, t1.gender, pulse_rate, blood_pressure, glucose, t1.height, t1.weight, bmi, t1.family_diabetes, t1.hypertensive, t2.family_hypertension, t1.diabetic 
from
(
	select distinct user_id, age, gender, pulse_rate, blood_pressure, hypertensive, family_diabetes, glucose, height, weight,
	round(cast(case when height is not null then (weight/(height * height)) end as numeric), 2) as bmi, 
	pregnant, diabetic
	from diabetes_data_v1_4
	where (pulse_rate is not null and blood_pressure is not null and glucose is not null and height is not null and weight is not null)
) t1
inner join diabetes_member_2 t2 on t1.user_id = t2.user_id
;


create table diabetes_data_rgp_final as
select *
from diabetes_rgp_data_7;


create table diabetes_final_data as
select
	user_id, age, gender, pulse_rate, blood_pressure, glucose, height, weight, bmi, family_diabetes, hypertensive, family_hypertension, diabetic
from diabetes_data_pksf_final
union all
select
	user_id, age, gender, pulse as pulse_rate, blood_pressure, glucose, height, weight, bmi, family_diabetes, hypertensive, family_hypertension, diabetic
from diabetes_data_rgp_final
;


select *
from diabetes_data_pksf_final ddpf 
;

create table diabetes_data_rgp_final_version as
select distinct t1.user_id, age, gender, pulse as pulse_rate, blood_pressure, glucose, height, weight, bmi, family_diabetes, hypertensive, family_hypertension, t2.cardiovascular_disease,
	t2.stroke,  diabetic
from diabetes_data_rgp_final t1
inner join rgp_stroke_cvd_data t2 on t1.user_id = t2.user_id
;

create table diabetes_data_pksf_final_version as
select t1.user_id, t1.age, t1.gender, pulse_rate, blood_pressure, glucose, t1.height, t1.weight, bmi, t1.family_diabetes, t1.hypertensive, family_hypertension, 
t2.has_cardiovascular as cardiovascular_disease, t2.has_stroke as stroke, t1.diabetic
from diabetes_data_pksf_final t1
inner join diabetes_member_3 t2 on t1.user_id = t2.user_id
;


create table diabetes_final_data as
select distinct user_id, age, gender, pulse_rate, blood_pressure, glucose, round(height::numeric,2) as height, weight, bmi, family_diabetes, hypertensive, family_hypertension, cardiovascular_disease,
	stroke,  diabetic
from diabetes_data_rgp_final_version
union all
select distinct user_id, age, gender, pulse_rate, blood_pressure, glucose, round(height::numeric,2) as height, weight, bmi, family_diabetes, hypertensive, family_hypertension, cardiovascular_disease,
	stroke,  diabetic
from diabetes_data_pksf_final_version
;


select *
from diabetes_final_data;

select *
from diabetes_rgp_data
where user_id = 10007


create table rgp_diastolic_1 as
select t2.*, max(t3."input") as diastolic_bp
from
(
	select t1.user_id, max(t1.meas_last_updated) as max_time
	from diabetes_rgp_data t1
	where t1.attr_code = 'DIASTOLIC'
	group by t1.user_id
) t2
inner join diabetes_rgp_data t3 on t2.user_id = t3.user_id
where t3.attr_code = 'DIASTOLIC'
group by t2.user_id, t2.max_time
order by t2.user_id
;

create table rgp_systolic_1 as
select t2.*, max(t3."input") as systolic_bp
from
(
	select t1.user_id, max(t1.meas_last_updated) as max_time
	from diabetes_rgp_data t1
	where t1.attr_code = 'SYSTOLIC'
	group by t1.user_id
) t2
inner join diabetes_rgp_data t3 on t2.user_id = t3.user_id
where t3.attr_code = 'SYSTOLIC'
group by t2.user_id, t2.max_time
order by t2.user_id


select t1.user_id, age, gender, pulse_rate, t2.systolic_bp, t3.diastolic_bp, glucose, height, weight, bmi, family_diabetes, hypertensive, family_hypertension, cardiovascular_disease,
	stroke,  diabetic
from diabetes_final_data t1
inner join rgp_systolic_1 t2 on t1.user_id = t2.user_id::text
inner join rgp_diastolic_1 t3 on t1.user_id = t3.user_id::text
;


create table pksf_systolic_1 as
select t1.user_id, max(t1."input") as systolic_bp
from diabetes_measurement2 t1
where t1.attr_code = 'SYSTOLIC'
group by t1.user_id


create table pksf_diastolic_1 as
select t1.user_id, max(t1."input") as diastolic_bp
from diabetes_measurement2 t1
where t1.attr_code = 'DIASTOLIC'
group by t1.user_id
;



create table diabetes_data_final as
select t1.user_id, age, gender, pulse_rate, t2.systolic_bp, t3.diastolic_bp, glucose, height, weight, bmi, family_diabetes, hypertensive, family_hypertension, cardiovascular_disease,
	stroke,  diabetic
from diabetes_final_data t1
inner join rgp_systolic_1 t2 on t1.user_id = t2.user_id::text
inner join rgp_diastolic_1 t3 on t1.user_id = t3.user_id::text
union
select t1.user_id, age, gender, pulse_rate, t2.systolic_bp, t3.diastolic_bp, glucose, height, weight, bmi, family_diabetes, hypertensive, family_hypertension, cardiovascular_disease,
	stroke,  diabetic
from diabetes_data_pksf_final_version t1
inner join pksf_systolic_1 t2 on t1.user_id = t2.user_id::text
inner join pksf_diastolic_1 t3 on t1.user_id = t3.user_id::text
;


select *
from diabetes_data_final
;

select gender, count(distinct user_id) 
from diabetes_data_final
group by gender