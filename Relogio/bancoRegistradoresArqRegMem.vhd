LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY bancoRegistradoresArqRegMem IS
    GENERIC (
        larguraDados        : NATURAL := 8;
        larguraEndBancoRegs : NATURAL := 3 --Resulta em 2^3=8 posicoes
    );

    -- Leitura e escrita de um registrador.
    PORT (
        clk             : IN std_logic;
        endereco        : IN std_logic_vector((larguraEndBancoRegs - 1) DOWNTO 0);
        dadoEscrita     : IN std_logic_vector((larguraDados - 1) DOWNTO 0);
        habilitaEscrita : IN std_logic := '0';
        saida           : OUT std_logic_vector((larguraDados - 1) DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE comportamento OF bancoRegistradoresArqRegMem IS

    SUBTYPE palavra_t IS std_logic_vector((larguraDados - 1) DOWNTO 0);
    TYPE memoria_t IS ARRAY(2 ** larguraEndBancoRegs - 1 DOWNTO 0) OF palavra_t;

    -- Declaracao dos registradores:
    SHARED VARIABLE registrador : memoria_t;

BEGIN
    PROCESS (clk) IS
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (habilitaEscrita = '1') THEN
                registrador(to_integer(unsigned(endereco))) := dadoEscrita;
            END IF;
        END IF;
    END PROCESS;
    saida <= registrador(to_integer(unsigned(endereco)));
END ARCHITECTURE;