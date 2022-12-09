create or replace view exercise_stats as
(
select pe.name
     , pe.weight
     , round(weight * (
          36.0/(37.0-(select max(r) from unnest(pe.reps) r))
       )) as brzycki_1_rm_max
     , pe.reps
     , (select sum(rep) from unnest(pe.reps) rep) * pe.weight /
       1000::decimal                   as volume_kg
     , pe.started_at
     , pe.completed_at
     , pe.completed_at - pe.started_at as exercise_time
     , ss.name as session_name
     , pe.note
     , ps.completed_at - ps.started_at as workout_time
     , date(pe.completed_at) as date
     , e.step_increment
     , e.sort_order
     , ps.performed_session_id
     , ss.session_schedule_id
     , ss.plan_id
     , pe.performed_exercise_id
     , pe.exercise_id
from performed_exercise pe
         join performed_session ps on pe.performed_session_id = ps.performed_session_id
         join session_schedule ss on ps.session_schedule_id = ss.session_schedule_id
         join exercise e on pe.exercise_id = e.exercise_id
order by ss.session_schedule_id, ps.completed_at desc, e.sort_order
);