LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;

ENTITY conversorHex7Seg IS
    PORT (
        -- Input ports
        dadoHex       : IN std_logic_vector(3 DOWNTO 0);
        habilita, clk : IN std_logic;
        -- Output ports
        saida7seg : OUT std_logic_vector(6 DOWNTO 0) -- := (others => '1')
    );
END ENTITY;

ARCHITECTURE comportamento OF conversorHex7Seg IS
    --
    --       0
    --      ---
    --     |   |
    --    5|   |1
    --     | 6 |
    --      ---
    --     |   |
    --    4|   |2
    --     |   |
    --      ---
    --       3
    --
    SIGNAL rascSaida7seg : std_logic_vector(6 DOWNTO 0);
BEGIN
    rascSaida7seg <= "1000000" WHEN dadoHex = x"0" ELSE                  ---0
						   "1111001" WHEN dadoHex = x"1" ELSE                  ---1
						   "0100100" WHEN dadoHex = x"2" ELSE                  ---2
						   "0110000" WHEN dadoHex = x"3" ELSE                  ---3
						   "0011001" WHEN dadoHex = x"4" ELSE                  ---4
						   "0010010" WHEN dadoHex = x"5" ELSE                  ---5
						   "0000010" WHEN dadoHex = x"6" ELSE                  ---6
						   "1111000" WHEN dadoHex = x"7" ELSE                  ---7
						   "0000000" WHEN dadoHex = x"8" ELSE                  ---8
						   "0010000" WHEN dadoHex = x"9" ELSE                  ---9
						   "0001000" WHEN dadoHex = x"a" ELSE                  ---A
						   "1111111" WHEN dadoHex = x"c" ELSE                  --- 12 vazio
						   "0001100" WHEN dadoHex = x"f" ELSE                  --- 15 P
						   "1111111";                                          -- Apaga todos segmentos.

    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (habilita = '1') THEN
                saida7seg <= rascSaida7seg;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;