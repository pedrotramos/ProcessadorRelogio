LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY flipFlop IS
	PORT (
		clock, d, clear, preset : IN std_logic;
		q                       : OUT std_logic := '0'
	);
END ENTITY;

ARCHITECTURE arch OF flipFlop IS
BEGIN

	PROCESS (clock, clear, preset)
	BEGIN
		IF (clear = '1') THEN
			q <= '0';
		ELSIF (preset = '1') THEN
			q <= '1';
		ELSIF (rising_edge(clock)) THEN
			q <= d;
		END IF;

	END PROCESS;

END ARCHITECTURE;