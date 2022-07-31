from operator import attrgetter
from pprint import pprint
from typing import List, Optional
from uuid import uuid1
from pydantic import UUID1, UUID4

from fastapi import Depends, FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import func
from sqlmodel import Field, Relationship, Session, SQLModel, create_engine, select
from sqlmodel import Field, Session, SQLModel, create_engine, select
from sqlalchemy.orm import joinedload, subqueryload, selectinload
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker


from workout_app.models import *


DATABASE_URL_ASYNC = (
    "postgresql+asyncpg://postgres:postgres@127.0.0.1:25432/workout_app"
)
dsn_2 = "postgresql://postgres:postgres@127.0.0.1:25432/workout_app"
engine = create_engine(dsn_2)
engine_async = create_async_engine(DATABASE_URL_ASYNC, echo=True, future=True)


def get_session_sync() -> Session:
    with Session(engine) as session:
        yield session


async def get_session() -> AsyncSession:
    async_session = sessionmaker(
        engine_async, class_=AsyncSession, expire_on_commit=False
    )
    async with async_session() as session:
        yield session


async def get_logged_in_user(session: AsyncSession = Depends(get_session)) -> AppUser:
    # TODO: Implement real function
    statement = select(AppUser).where(AppUser.email == "ahultner@gmail.com").limit(1)
    user = (await session.execute(statement)).scalars().first()
    return user


# with Session(engine) as session:
#     statement = select(AppUser).where(AppUser.name == "hultner")
#     user = session.exec(statement).first()
#     print(user)
#     plan = session.exec(select(Plan).options(subqueryload(Plan.session_schedule))).one()
#     print(plan.json())

# print(plan.session_schedule)


app = FastAPI()
FASTAPI_ALLOW_CREDENTIALS: bool = True
FASTAPI_ALLOW_METHODS: List[str] = ["*"]
FASTAPI_ALLOW_HEADERS: List[str] = ["*"]

BACKEND_CORS_ORIGINS = [
    "http://localhost",
    "http://192.168.1.98:3001",
    "http://localhost:3001",
    "http://localhost:3000",
    "http://hultnerimac.local",
    "http://hultnerimac.local:3000",
    "http://hultnerimac.local:3001",
    "http://127.0.0.1:3001",
    "http://hultnertechmbp.local:3001",
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=BACKEND_CORS_ORIGINS,
    allow_credentials=FASTAPI_ALLOW_CREDENTIALS,
    allow_methods=FASTAPI_ALLOW_METHODS,
    allow_headers=FASTAPI_ALLOW_HEADERS,
)


@app.get("/plans/", response_model=List[Plan])
async def read_plans(
    *,
    session: AsyncSession = Depends(get_session),
    offset: int = 0,
    limit: int = Query(default=100, lte=100),
):
    plans = (
        (await session.execute(select(Plan).offset(offset).limit(limit)))
        .scalars()
        .all()
    )
    return plans


@app.get("/plans/{plan_id}", response_model=PlanRead)
async def read_plan(*, session: AsyncSession = Depends(get_session), plan_id: UUID1):
    plan = await session.get(
        Plan,
        plan_id.hex,
        options=(
            selectinload(Plan.session_schedule)
            .selectinload(SessionSchedule.exercise)
            .selectinload(Exercise.base_exercise),
        ),
    )
    if not plan:
        raise HTTPException(status_code=404, detail="Plan not found")
    return plan


@app.get("/session-schedules/{session_schedule_id}", response_model=SessionScheduleRead)
async def read_session_schedule(
    *, session: AsyncSession = Depends(get_session), session_schedule_id: UUID1
):
    session_schedule = await session.get(
        SessionSchedule,
        session_schedule_id.hex,
        options=(
            selectinload(SessionSchedule.exercise).selectinload(Exercise.base_exercise),
        ),
    )
    if not session_schedule:
        raise HTTPException(status_code=404, detail="Not found")
    return session_schedule


@app.get("/performed-sessions/", response_model=List[PerformedSessionReadMany])
async def read_performed_sessions(
    *,
    session: AsyncSession = Depends(get_session),
    user: AppUser = Depends(get_logged_in_user),
    offset: int = 0,
    limit: int = Query(default=100, lte=100),
    session_schedule_id: Optional[UUID1] = None,
):
    filters = [
        PerformedSession.app_user_id == user.app_user_id,
    ]
    if session_schedule_id is not None:
        filters = [
            *filters,
            PerformedSession.session_schedule_id == session_schedule_id.hex,
        ]
    performed_sessions = (
        (
            await session.execute(
                select(PerformedSession)
                .where(*filters)
                .order_by(PerformedSession.completed_at.desc())
                .offset(offset)
                .limit(limit)
                .options(selectinload(PerformedSession.session_schedule))
            )
        )
        .scalars()
        .all()
    )
    return performed_sessions


@app.get(
    "/performed-sessions/{performed_session_id}", response_model=PerformedSessionRead
)
async def read_performed_session(
    *,
    session: AsyncSession = Depends(get_session),
    user: AppUser = Depends(get_logged_in_user),
    performed_session_id: UUID1,
):
    performed_session = await session.get(
        PerformedSession,
        performed_session_id.hex,
        options=(
            selectinload(PerformedSession.session_schedule),
            # selectinload(SessionSchedule.exercise).
            # selectinload(Exercise.base_exercise),
            selectinload(PerformedSession.performed_exercise)
            .selectinload(PerformedExercise.exercise)
            .selectinload(Exercise.base_exercise),
        ),
    )
    if not performed_session or performed_session.app_user_id != user.app_user_id:
        raise HTTPException(status_code=404, detail="Not found")
    return performed_session


@app.get(
    "/performed-sessions/{performed_session_id}/draft-exercises",
    # response_model=PerformedSessionRead
)
async def draft_new_session_exercises(
    *,
    session: AsyncSession = Depends(get_session),
    user: AppUser = Depends(get_logged_in_user),
    performed_session_id: UUID1,
):
    exercises = (
        await session.execute(
            # select(func.draft_session_exercises(performed_session_id))
            """
                select * from next_exercise_progression
                where app_user_id = :app_user_id
                    and performed_session_id = :performed_session_id
                ;
            """,
            {
                "performed_session_id": performed_session_id,
                "app_user_id": user.app_user_id,
            },
        )
    ).all()
    return exercises


def set_next_weights(
    session_schedule: SessionSchedule,
    last_performed_exercises: List[PerformedExercise],
) -> SessionScheduleReadNew:
    new = SessionScheduleReadNew.from_orm(session_schedule)
    for exercise, new_exercise in zip(session_schedule.exercise, new.exercise):
        print("----------")
        pprint(exercise)
        pprint(exercise.performed_exercise)
        print("----------")
        pprint(new_exercise)
        # Problem, will use other users last exercise atm
        # Better solution, get all exercise ids
        # Get all performed exercises ordered by completion time with user id
        # Limit 1 per exercise id
        # select * from performed_exercise where app_user_id = user.app_user_id order by completion_time desc
        last_ex = 0
        try:
            last_ex = (
                max(
                    exercise.performed_exercise,
                    key=attrgetter("completed_at"),
                ).weight
                or 0
            )
        except ValueError:
            # Wasn't performed yet
            last_ex = 0

        new_exercise.weight = last_ex + 1000  # exercise.weight_increment
    return new


@app.get(
    "/session-schedules/{session_schedule_id}/new",
    response_model=SessionScheduleReadNew,
)
async def generate_session_new(
    *,
    session: AsyncSession = Depends(get_session),
    user: AppUser = Depends(get_logged_in_user),
    session_schedule_id: UUID1,
):
    session_schedule = await session.get(
        SessionSchedule,
        session_schedule_id.hex,
        options=(
            selectinload(SessionSchedule.exercise).selectinload(Exercise.base_exercise),
            selectinload(SessionSchedule.exercise).selectinload(
                Exercise.performed_exercise
            ),
        ),
    )
    # TODO: This won't work if same base exercise exists in multiple sessions
    last_performed_session = (
        (
            await session.execute(
                select(PerformedSession)
                .where(
                    PerformedSession.app_user_id == user.app_user_id,
                    PerformedSession.session_schedule_id == session_schedule_id.hex,
                )
                .order_by(PerformedSession.completed_at.desc())
                .limit(1)
                .options(selectinload(PerformedSession.performed_exercise))
            )
        )
        .scalars()
        .first()
    )
    if (
        not last_performed_session
        or last_performed_session.app_user_id != user.app_user_id
    ):
        # Create empty new draft
        return session_schedule
        raise HTTPException(status_code=404, detail="Not found")
    # n = SessionScheduleReadNew.from_orm(session_schedule)
    return set_next_weights(session_schedule, last_performed_session.performed_exercise)


if __name__ == "__main__":
    pass
