LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY divisorGenerico_e_Interface IS
   PORT (
      clk              : IN std_logic;
      habilitaLeitura  : IN std_logic;
      limpaLeitura     : IN std_logic;
      leituraUmSegundo : OUT std_logic_vector(7 DOWNTO 0)
   );
END ENTITY;

ARCHITECTURE interface OF divisorGenerico_e_Interface IS
   SIGNAL sinalUmSegundo   : std_logic;
   SIGNAL saidaclk_reg1seg : std_logic;
BEGIN

   baseTempo : ENTITY work.divisorGenerico
      GENERIC MAP(divisor => 25000000) -- divide por 10.
      PORT MAP(
         clk       => clk,
         saida_clk => saidaclk_reg1seg
      );

   registra1Segundo : ENTITY work.flipFlop
      PORT MAP(
         DIN    => '1',
         DOUT   => sinalUmSegundo,
         ENABLE => '1',
         CLK    => saidaclk_reg1seg,
         RST    => limpaLeitura
      );
   -- Faz o tristate de saida:
   leituraUmSegundo <= "0000000" & sinalUmSegundo WHEN habilitaLeitura = '1' ELSE
      (OTHERS => 'Z');
END ARCHITECTURE interface;