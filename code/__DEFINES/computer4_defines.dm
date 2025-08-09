#define PERIPHERAL_TYPE_WIRELESS_CARD "WNET_ADAPTER"
#define PERIPHERAL_TYPE_CARD_READER "ID_SCANNER"
#define PERIPHERAL_TYPE_PRINTER "LAR_PRINTER"

// See proc/peripheral_input
#define PERIPHERAL_CMD_RECEIVE_PACKET "receive_packet"
#define PERIPHERAL_CMD_SCAN_CARD "scan_card"

// MedTrak menus
#define MEDTRAK_MENU_HOME 1
#define MEDTRAK_MENU_INDEX 2
#define MEDTRAK_MENU_RECORD 3
#define MEDTRAK_MENU_COMMENTS 4

// Wireless card incoming filter modes
#define WIRELESS_FILTER_PROMISC 0 //! Forward all packets
#define WIRELESS_FILTER_NETADDR 1 //! Forward only bcast/unicast matched GPRS packets
#define WIRELESS_FILTER_ID_TAGS 2 //! id_tag based filtering, for non-GPRS Control.

#define WIRELESS_FILTER_MODEMAX 2 //! Max of WIRELESS_FILTER_* Defines.

// Remote Command Packet Defines
#define PACKET_COMMAND_TYPE "command_type"
#define PACKET_COMMAND_DATA "command_data"
#define NET_CLASS_REMOTE_COMMAND "remote_command"

// Remote Command Execution Defines
#define PACKET_COMMAND_ARGS "command_args" // Key for command arguments in remote packet
#define PACKET_COMMAND_OPTIONS "command_options" // Key for command options in remote packet
#define PACKET_DEST_ADDRESS "dest_address" // Key for destination address in remote packet
#define PACKET_DATA "data" // Key for message data in remote packet
#define NET_CLASS_MESSAGE "message" // Network class for general messages

#define WATCHDOG_COOLDOWN_SECONDS 60 // Cooldown for watchdog alert in seconds
#define AIC_LOGIN_SOUND_RANGE 6 // Range within which AIC login sound is not played directly to the player if already played at computer location
