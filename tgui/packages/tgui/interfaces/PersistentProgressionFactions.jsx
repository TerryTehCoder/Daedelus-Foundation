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

export const PersistentProgressionFactions = (props) => {
  const { act, data } = useBackend();
  const { factions } = data;

  return (
    <Window title="Available Factions" width={800} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          {factions.map((factionData) => (
            <Stack.Item key={factionData.id}>
              <Section title={factionData.name}>
                <Box mb={2}>
                  <strong>Description:</strong> {factionData.description}
                </Box>

                <LabeledList>
                  <LabeledList.Item label="Experience Multiplier">
                    {factionData.exp_multiplier}x
                  </LabeledList.Item>
                </LabeledList>

                <Collapsible title="Available Classes" mt={2}>
                  <Stack fill vertical>
                    {factionData.available_classes.map((classData, index) => (
                      <Stack.Item key={index}>
                        <Box p={1} backgroundColor="rgba(0, 0, 0, 0.1)">
                          <Box fontSize="1em" fontWeight="bold">
                            {classData.name}
                          </Box>
                          <Box color="gray">{classData.description}</Box>
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
