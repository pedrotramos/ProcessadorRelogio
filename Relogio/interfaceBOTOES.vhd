LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY interfaceBOTOES IS
  GENERIC (
    dataWidth : NATURAL := 4
  );
  PORT (
    entrada  : IN std_logic_vector(dataWidth - 1 DOWNTO 0);
    habilita : IN std_logic_vector(dataWidth - 1 DOWNTO 0);
    saida    : OUT std_logic_vector(7 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE comportamento OF interfaceBOTOES IS
BEGIN
  saida <= "0000000" & entrada(0) WHEN habilita(0) = '1' ELSE
    "0000000" & entrada(1) WHEN habilita(1) = '1' ELSE
    "0000000" & entrada(2) WHEN habilita(2) = '1' ELSE
    "0000000" & entrada(3) WHEN habilita(3) = '1' ELSE
    (OTHERS => 'Z');
END ARCHITECTURE;