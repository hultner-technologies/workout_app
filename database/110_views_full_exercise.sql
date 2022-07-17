create view full_exercise as
(
    select exercise_id
     , be.base_exercise_id
     , ex.session_schedule_id
     , ss.name as session
     , be.name
     , be.description
     , reps
     , sets
     , rest
     , sort_order
     , be.links
     , ex.data as data
     , be.data       as base_data
    from exercise ex
         join base_exercise be on be.base_exercise_id = ex.base_exercise_id
         join session_schedule ss on ex.session_schedule_id = ss.session_schedule_id
    order by ss.name asc, sort_order asc
)