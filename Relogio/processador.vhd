LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY processador IS
    GENERIC (
        DATA_WIDTH : NATURAL := 8;
        ADDR_WIDTH : NATURAL := 12
    );
    PORT (
        -- Input ports
        clk    : IN std_logic;
        dataIn : IN std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
        -- Output ports
        dadoDsp     : OUT std_logic_vector(3 DOWNTO 0);
        load        : OUT std_logic;
        store       : OUT std_logic;
        outToDecode : OUT std_logic_vector(DATA_WIDTH - 1 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE arch_name OF processador IS
    SIGNAL toDecode        : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL saidaBancoReg   : std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
    SIGNAL palavraControle : std_logic_vector(9 DOWNTO 0);
    SIGNAL opCode          : std_logic_vector(2 DOWNTO 0);
BEGIN
    FD : ENTITY work.fluxoDados
        PORT MAP(
            clk             => clk,
            dataIN          => dataIN,
            palavraControle => palavraControle(9 DOWNTO 2), -- nao precisamos passar o habilita leitura e escrita do decodificador
            opCode          => opCode,
            toDecode        => toDecode,
            dataOUT         => saidaBancoReg
        );

    UC : ENTITY work.Unidade_Controle
        PORT MAP(
            palavraControle => palavraControle,
            opCode          => opCode,
            clk             => clk
        );

    load        <= palavraControle(1);
    store       <= palavraControle(0);
    dadoDsp     <= saidaBancoReg(3 DOWNTO 0);
    outToDecode <= toDecode;
END ARCHITECTURE;