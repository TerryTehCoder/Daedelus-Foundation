import { useBackend } from '../backend';
import { Box, Button, Grid } from '../components';
import { Window } from '../layouts';

export const LateChoices = (props, context) => {
  console.log('LateChoices component loaded');
  const { act, data } = useBackend(context);
  console.log('LateChoices data:', data);
  const { round_duration, emergency_status, departments, observer_only } = data;

  return (
    <Window
      title="Late Join Selection"
      width={900}
      height={600}
      theme="ntos_terminal"
    >
      <Window.Content>
        <Box
          style={{
            background: 'rgba(0,0,0,0.7)',
            border: '1px solid rgba(255,255,255,0.2)',
            borderRadius: '5px',
            padding: '20px',
            fontFamily: 'monospace',
            fontSize: '14px',
            color: '#ffffff',
            minHeight: '100%',
            position: 'relative',
          }}
        >
          {/* Header Section */}
          <Box style={{ marginBottom: '20px' }}>
            <Box
              style={{
                fontSize: '24px',
                fontWeight: 'bold',
                marginBottom: '5px',
              }}
            >
              LATE JOIN SELECTION
            </Box>
            <Box style={{ fontSize: '16px', opacity: 0.8 }}>
              PROFESSION & DEPARTMENT CHOICE
            </Box>
          </Box>

          {/* Round Duration */}
          <Box
            style={{
              background: 'rgba(0,255,255,0.1)',
              border: '1px solid rgba(0,255,255,0.3)',
              borderRadius: '5px',
              padding: '10px',
              marginBottom: '20px',
              textAlign: 'center',
              color: '#66ffff',
              fontWeight: 'bold',
            }}
          >
            Round Duration: {round_duration}
          </Box>

          {/* Emergency Status */}
          {emergency_status && (
            <Box
              style={{
                background: 'rgba(255,0,0,0.2)',
                border: '1px solid rgba(255,0,0,0.5)',
                borderRadius: '5px',
                padding: '10px',
                marginBottom: '15px',
                textAlign: 'center',
                color: '#ff6666',
              }}
            >
              {emergency_status}
            </Box>
          )}

          {/* Observer Only Notice */}
          {observer_only && (
            <Box
              style={{
                background: 'rgba(255,0,0,0.2)',
                border: '1px solid rgba(255,0,0,0.5)',
                borderRadius: '5px',
                padding: '10px',
                marginBottom: '15px',
                textAlign: 'center',
                color: '#ff6666',
              }}
            >
              Only Observers may join at this time.
            </Box>
          )}

          {/* Department Grid */}
          <Grid style={{ gap: '10px' }}>
            {departments?.map((department) => (
              <Grid.Column key={department.id} size={4}>
                <Box
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: `2px solid ${department.color}`,
                    borderRadius: '5px',
                    padding: '10px',
                    minHeight: '120px',
                  }}
                >
                  <Box
                    style={{
                      color: department.color,
                      fontWeight: 'bold',
                      textAlign: 'center',
                      marginBottom: '10px',
                      fontSize: '14px',
                    }}
                  >
                    {department.name}
                  </Box>

                  {department.jobs?.length > 0 ? (
                    department.jobs.map((job) => (
                      <Button
                        key={job.title}
                        fluid
                        style={{
                          margin: '2px 0',
                          background: job.priority
                            ? 'rgba(0,255,0,0.1)'
                            : job.command
                              ? 'rgba(255,165,0,0.2)'
                              : 'rgba(255,255,255,0.1)',
                          border: job.priority
                            ? '1px solid rgba(0,255,0,0.3)'
                            : job.command
                              ? '1px solid rgba(255,165,0,0.4)'
                              : '1px solid rgba(255,255,255,0.2)',
                          color: job.priority
                            ? '#66ff66'
                            : job.command
                              ? '#ffaa66'
                              : '#ffffff',
                          fontSize: '12px',
                          padding: '4px 6px',
                          textAlign: 'left',
                          fontWeight:
                            job.priority || job.command ? 'bold' : 'normal',
                        }}
                        onClick={() => act('select_job', { job: job.title })}
                      >
                        {job.title} ({job.positions})
                      </Button>
                    ))
                  ) : (
                    <Box
                      style={{
                        fontStyle: 'italic',
                        color: '#888888',
                        textAlign: 'center',
                        padding: '10px',
                        background: 'rgba(255,255,255,0.05)',
                        borderRadius: '3px',
                      }}
                    >
                      No positions open.
                    </Box>
                  )}
                </Box>
              </Grid.Column>
            ))}
          </Grid>
        </Box>
      </Window.Content>
    </Window>
  );
};
