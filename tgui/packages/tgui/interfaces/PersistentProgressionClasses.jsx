import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  Box,
  Stack,
  Collapsible,
} from '../components';
import { Window } from '../layouts';

export const PersistentProgressionClasses = (props) => {
  const { act, data } = useBackend();
  const { classes } = data;

  return (
    <Window title="Available Classes" width={800} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          {classes.map((classData) => (
            <Stack.Item key={classData.id}>
              <Section title={classData.name}>
                <Box mb={2}>
                  <strong>Description:</strong> {classData.description}
                </Box>

                <LabeledList>
                  <LabeledList.Item label="Experience Multiplier">
                    {classData.exp_multiplier}x
                  </LabeledList.Item>
                  <LabeledList.Item label="Max Rank">
                    {classData.max_rank}
                  </LabeledList.Item>
                  <LabeledList.Item label="Compatible Factions">
                    {classData.compatible_factions.join(', ')}
                  </LabeledList.Item>
                </LabeledList>

                <Collapsible title="Rank Progression" mt={2}>
                  <Stack fill vertical>
                    {classData.ranks.map((rank, index) => (
                      <Stack.Item key={index}>
                        <Box p={1} backgroundColor="rgba(0, 0, 0, 0.1)">
                          <Box
                            fontSize="1em"
                            fontWeight="bold"
                            color={rank.color}
                          >
                            {rank.name}
                          </Box>
                          <Box color="gray">
                            {rank.requirement.toLocaleString()} experience
                            required
                          </Box>
                        </Box>
                      </Stack.Item>
                    ))}
                  </Stack>
                </Collapsible>
              </Section>
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};
