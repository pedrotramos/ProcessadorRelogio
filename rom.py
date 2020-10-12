def write_tmp(i, line):
    s = f'tmp({i}):= b"{line}";\n'
    return s


def main():
    lines = []
    with open("instructions.txt", "r") as f:
        lines = f.read().splitlines()

    with open("Relogio/memoriaROM.vhd", "w") as f:
        f.write(
            """
        LIBRARY IEEE;
        USE IEEE.std_logic_1164.ALL;
        USE ieee.numeric_std.ALL;

        ENTITY memoriaROM IS
            GENERIC (
                dataWidth : NATURAL := 17;
                addrWidth : NATURAL := 10
            );
            PORT (
                Endereco : IN std_logic_vector (addrWidth - 1 DOWNTO 0);
                Dado     : OUT std_logic_vector (dataWidth - 1 DOWNTO 0)
            );
        END ENTITY;

        ARCHITECTURE assincrona OF memoriaROM IS

            TYPE blocoMemoria IS ARRAY(0 TO 2 ** addrWidth - 1) OF std_logic_vector(dataWidth - 1 DOWNTO 0);

            FUNCTION initMemory
                RETURN blocoMemoria IS VARIABLE tmp : blocoMemoria := (OTHERS => (OTHERS => '0'));
            BEGIN
        """
        )

        for i in range(len(lines)):
            print(lines[i])
            f.write(write_tmp(i, lines[i]))

        f.write(
            """
            RETURN tmp;
        END initMemory;

        SIGNAL memROM : blocoMemoria := initMemory;

        BEGIN
            Dado <= memROM (to_integer(unsigned(Endereco)));
        END ARCHITECTURE;
        """
        )


main()