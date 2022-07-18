from operator import attrgetter
from typing import List, Optional
from pydantic import UUID1, UUID4

from sqlmodel import Field, Session, SQLModel, create_engine, select
from sqlalchemy.orm import joinedload, subqueryload


from workout_app.models import *

from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Relationship, Session, SQLModel, create_engine, select

# dsn = "postgresql+asyncpg://postgres:postgres@127.0.0.1:25432/workout_app"
dsn_2 = "postgresql://postgres:postgres@127.0.0.1:25432/workout_app"
engine = create_engine(dsn_2)


def get_session() -> Session:
    with Session(engine) as session:
        yield session


def get_logged_in_user(session: Session = Depends(get_session)) -> AppUser:
    # TODO: Implement real function
    statement = select(AppUser).where(AppUser.email == "ahultner@gmail.com")
    user = session.exec(statement).first()
    return user


# with Session(engine) as session:
#     statement = select(AppUser).where(AppUser.name == "hultner")
#     user = session.exec(statement).first()
#     print(user)
#     plan = session.exec(select(Plan).options(subqueryload(Plan.session_schedule))).one()
#     print(plan.json())

# print(plan.session_schedule)


app = FastAPI()


@app.get("/plans/", response_model=List[Plan])
def read_plans(
    *,
    session: Session = Depends(get_session),
    offset: int = 0,
    limit: int = Query(default=100, lte=100),
):
    plans = session.exec(select(Plan).offset(offset).limit(limit)).all()
    return plans


@app.get("/plans/{plan_id}", response_model=PlanRead)
def read_plan(*, session: Session = Depends(get_session), plan_id: UUID1):
    plan = session.get(Plan, plan_id.hex)
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")
    return plan


@app.get("/session-schedules/{session_schedule_id}", response_model=SessionScheduleRead)
def read_session_schedule(
    *, session: Session = Depends(get_session), session_schedule_id: UUID1
):
    session_schedule = session.get(SessionSchedule, session_schedule_id.hex)
    if not session_schedule:
        raise HTTPException(status_code=404, detail="Not found")
    return session_schedule


@app.get("/performed-sessions/", response_model=List[PerformedSession])
def read_performed_sessions(
    *,
    session: Session = Depends(get_session),
    user: AppUser = Depends(get_logged_in_user),
    offset: int = 0,
    limit: int = Query(default=100, lte=100),
):
    performed_sessions = session.exec(
        select(PerformedSession)
        .where(PerformedSession.app_user_id == user.app_user_id)
        .offset(offset)
        .limit(limit)
    ).all()
    return performed_sessions


@app.get(
    "/performed-sessions/{performed_session_id}", response_model=PerformedSessionRead
)
def read_performed_session(
    *,
    session: Session = Depends(get_session),
    user: AppUser = Depends(get_logged_in_user),
    performed_session_id: UUID1,
):
    performed_session = session.get(PerformedSession, performed_session_id.hex)
    if not performed_session or performed_session.app_user_id != user.app_user_id:
        raise HTTPException(status_code=404, detail="Not found")
    return performed_session


if __name__ == "__main__":
    pass
