$nocompile


'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
'  +
'  + File NAME      rfm23b_register_constants.inc
'  +
'  + DESCRIPTION:   Register addresses of RFM23B
'  +
'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


Const Device_type = &H00
Const Device_version = &H01
Const Device_status = &H02
Const Interrupt_status_1 = &H03
Const Interrupt_status_2 = &H04
Const Interrupt_enable_1 = &H05
Const Interrupt_enable_2 = &H06
Const Operating_function_control_1 = &H07
Const Operating_function_control_2 = &H08
Const Crystal_osc_load_capacitance = &H09
Const Microcontroller_output_clock = &H0A
Const Gpio0_configuration = &H0B
Const Gpio1_configuration = &H0C
Const Gpio2_configuration = &H0D
Const I_o_port_configuration = &H0E
Const Adc_configuration = &H0F
Const Adc_sensor_amplifier_offset = &H10
Const Adc_value = &H11
Const Temperature_sensor_control = &H12
Const Temperature_value_offset = &H13
Const Wake_up_timer_period_1 = &H14
Const Wake_up_timer_period_2 = &H15
Const Wake_up_timer_period_3 = &H16
Const Wake_up_timer_value_1 = &H17
Const Wake_up_timer_value_2 = &H18
Const Low_duty_cycle_mode_duration = &H19
Const Low_battery_detector_threshold = &H1A
Const Battery_voltage_level = &H1B
Const If_filter_bandwidth = &H1C
Const Afc_loop_gearshift_override = &H1D
Const Afc_timing_control = &H1E
Const Clock_recovery_gearshift_overr = &H1F
Const Clock_recovery_oversampling_rat = &H20
Const Clock_recovery_offset_2 = &H21
Const Clock_recovery_offset_1 = &H22
Const Clock_recovery_offset_0 = &H23
Const Clock_recovery_tim_loop_gain_1 = &H24
Const Clock_recovery_tim_loop_gain_0 = &H25
Const Received_signal_strength_indic = &H26
Const Rssi_thresh_for_clear_ch_indi = &H27
Const Antenna_diversity_register_1 = &H28
Const Antenna_diversity_register_2 = &H29
Const Afc_limiter = &H2A
Const Afc_correction_read = &H2B
Const Ook_counter_value_1 = &H2C
Const Ook_counter_value_2 = &H2D
Const Slicer_peak_hold = &H2E
Const Data_access_control = &H30
Const Ezmac_status = &H31
Const Header_control_1 = &H32
Const Header_control_2 = &H33
Const Preamble_length = &H34
Const Preamble_detection_control = &H35
Const Sync_word_3 = &H36
Const Sync_word_2 = &H37
Const Sync_word_1 = &H38
Const Sync_word_0 = &H39
Const Transmit_header_3 = &H3A
Const Transmit_header_2 = &H3B
Const Transmit_header_1 = &H3C
Const Transmit_header_0 = &H3D
Const Transmit_packet_length = &H3E
Const Check_header_3 = &H3F
Const Check_header_2 = &H40
Const Check_header_1 = &H41
Const Check_header_0 = &H42
Const Header_enable_3 = &H43
Const Header_enable_2 = &H44
Const Header_enable_1 = &H45
Const Header_enable_0 = &H46
Const Received_header_3 = &H47
Const Received_header_2 = &H48
Const Received_header_1 = &H49
Const Received_header_0 = &H4A
Const Received_packet_length = &H4B
Const Adc8_control = &H4F
Const Channel_filter_coefficient_addr = &H60
Const Crystal_oscillator_control_test = &H62
Const Agc_override_1 = &H69
Const Tx_power = &H6D
Const Tx_data_rate_1 = &H6E
Const Tx_data_rate_0 = &H6F
Const Modulation_mode_control_1 = &H70
Const Modulation_mode_control_2 = &H71
Const Frequency_deviation = &H72
Const Frequency_offset_1 = &H73
Const Frequency_offset_2 = &H74
Const Frequency_band_select = &H75
Const Nominal_carrier_frequency_1 = &H76
Const Nominal_carrier_frequency_0 = &H77
Const Frequency_hopping_channel_select = &H79
Const Frequency_hopping_step_size = &H7A
Const Tx_fifo_control_1 = &H7C
Const Tx_fifo_control_2 = &H7D
Const Rx_fifo_control = &H7E
Const Fifo_access = &H7F
