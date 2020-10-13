library IEEE;
use ieee.std_logic_1164.all;

entity mux1bit is	

   port
    (
       A : in std_logic;
		 B : in std_logic;		 
		 s : in std_logic;
		 o : out std_logic
    );
end entity;

architecture Arc of mux1bit is

begin
  
	
	o <= B when s = '1' else
		  A;
	 
end architecture;