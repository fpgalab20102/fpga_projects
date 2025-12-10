LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY decdr3to8 IS

    PORT ( 
        Din  : in  STD_LOGIC_VECTOR (2 downto 0); 
        Dout : out STD_LOGIC_VECTOR (7 downto 0)  
    );
	
END decdr3to8;

ARCHITECTURE bhv of decdr3to8 IS
BEGIN

    WITH Din SELECT 
        Dout <= "00000001" WHEN "000", --Pinakas 1(states), ginetai antistoixhsh me tis times toy IR&00 gia to kalesma twn entolwn systhmatos
                "00000010" WHEN "001", 
                "00000100" WHEN "010", 
                "00001000" WHEN "011", 
                "00010000" WHEN "100", 
                "00100000" WHEN "101", 
                "01000000" WHEN "110", 
                "10000000" WHEN "111", 
                "00000000" WHEN OTHERS; 

END bhv;