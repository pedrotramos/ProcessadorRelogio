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
    SW       : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END ENTITY;
ARCHITECTURE arch_name OF Relogio IS

  SIGNAL leituraSw, processador_decode : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
  SIGNAL saidaBaseTempo                : std_logic;

  SIGNAL write_hex   : std_logic_vector(3 DOWNTO 0); -- displays so aceitam 4 bits
  SIGNAL load, store : std_logic;

  SIGNAL habilitaDsp    : std_logic_vector(5 DOWNTO 0);
  SIGNAL habilitaSw     : std_logic_vector(7 DOWNTO 0);
  SIGNAL habilitaBtempo : std_logic;
  SIGNAL clearBtempo    : std_logic;
  SIGNAL habilitaKey    : std_logic_vector(3 DOWNTO 0);

BEGIN

  Processador : ENTITY work.processador
    PORT MAP(
      clk         => CLOCK_50,
      dataIn      => "00000000", -- Adicionar leitura dos botoes e base de tempo e switches
      dadoHex     => write_hex,
      load        => load,
      store       => store,
      outToDecode => processador_decode
    );

  Decodificador : ENTITY work.decodificador
    PORT MAP(
      dataIN         => processador_decode,
      store          => store,
      load           => load,
      habilitaDsp    => habilitaDsp,
      habilitaKey    => habilitaKey,
      habilitaSW     => habilitaSw,
      habilitaBtempo => habilitaBtempo,
      clearBtempo    => clearBtempo
    );

  -- tirar duvida como fazer uma chave por vez,
  --pois temos um habilita pra cada
  entradaChaves : ENTITY work.interfaceCHAVES
    PORT MAP(
      entrada  => SW(DATA_WIDTH - 1 DOWNTO 0),
      saida    => leituraSw,
      habilita => habilitaSw
    );

  interfaceBaseTempo : ENTITY work.divisorGenerico_e_Interface
    PORT MAP(
      clk              => CLOCK_50,
      habilitaLeitura  => habilitaBtempo,
      limpaLeitura     => clearBtempo,
      leituraUmSegundo => saidaBaseTempo -- precisa expandir pra 8 bits pra entrar no dataIN do processador
    );

  Displays : ENTITY work.interfaceDISPLAYS
    PORT MAP(
      dataIN => write_hex,
      enable => habilitaDsp,
      clk    => CLOCK_50
    );
END ARCHITECTURE;