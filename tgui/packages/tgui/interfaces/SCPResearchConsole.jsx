import { useBackend, useSharedState } from '../backend';
import { Box, Button, Flex, Grid, Input, Section, Tabs } from '../components';
import { Window } from '../layouts';

const SCPCard = (props, context) => {
  const { scp } = props;
  const { act } = useBackend(context);

  return (
    <Section
      title={`SCP-${scp.id}: ${scp.name}`}
      level={2}
      buttons={
        !scp.unlocked && (
          <Button
            content={`Requisition (${scp.cost} RP)`}
            onClick={() => act('purchase_scp', { scp_id: scp.id })}
          />
        )
      }
    >
      <Box>
        <p>Danger Tier: {scp.dangerTier}</p>
        <p>Status: {scp.unlocked ? 'Unlocked' : 'Locked'}</p>
      </Box>
    </Section>
  );
};

const ProjectCard = (props, context) => {
  const { project, userAccess } = props;
  const { data, act } = useBackend(context);
  const [signature, setSignature] = useSharedState(
    context,
    `signature-${project.id}`,
    '',
  );
  const [manualReport, setManualReport] = useSharedState(
    context,
    `manual-report-${project.id}`,
    '',
  );

  const canAuthorize = userAccess?.includes(2) || userAccess?.includes(4); // 2 = RD, 4 = Captain

  return (
    <Section title={`SCP-${project.scp_id}: ${project.name}`} level={2}>
      <Box>
        <p>Proposed by: {project.proposer}</p>
        <p>Description: {project.description}</p>
        {project.test && (
          <Box>
            <p>Test: {project.test.name}</p>
            <p>Test Description: {project.test.description}</p>
            <p>
              Budget Allocation: {project.test.reward_rp} RP,{' '}
              {project.test.reward_lp} LP
            </p>
          </Box>
        )}
        {project.status === 'AUTHORIZED' && (
          <p>
            Authorized by: {project.authorizer} ({project.signature})
          </p>
        )}
        {project.status === 'AUDIT_FAILED' && (
          <p style={{ color: 'red' }}>Audit Failed</p>
        )}
      </Box>
      {project.status === 'PROPOSED' && canAuthorize && (
        <Flex>
          <Flex.Item>
            <Input
              placeholder="Digital Signature"
              value={signature}
              onInput={(e, val) => setSignature(val)}
            />
          </Flex.Item>
          <Flex.Item>
            <Button
              content="Authorize"
              onClick={() =>
                act('authorize_test', {
                  project_id: project.id,
                  signature: signature,
                })
              }
            />
          </Flex.Item>
        </Flex>
      )}
      {project.status === 'AUTHORIZED' && (
        <Button
          content="Begin Test"
          onClick={() => act('begin_test', { project_id: project.id })}
        />
      )}
      {project.status === 'ACTIVE' && (
        <Flex>
          <Flex.Item>
            <Input
              placeholder="Manual Report (Optional)"
              value={manualReport}
              onInput={(e, val) => setManualReport(val)}
            />
          </Flex.Item>
          <Flex.Item>
            <Button
              content="Submit Report"
              onClick={() =>
                act('submit_report', {
                  project_id: project.id,
                  manual_report: manualReport,
                })
              }
            />
          </Flex.Item>
        </Flex>
      )}
    </Section>
  );
};

const ResearchBoard = (props, context) => {
  const { data } = useBackend(context);
  const { projects = [], user_access } = data;

  const proposed = projects.filter((p) => p.status === 'PROPOSED');
  const active = projects.filter(
    (p) => p.status === 'AUTHORIZED' || p.status === 'ACTIVE',
  );
  const submitted = projects.filter((p) => p.status === 'REPORT_SUBMITTED');
  const completed = projects.filter(
    (p) => p.status === 'COMPLETED' || p.status === 'AUDIT_FAILED',
  );

  return (
    <Grid>
      <Grid.Column>
        <Section title="Proposals">
          {proposed.map((p) => (
            <ProjectCard key={p.id} project={p} userAccess={user_access} />
          ))}
        </Section>
      </Grid.Column>
      <Grid.Column>
        <Section title="Active">
          {active.map((p) => (
            <ProjectCard key={p.id} project={p} userAccess={user_access} />
          ))}
        </Section>
      </Grid.Column>
      <Grid.Column>
        <Section title="Submitted">
          {submitted.map((p) => (
            <ProjectCard key={p.id} project={p} userAccess={user_access} />
          ))}
        </Section>
      </Grid.Column>
      <Grid.Column>
        <Section title="Completed">
          {completed.map((p) => (
            <ProjectCard key={p.id} project={p} userAccess={user_access} />
          ))}
        </Section>
      </Grid.Column>
    </Grid>
  );
};

const ProposeTest = (props, context) => {
  const { data, act } = useBackend(context);
  const { scps = [] } = data;
  const [scpId, setScpId] = useSharedState(context, 'propose-scpId', null);
  const [projectName, setProjectName] = useSharedState(
    context,
    'propose-projectName',
    '',
  );
  const [description, setDescription] = useSharedState(
    context,
    'propose-description',
    '',
  );

  return (
    <Section title="Propose Custom Test">
      <Flex direction="column">
        <Flex.Item>
          <label>SCP:</label>
          <select value={scpId} onChange={(e) => setScpId(e.target.value)}>
            <option value={null}>Select an SCP</option>
            {scps.map((scp) => (
              <option key={scp.id} value={scp.id}>
                SCP-{scp.id}: {scp.name}
              </option>
            ))}
          </select>
        </Flex.Item>
        <Flex.Item>
          <label>Project Name:</label>
          <Input
            value={projectName}
            onInput={(e, val) => setProjectName(val)}
          />
        </Flex.Item>
        <Flex.Item>
          <label>Description:</label>
          <Input
            value={description}
            onInput={(e, val) => setDescription(val)}
          />
        </Flex.Item>
        <Flex.Item>
          <Button
            content="Propose"
            disabled={!scpId || !projectName || !description}
            onClick={() =>
              act('propose_custom_test', {
                scp_id: scpId,
                project_name: projectName,
                description: description,
              })
            }
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

export const SCPResearchConsole = (props, context) => {
  const { data } = useBackend(context);
  const { researchPoints, logisticsPoints, scps = [] } = data;

  return (
    <Window>
      <Window.Content>
        <Flex>
          <Flex.Item grow={1}>Research Points: {researchPoints}</Flex.Item>
          <Flex.Item grow={1}>Logistics Points: {logisticsPoints}</Flex.Item>
        </Flex>
        <Section>
          <Tabs>
            <Tabs.Tab key="research-board" label="Research Board" icon="tasks">
              <ResearchBoard />
            </Tabs.Tab>
            <Tabs.Tab key="scp-catalog" label="SCP Catalog" icon="book">
              <Grid>
                {scps.map((scp) => (
                  <Grid.Column key={scp.id}>
                    <SCPCard scp={scp} />
                  </Grid.Column>
                ))}
              </Grid>
            </Tabs.Tab>
            <Tabs.Tab key="propose-test" label="Propose Test" icon="plus">
              <ProposeTest />
            </Tabs.Tab>
          </Tabs>
        </Section>
      </Window.Content>
    </Window>
  );
};
