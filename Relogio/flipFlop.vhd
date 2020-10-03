LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY flipFlop IS
	GENERIC (
		larguraDados : NATURAL := 8
	);
	PORT (
		DIN      : IN std_logic;
		DOUT     : OUT std_logic;
		ENABLE   : IN std_logic;
		CLK, RST : IN std_logic
	);
END ENTITY;

ARCHITECTURE comportamento OF flipFlop IS
BEGIN
	PROCESS (RST, CLK)
	BEGIN
		IF (RST = '1') THEN
			DOUT <= '0';
		ELSE
			IF (rising_edge(CLK)) THEN
				IF (ENABLE = '1') THEN
					DOUT <= DIN;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;