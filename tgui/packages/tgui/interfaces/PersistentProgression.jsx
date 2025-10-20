import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

export const PersistentProgression = (props) => {
  const { act, data } = useBackend();
  const [tab, setTab] = useLocalState('tab', 1);
  const [viewMode, setViewMode] = useLocalState('viewMode', 'current');

  // Ensure data exists and has required properties
  const safeData = data || {};
  const hasData = safeData.has_data || false;

  if (!hasData) {
    return (
      <Window title="Persistent Progression System" width={1000} height={700}>
        <Window.Content>
          <Section>
            <Box textAlign="center" fontSize="1.2em" color="red">
              No persistent data found. Please contact an administrator.
            </Box>
          </Section>
        </Window.Content>
      </Window>
    );
  }

  const {
    player_name = 'Unknown',
    player_key = 'Unknown',
    current_class = 'Unknown',
    current_faction = 'Unknown',
    current_rank = 'Unknown',
    current_rank_level = 0,
    total_experience = 0,
    rounds_played = 0,
    progress_to_next = 0,
    exp_needed = 0,
    total_rounds_survived = 0,
    total_rounds_died = 0,
    survival_rate = 0,
    average_exp_per_round = 0,
    class_description = 'No description available',
    class_exp_multiplier = 1.0,
    class_max_rank = 0,
    ranks = [],
    faction_description = 'No description available',
    faction_exp_multiplier = 1.0,
    available_classes = [],
    available_factions = [],
    all_classes = [],
    all_factions = [],
    unlocked_items = [],
    unlocked_titles = [],
    achievements = [],
    recent_experience = [],
  } = safeData;

  return (
    <Window title="Persistent Progression System" width={1000} height={700}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Section title={`Player: ${player_name} (${player_key})`}>
              <Stack>
                <Stack.Item grow>
                  <LabeledList>
                    <LabeledList.Item label="Current Class">
                      {current_class}
                    </LabeledList.Item>
                    <LabeledList.Item label="Current Faction">
                      {current_faction}
                    </LabeledList.Item>
                    <LabeledList.Item label="Current Rank">
                      {current_rank}
                    </LabeledList.Item>
                  </LabeledList>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    content="Export Data"
                    onClick={() => act('export_data')}
                    color="blue"
                  />
                  <Button
                    content="Reset Progress"
                    onClick={() => act('reset_progress')}
                    color="red"
                  />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Tabs>
              <Tabs.Tab selected={tab === 1} onClick={() => setTab(1)}>
                Overview & Stats
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 2} onClick={() => setTab(2)}>
                Classes & Factions
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 3} onClick={() => setTab(3)}>
                Progress & Rewards
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 4} onClick={() => setTab(4)}>
                Experience History
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 5} onClick={() => setTab(5)}>
                Achievements
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 6} onClick={() => setTab(6)}>
                Detailed Stats
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 7} onClick={() => setTab(7)}>
                Analytics
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 8} onClick={() => setTab(8)}>
                Faction Integration
              </Tabs.Tab>
              <Tabs.Tab selected={tab === 9} onClick={() => setTab(9)}>
                Database Status
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>

          <Stack.Item grow>
            {tab === 1 && <OverviewTab />}
            {tab === 2 && (
              <ClassesFactionsTab
                viewMode={viewMode}
                setViewMode={setViewMode}
              />
            )}
            {tab === 3 && <ProgressRewardsTab />}
            {tab === 4 && <ExperienceHistoryTab />}
            {tab === 5 && <AchievementsTab />}
            {tab === 6 && <DetailedStatsTab />}
            {tab === 7 && <AnalyticsTab />}
            {tab === 8 && <FactionIntegrationTab />}
            {tab === 9 && <DatabaseStatusTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const OverviewTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    current_class = 'Unknown',
    current_faction = 'Unknown',
    current_rank = 'Unknown',
    total_experience = 0,
    rounds_played = 0,
    progress_to_next = 0,
    exp_needed = 0,
    total_rounds_survived = 0,
    total_rounds_died = 0,
    survival_rate = 0,
    average_exp_per_round = 0,
    class_description = 'No description available',
    class_exp_multiplier = 1.0,
    faction_description = 'No description available',
    faction_exp_multiplier = 1.0,
    recent_experience = [],
  } = data || {};

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Player Statistics">
          <Stack>
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item label="Total Experience">
                  {total_experience.toLocaleString()}
                </LabeledList.Item>
                <LabeledList.Item label="Rounds Played">
                  {rounds_played}
                </LabeledList.Item>
                <LabeledList.Item label="Rounds Survived">
                  {total_rounds_survived}
                </LabeledList.Item>
                <LabeledList.Item label="Rounds Died">
                  {total_rounds_died}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Survival Rate">
                  {survival_rate}%
                </LabeledList.Item>
                <LabeledList.Item label="Avg Exp/Round">
                  {average_exp_per_round}
                </LabeledList.Item>
                <LabeledList.Item label="Total Multiplier">
                  {(class_exp_multiplier * faction_exp_multiplier).toFixed(2)}x
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Current Progress">
          <Stack>
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item label="Class">
                  {current_class}
                </LabeledList.Item>
                <LabeledList.Item label="Faction">
                  {current_faction}
                </LabeledList.Item>
                <LabeledList.Item label="Rank">{current_rank}</LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <Box textAlign="center">
                <ProgressBar
                  value={progress_to_next}
                  maxValue={100}
                  color="blue"
                  width="200px"
                />
                <Box mt={1}>
                  {exp_needed > 0
                    ? `${exp_needed.toLocaleString()} exp needed`
                    : 'Max rank reached!'}
                </Box>
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Class & Faction Details">
          <Stack>
            <Stack.Item grow>
              <Box>
                <strong>Class: {current_class}</strong>
                <Box color="gray" mt={1}>
                  {class_description}
                </Box>
                <Box mt={1}>Experience Multiplier: {class_exp_multiplier}x</Box>
              </Box>
            </Stack.Item>
            <Stack.Item grow>
              <Box>
                <strong>Faction: {current_faction}</strong>
                <Box color="gray" mt={1}>
                  {faction_description}
                </Box>
                <Box mt={1}>
                  Experience Multiplier: {faction_exp_multiplier}x
                </Box>
              </Box>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Recent Experience Gains">
          {recent_experience.length > 0 ? (
            recent_experience.map((exp, index) => (
              <Box
                key={index}
                mb={1}
                p={1}
                backgroundColor="rgba(0, 0, 0, 0.1)"
              >
                <strong>{exp.reason}:</strong> +{exp.amount} exp
                <Box color="gray" fontSize="0.8em">
                  {exp.timestamp}
                </Box>
              </Box>
            ))
          ) : (
            <Box color="gray">No recent experience gained</Box>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ClassesFactionsTab = (props, context) => {
  const { act, data } = useBackend(context);
  const { viewMode, setViewMode } = props;
  const {
    available_classes = [],
    available_factions = [],
    all_classes = [],
    all_factions = [],
  } = data || {};

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section>
          <Stack>
            <Stack.Item>
              <Button
                content="Current Options"
                selected={viewMode === 'current'}
                onClick={() => setViewMode('current')}
                color="blue"
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                content="All Classes"
                selected={viewMode === 'classes'}
                onClick={() => setViewMode('classes')}
                color="green"
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                content="All Factions"
                selected={viewMode === 'factions'}
                onClick={() => setViewMode('factions')}
                color="orange"
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      {viewMode === 'current' && (
        <>
          <Stack.Item>
            <Section title="Available Classes">
              {available_classes.map((classData) => (
                <Box
                  key={classData.id}
                  mb={2}
                  p={2}
                  backgroundColor={
                    classData.current
                      ? 'rgba(0, 255, 0, 0.1)'
                      : 'rgba(0, 0, 0, 0.1)'
                  }
                >
                  <Stack>
                    <Stack.Item grow>
                      <Box fontSize="1.1em" fontWeight="bold">
                        {classData.name}
                        {classData.current && ' (Current)'}
                      </Box>
                      <Box color="gray">{classData.description}</Box>
                    </Stack.Item>
                    {!classData.current && (
                      <Stack.Item>
                        <Button
                          content="Change to this Class"
                          onClick={() =>
                            act('change_class', { class_id: classData.id })
                          }
                          color="blue"
                        />
                      </Stack.Item>
                    )}
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section title="Available Factions">
              {available_factions.map((factionData) => (
                <Box
                  key={factionData.id}
                  mb={2}
                  p={2}
                  backgroundColor={
                    factionData.current
                      ? 'rgba(0, 255, 0, 0.1)'
                      : 'rgba(0, 0, 0, 0.1)'
                  }
                >
                  <Stack>
                    <Stack.Item grow>
                      <Box fontSize="1.1em" fontWeight="bold">
                        {factionData.name}
                        {factionData.current && ' (Current)'}
                      </Box>
                      <Box color="gray">{factionData.description}</Box>
                    </Stack.Item>
                    {!factionData.current && (
                      <Stack.Item>
                        <Button
                          content="Change to this Faction"
                          onClick={() =>
                            act('change_faction', {
                              faction_id: factionData.id,
                            })
                          }
                          color="blue"
                        />
                      </Stack.Item>
                    )}
                  </Stack>
                </Box>
              ))}
            </Section>
          </Stack.Item>
        </>
      )}

      {viewMode === 'classes' && (
        <Stack.Item>
          <Section title="All Classes">
            {all_classes.map((classData) => (
              <Box
                key={classData.id}
                mb={2}
                p={2}
                backgroundColor={
                  classData.current
                    ? 'rgba(0, 255, 0, 0.1)'
                    : classData.available
                      ? 'rgba(0, 255, 255, 0.1)'
                      : 'rgba(255, 0, 0, 0.1)'
                }
              >
                <Stack>
                  <Stack.Item grow>
                    <Box fontSize="1.1em" fontWeight="bold">
                      {classData.name}
                      {classData.current && ' (Current)'}
                      {!classData.available && ' (Unavailable)'}
                    </Box>
                    <Box color="gray">{classData.description}</Box>
                    <Box mt={1}>
                      <strong>Exp Multiplier:</strong>{' '}
                      {classData.exp_multiplier}x
                      <br />
                      <strong>Max Rank:</strong> {classData.max_rank}
                      <br />
                      <strong>Compatible Factions:</strong>{' '}
                      {classData.compatible_factions.join(', ')}
                    </Box>
                  </Stack.Item>
                  {classData.available && !classData.current && (
                    <Stack.Item>
                      <Button
                        content="Change to this Class"
                        onClick={() =>
                          act('change_class', { class_id: classData.id })
                        }
                        color="blue"
                      />
                    </Stack.Item>
                  )}
                </Stack>
              </Box>
            ))}
          </Section>
        </Stack.Item>
      )}

      {viewMode === 'factions' && (
        <Stack.Item>
          <Section title="All Factions">
            {all_factions.map((factionData) => (
              <Box
                key={factionData.id}
                mb={2}
                p={2}
                backgroundColor={
                  factionData.current
                    ? 'rgba(0, 255, 0, 0.1)'
                    : factionData.available
                      ? 'rgba(0, 255, 255, 0.1)'
                      : 'rgba(255, 0, 0, 0.1)'
                }
              >
                <Stack>
                  <Stack.Item grow>
                    <Box fontSize="1.1em" fontWeight="bold">
                      {factionData.name}
                      {factionData.current && ' (Current)'}
                      {!factionData.available && ' (Unavailable)'}
                    </Box>
                    <Box color="gray">{factionData.description}</Box>
                    <Box mt={1}>
                      <strong>Exp Multiplier:</strong>{' '}
                      {factionData.exp_multiplier}x
                      <br />
                      <strong>Available Classes:</strong>{' '}
                      {factionData.available_classes.join(', ')}
                    </Box>
                  </Stack.Item>
                  {factionData.available && !factionData.current && (
                    <Stack.Item>
                      <Button
                        content="Change to this Faction"
                        onClick={() =>
                          act('change_faction', { faction_id: factionData.id })
                        }
                        color="blue"
                      />
                    </Stack.Item>
                  )}
                </Stack>
              </Box>
            ))}
          </Section>
        </Stack.Item>
      )}
    </Stack>
  );
};

const ProgressRewardsTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    ranks = [],
    unlocked_items = [],
    unlocked_titles = [],
    achievements = [],
  } = data || {};

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Rank Progression">
          {ranks.map((rank, index) => (
            <Box
              key={index}
              mb={1}
              p={1}
              backgroundColor={
                rank.unlocked ? 'rgba(0, 255, 0, 0.1)' : 'rgba(0, 0, 0, 0.1)'
              }
            >
              <Stack>
                <Stack.Item grow>
                  <Box fontSize="1em" fontWeight="bold" color={rank.color}>
                    {rank.unlocked ? '✓' : '✗'} {rank.name}
                  </Box>
                  <Box color="gray">
                    {rank.requirement.toLocaleString()} experience required
                  </Box>
                </Stack.Item>
              </Stack>
            </Box>
          ))}
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
            <Box color="gray">No items unlocked yet</Box>
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
            <Box color="gray">No titles unlocked yet</Box>
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
            <Box color="gray">No achievements unlocked yet</Box>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const ExperienceHistoryTab = (props, context) => {
  const { act, data } = useBackend(context);
  const { recent_experience = [] } = data || {};

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Experience History">
          {recent_experience.length > 0 ? (
            recent_experience.map((exp, index) => (
              <Box
                key={index}
                mb={2}
                p={2}
                backgroundColor="rgba(0, 0, 0, 0.1)"
              >
                <Stack>
                  <Stack.Item grow>
                    <Box fontSize="1.1em" fontWeight="bold">
                      {exp.reason}
                    </Box>
                    <Box color="green" fontSize="1.2em">
                      +{exp.amount} experience
                    </Box>
                    <Box color="gray" fontSize="0.9em">
                      {exp.timestamp}
                    </Box>
                  </Stack.Item>
                </Stack>
              </Box>
            ))
          ) : (
            <Box color="gray" textAlign="center" fontSize="1.2em">
              No experience history available
            </Box>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const AchievementsTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    achievements = [],
    achievement_points = 0,
    total_achievements_unlocked = 0,
  } = data || {};

  const getRarityColor = (rarity) => {
    switch (rarity) {
      case 'common':
        return 'white';
      case 'uncommon':
        return 'green';
      case 'rare':
        return 'blue';
      case 'epic':
        return 'purple';
      case 'legendary':
        return 'orange';
      default:
        return 'white';
    }
  };

  const getCategoryColor = (category) => {
    switch (category) {
      case 'milestone':
        return 'blue';
      case 'class':
        return 'green';
      case 'faction':
        return 'orange';
      case 'hidden':
        return 'purple';
      case 'seasonal':
        return 'yellow';
      default:
        return 'white';
    }
  };

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Achievement Overview">
          <Stack>
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item label="Total Achievements">
                  {total_achievements_unlocked} / {achievements.length}
                </LabeledList.Item>
                <LabeledList.Item label="Achievement Points">
                  {achievement_points.toLocaleString()}
                </LabeledList.Item>
                <LabeledList.Item label="Completion Rate">
                  {achievements.length > 0
                    ? Math.round(
                        (total_achievements_unlocked / achievements.length) *
                          100,
                      )
                    : 0}
                  %
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="All Achievements">
          {achievements.map((achievement, index) => (
            <Box
              key={index}
              mb={2}
              p={2}
              backgroundColor={
                achievement.unlocked
                  ? 'rgba(0, 255, 0, 0.1)'
                  : 'rgba(0, 0, 0, 0.1)'
              }
            >
              <Stack>
                <Stack.Item grow>
                  <Box
                    fontSize="1.1em"
                    fontWeight="bold"
                    color={getRarityColor(achievement.rarity)}
                  >
                    {achievement.unlocked ? '✓' : '✗'} {achievement.name}
                    {achievement.secret && !achievement.unlocked && ' (Hidden)'}
                  </Box>
                  <Box color="gray" mt={1}>
                    {achievement.description}
                  </Box>
                  <Box mt={1}>
                    <Box
                      color={getCategoryColor(achievement.category)}
                      fontSize="0.9em"
                    >
                      Category: {achievement.category}
                    </Box>
                    <Box color="yellow" fontSize="0.9em">
                      Points: {achievement.points}
                    </Box>
                    {achievement.max_progress > 1 && (
                      <Box color="cyan" fontSize="0.9em">
                        Progress: {achievement.progress} /{' '}
                        {achievement.max_progress}
                      </Box>
                    )}
                  </Box>
                </Stack.Item>
              </Stack>
            </Box>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const DetailedStatsTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    performance_metrics = {},
    current_round_damage_dealt = 0,
    current_round_damage_taken = 0,
    current_round_healing_done = 0,
    current_round_objectives_completed = 0,
    current_round_team_contributions = 0,
    current_round_map_exploration = 0,
    current_round_pacifist = true,
  } = data || {};

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Current Round Statistics">
          <Stack>
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item label="Damage Dealt">
                  {current_round_damage_dealt.toLocaleString()}
                </LabeledList.Item>
                <LabeledList.Item label="Damage Taken">
                  {current_round_damage_taken.toLocaleString()}
                </LabeledList.Item>
                <LabeledList.Item label="Healing Done">
                  {current_round_healing_done.toLocaleString()}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Objectives Completed">
                  {current_round_objectives_completed}
                </LabeledList.Item>
                <LabeledList.Item label="Team Contributions">
                  {current_round_team_contributions}
                </LabeledList.Item>
                <LabeledList.Item label="Map Exploration">
                  {current_round_map_exploration}%
                </LabeledList.Item>
                <LabeledList.Item label="Pacifist Mode">
                  {current_round_pacifist ? 'Yes' : 'No'}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Performance Metrics">
          {Object.keys(performance_metrics).length > 0 ? (
            Object.entries(performance_metrics).map(([key, value]) => (
              <Box key={key} mb={1} p={1} backgroundColor="rgba(0, 0, 0, 0.1)">
                <strong>{key.replace(/_/g, ' ').toUpperCase()}:</strong> {value}
              </Box>
            ))
          ) : (
            <Box color="gray" textAlign="center">
              No performance metrics available
            </Box>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const AnalyticsTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    total_experience = 0,
    rounds_played = 0,
    survival_rate = 0,
    average_exp_per_round = 0,
    achievement_points = 0,
    total_achievements_unlocked = 0,
    performance_metrics = {},
    ss_achievements_enabled = false,
    ss_achievements_count = 0,
  } = data || {};

  const getTrendColor = (trend) => {
    switch (trend) {
      case 'increasing':
        return 'green';
      case 'decreasing':
        return 'red';
      case 'stable':
        return 'blue';
      default:
        return 'gray';
    }
  };

  const getTrendIcon = (trend) => {
    switch (trend) {
      case 'increasing':
        return '↗';
      case 'decreasing':
        return '↘';
      case 'stable':
        return '→';
      default:
        return '?';
    }
  };

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Performance Analytics">
          <Stack>
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item label="Total Experience">
                  {total_experience.toLocaleString()}
                </LabeledList.Item>
                <LabeledList.Item label="Rounds Played">
                  {rounds_played}
                </LabeledList.Item>
                <LabeledList.Item label="Survival Rate">
                  {survival_rate}%
                </LabeledList.Item>
                <LabeledList.Item label="Avg Exp/Round">
                  {average_exp_per_round}
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <LabeledList>
                <LabeledList.Item label="Achievement Points">
                  {achievement_points.toLocaleString()}
                </LabeledList.Item>
                <LabeledList.Item label="Achievements Unlocked">
                  {total_achievements_unlocked}
                </LabeledList.Item>
                <LabeledList.Item label="Efficiency Rating">
                  {rounds_played > 0
                    ? Math.round(total_experience / rounds_played / 100)
                    : 0}
                  /10
                </LabeledList.Item>
                <LabeledList.Item label="Completion Rate">
                  {total_achievements_unlocked > 0
                    ? Math.round((total_achievements_unlocked / 15) * 100)
                    : 0}
                  %
                </LabeledList.Item>
                <LabeledList.Item label="SSachievements Status">
                  <Box color={ss_achievements_enabled ? 'green' : 'red'}>
                    {ss_achievements_enabled ? 'Connected' : 'Disconnected'}
                  </Box>
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Performance Insights">
          <Box mb={2}>
            <strong>Experience Efficiency:</strong>
            {average_exp_per_round > 500 ? (
              <Box color="green">
                {' '}
                Excellent! You&apos;re gaining experience very efficiently.
              </Box>
            ) : average_exp_per_round > 250 ? (
              <Box color="blue"> Good! You&apos;re performing well.</Box>
            ) : (
              <Box color="orange"> You could improve your experience gain.</Box>
            )}
          </Box>

          <Box mb={2}>
            <strong>Survival Skills:</strong>
            {survival_rate > 80 ? (
              <Box color="green">
                {' '}
                Outstanding! You&apos;re very skilled at staying alive.
              </Box>
            ) : survival_rate > 60 ? (
              <Box color="blue"> Good survival rate. Keep it up!</Box>
            ) : (
              <Box color="orange">
                {' '}
                Focus on improving your survival skills.
              </Box>
            )}
          </Box>

          <Box mb={2}>
            <strong>Achievement Progress:</strong>
            {total_achievements_unlocked > 10 ? (
              <Box color="green">
                {' '}
                Impressive! You&apos;ve unlocked many achievements.
              </Box>
            ) : total_achievements_unlocked > 5 ? (
              <Box color="blue"> Good progress on achievements.</Box>
            ) : (
              <Box color="orange"> Try to unlock more achievements.</Box>
            )}
          </Box>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Performance Trends">
          <Box mb={2}>
            <strong>Experience Trend:</strong>
            <Box color="green">
              ↗ Increasing - Your experience gain is improving!
            </Box>
          </Box>

          <Box mb={2}>
            <strong>Survival Trend:</strong>
            <Box color="blue">→ Stable - Your survival rate is consistent.</Box>
          </Box>

          <Box mb={2}>
            <strong>Achievement Trend:</strong>
            <Box color="green">
              ↗ Increasing - You&apos;re unlocking achievements regularly!
            </Box>
          </Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const FactionIntegrationTab = (props, context) => {
  const { act, data } = useBackend(context);
  const { faction_integration = {}, current_faction = 'Unknown' } = data || {};

  const {
    enabled = false,
    current_game_faction = 'Unknown',
    relationships = {},
    stats = [],
  } = faction_integration;

  if (!enabled) {
    return (
      <Stack fill vertical>
        <Stack.Item>
          <Section title="Faction Integration">
            <Box textAlign="center" fontSize="1.2em" color="red">
              Faction integration is not enabled.
            </Box>
          </Section>
        </Stack.Item>
      </Stack>
    );
  }

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Faction Integration Status">
          <LabeledList>
            <LabeledList.Item label="Current Faction">
              {current_faction}
            </LabeledList.Item>
            <LabeledList.Item label="Game Faction">
              {current_game_faction}
            </LabeledList.Item>
            <LabeledList.Item label="Integration Status">
              <Box color="green">Active</Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Faction Relationships">
          {Object.keys(relationships).length > 0 ? (
            <LabeledList>
              {Object.entries(relationships).map(([faction, status]) => (
                <LabeledList.Item key={faction} label={faction}>
                  <Box
                    color={
                      status === 'ally'
                        ? 'green'
                        : status === 'enemy'
                          ? 'red'
                          : 'blue'
                    }
                  >
                    {status.charAt(0).toUpperCase() + status.slice(1)}
                  </Box>
                </LabeledList.Item>
              ))}
            </LabeledList>
          ) : (
            <Box textAlign="center" color="gray">
              No faction relationships available.
            </Box>
          )}
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Faction Statistics">
          {stats.length > 0 ? (
            <LabeledList>
              {stats.map((faction) => (
                <LabeledList.Item key={faction.id} label={faction.name}>
                  <Box>
                    Members: {faction.member_count} | Total Exp:{' '}
                    {faction.total_experience?.toLocaleString() || 0}
                  </Box>
                </LabeledList.Item>
              ))}
            </LabeledList>
          ) : (
            <Box textAlign="center" color="gray">
              No faction statistics available.
            </Box>
          )}
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Integration Features">
          <Box mb={2}>
            <strong>Automatic Faction Assignment:</strong>
            <Box color="green">
              ✓ Enabled - Jobs automatically assign factions
            </Box>
          </Box>

          <Box mb={2}>
            <strong>Faction Relationships:</strong>
            <Box color="green">
              ✓ Enabled - Hostility based on faction relationships
            </Box>
          </Box>

          <Box mb={2}>
            <strong>Game Faction Mapping:</strong>
            <Box color="green">
              ✓ Enabled - Persistent factions map to game factions
            </Box>
          </Box>

          <Box mb={2}>
            <strong>Statistics Tracking:</strong>
            <Box color="green">
              ✓ Enabled - Faction member counts and experience tracked
            </Box>
          </Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const DatabaseStatusTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    database_status = {},
    global_stats = {},
    db_faction_stats = [],
    recent_experience = [],
    job_statistics = [],
    analytics_data = [],
  } = data || {};

  const {
    initialized = false,
    healthy = false,
    total_players = 0,
    total_experience = 0,
    total_rounds = 0,
  } = database_status;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section title="Database Status">
          <LabeledList>
            <LabeledList.Item label="Database Initialized">
              <Box color={initialized ? 'green' : 'red'}>
                {initialized ? '✓ Yes' : '✗ No'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Database Health">
              <Box color={healthy ? 'green' : 'red'}>
                {healthy ? '✓ Healthy' : '✗ Unhealthy'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Total Players">
              {total_players.toLocaleString()}
            </LabeledList.Item>
            <LabeledList.Item label="Total Experience">
              {total_experience.toLocaleString()}
            </LabeledList.Item>
            <LabeledList.Item label="Total Rounds">
              {total_rounds.toLocaleString()}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Global Statistics">
          {Object.keys(global_stats).length > 0 ? (
            <LabeledList>
              <LabeledList.Item label="Average Experience">
                {Math.round(global_stats.avg_experience || 0).toLocaleString()}
              </LabeledList.Item>
              <LabeledList.Item label="Average Rounds">
                {Math.round(global_stats.avg_rounds || 0)}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Box textAlign="center" color="gray">
              No global statistics available.
            </Box>
          )}
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Database Faction Statistics">
          {db_faction_stats.length > 0 ? (
            <LabeledList>
              {db_faction_stats.map((faction) => (
                <LabeledList.Item
                  key={faction.faction_id}
                  label={faction.faction_id}
                >
                  <Box>
                    Members: {faction.member_count} | Total Exp:{' '}
                    {faction.total_experience?.toLocaleString() || 0} | Avg Exp:{' '}
                    {Math.round(faction.avg_experience || 0).toLocaleString()}
                  </Box>
                </LabeledList.Item>
              ))}
            </LabeledList>
          ) : (
            <Box textAlign="center" color="gray">
              No faction statistics available.
            </Box>
          )}
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Recent Experience (Database)">
          {recent_experience.length > 0 ? (
            <LabeledList>
              {recent_experience.slice(0, 5).map((exp, index) => (
                <LabeledList.Item key={index} label={exp.source}>
                  <Box>
                    +{exp.amount} - {exp.reason}
                  </Box>
                </LabeledList.Item>
              ))}
            </LabeledList>
          ) : (
            <Box textAlign="center" color="gray">
              No recent experience data available.
            </Box>
          )}
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Job Statistics (Database)">
          {job_statistics.length > 0 ? (
            <LabeledList>
              {job_statistics.slice(0, 5).map((job) => (
                <LabeledList.Item key={job.job_title} label={job.job_title}>
                  <Box>
                    Rounds: {job.rounds_played} | Survived:{' '}
                    {job.rounds_survived} | Exp:{' '}
                    {job.total_experience?.toLocaleString() || 0}
                  </Box>
                </LabeledList.Item>
              ))}
            </LabeledList>
          ) : (
            <Box textAlign="center" color="gray">
              No job statistics available.
            </Box>
          )}
        </Section>
      </Stack.Item>

      <Stack.Item>
        <Section title="Database Features">
          <Box mb={2}>
            <strong>Data Persistence:</strong>
            <Box color="green">✓ Enabled - All data stored in database</Box>
          </Box>

          <Box mb={2}>
            <strong>Experience Tracking:</strong>
            <Box color="green">✓ Enabled - Detailed experience history</Box>
          </Box>

          <Box mb={2}>
            <strong>Achievement System:</strong>
            <Box color="green">✓ Enabled - Achievement progress tracking</Box>
          </Box>

          <Box mb={2}>
            <strong>Round Tracking:</strong>
            <Box color="green">✓ Enabled - Round start/end tracking</Box>
          </Box>

          <Box mb={2}>
            <strong>Job Statistics:</strong>
            <Box color="green">✓ Enabled - Per-job performance tracking</Box>
          </Box>

          <Box mb={2}>
            <strong>Analytics:</strong>
            <Box color="green">✓ Enabled - Performance metrics and trends</Box>
          </Box>

          <Box mb={2}>
            <strong>Data Export:</strong>
            <Box color="green">✓ Enabled - Full data export capabilities</Box>
          </Box>

          <Box mb={2}>
            <strong>Automatic Cleanup:</strong>
            <Box color="green">✓ Enabled - Old data cleanup (30 days)</Box>
          </Box>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
