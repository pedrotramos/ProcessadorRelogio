LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY decodificador IS
  GENERIC (
    DATA_WIDTH : NATURAL := 8;
    ADDR_WIDTH : NATURAL := 8
  );

  PORT (
    -- Input ports
    dataIN : IN std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
    store  : IN std_logic; --PRA QUE
    load   : IN std_logic; --PRA QUE
    -- Output ports
    habilitaDsp : OUT std_logic_vector(5 DOWNTO 0);
    habilitaKey : OUT std_logic_vector(3 DOWNTO 0);
    habilitaSW  : OUT std_logic
    -- habilitaBt  : OUT std_logic_vector(1 DOWNTO 0);
  );
END ENTITY;
ARCHITECTURE arch_name OF decodificador IS

BEGIN
  habilitaDsp(0) <= ('1' AND store) WHEN DataIN = x"0E" ELSE -- Display unidade segundo
  '0';
  habilitaDsp(1) <= ('1' AND store) WHEN DataIN = x"0F" ELSE -- Display dezena segundo
  '0';
  habilitaDsp(2) <= ('1' AND store) WHEN DataIN = x"10" ELSE -- Display unidade minuto
  '0';
  habilitaDsp(3) <= ('1' AND store) WHEN DataIN = x"11" ELSE -- Display dezena minuto
  '0';
  habilitaDsp(4) <= ('1' AND store) WHEN DataIN = x"12" ELSE -- Display unidade hora
  '0';
  habilitaDsp(5) <= ('1' AND store) WHEN DataIN = x"13" ELSE -- Display dezena hora
  '0';

  habilitaKey(0) <= ('1' AND load) WHEN DataIN = x"0A" ELSE -- Botao incrementa unidade minuto
  '0';
  habilitaKey(1) <= ('1' AND load) WHEN DataIN = x"0B" ELSE -- Botao incrementa dezena minuto
  '0';
  habilitaKey(2) <= ('1' AND load) WHEN DataIN = x"0C" ELSE -- Botao incrementa unidade hora
  '0';
  habilitaKey(3) <= ('1' AND load) WHEN DataIN = x"0D" ELSE -- Botao incrementa dezena hora
  '0';

  habilitaSW <= ('1' AND load) WHEN DataIN = x"00" ELSE
    '0';

END ARCHITECTURE;