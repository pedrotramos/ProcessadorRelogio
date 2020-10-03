LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fluxoDados IS
    GENERIC (
        VALUE_WIDTH    : NATURAL := 8;
        ROM_ADDR_WIDTH : NATURAL := 10;
        REG_ADDR_WIDTH : NATURAL := 4;
        ROM_DATA_WIDTH : NATURAL := 17;
        OPCODE_WIDTH   : NATURAL := 3
    );
    PORT (
        -- Input ports
        clk             : IN std_logic;
        dataIN          : IN std_logic_vector(VALUE_WIDTH - 1 DOWNTO 0);
        palavraControle : IN std_logic_vector(7 DOWNTO 0);
        -- Output ports
        opCode   : OUT std_logic_vector(OPCODE_WIDTH - 1 DOWNTO 0);
        toDecode : OUT std_logic_vector(VALUE_WIDTH - 1 DOWNTO 0);
        dataOUT  : OUT std_logic_vector(VALUE_WIDTH - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch_name OF fluxoDados IS
    SIGNAL PC_ROM                 : std_logic_vector(ROM_ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL SomaUm_MuxProxPC       : std_logic_vector(ROM_ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL MuxProxPC_PC           : std_logic_vector(ROM_ADDR_WIDTH - 1 DOWNTO 0);
    SIGNAL selMuxProxPC_FlagEqual : std_logic;
    SIGNAL flagEqual              : std_logic;
    SIGNAL saidaFlopFlop          : std_logic;
    SIGNAL Instrucao              : std_logic_vector(ROM_DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL muxIOImed_ULA          : std_logic_vector(VALUE_WIDTH - 1 DOWNTO 0);
    SIGNAL saidaBancoReg          : std_logic_vector(VALUE_WIDTH - 1 DOWNTO 0);
    SIGNAL saidaULA_bancoReg      : std_logic_vector(VALUE_WIDTH - 1 DOWNTO 0);

    ALIAS opCodeLocal  : std_logic_vector(OPCODE_WIDTH - 1 DOWNTO 0) IS Instrucao(16 DOWNTO 14);
    ALIAS enderecoREG  : std_logic_vector(REG_ADDR_WIDTH - 1 DOWNTO 0) IS Instrucao(13 DOWNTO 10);
    ALIAS enderecoJUMP : std_logic_vector(ROM_ADDR_WIDTH - 1 DOWNTO 0) IS Instrucao(9 DOWNTO 0);
    ALIAS imediato     : std_logic_vector(VALUE_WIDTH - 1 DOWNTO 0) IS Instrucao(7 DOWNTO 0);

    ALIAS selMuxProxPC       : std_logic IS palavraControle(7);
    ALIAS selJe              : std_logic IS palavraControle(6);
    ALIAS selMuxIOImed       : std_logic IS palavraControle(5);
    ALIAS habEscritaBancoReg : std_logic IS palavraControle(4);
    ALIAS selOperacaoULA     : std_logic_vector(3 DOWNTO 1) IS palavraControle(3 DOWNTO 1);
    ALIAS habFlipFlop        : std_logic IS palavraControle(0);

    CONSTANT INCREMENTO : NATURAL := 1;
BEGIN
    PC : ENTITY work.registradorGenerico
        GENERIC MAP(
            larguraDados => ROM_ADDR_WIDTH
        )
        PORT MAP(
            DIN    => MuxProxPC_PC,
            DOUT   => PC_ROM,
            ENABLE => '1',
            CLK    => clk,
            RST    => '0'
        );

    MuxProxPC : ENTITY work.muxGenerico2x1
        GENERIC MAP(
            larguraDados => ROM_ADDR_WIDTH
        )
        PORT MAP(
            entradaA_MUX => SomaUm_MuxProxPC,
            entradaB_MUX => enderecoJUMP,
            seletor_MUX  => selMuxProxPC_FlagEqual,
            saida_MUX    => MuxProxPC_PC
        );

    selMuxProxPC_FlagEqual <= selMuxProxPC OR (selJe AND saidaFlopFlop);

    somaUm : ENTITY work.somaConstante
        GENERIC MAP(
            larguraDados => ROM_ADDR_WIDTH,
            constante    => INCREMENTO
        )
        PORT MAP(
            entrada => PC_ROM,
            saida   => SomaUm_MuxProxPC
        );

    ROM : ENTITY work.memoriaROM
        GENERIC MAP(
            dataWidth => ROM_DATA_WIDTH,
            addrWidth => ROM_ADDR_WIDTH
        )
        PORT MAP(
            Endereco => PC_ROM,
            Dado     => Instrucao
        );

    muxIO_Imediato : ENTITY work.muxGenerico2x1
        GENERIC MAP(
            larguraDados => VALUE_WIDTH
        )
        PORT MAP(
            entradaA_MUX => dataIN,
            entradaB_MUX => imediato,
            seletor_MUX  => selMuxIOImed,
            saida_MUX    => muxIOImed_ULA
        );

    ULA : ENTITY work.ULA
        GENERIC MAP(
            larguraDados => VALUE_WIDTH
        )
        PORT MAP(
            entradaA  => muxIOImed_ULA,
            entradaB  => saidaBancoReg,
            saida     => saidaULA_bancoReg,
            seletor   => selOperacaoULA,
            flagEqual => flagEqual
        );

    guardaFlagEq : ENTITY work.flipFlop
        PORT MAP(
            DIN    => flagEqual,
            DOUT   => saidaFlopFlop,
            ENABLE => habFlipFlop,
            CLK    => clk,
            RST    => '0'
        );

    BancoRegistradores : ENTITY work.bancoRegistradoresArqRegMem
        GENERIC MAP(larguraDados => VALUE_WIDTH, larguraEndBancoRegs => 4)
        PORT MAP(
            clk             => clk,
            endereco        => enderecoREG,
            dadoEscrita     => saidaULA_bancoReg,
            habilitaEscrita => habEscritaBancoReg,
            saida           => saidaBancoReg);

    opCode   <= opCodeLocal;
    dataOUT  <= saidaBancoReg;
    toDecode <= imediato;
END ARCHITECTURE;