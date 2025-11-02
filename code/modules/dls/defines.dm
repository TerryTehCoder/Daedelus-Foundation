// --- DLS Subsystem ---
#define FIRE_PRIORITY_DLS 20
#define DLS_RECENT_EVENT_WINDOW 5 MINUTES
#define DLS_WHISPER_COOLDOWN 1 MINUTE

// --- DLS Operating Modes ---
#define DLS_MODE_AUTONOMOUS 1
#define DLS_MODE_GUIDED 2
#define DLS_MODE_MANUAL 3

// --- DLS Behavioral Score Types ---
#define DLS_SCORE_STRESS "stress"
#define DLS_SCORE_AGGRESSION "aggression"
#define DLS_SCORE_SUSPICION "suspicion"
#define DLS_SCORE_ISOLATION "isolation"
#define DLS_SCORE_ILLICIT "illicit"

// --- DLS Whisper Tiers ---
#define DLS_TIER_ROUTINE 1
#define DLS_TIER_SUSPICIOUS 2
#define DLS_TIER_CRITICAL 3

// --- DLS Whisper Status ---
#define DLS_STATUS_UNVALIDATED 0
#define DLS_STATUS_VALIDATED 1
#define DLS_STATUS_INVALIDATED 2
