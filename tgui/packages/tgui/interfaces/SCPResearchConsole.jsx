import { useState } from 'react';

import { useBackend, useSharedState } from '../backend';
import {
  Box,
  Button,
  Flex,
  Grid,
  Input,
  Section,
  Tabs,
  TextArea,
} from '../components';
import { Window } from '../layouts';

const SCPCard = (props, context) => {
  const { scp } = props;
  const { act } = useBackend(context);

  return (
    <Section title={`SCP-${scp.id}: ${scp.name}`} level={2}>
      <Box>
        <p>Danger Tier: {scp.dangerTier}</p>
        <p>Status: {scp.unlocked ? 'Unlocked' : 'Locked'}</p>
        {!scp.unlocked && (
          <Button
            content={`Requisition (${scp.cost} RP)`}
            onClick={() => act('purchase_scp', { scp_id: scp.id })}
          />
        )}
      </Box>
    </Section>
  );
};

const ProjectCard = (props, context) => {
  const { project, userAccess } = props;
  const { act } = useBackend(context);
  const [isExpanded, setIsExpanded] = useState(false);
  const [signature, setSignature] = useState('');
  const [manualReport, setManualReport] = useState('');
  const [denialReason, setDenialReason] = useState('');
  const [authNotes, setAuthNotes] = useState('');
  const [viewAttachment, setViewAttachment] = useState(false);
  const [attachmentContent, setAttachmentContent] = useState('');

  const canAuthorize = userAccess?.includes(2) || userAccess?.includes(4); // 2 = RD, 4 = Captain
  const dangerTierColor =
    project.dangerTier === 'Safe'
      ? 'green'
      : project.dangerTier === 'Euclid'
        ? 'orange'
        : 'red';

  const handleInput = (e, val, setter) => {
    e.stopPropagation();
    setter(val);
  };

  return (
    <Section
      title={`SCP-${project.scp_id}: ${project.name}`}
      level={5}
      buttons={
        <Button
          icon={isExpanded ? 'minus' : 'plus'}
          onClick={() => setIsExpanded(!isExpanded)}
          style={{ 'font-size': '0.8em', 'line-height': '1.5em' }}
        />
      }
    >
      <Box style={{ 'border-left': `2px solid ${dangerTierColor}` }}>
        {project.status === 'ACTIVE' && (
          <Box color="good" style={{ 'font-weight': 'bold' }}>
            Active
          </Box>
        )}
      </Box>
      {isExpanded && (
        <>
          <Box>
            <p>Proposed by: {project.proposer}</p>
            <p>Description: {project.description}</p>
            <p>
              Danger Tier:{' '}
              <span style={{ color: dangerTierColor }}>
                {project.dangerTier}
              </span>
            </p>
            {project.test && (
              <Box>
                <p>
                  <b>Test:</b> {project.test.name}
                </p>
                <p>
                  <b>Hypothesis:</b> {project.test.hypothesis}
                </p>
                <p>
                  <b>Procedure:</b> {project.test.procedure}
                </p>
                <p>
                  <b>Risks:</b> {project.test.risks}
                </p>
                <p>
                  <b>Required Equipment:</b> {project.test.required_equipment}
                </p>
                <p>
                  <b>Budget Allocation:</b> {project.test.reward_rp} RP,{' '}
                  {project.test.reward_lp} LP
                </p>
              </Box>
            )}
            {project.attachment_uid && (
              <Flex>
                <Flex.Item>
                  <Button
                    content="View Form"
                    onClick={async () => {
                      if (viewAttachment) {
                        setViewAttachment(false);
                        return;
                      }
                      const content = await act('view_attachment', {
                        project_id: project.id,
                      });
                      setAttachmentContent(content.content);
                      setViewAttachment(true);
                    }}
                  />
                </Flex.Item>
                <Flex.Item>
                  <Button
                    content="Download Form"
                    onClick={() =>
                      act('download_attachment', { project_id: project.id })
                    }
                  />
                </Flex.Item>
              </Flex>
            )}
            {viewAttachment && (
              <Section title="Attachment">
                <Box>{attachmentContent}</Box>
              </Section>
            )}
            {project.status === 'AUTHORIZED' && (
              <p>
                Authorized by: {project.authorizer} (<i>{project.signature}</i>)
              </p>
            )}
            {project.authorization_notes && (
              <p>Notes: {project.authorization_notes}</p>
            )}
            {project.status === 'AUDIT_FAILED' && (
              <p style={{ color: 'red' }}>Audit Failed</p>
            )}
          </Box>
          {project.status === 'PROPOSED' && canAuthorize && (
            <Grid>
              <Grid.Column>
                <Button
                  content="Authorize"
                  onClick={() =>
                    act('authorize_test', {
                      project_id: project.id,
                      signature: signature,
                      notes: authNotes,
                    })
                  }
                />
              </Grid.Column>
              <Grid.Column>
                <Button
                  content="Deny"
                  color="red"
                  onClick={() =>
                    act('deny_test', {
                      project_id: project.id,
                      reason: denialReason,
                    })
                  }
                />
              </Grid.Column>
              <Grid.Row>
                <Grid.Column>
                  <Input
                    placeholder="Authorization Notes (Optional)"
                    value={authNotes}
                    onInput={(e, val) => handleInput(e, val, setAuthNotes)}
                  />
                </Grid.Column>
              </Grid.Row>
              <Grid.Row>
                <Grid.Column>
                  <Input
                    placeholder="Denial Reason (Optional)"
                    value={denialReason}
                    onInput={(e, val) => handleInput(e, val, setDenialReason)}
                  />
                </Grid.Column>
              </Grid.Row>
              <Grid.Row>
                <Grid.Column>
                  <Input
                    placeholder="Digital Signature"
                    value={signature}
                    onInput={(e, val) => handleInput(e, val, setSignature)}
                  />
                </Grid.Column>
              </Grid.Row>
            </Grid>
          )}
          {project.status === 'PROPOSED' && canAuthorize && (
            <Button
              content="Remove Proposal"
              color="red"
              onClick={() => act('remove_proposal', { project_id: project.id })}
            />
          )}
          {project.status === 'AUTHORIZED' && (
            <Button
              content="Begin Test"
              onClick={() => act('begin_test', { project_id: project.id })}
            />
          )}
          {project.status === 'AUTHORIZED' && canAuthorize && (
            <Button
              content="Unauthorize Test"
              color="orange"
              onClick={() =>
                act('unauthorize_test', { project_id: project.id })
              }
            />
          )}
          {project.status === 'ACTIVE' && (
            <Flex>
              <Flex.Item>
                <Input
                  placeholder="Manual Report (Optional)"
                  value={manualReport}
                  onInput={(e, val) => handleInput(e, val, setManualReport)}
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
        </>
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
  const denied = projects.filter((p) => p.status === 'DENIED');

  return (
    <Grid>
      <Grid.Column style={{ 'border-right': '1px solid #222' }}>
        <Section title="Proposals" level={3}>
          {proposed.map((p) => (
            <ProjectCard key={p.id} project={p} userAccess={user_access} />
          ))}
        </Section>
      </Grid.Column>
      <Grid.Column style={{ 'border-right': '1px solid #222' }}>
        <Section title="Active" level={3}>
          {active.map((p) => (
            <ProjectCard key={p.id} project={p} userAccess={user_access} />
          ))}
        </Section>
      </Grid.Column>
      <Grid.Column style={{ 'border-right': '1px solid #222' }}>
        <Section title="Submitted" level={3}>
          {submitted.map((p) => (
            <ProjectCard key={p.id} project={p} userAccess={user_access} />
          ))}
        </Section>
      </Grid.Column>
      <Grid.Column>
        <Section title="Completed" level={3}>
          {completed.map((p) => (
            <ProjectCard key={p.id} project={p} userAccess={user_access} />
          ))}
        </Section>
      </Grid.Column>
      {denied.length > 0 && (
        <Grid.Column>
          <Section title="Archived" level={3}>
            {denied.map((p) => (
              <ProjectCard key={p.id} project={p} userAccess={user_access} />
            ))}
          </Section>
        </Grid.Column>
      )}
    </Grid>
  );
};

const ProposeTest = (props, context) => {
  const { data, act } = useBackend(context);
  const { scps = [] } = data;
  const [scpId, setScpId] = useState('');
  const [customScpId, setCustomScpId] = useState('');
  const [projectName, setProjectName] = useState('');
  const [description, setDescription] = useState('');
  const [hypothesis, setHypothesis] = useState('');
  const [procedure, setProcedure] = useState('');
  const [risks, setRisks] = useState('');
  const [requiredEquipment, setRequiredEquipment] = useState('');
  const [suggestion, setSuggestion] = useState(null);
  const [attachment, setAttachment] = useState(null);
  const [showFileBrowser, setShowFileBrowser] = useState(false);
  const [computerFiles, setComputerFiles] = useState([]);

  const sanitizeScpId = (input) => {
    return input.replace(/[^0-9]/g, '');
  };

  const handleCustomScpInput = (e, val) => {
    setCustomScpId(val);
    const sanitized = sanitizeScpId(val);
    const foundScp = scps.find((scp) => scp.id === sanitized);
    if (foundScp) {
      setSuggestion(foundScp);
    } else {
      setSuggestion(null);
    }
  };

  const handlePropose = () => {
    const finalScpId =
      scpId === 'custom' ? (suggestion ? suggestion.id : customScpId) : scpId;
    act('propose_custom_test', {
      scp_id: finalScpId,
      project_name: projectName,
      description: description,
      hypothesis: hypothesis,
      procedure: procedure,
      risks: risks,
      required_equipment: requiredEquipment,
      attachment_uid: attachment ? attachment.uid : null,
    });
  };

  const isScpSelected =
    (scpId && scpId !== 'custom') || (scpId === 'custom' && customScpId);

  return (
    <Section title="Propose Custom Test">
      <Flex direction="column" style={{ gap: '10px' }}>
        <Flex align="center">
          <Flex.Item grow={1}>
            <label>SCP:</label>
          </Flex.Item>
          <Flex.Item grow={3}>
            <select
              value={scpId}
              onChange={(e) => setScpId(e.target.value)}
              style={{ width: '100%' }}
            >
              <option value="">Select an SCP</option>
              {scps.map((scp) => (
                <option key={scp.id} value={scp.id}>
                  SCP-{scp.id}: {scp.name}
                </option>
              ))}
              <option value="custom">Custom SCP</option>
            </select>
          </Flex.Item>
        </Flex>

        {scpId === 'custom' && (
          <Flex align="center">
            <Flex.Item grow={1}>
              <label>Custom SCP Designation:</label>
            </Flex.Item>
            <Flex.Item grow={3}>
              <Input
                value={customScpId}
                onInput={handleCustomScpInput}
                width="100%"
              />
              {suggestion && (
                <Box color="good" mt={1}>
                  Suggestion: SCP-{suggestion.id}: {suggestion.name}
                </Box>
              )}
            </Flex.Item>
          </Flex>
        )}

        <Flex align="center">
          <Flex.Item grow={1}>
            <label>Project Name:</label>
          </Flex.Item>
          <Flex.Item grow={3}>
            <Input
              value={projectName}
              onInput={(e, val) => setProjectName(val)}
              width="100%"
            />
          </Flex.Item>
        </Flex>

        <Divider />

        <Flex direction="column">
          <label>Description/Hypothesis:</label>
          <TextArea
            value={description}
            onInput={(e, val) => setDescription(val)}
            height="60px"
            style={{ 'white-space': 'pre-wrap' }}
          />
        </Flex>

        <Divider />

        <Flex direction="column">
          <label>Procedure:</label>
          <TextArea
            value={procedure}
            onInput={(e, val) => setProcedure(val)}
            height="80px"
            style={{ 'white-space': 'pre-wrap' }}
          />
        </Flex>

        <Divider />

        <Flex direction="column">
          <label>Risks:</label>
          <TextArea
            value={risks}
            onInput={(e, val) => setRisks(val)}
            height="60px"
            style={{ 'white-space': 'pre-wrap' }}
          />
        </Flex>

        <Divider />

        <Flex direction="column">
          <label>Required Equipment:</label>
          <TextArea
            value={requiredEquipment}
            onInput={(e, val) => setRequiredEquipment(val)}
            height="60px"
            style={{ 'white-space': 'pre-wrap' }}
          />
        </Flex>

        <Divider />

        <Flex justify="space-between" align="center">
          <Button
            content={
              attachment ? `Attached: ${attachment.name}` : 'Attach Form'
            }
            onClick={async () => {
              if (showFileBrowser) {
                setShowFileBrowser(false);
                return;
              }
              const files = await act('get_computer_files');
              setComputerFiles(files || []);
              setShowFileBrowser(true);
            }}
          />
          <Button
            content="Propose"
            disabled={!isScpSelected || !projectName || !description}
            onClick={handlePropose}
            icon="paper-plane"
            ml="auto"
          />
        </Flex>

        {showFileBrowser && (
          <Section title="Attach File" mt={2}>
            <Grid>
              {computerFiles.map((file) => (
                <Grid.Column key={file.uid}>
                  <Button
                    content={file.name}
                    onClick={() => {
                      setAttachment(file);
                      setShowFileBrowser(false);
                    }}
                    fluid
                  />
                </Grid.Column>
              ))}
            </Grid>
          </Section>
        )}
      </Flex>
    </Section>
  );
};

export const SCPResearchConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const { researchPoints, logisticsPoints, scps = [], dangerLevels } = data;
  const [view, setView] = useSharedState(context, 'view', 'board');
  const [filter, setFilter] = useState('All');

  const filteredScps =
    filter === 'All' ? scps : scps.filter((scp) => scp.dangerTier === filter);

  return (
    <Window theme="scp">
      <Window.Content scrollable>
        <Flex>
          <Flex.Item grow={1}>Research Points: {researchPoints}</Flex.Item>
          <Flex.Item grow={1}>Logistics Points: {logisticsPoints}</Flex.Item>
          <Flex.Item>
            <Button
              icon="arrow-left"
              content="Back"
              onClick={() => act('PC_minimize')}
            />
          </Flex.Item>
        </Flex>
        <Tabs>
          <Tabs.Tab
            key="board"
            label="Research Board"
            icon="tasks"
            selected={view === 'board'}
            onClick={() => setView('board')}
          />
          <Tabs.Tab
            key="catalogue"
            label="SCP Catalogue"
            icon="book"
            selected={view === 'catalogue'}
            onClick={() => setView('catalogue')}
          />
          <Tabs.Tab
            key="propose"
            label="Propose Test"
            icon="plus"
            selected={view === 'propose'}
            onClick={() => setView('propose')}
          />
        </Tabs>
        {view === 'board' && <ResearchBoard />}
        {view === 'catalogue' && (
          <Section title="SCP Catalogue" style={{ 'border-width': '0' }}>
            <Flex direction="column" style={{ gap: '10px' }}>
              <Flex justify="center" style={{ gap: '10px' }}>
                <Button
                  content="All"
                  selected={filter === 'All'}
                  onClick={() => setFilter('All')}
                  color="white"
                />
                {dangerLevels.map((level) => (
                  <Button
                    key={level.key}
                    content={level.label}
                    selected={filter === level.key}
                    onClick={() => setFilter(level.key)}
                    color={
                      level.key === 'Safe'
                        ? 'green'
                        : level.key === 'Euclid'
                          ? 'orange'
                          : 'red'
                    }
                  />
                ))}
              </Flex>
              <Grid>
                {filteredScps.map((scp) => (
                  <Grid.Column key={scp.id} size={0.5}>
                    <SCPCard scp={scp} />
                  </Grid.Column>
                ))}
              </Grid>
            </Flex>
          </Section>
        )}
        {view === 'propose' && <ProposeTest />}
      </Window.Content>
    </Window>
  );
};
