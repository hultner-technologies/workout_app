#!/usr/bin/env python3
import click
import dotenv

@click.command()
@click.option('--database' help='Specify a specific database name')
def setup_db(database):
    pass

