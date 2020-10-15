LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY divisorGenerico_e_Interface IS
   PORT (
      clk              : IN std_logic;
      habilitaLeitura  : IN std_logic;
      limpaLeitura     : IN std_logic;
		selBaseTempo     : IN std_logic;
      leituraUmSegundo : OUT std_logic_vector(7 DOWNTO 0)
   );
END ENTITY;

ARCHITECTURE interface OF divisorGenerico_e_Interface IS
   SIGNAL sinalUmSegundo     : std_logic;
   SIGNAL saidaclk_reg1seg   : std_logic;
	SIGNAL saidaclk_regRapida : std_logic;
	SIGNAL clk_usado          : std_logic;
BEGIN

   baseTempo1Seg : ENTITY work.divisorGenerico
      GENERIC MAP(divisor => 25000000) -- 1s
      PORT MAP(
         clk       => clk,
         saida_clk => saidaclk_reg1seg
      );
		
	baseTempoRapida : ENTITY work.divisorGenerico
		GENERIC MAP(divisor => 25000) -- mais rapida
		PORT MAP(
			clk       => clk,
			saida_clk => saidaclk_regRapida
		);
		
		
	-- possibilita a escolha de qual base de tempo sera usada
	muxBaseTempo : ENTITY work.mux1bit
	  PORT MAP(
			A => saidaclk_reg1seg,
			B => saidaclk_regRapida,
			s => selBaseTempo,
			o => clk_usado
	  );
	  
	  
	-- guarda valor de saida do mux acima, para ser lido e enviado ao processador
   registra1Segundo : ENTITY work.flipFlop
      PORT MAP(
         DIN    => '1',
         DOUT   => sinalUmSegundo,
         ENABLE => '1',
         CLK    => clk_usado,
         RST    => limpaLeitura
      );
   -- Faz o tristate de saida:
   leituraUmSegundo <= "0000000" & sinalUmSegundo WHEN habilitaLeitura = '1' ELSE
      (OTHERS => 'Z');
END ARCHITECTURE interface;