import {
  Breadcrumbs,
  Button,
  Grid,
  ListItemButton,
  ListSubheader,
  Stack,
  Typography,
} from "@mui/material";
import { NextPage } from "next";
import { useRouter } from "next/router";
import useSWR from "swr";
import { DefaultService } from "../../src/client/services/DefaultService";

import MuiLink from "@mui/material/Link";
import List from "@mui/material/List";
import ListItem from "@mui/material/ListItem";
import ListItemText from "@mui/material/ListItemText";
import ListItemAvatar from "@mui/material/ListItemAvatar";
import Avatar from "@mui/material/Avatar";
import FitnessCenterIcon from "@mui/icons-material/FitnessCenter";
import {
  FormattedDate,
  FormattedDateTimeRange,
  FormattedNumber,
  FormattedRelativeTime,
  FormattedTime,
} from "react-intl";
import Link from "next/link";

const PerformedSession: NextPage = () => {
  const router = useRouter();
  const { performed_session_id } = router.query;
  const { data: session, error } = useSWR(
    performed_session_id,
    DefaultService.readPerformedSessionPerformedSessionsPerformedSessionIdGet
  );

  return (
    <Stack spacing={2}>
      <Breadcrumbs aria-label="breadcrumb">
        <Link href="/plans" passHref>
          <MuiLink underline="hover" color="inherit">
            Plans
          </MuiLink>
        </Link>
        <Link href={`/plans/${session?.session_schedule?.plan_id}`} passHref>
          <MuiLink underline="hover" color="inherit">
            Current plan
          </MuiLink>
        </Link>

        <Link
          href={`/session-schedule/${session?.session_schedule?.session_schedule_id}`}
          passHref
        >
          <MuiLink underline="hover" color="inherit">
            Schedule: {session?.session_schedule?.name}
          </MuiLink>
        </Link>
        <Typography color="text.primary">Current session</Typography>
      </Breadcrumbs>
      <Typography variant="h2">{session?.session_schedule?.name}</Typography>
      <Typography variant="subtitle1" gutterBottom component="div">
        <Typography variant="body1">{session?.note}</Typography>
        <FormattedDate
          value={session?.started_at && new Date(session.started_at)}
        />{" "}
        <FormattedTime
          value={session?.started_at && new Date(session.started_at)}
        />
        –
        <FormattedTime
          value={session?.completed_at && new Date(session.completed_at)}
        />
      </Typography>
      <Button variant="contained">New workout!</Button>

      {/* Full number input  */}
      {/* <p>
        <input type="number" pattern="\d*" />
      </p> */}

      <Grid
        container
        rowSpacing={{ xs: 2, md: 3 }}
        columns={{ xs: 1, sm: 2, md: 3 }}
      >
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
            {session?.performed_exercise
              ?.sort((a, b) =>
                (a.started_at || 0) < (b?.started_at || 0) ? -1 : 1
              )
              .map(
                ({
                  name,
                  performed_exercise_id,
                  reps,
                  sets,
                  weight,
                  exercise,
                  started_at,
                  completed_at,
                }) => (
                  <ListItem key={performed_exercise_id}>
                    <ListItemAvatar>
                      <Avatar>
                        <FitnessCenterIcon />
                      </Avatar>
                    </ListItemAvatar>
                    <ListItemText
                      primary={
                        <>
                          {name ?? exercise?.base_exercise?.name},{" "}
                          <FormattedNumber
                            unit="kilogram"
                            style="unit"
                            value={weight / 1000}
                          />
                        </>
                      }
                      secondary={
                        <>
                          {`Reps: ${reps}`}.{` Sets:️ ${sets}`}
                          <br />
                          <FormattedTime value={started_at} /> –
                          <FormattedTime value={completed_at} />
                        </>
                      }
                    />
                  </ListItem>
                )
              )}
          </List>
        </Grid>
      </Grid>
    </Stack>
  );
};
export default PerformedSession;
