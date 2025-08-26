{
  imports =
    [
      ./frigate
      ./home-assistant
      ./kamstrup-mqtt
      ./zigbee2mqtt
      ./mosquitto
      ./anythingllm
      ./wol-proxy # Added wol-proxy to the list of container services.
    ];
}
