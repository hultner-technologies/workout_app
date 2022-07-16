create view full_exercise as
(
    select exercise_id
     , be.base_exercise_id
     , name
     , description
     , reps
     , sets
     , rest
     , links
     , exercise.data as data
     , be.data       as base_data
    from exercise
         join base_exercise be on be.base_exercise_id = exercise.base_exercise_id
)