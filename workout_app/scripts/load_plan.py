#!/usr/bin/env python

from itertools import count
from pathlib import Path
from pprint import pprint
from typing import Annotated

import typer
from dotenv import load_dotenv
from sqlmodel import Session, create_engine, select
from strictyaml import load

from workout_app.models import BaseExercise, Exercise, Plan, SessionSchedule

load_dotenv()
# TODO: Support for custom DSN via env or similar
dsn_2 = "postgresql://postgres:postgres@127.0.0.1:25432/workout_app"
# engine = create_engine(dsn_2)
# session = Session(engine)
plan_a = "Julian_Plan_A.yml"
plan_b = "Julian_Plan_B.yml"


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
        print("-- after if be None --")
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


def create_plan(
    plan_file: Path, dsn: Annotated[str, typer.Argument(envvar="pg_dsn")] = dsn_2
):

    plan_data = load(plan_file.read_text()).data
    engine = create_engine(dsn)
    session = Session(engine)
    p = Plan(**plan_data)
    pprint(p)
    session.add(p)
    session.commit()

    schedules = [
        (
            schedule := SessionSchedule(
                plan_id=p.plan_id,
                progression_limit=plan_data.get("progression_limit"),
                **workout_session,
            ),
            create_exercises(plan_data, workout_session, schedule, session),
        )
        for workout_session in plan_data.get("sessions")
    ]

    session.commit()


if __name__ == "__main__":
    typer.run(create_plan)
