import { useBackend, useLocalState } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  Box,
  Stack,
  Input,
  Modal,
} from '../components';
import { Window } from '../layouts';

export const PersistentProgressionAdmin = (props, context) => {
  const { act, data } = useBackend(context);
  const { players } = data;
  const [selectedPlayer, setSelectedPlayer] = useLocalState(
    context,
    'selectedPlayer',
    null,
  );
  const [showAwardModal, setShowAwardModal] = useLocalState(
    context,
    'showAwardModal',
    false,
  );
  const [showRankModal, setShowRankModal] = useLocalState(
    context,
    'showRankModal',
    false,
  );
  const [awardAmount, setAwardAmount] = useLocalState(
    context,
    'awardAmount',
    '',
  );
  const [awardReason, setAwardReason] = useLocalState(
    context,
    'awardReason',
    '',
  );
  const [rankClass, setRankClass] = useLocalState(context, 'rankClass', '');
  const [rankLevel, setRankLevel] = useLocalState(context, 'rankLevel', '');

  const handleAwardExperience = () => {
    if (selectedPlayer && awardAmount && awardReason) {
      act('award_experience', {
        ckey: selectedPlayer,
        amount: parseInt(awardAmount),
        reason: awardReason,
      });
      setShowAwardModal(false);
      setAwardAmount('');
      setAwardReason('');
    }
  };

  const handleSetRank = () => {
    if (selectedPlayer && rankClass && rankLevel !== '') {
      act('set_rank', {
        ckey: selectedPlayer,
        class_id: rankClass,
        rank_level: parseInt(rankLevel),
      });
      setShowRankModal(false);
      setRankClass('');
      setRankLevel('');
    }
  };

  return (
    <Window title="Persistent Progression Admin" width={1000} height={700}>
      <Window.Content scrollable>
        <Section title="Player Management">
          <Stack fill vertical>
            {players.map((player) => (
              <Stack.Item key={player.ckey}>
                <Box p={2} backgroundColor="rgba(0, 0, 0, 0.1)">
                  <Stack>
                    <Stack.Item grow>
                      <Box fontSize="1.1em" fontWeight="bold">
                        {player.name} ({player.ckey})
                      </Box>
                      <LabeledList>
                        <LabeledList.Item label="Class">
                          {player.class}
                        </LabeledList.Item>
                        <LabeledList.Item label="Rank">
                          {player.rank}
                        </LabeledList.Item>
                        <LabeledList.Item label="Experience">
                          {player.experience.toLocaleString()}
                        </LabeledList.Item>
                        <LabeledList.Item label="Rounds Played">
                          {player.rounds_played}
                        </LabeledList.Item>
                      </LabeledList>
                    </Stack.Item>
                    <Stack.Item>
                      <Stack vertical>
                        <Stack.Item>
                          <Button
                            content="Award Experience"
                            onClick={() => {
                              setSelectedPlayer(player.ckey);
                              setShowAwardModal(true);
                            }}
                            color="blue"
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            content="Set Rank"
                            onClick={() => {
                              setSelectedPlayer(player.ckey);
                              setShowRankModal(true);
                            }}
                            color="green"
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            content="Reset Progress"
                            onClick={() =>
                              act('reset_progress', { ckey: player.ckey })
                            }
                            color="red"
                          />
                        </Stack.Item>
                        <Stack.Item>
                          <Button
                            content="View Progress"
                            onClick={() =>
                              act('view_progress', { ckey: player.ckey })
                            }
                            color="yellow"
                          />
                        </Stack.Item>
                      </Stack>
                    </Stack.Item>
                  </Stack>
                </Box>
              </Stack.Item>
            ))}
          </Stack>
        </Section>

        {showAwardModal && (
          <Modal>
            <Section title="Award Experience">
              <Stack fill vertical>
                <Stack.Item>
                  <Box>Player: {selectedPlayer}</Box>
                </Stack.Item>
                <Stack.Item>
                  <Input
                    placeholder="Amount"
                    value={awardAmount}
                    onChange={(e, value) => setAwardAmount(value)}
                    type="number"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Input
                    placeholder="Reason"
                    value={awardReason}
                    onChange={(e, value) => setAwardReason(value)}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <Stack.Item grow>
                      <Button
                        content="Cancel"
                        onClick={() => setShowAwardModal(false)}
                        color="red"
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        content="Award"
                        onClick={handleAwardExperience}
                        color="green"
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Modal>
        )}

        {showRankModal && (
          <Modal>
            <Section title="Set Rank">
              <Stack fill vertical>
                <Stack.Item>
                  <Box>Player: {selectedPlayer}</Box>
                </Stack.Item>
                <Stack.Item>
                  <Input
                    placeholder="Class ID (e.g., security)"
                    value={rankClass}
                    onChange={(e, value) => setRankClass(value)}
                  />
                </Stack.Item>
                <Stack.Item>
                  <Input
                    placeholder="Rank Level (0-6)"
                    value={rankLevel}
                    onChange={(e, value) => setRankLevel(value)}
                    type="number"
                  />
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <Stack.Item grow>
                      <Button
                        content="Cancel"
                        onClick={() => setShowRankModal(false)}
                        color="red"
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        content="Set Rank"
                        onClick={handleSetRank}
                        color="green"
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Modal>
        )}
      </Window.Content>
    </Window>
  );
};
