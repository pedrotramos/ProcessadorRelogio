LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Unidade_Controle IS
    GENERIC (
        DATA_WIDTH : NATURAL := 8;
        ADDR_WIDTH : NATURAL := 8
    );
    PORT (
        -- Input ports
        clk    : IN std_logic;
        opCode : IN std_logic_vector(2 DOWNTO 0);
        -- Output ports
        palavraControle : OUT std_logic_vector(9 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch_name OF Unidade_Controle IS

	 -- aliases para a saida da unidade de controle, facilita definir cada 'habilita'
    ALIAS selMuxProxPC       : std_logic IS palavraControle(9);
    ALIAS selJe              : std_logic IS palavraControle(8);
    ALIAS selMuxIOImed       : std_logic IS palavraControle(7);
    ALIAS habEscritaBancoReg : std_logic IS palavraControle(6);
    ALIAS selOperacaoULA     : std_logic_vector(5 DOWNTO 3) IS palavraControle(5 DOWNTO 3);
    ALIAS habFlipFlop        : std_logic IS palavraControle(2);
    ALIAS load               : std_logic IS palavraControle(1);
    ALIAS store              : std_logic IS palavraControle(0);
    
	 
	 -- opCodes possiveis
    CONSTANT opCodeCmp     : std_logic_vector(2 DOWNTO 0) := "000";
    CONSTANT opCodeJmp     : std_logic_vector(2 DOWNTO 0) := "001";
    CONSTANT opCodeAdd     : std_logic_vector(2 DOWNTO 0) := "010";
    CONSTANT opCodeSub     : std_logic_vector(2 DOWNTO 0) := "011";
    CONSTANT opCodeGetIO   : std_logic_vector(2 DOWNTO 0) := "100";
    CONSTANT opCodeDisplay : std_logic_vector(2 DOWNTO 0) := "101";
    CONSTANT opCodeJe      : std_logic_vector(2 DOWNTO 0) := "110";
    CONSTANT opCodeMov     : std_logic_vector(2 DOWNTO 0) := "111";

	 SIGNAL instrucao       : std_logic_vector(7 DOWNTO 0);
	 
	 -- aliases para instrucao
    ALIAS cmp     : std_logic IS instrucao(0);
    ALIAS jmp     : std_logic IS instrucao(1);
    ALIAS add     : std_logic IS instrucao(2);
    ALIAS sub     : std_logic IS instrucao(3);
    ALIAS getIO   : std_logic IS instrucao(4);
    ALIAS display : std_logic IS instrucao(5);
    ALIAS je      : std_logic IS instrucao(6);
    ALIAS mov     : std_logic IS instrucao(7);

    --       selMuxProxPC selJe  selMuxIOImed  habEscritaBancoReg  selOperacaoULA  habFlipFlop  load  store
    -- cmp        0         0         1                0                 001            1         0    0
    -- jmp        1         0         0                0                 000            0         0    0
    -- add        0         0         1                1                 000            0         0    0
    -- sub        0         0         1                1                 001            0         0    0
    -- display    0         0         0                0                 000            0         0    1
    -- getIO      0         0         0                1                 010            0         1    0
    -- je         0         1         0                0                 000            0         0    0
    -- mov        0         0         1                1                 010            0         0    0
	 
	 -- deciframos o opCode que vem da ROM
	 -- e definimos os habilitas necessarios no processador baseado na tabela acima 

BEGIN
    WITH opCode SELECT
        instrucao <= "00000001" WHEN opCodeCmp,
        "00000010" WHEN opCodeJmp,
        "00000100" WHEN opCodeAdd,
        "00001000" WHEN opCodeSub,
        "00010000" WHEN opCodeGetIO,
        "00100000" WHEN opCodeDisplay,
        "01000000" WHEN opCodeJe,
        "10000000" WHEN opCodeMov,
        "00000000" WHEN OTHERS;

    WITH opCode SELECT
        selOperacaoULA <= "000" WHEN opCodeJmp,
        "000" WHEN opCodeDisplay,
        "000" WHEN opCodeAdd,
        "001" WHEN opCodeCmp,
        "001" WHEN opCodeSub,
        "010" WHEN opCodeGetIO,
        "010" WHEN opCodeMov,
        "000" WHEN OTHERS;

    selMuxProxPC       <= jmp;
    selJe              <= je;
    selMuxIOImed       <= cmp OR add OR sub OR mov;
    habEscritaBancoReg <= add OR sub OR getIO OR mov;
    habFlipFlop        <= cmp;
    load               <= getIO;
    store              <= display;

END ARCHITECTURE;