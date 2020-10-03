LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY interfaceDISPLAYS IS
  GENERIC (
    DATA_WIDTH : NATURAL := 4
  );

  PORT (
    dataIN                             : IN std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
    enable                             : IN std_logic_vector(5 DOWNTO 0);
    clk                                : IN std_logic;
    HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
  );
END ENTITY;
ARCHITECTURE arch_name OF interfaceDISPLAYS IS
BEGIN
  -- Inicializacao display unidade segundos OU A/P (caso am/pm)
  DISPLAY0 : ENTITY work.conversorHex7Seg
    PORT MAP
    (
      clk       => clk,
      dadoHex   => dataIN,
      habilita  => enable(0),
      saida7seg => HEX0
    );

  -- Inicializacao display dezena segundos OU vazio (caso am/pm)
  DISPLAY1 : ENTITY work.conversorHex7Seg
    PORT MAP
    (
      clk       => clk,
      dadoHex   => dataIN,
      habilita  => enable(1),
      saida7seg => HEX1
    );
  -- Inicializacao display unidade minuto
  DISPLAY2 : ENTITY work.conversorHex7Seg
    PORT MAP
    (
      clk       => clk,
      dadoHex   => dataIN,
      habilita  => enable(2),
      saida7seg => HEX2
    );
  -- Inicializacao display dezena minuto
  DISPLAY3 : ENTITY work.conversorHex7Seg
    PORT MAP
    (
      clk       => clk,
      dadoHex   => dataIN,
      habilita  => enable(3),
      saida7seg => HEX3
    );
  -- Inicializacao display unidade hora
  DISPLAY4 : ENTITY work.conversorHex7Seg
    PORT MAP
    (
      clk       => clk,
      dadoHex   => dataIN,
      habilita  => enable(4),
      saida7seg => HEX4
    );
  -- Inicializacao display dezena hora
  DISPLAY5 : ENTITY work.conversorHex7Seg
    PORT MAP
    (
      clk       => clk,
      dadoHex   => dataIN,
      habilita  => enable(5),
      saida7seg => HEX5
    );
END ARCHITECTURE;