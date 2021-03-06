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
    store  : IN std_logic; 
    load   : IN std_logic; 
    -- Output ports
    habilitaDsp    : OUT std_logic_vector(5 DOWNTO 0);
    habilitaKey    : OUT std_logic_vector(3 DOWNTO 0);
    habilitaSW     : OUT std_logic_vector(7 DOWNTO 0);
    habilitaBtempo : OUT std_logic;
    clearBtempo    : OUT std_logic
  );
END ENTITY;
ARCHITECTURE arch_name OF decodificador IS

  -- Mapa de memoria
  -- sw: 1 endereco p/ cada       [x00 ~ x09]
  -- keys: 1 endereco p/ cada     [x0A ~ x0D]
  -- displays: 1 endereco p/ cada [x0E ~ x13]
  -- base tempo: 1 endereco       [x14]
  -- limpa base tempo: 1 endereco [x15]
  -- 

BEGIN
  habilitaSW(0) <= '1' WHEN (DataIN = x"00" AND load = '1') ELSE -- SW[0]: sem funcionalidade programavel, mas funciona pra selecionar a base de tempo usada
  '0';
  habilitaSW(1) <= '1' WHEN (DataIN = x"01" AND load = '1') ELSE -- SW[1]: seleciona AM/PM ou 24h
  '0';
  habilitaSW(2) <= '1' WHEN (DataIN = x"02" AND load = '1') ELSE -- SW[2]: ativa configuracao do relogio
  '0';
  habilitaSW(3) <= '1' WHEN (DataIN = x"03" AND load = '1') ELSE -- SW[3]: ativa configuracao do timer
  '0';
  habilitaSW(4) <= '1' WHEN (DataIN = x"04" AND load = '1') ELSE -- SW[4]: ativa timer
  '0';
  habilitaSW(5) <= '1' WHEN (DataIN = x"05" AND load = '1') ELSE -- SW[5]: sem funcionalidade
  '0';
  habilitaSW(6) <= '1' WHEN (DataIN = x"06" AND load = '1') ELSE -- SW[6]: sem funcionalidade
  '0';
  habilitaSW(7) <= '1' WHEN (DataIN = x"07" AND load = '1') ELSE -- SW[7]: sem funcionalidade
  '0';
  
  -- ==============================================================
  -- Nao usadas nem inicializadas no qsf
  -- habilitaSW(8) <= '1' WHEN (DataIN = x"08" AND load = '1') ELSE 
  -- '0';
  -- habilitaSW(9) <= '1' WHEN (DataIN = x"09" AND load = '1') ELSE
  -- '0';
  -- ==============================================================
  
  -- Btns usados tanto na configuracao relogio quanto timer
  habilitaKey(0) <= '1' WHEN (DataIN = x"0A" AND load = '1') ELSE -- Botao incrementa unidade minuto 
  '0';
  habilitaKey(1) <= '1' WHEN (DataIN = x"0B" AND load = '1') ELSE -- Botao incrementa dezena minuto
  '0';
  habilitaKey(2) <= '1' WHEN (DataIN = x"0C" AND load = '1') ELSE -- Botao incrementa hora (tanto dezena quanto unidade)
  '0';
  habilitaKey(3) <= '1' WHEN (DataIN = x"0D" AND load = '1') ELSE -- sem funcionalidade relogio, zera timer
  '0';

  habilitaDsp(0) <= '1' WHEN (DataIN = x"0E" AND store = '1') ELSE -- Display unidade segundo 
  '0';
  habilitaDsp(1) <= '1' WHEN (DataIN = x"0F" AND store = '1') ELSE -- Display dezena segundo
  '0';
  habilitaDsp(2) <= '1' WHEN (DataIN = x"10" AND store = '1') ELSE -- Display unidade minuto
  '0';
  habilitaDsp(3) <= '1' WHEN (DataIN = x"11" AND store = '1') ELSE -- Display dezena minuto
  '0';
  habilitaDsp(4) <= '1' WHEN (DataIN = x"12" AND store = '1') ELSE -- Display unidade hora
  '0';
  habilitaDsp(5) <= '1' WHEN (DataIN = x"13" AND store = '1') ELSE -- Display dezena hora
  '0';

  habilitaBtempo <= '1' WHEN (DataIN = x"14" AND load = '1') ELSE -- Habilita Base de tempo
    '0';

  clearBtempo <= '1' WHEN (DataIN = x"15" AND load = '1') ELSE -- Limpa base de tempo -> getio  
    '0';

END ARCHITECTURE;