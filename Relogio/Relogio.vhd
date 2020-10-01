LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Relogio IS
  GENERIC (
    DATA_WIDTH : NATURAL := 8;
    ADDR_WIDTH : NATURAL := 8
  );

  PORT (
    -- Input ports
    CLOCK_50 : IN std_logic;
    SW       : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	 HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT STD_LOGIC_VECTOR(6 downto 0)
  );
END ENTITY;
ARCHITECTURE arch_name OF Relogio IS

  SIGNAL barramentoLeituraDados, process_decode : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);

  SIGNAL write_hex   : std_logic_vector(3 DOWNTO 0); -- displays só aceitam 4 bits
  SIGNAL load, store : std_logic;

  SIGNAL habilitaDsp : std_logic_vector(5 DOWNTO 0);
  SIGNAL habilitaSw  : std_logic;
  SIGNAL habilitaKey : std_logic_vector(3 DOWNTO 0);

BEGIN

  Processador : ENTITY work.processador
    PORT MAP(
      clk         => CLOCK_50,
      dataIn      => barramentoLeituraDados, -- Adicionar leitura dos botoes e base de tempo??
      dadoHex     => write_hex,
      load        => load,
      store       => store,
      outToDecode => process_decode
    );

  Decodificador : ENTITY work.decodificador
    PORT MAP(
      dataIN      => process_decode,
      store       => store,
      load        => load,
      habilitaDsp => habilitaDsp,
      habilitaKey => habilitaKey,
      habilitaSW  => habilitaSw
    );

  entradaChaves : ENTITY work.interfaceCHAVES
    PORT MAP(
      entrada  => SW(DATA_WIDTH - 1 DOWNTO 0),
      saida    => barramentoLeituraDados,
      habilita => habilitaSw
    );

  -- Inicializacao display unidade segundos OU A/P (caso am/pm)
  DISPLAY0 : ENTITY work.conversorHex7Seg
    PORT MAP
    (
      clk       => CLOCK_50,
      dadoHex   => write_hex,
      habilita  => habilitaDsp(0),
      saida7seg => HEX0
    );

  -- Inicializacao display dezena segundos OU vazio (caso am/pm)
  DISPLAY1 : ENTITY work.conversorHex7Seg
    PORT MAP
    (
      clk       => CLOCK_50,
      dadoHex   => write_hex,
      habilita  => habilitaDsp(1),
      saida7seg => HEX1
    );
  -- Inicializacao display unidade minuto
  DISPLAY2 : ENTITY work.conversorHex7Seg
    PORT MAP
    (
      clk       => CLOCK_50,
      dadoHex   => write_hex,
      habilita  => habilitaDsp(2),
      saida7seg => HEX2
    );
  -- Inicializacao display dezena minuto
  DISPLAY3 : ENTITY work.conversorHex7Seg
    PORT MAP
    (
      clk       => CLOCK_50,
      dadoHex   => write_hex,
      habilita  => habilitaDsp(3),
      saida7seg => HEX3
    );
  -- Inicializacao display unidade hora
  DISPLAY4 : ENTITY work.conversorHex7Seg
    PORT MAP
    (
      clk       => CLOCK_50,
      dadoHex   => write_hex,
      habilita  => habilitaDsp(4),
      saida7seg => HEX4
    );
  -- Inicializacao display dezena hora
  DISPLAY5 : ENTITY work.conversorHex7Seg
    PORT MAP
    (
      clk       => CLOCK_50,
      dadoHex   => write_hex,
      habilita  => habilitaDsp(5),
      saida7seg => HEX5
    );

END ARCHITECTURE;