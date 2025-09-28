import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  Box,
  Stack,
  ProgressBar,
} from '../components';
import { Window } from '../layouts';

export const PersistentProgressionPlayerView = (props, context) => {
  const { act, data } = useBackend(context);

  if (!data.has_data) {
    return (
      <Window title="Player Progress" width={800} height={600}>
        <Window.Content>
          <Section>
            <Box textAlign="center" fontSize="1.2em" color="red">
              No persistent data found for this player.
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  const {
    ckey,
    current_class,
    current_faction,
    current_rank,
    current_rank_level,
    total_experience,
    rounds_played,
    last_login,
    progress_to_next,
    exp_needed,
    unlocked_items,
    unlocked_titles,
    achievements,
    recent_experience,
  } = data;

  return (
    <Window title={`Player Progress - ${ckey}`} width={800} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Player Information">
              <LabeledList>
                <LabeledList.Item label="Ckey">{ckey}</LabeledList.Item>
                <LabeledList.Item label="Class">
                  {current_class}
                </LabeledList.Item>
                <LabeledList.Item label="Faction">
                  {current_faction}
                </LabeledList.Item>
                <LabeledList.Item label="Rank">
                  {current_rank} (Level {current_rank_level})
                </LabeledList.Item>
                <LabeledList.Item label="Total Experience">
                  {total_experience.toLocaleString()}
                </LabeledList.Item>
                <LabeledList.Item label="Rounds Played">
                  {rounds_played}
                </LabeledList.Item>
                <LabeledList.Item label="Last Login">
                  {last_login}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Progress to Next Rank">
              <ProgressBar
                value={progress_to_next}
                maxValue={100}
                color={progress_to_next >= 100 ? 'green' : 'blue'}
              >
                {progress_to_next}%
              </ProgressBar>
              {exp_needed > 0 && (
                <Box mt={1} textAlign="center">
                  {exp_needed.toLocaleString()} experience needed for next rank
                </Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Unlocked Items">
              {unlocked_items.length > 0 ? (
                unlocked_items.map((item, index) => (
                  <Box key={index} mb={1}>
                    • {item}
                  </Box>
                ))
              ) : (
                <Box color="gray">No items unlocked</Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Unlocked Titles">
              {unlocked_titles.length > 0 ? (
                unlocked_titles.map((title, index) => (
                  <Box key={index} mb={1}>
                    • {title}
                  </Box>
                ))
              ) : (
                <Box color="gray">No titles unlocked</Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Achievements">
              {achievements.length > 0 ? (
                achievements.map((achievement, index) => (
                  <Box key={index} mb={1}>
                    • {achievement}
                  </Box>
                ))
              ) : (
                <Box color="gray">No achievements unlocked</Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Recent Experience Sources">
              {recent_experience.length > 0 ? (
                recent_experience.map((exp, index) => (
                  <Box key={index} mb={1}>
                    <strong>{exp.reason}:</strong> {exp.amount} exp (
                    {exp.timestamp})
                  </Box>
                ))
              ) : (
                <Box color="gray">No recent experience gained</Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

