library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_data_out is
	port(
		clk							: in std_logic;
		avl_str_sink_valid			: in std_logic;
		avl_str_sink_channel		: in std_logic_vector(4 downto 0);
		avl_str_sink_data			: in std_logic_vector(11 downto 0);
		avl_str_sink_startofpacket	: in std_logic;
		avl_str_sink_endofpacket	: in std_logic;
		data_out					: out std_logic_vector(11 downto 0);
		data_valid 					: out std_logic
	);
end adc_data_out;

architecture arch of adc_data_out is
	signal received_sample	: std_logic_vector(11 downto 0);
begin

	process(clk)

	begin
		if rising_edge(clk) then
			data_valid <= '0';
			-- Get the data from ADC channel 1, 
			if avl_str_sink_channel="00001" and avl_str_sink_valid = '1' then
				received_sample <= avl_str_sink_data;
				data_valid <= '1';
			end if;               
		end if;
	end process;
	 
	data_out <= received_sample;
end;
