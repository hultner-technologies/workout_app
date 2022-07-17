#!/usr/bin/env python

from pprint import pprint
from itertools import count

from sqlmodel import Session, create_engine, select
from path import Path
from strictyaml import load

from workout_app.models import Plan, BaseExercise, Exercise, SessionSchedule


plan_data = load(Path("./workout_plans/Julian_Plan_A.yml").text()).data
dsn_2 = "postgresql://postgres:postgres@127.0.0.1:25432/workout_app"
engine = create_engine(dsn_2)
session = Session(engine)

p = Plan(**plan_data)
pprint(p)
session.add(p)
session.commit()


def create_exercises(plan_data, ss_data, session_schedule, session):
    base_ex = []
    exercises = []
    sort_order = count()
    # skip 0
    next(sort_order)
    session.add(session_schedule)
    for e in ss_data.get("exercises"):
        be = session.exec(
            select(BaseExercise).where(BaseExercise.name == e["name"])
        ).one_or_none()
        print(be)
        if be is None:
            be = BaseExercise(**e)
            session.add(be)
            session.commit()
            print("Doesn't exist")
            print(be)
        print("after if")
        print(be)
        ex = Exercise(
            base_exercise_id=be.base_exercise_id,
            session_schedule_id=session_schedule.session_schedule_id,
            sort_order=next(sort_order) * 1000,
            **{
                "reps": plan_data["default_reps"],
                "sets": plan_data["default_sets"],
                "rest": plan_data["default_rest"],
                **e,
            },
        )
        session.add(ex)
        session.commit()
        base_ex += [be]
        exercises += [ex]
    return (base_ex, exercises)


sched = [
    (
        ss_ := SessionSchedule(
            plan_id=p.plan_id, progression_limit=plan_data.get("progression_limit"), **s
        ),
        create_exercises(plan_data, s, ss_, session),
    )
    for s in plan_data.get("sessions")
]

session.commit()
