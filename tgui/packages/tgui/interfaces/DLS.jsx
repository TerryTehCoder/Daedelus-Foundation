import '../styles/dls.css';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

export const DLS = (props) => {
  const { act, data } = useBackend();
  const [tab, setTab] = useLocalState('tab', 1);

  const safeData = data || {};
  const hasManager = safeData.has_manager || false;

  if (!hasManager) {
    return (
      <Window title="Data Listening System" width={800} height={600}>
        <Window.Content>
          <Section>
            <Box textAlign="center" fontSize="1.2em" color="red">
              DLS Manager component not found.
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  const { dls_mode = 2, crew_profiles = [], active_whispers = [] } = safeData;

  return (
    <Window title="Data Listening System" width={800} height={600}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="DLS Control">
              <Stack>
                <Stack.Item>
                  <Button
                    content="Autonomous"
                    selected={dls_mode === 1}
                    onClick={() => act('set_mode', { mode: 1 })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    content="Guided"
                    selected={dls_mode === 2}
                    onClick={() => act('set_mode', { mode: 2 })}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Button
                    content="Manual"
                    selected={dls_mode === 3}
                    onClick={() => act('set_mode', { mode: 3 })}
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Tabs>
              <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
                Crew Manifest
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
                Whisper Log
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>

          <Stack.Item grow>
            {tab === 1 && <CrewManifestTab />}
            {tab === 2 && <WhisperLogTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CrewManifestTab = (props, context) => {
  const { act, data } = useBackend(context);
  const { crew_profiles = [] } = data || {};

  return (
    <Section title="Crew Manifest">
      {crew_profiles.map((profile, index) => (
        <Box key={index} mb={2} p={2} backgroundColor="rgba(0, 0, 0, 0.1)">
          <Stack>
            <Stack.Item grow>
              <Box fontSize="1.1em" fontWeight="bold">
                {profile.name} ({profile.rank})
              </Box>
              {profile.traits && profile.traits.length > 0 && (
                <Box mt={1}>
                  Traits:{' '}
                  {profile.traits.map((trait, i) => (
                    <span key={i} className="DLS-trait">
                      {trait}
                    </span>
                  ))}
                </Box>
              )}
              <Box>
                Status:{' '}
                <span className={'DLS-status-' + profile.status.class}>
                  {profile.status.text}
                </span>
              </Box>
              <Box>Confidence: {profile.confidence}%</Box>
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Stress">
                  {profile.scores.stress}
                </LabeledList.Item>
                <LabeledList.Item label="Aggression">
                  {profile.scores.aggression}
                </LabeledList.Item>
                <LabeledList.Item label="Suspicion">
                  {profile.scores.suspicion}
                </LabeledList.Item>
                <LabeledList.Item label="Isolation">
                  {profile.scores.isolation}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
          <Section title="Event History" collapsible>
            {profile.event_history.map((event, i) => (
              <Box key={i}>
                [{new Date(event.timestamp * 100).toLocaleTimeString()}]{' '}
                {event.event} ({event.confidence}%)
              </Box>
            ))}
          </Section>
          <Section title="Manual Trait Adjustment" collapsible>
            <Stack>
              <Stack.Item>
                <Button
                  content="Add Volatile"
                  onClick={() =>
                    act('add_trait', {
                      target: profile.name,
                      trait: 'Volatile',
                    })
                  }
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  content="Remove Volatile"
                  onClick={() =>
                    act('remove_trait', {
                      target: profile.name,
                      trait: 'Volatile',
                    })
                  }
                />
              </Stack.Item>
            </Stack>
          </Section>
        </Box>
      ))}
    </Section>
  );
};

const WhisperLogTab = (props, context) => {
  const { act, data } = useBackend(context);
  const { active_whispers = [] } = data || {};

  const getTierColor = (tier) => {
    switch (tier) {
      case 1:
        return 'blue';
      case 2:
        return 'orange';
      case 3:
        return 'red';
      default:
        return 'white';
    }
  };

  return (
    <Section title="Whisper Log">
      {active_whispers.map((whisper, index) => (
        <Box key={index} mb={2} p={2} backgroundColor="rgba(0, 0, 0, 0.1)">
          <Stack>
            <Stack.Item grow>
              <Box color={getTierColor(whisper.tier)}>
                [{new Date(whisper.timestamp * 100).toLocaleTimeString()}] [
                {whisper.target}] {whisper.text} ({whisper.confidence}%)
              </Box>
            </Stack.Item>
            <Stack.Item>
              {whisper.status === 0 && (
                <>
                  <Button
                    content="Validate"
                    onClick={() =>
                      act('validate_whisper', {
                        whisper_id: whisper.whisper_id,
                      })
                    }
                    color="green"
                  />
                  <Button
                    content="Invalidate"
                    onClick={() =>
                      act('invalidate_whisper', {
                        whisper_id: whisper.whisper_id,
                      })
                    }
                    color="red"
                  />
                </>
              )}
              {whisper.status === 1 && <Box color="green">Validated</Box>}
              {whisper.status === 2 && <Box color="red">Invalidated</Box>}
            </Stack.Item>
          </Stack>
        </Box>
      ))}
    </Section>
  );
};
