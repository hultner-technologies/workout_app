import {
  Button,
  Divider,
  Grid,
  Stack,
  ListItemButton,
  ListSubheader,
  Typography,
} from "@mui/material";
import { NextPage } from "next";
import { useRouter } from "next/router";
import useSWR from "swr";
import { DefaultService } from "../../src/client/services/DefaultService";

import List from "@mui/material/List";
import ListItem from "@mui/material/ListItem";
import ListItemText from "@mui/material/ListItemText";
import ListItemAvatar from "@mui/material/ListItemAvatar";
import Avatar from "@mui/material/Avatar";
import FitnessCenterIcon from "@mui/icons-material/FitnessCenter";
import {
  FormattedDate,
  FormattedDateTimeRange,
  FormattedRelativeTime,
  FormattedTime,
} from "react-intl";
import Link from "next/link";

const SessionSchedule: NextPage = () => {
  const router = useRouter();
  const { session_schedule_id } = router.query;
  const { data: schedule, error: errorS } = useSWR(
    session_schedule_id,
    DefaultService.readSessionScheduleSessionSchedulesSessionScheduleIdGet
  );

  const { data: performedSessions, error: errorPs } = useSWR(
    [undefined, 10, session_schedule_id],
    DefaultService.readPerformedSessionsPerformedSessionsGet
  );
  return (
    <Stack spacing={2}>
      <Typography variant="h2">{schedule?.name}</Typography>
      <Typography variant="subtitle1" gutterBottom component="div">
        {schedule?.description}
      </Typography>
      <Button variant="contained">New workout!</Button>

      <Grid
        container
        rowSpacing={{ xs: 2, md: 3 }}
        columns={{ xs: 1, sm: 2, md: 3 }}
      >
        <Grid item xs={1} sm={1} md={1}>
          <List
            subheader={
              <ListSubheader component="div" id="nested-list-subheader">
                Last performed sessions
              </ListSubheader>
            }
          >
            {performedSessions?.map((session) => (
              <Link
                key={session.performed_session_id}
                href={`/performed-session/${session.performed_session_id}`}
                passHref
              >
                <ListItemButton>
                  <ListItemText
                    primary={
                      <>
                        <FormattedDate
                          value={
                            session?.started_at && new Date(session.started_at)
                          }
                        />{" "}
                        <FormattedTime
                          value={
                            session?.started_at && new Date(session.started_at)
                          }
                        />
                        –
                        <FormattedTime
                          value={
                            session?.completed_at &&
                            new Date(session.completed_at)
                          }
                        />
                      </>
                    }
                    secondary={session.note}
                  />
                </ListItemButton>
              </Link>
            ))}
          </List>
          <Divider />
        </Grid>
        <Grid item xs={1} sm={1} md={1}>
          <List
            sx={{
              width: "100%",
              maxWidth: 360,
              bgcolor: "background.paper",
            }}
            subheader={
              <ListSubheader component="div" id="nested-list-subheader">
                Exercises in session
              </ListSubheader>
            }
          >
            {schedule?.exercise?.map((exercise) => (
              <ListItem key={exercise.exercise_id}>
                <ListItemAvatar>
                  <Avatar>
                    <FitnessCenterIcon />
                  </Avatar>
                </ListItemAvatar>
                <ListItemText
                  primary={exercise.base_exercise.name}
                  secondary={`${exercise.reps} ✖️ ${exercise.sets}`}
                />
              </ListItem>
            ))}
          </List>
        </Grid>
      </Grid>
    </Stack>
  );
};
export default SessionSchedule;
