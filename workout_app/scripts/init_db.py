#!/usr/bin/env python3
import click

# import dotenv


@click.command()
@click.option("--database", help="Specify a specific database name")
def setup_db(database):
    # Get connection string from .env/user input
    # - (See if database exists, if not create)
    # Fetch content of all psql/sql files in database directory
    # Execute in correct order to database
    # Seed with default plans?
    pass


if __name__ == "__main__":
    # Pass args?
    setup_db()
