import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useState } from 'react';

import { useBackend, useSharedState } from '../backend';
import {
  Box,
  Button,
  Flex,
  Grid,
  Icon,
  Input,
  Section,
  Stack,
  Table,
  Tabs,
  TextArea,
} from '../components';
import { Window } from '../layouts';

const SCPTableRow = (props, context) => {
  const { scp } = props;
  const { act } = useBackend(context);

  return (
    <Table.Row key={scp.id} className="candystripe">
      <Table.Cell collapsing color="label">
        SCP-{scp.id}
      </Table.Cell>
      <Table.Cell>{scp.name}</Table.Cell>
      <Table.Cell collapsing textAlign="right">
        {scp.dangerTier}
      </Table.Cell>
      <Table.Cell collapsing textAlign="right">
        {scp.unlocked ? 'Unlocked' : 'Locked'}
      </Table.Cell>
      <Table.Cell collapsing textAlign="right">
        {!scp.unlocked && (
          <Button
            fluid
            content={`Requisition (${scp.cost} RP)`}
            onClick={() => act('purchase_scp', { scp_id: scp.id })}
          />
        )}
      </Table.Cell>
    </Table.Row>
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
      {isExpanded && (
        <>
          <Box>
            <p>Proposed by: {project.proposer}</p>
            <p>Description: {project.description}</p>
            {project.authorizer && (
              <Box>
                <p>Authorized by: {project.authorizer}</p>
                {project.signature && (
                  <p>Digital Signature: {project.signature}</p>
                )}
                {project.authorization_notes && (
                  <p>Authorization Notes: {project.authorization_notes}</p>
                )}
              </Box>
            )}
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
                  onInput={(e, val) => handleInput(e, val, setSignature)}
                />
              </Flex.Item>
              <Flex.Item>
                <Input
                  placeholder="Authorization Notes (Optional)"
                  value={authNotes}
                  onInput={(e, val) => handleInput(e, val, setAuthNotes)}
                />
              </Flex.Item>
              <Flex.Item>
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
              </Flex.Item>
              <Flex.Item>
                <Input
                  placeholder="Denial Reason (Optional)"
                  value={denialReason}
                  onInput={(e, val) => handleInput(e, val, setDenialReason)}
                />
              </Flex.Item>
              <Flex.Item>
                <Button
                  content="Deny Proposal"
                  color="red"
                  onClick={() =>
                    act('deny_proposal', {
                      project_id: project.id,
                      reason: denialReason,
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
      <Flex direction="column">
        <Flex.Item>
          <label>SCP:</label>
          <select value={scpId} onChange={(e) => setScpId(e.target.value)}>
            <option value="">Select an SCP</option>
            {scps.map((scp) => (
              <option key={scp.id} value={scp.id}>
                SCP-{scp.id}: {scp.name}
              </option>
            ))}
            <option value="custom">Custom SCP</option>
          </select>
        </Flex.Item>
        {scpId === 'custom' && (
          <Flex.Item>
            <label>Custom SCP Designation:</label>
            <Input value={customScpId} onInput={handleCustomScpInput} />
            {suggestion && (
              <Box color="good">
                Suggestion: SCP-{suggestion.id}: {suggestion.name}
              </Box>
            )}
          </Flex.Item>
        )}
        <Flex.Item>
          <label>Project Name:</label>
          <Input
            value={projectName}
            onInput={(e, val) => setProjectName(val)}
          />
        </Flex.Item>
        <Flex.Item>
          <label>Description:</label>
          <TextArea
            value={description}
            onInput={(e, val) => setDescription(val)}
          />
        </Flex.Item>
        <Flex.Item>
          <label>Hypothesis:</label>
          <TextArea
            value={hypothesis}
            onInput={(e, val) => setHypothesis(val)}
          />
        </Flex.Item>
        <Flex.Item>
          <label>Procedure:</label>
          <TextArea value={procedure} onInput={(e, val) => setProcedure(val)} />
        </Flex.Item>
        <Flex.Item>
          <label>Risks:</label>
          <TextArea value={risks} onInput={(e, val) => setRisks(val)} />
        </Flex.Item>
        <Flex.Item>
          <label>Required Equipment:</label>
          <TextArea
            value={requiredEquipment}
            onInput={(e, val) => setRequiredEquipment(val)}
          />
        </Flex.Item>
        <Flex.Item>
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
              setComputerFiles(files || []); // Ensure files is an array
              setShowFileBrowser(true);
            }}
          />
        </Flex.Item>
        {showFileBrowser && (
          <Section title="Attach File">
            {computerFiles.map((file) => (
              <Button
                key={file.uid}
                content={file.name}
                onClick={() => {
                  setAttachment(file);
                  setShowFileBrowser(false);
                }}
              />
            ))}
          </Section>
        )}
        <Flex.Item>
          <Button
            content="Propose"
            disabled={!isScpSelected || !projectName || !description}
            onClick={handlePropose}
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

export const SCPResearchConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    researchPoints,
    logisticsPoints,
    scps = [],
    dangerLevels = [],
  } = data;
  const [view, setView] = useSharedState(context, 'view', 'board');
  const [filter, setFilter] = useState('All');
  const [searchText, setSearchText] = useState('');

  const searchForScps = (scpList, search) => {
    search = search.toLowerCase();
    return flow([
      (list) =>
        list.filter(
          (scp) =>
            scp.name?.toLowerCase().includes(search) ||
            scp.id?.toLowerCase().includes(search) ||
            scp.dangerTier?.toLowerCase().includes(search),
        ),
      sortBy((scp) => scp.id),
    ])(scpList);
  };

  const filteredScps =
    filter === 'search_results'
      ? searchForScps(scps, searchText)
      : filter === 'All'
        ? scps
        : scps.filter((scp) => scp.obj_class_enum === filter);

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
          <Section title="SCP Catalogue">
            <Flex>
              <Flex.Item minWidth="30%" ml={-1} mr={1}>
                <Tabs vertical>
                  <Tabs.Tab
                    key="search_results"
                    selected={filter === 'search_results'}
                  >
                    <Stack align="baseline">
                      <Stack.Item>
                        <Icon name="search" />
                      </Stack.Item>
                      <Stack.Item grow>
                        <Input
                          fluid
                          placeholder="Search..."
                          value={searchText}
                          onInput={(e, value) => {
                            if (value === searchText) {
                              return;
                            }
                            if (value.length) {
                              setFilter('search_results');
                            } else if (filter === 'search_results') {
                              setFilter('All');
                            }
                            setSearchText(value);
                          }}
                        />
                      </Stack.Item>
                    </Stack>
                  </Tabs.Tab>
                  <Tabs.Tab
                    key="All"
                    label="All"
                    selected={filter === 'All'}
                    onClick={() => {
                      setFilter('All');
                      setSearchText('');
                    }}
                  />
                  {dangerLevels.map((level) => (
                    <Tabs.Tab
                      key={level.key}
                      label={level.label}
                      selected={filter === level.key}
                      onClick={() => {
                        setFilter(level.key);
                        setSearchText('');
                      }}
                    />
                  ))}
                </Tabs>
              </Flex.Item>
              <Flex.Item grow={1} basis={0}>
                <Table>
                  {filteredScps.map((scp) => (
                    <SCPTableRow key={scp.id} scp={scp} />
                  ))}
                </Table>
              </Flex.Item>
            </Flex>
          </Section>
        )}
        {view === 'propose' && <ProposeTest />}
      </Window.Content>
    </Window>
  );
};
