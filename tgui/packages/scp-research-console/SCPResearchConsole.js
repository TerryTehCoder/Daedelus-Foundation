import { useBackend } from '../../backend';
import { Box, Button, Flex, Grid, Section, Tabs } from '../../components';
import { Input } from '../../components';
import { Window } from '../../layouts';

const SCPList = (props, context) => {
  const { data } = useBackend(context);
  const { scps = [] } = data;
  return (
    <Section title="SCP Database">
      <Grid>
        {scps.map((scp) => (
          <Grid.Column key={scp.id}>
            <Section
              title={`SCP-${scp.id} - ${scp.name}`}
              level={2}
              buttons={
                !scp.unlocked && (
                  <Button
                    content={`Unlock (${scp.cost} RP)`}
                    onClick={() => act('purchase_scp', { scp_id: scp.id })}
                  />
                )
              }
            >
              <Box>Danger Tier: {scp.dangerTier}</Box>
              <Box>
                Tests:
                <ul>
                  {scp.tests.map((test) => (
                    <li key={test.name}>
                      {test.name} - {test.description}
                    </li>
                  ))}
                </ul>
              </Box>
            </Section>
          </Grid.Column>
        ))}
      </Grid>
    </Section>
  );
};

const TestDocumentation = (props, context) => {
  const { data } = useBackend(context);
  const { scps = [] } = data;
  const [selectedScp, setSelectedScp] = useSharedState(
    context,
    'selectedScp',
    scps[0]?.id,
  );
  const [selectedTest, setSelectedTest] = useSharedState(
    context,
    'selectedTest',
    scps[0]?.tests[0]?.name,
  );
  const [manualReport, setManualReport] = useSharedState(
    context,
    'manualReport',
    '',
  );

  const scp = scps.find((s) => s.id === selectedScp);

  return (
    <Section title="Test Documentation">
      <Flex>
        <Flex.Item>
          <label>SCP:</label>
          <select
            value={selectedScp}
            onChange={(e) => setSelectedScp(e.target.value)}
          >
            {scps.map((s) => (
              <option key={s.id} value={s.id}>
                SCP-{s.id}
              </option>
            ))}
          </select>
        </Flex.Item>
        <Flex.Item>
          <label>Test:</label>
          <select
            value={selectedTest}
            onChange={(e) => setSelectedTest(e.target.value)}
          >
            {scp?.tests.map((t) => (
              <option key={t.name} value={t.name}>
                {t.name}
              </option>
            ))}
          </select>
        </Flex.Item>
      </Flex>
      <Box>
        <label>Manual Report (Optional, +5 RP):</label>
        <Input.TextArea
          value={manualReport}
          onInput={(e, value) => setManualReport(value)}
        />
      </Box>
      <Button
        content="Submit Report"
        onClick={() =>
          act('submit_report', {
            scp_id: selectedScp,
            test_name: selectedTest,
            manual_report: manualReport,
          })
        }
      />
    </Section>
  );
};

export const SCPResearchConsole = (props, context) => {
  const { data } = useBackend(context);
  const { researchPoints, logisticsPoints } = data;

  return (
    <Window>
      <Window.Content>
        <Flex>
          <Flex.Item>Research Points: {researchPoints}</Flex.Item>
          <Flex.Item>Logistics Points: {logisticsPoints}</Flex.Item>
        </Flex>
        <Tabs>
          <Tabs.Tab key="scp_database" label="SCP Database">
            <SCPList />
          </Tabs.Tab>
          <Tabs.Tab key="documentation" label="Test Documentation">
            <TestDocumentation />
          </Tabs.Tab>
          <Tabs.Tab key="redemption" label="Point Redemption">
            <Section title="Redemption">
              <Box>WIP</Box>
            </Section>
          </Tabs.Tab>
        </Tabs>
      </Window.Content>
    </Window>
  );
};
