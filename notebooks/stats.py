#!/usr/bin/env python
# coding: utf-8

# In[ ]:


from sqlalchemy import create_engine


# In[ ]:


import pandas as pd
import matplotlib.pyplot as plt
import plotly.express as px


# In[ ]:


import unicodedata
import re


# In[ ]:


from pydantic import BaseSettings


# In[ ]:


def remove_accents(input_str):
    nfkd_form = unicodedata.normalize('NFKD', input_str)
    output_string = u"".join([c for c in nfkd_form if not unicodedata.combining(c)])
    return re.sub(r'\W+', '', output_string).replace("  ", " ")



# In[ ]:


class Settings(BaseSettings):
    pg_dsn: str

    class Config:
        env_file = '../.env'
        env_file_encoding = 'utf-8'


# In[ ]:


settings = Settings(_env_file='../.env.local')


# In[ ]:


engine = create_engine(settings.pg_dsn)


# In[ ]:


# df = pd.read_sql("select * from performed_exercise", engine)


# In[ ]:


# df.reset_index()
# df.set_index('completed_at', inplace=True)


# In[ ]:


#(
#    df
#    .groupby('name')['weight']
#    .plot(
#        #x="completed_at",
#        #y="weight",
#        legend=True,
#    )
#)
#plt.legend(bbox_to_anchor=(1.1, 1.05))
##plt.figure(figsize=(16,16), dpi=380)
#fig = plt.gcf()
#fig.set_size_inches(18.5, 10.5, forward=True)


# In[ ]:


#df = pd.read_sql("""
#    with vagg as (
#        select sum(volume_kg) as agg_volume_kg,
#               performed_session_id,
#               array_agg(performed_exercise_id) as performed_exercise_id
#        from exercise_stats
#        where session_name = 'Biceps, triceps, back'
#        group by name, performed_session_id
#    )
#    select *, vagg.performed_exercise_id[1] from vagg
#    join exercise_stats es on vagg.performed_exercise_id[1]=es.performed_exercise_id
#""", engine)
#df.set_index('date', inplace=True)
#(
#    df
#    .groupby('name')['agg_volume_kg']
#    .plot(
#        #x="completed_at",
#        #y="weight",
        
#        legend=True,
#    )
#)

#plt.legend(bbox_to_anchor=(1.1, 1.05))
#fig = plt.gcf()
#fig.set_size_inches(18.5, 10.5, forward=True)


## In[ ]:


#df = pd.read_sql("""
#    with vagg as (
#        select sum(volume_kg) as agg_volume_kg,
#               performed_session_id,
#               array_agg(performed_exercise_id) as performed_exercise_id
#        from exercise_stats
#        where session_name = 'Legs, pickup'
#        group by name, performed_session_id
#    )
#    select *, vagg.performed_exercise_id[1] from vagg
#    join exercise_stats es on vagg.performed_exercise_id[1]=es.performed_exercise_id
#""", engine)
#df.set_index('date', inplace=True)
#(
#    df
#    .groupby('name')['agg_volume_kg']
#    .plot(
#        #x="completed_at",
#        #y="weight",
        
#        legend=True,
#    )
#)

#plt.legend(bbox_to_anchor=(1.1, 1.05))
#fig = plt.gcf()
# fig.set_size_inches(18.5, 10.5, forward=True)


# In[ ]:


#df = pd.read_sql("""
#    with vagg as (
#        select sum(volume_kg) as agg_volume_kg,
#               performed_session_id,
#               array_agg(performed_exercise_id) as performed_exercise_id
#        from exercise_stats
#        where session_name = 'Chest, shoulders, abs'
#        group by name, performed_session_id
#    )
#    select *, vagg.performed_exercise_id[1] from vagg
#    join exercise_stats es on vagg.performed_exercise_id[1]=es.performed_exercise_id
#""", engine)
#df.set_index('date', inplace=True)
#(
#    df
#    .groupby('name')['agg_volume_kg']
#    .plot(
#        #x="completed_at",
#        #y="weight",
        
#        legend=True,
#    )
#)

#plt.legend(bbox_to_anchor=(1.1, 1.05))
#fig = plt.gcf()
#fig.set_size_inches(18.5, 10.5, forward=True)


# In[ ]:


df = pd.read_sql("select * from performed_exercise", engine)
fig = px.scatter(
    df,
    x="completed_at",
    y="weight",
    title="Weight",
    trendline="lowess",
    color="name",
)
fig.update_layout(legend={"orientation": "h"})
# fig.show()
fig.write_html("output/weight.html")
#df.set_index('completed_at', inplace=True)
# for name, exercise in df.groupby('name'):
#     fig = px.scatter(
#         exercise,
#         x="completed_at",
#         y="weight",
#         title=name,
#         trendline="lowess",
#     )
#     fig.show()

    #plt.legend(bbox_to_anchor=(1.1, 1.05))
    #plt.figure(figsize=(16,16), dpi=380)›
    #fig = plt.gcf()
    #fig.set_size_inches(18.5, 10.5, forward=True)


# In[ ]:


# df = pd.read_sql("select * from performed_exercise", engine)

#df.set_index('completed_at', inplace=True)
#dir(
#list(df.groupby('name'))[0][0]
#)

# list(df.name)


# In[ ]:


df = pd.read_sql("select * from exercise_stats", engine)
data = df.groupby(["name", "date"]).max("brzycki_1_rm_max").reset_index()
data["date"] = pd.to_datetime(data["date"])
fig = px.scatter(
    data,
    x="date",
    y="brzycki_1_rm_max",
    color="name",
    title="1 rm max",
    trendline="lowess",
)
# fig.show()

fig.write_html(f"""output/1rm_max.html""")
#df.set_index('completed_at', inplace=True)
"""
for name, exercise in df.groupby('name'):
    fig = px.scatter(
        exercise,
        x="completed_at",
        y="brzycki_1_rm_max",
        title=name,
        trendline="lowess",
    )
    fig.show()
"""


# In[ ]:


#df = pd.read_sql("select * from exercise_stats", engine)

#df.set_index('completed_at', inplace=True)
for (name, session_name), exercise in df.groupby(['name', 'session_name']):
    exercise["date"] = pd.to_datetime(exercise["date"])
    ex_agg = (
        exercise
        # Group multiple exercise instances on the same day
        .groupby("date")
        # Sum their volume
        .sum("volume_kg")
        # Reset the index to make it plottable.
        .reset_index()
    )
    #print(ex_agg)
    fig = px.scatter(
        ex_agg,
        x="date",
        y="volume_kg",
        title=f"{session_name}: {name}",
        trendline="lowess",
    )
    # fig.show()
    #print(ex_agg.columns)
    file_name = remove_accents(f"{session_name} {name}".lower().replace(" ", "_"))
    fig.write_html(f"""output/{file_name}_volume.html""")


# In[ ]:




