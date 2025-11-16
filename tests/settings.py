from functools import lru_cache
from typing import Optional

from dotenv import load_dotenv
from pydantic import AnyHttpUrl
from pydantic_settings import BaseSettings, SettingsConfigDict

load_dotenv()


class DatabaseSettings(BaseSettings):
    host: str = "127.0.0.1"
    port: int = 54322
    user: str = "postgres"
    password: str = "postgres"
    database: str = "postgres"

    model_config = SettingsConfigDict(
        env_prefix="TEST_PG_",
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


class SupabaseSettings(BaseSettings):
    url: Optional[AnyHttpUrl] = None
    anon_key: Optional[str] = None
    service_role_key: Optional[str] = None

    model_config = SettingsConfigDict(
        env_prefix="TEST_SUPABASE_",
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


@lru_cache()
def get_db_settings() -> DatabaseSettings:
    return DatabaseSettings()


@lru_cache()
def get_supabase_settings() -> SupabaseSettings:
    return SupabaseSettings()
