LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY decdr4to16 IS

    PORT ( 
        Din  : in  STD_LOGIC_VECTOR (3 downto 0); 
        Dout : out STD_LOGIC_VECTOR (15 downto 0)  
    );
	
END decdr4to16;

ARCHITECTURE bhv of decdr4to16 IS
BEGIN

    WITH Din SELECT
        Dout <= "0000000000000001" WHEN "0000", --Pinakas 1, klasikh syntaksh IR(opcode)x4(dhladh IR&00)
                "0000000000000010" WHEN "0001", 
                "0000000000000100" WHEN "0010", 
                "0000000000001000" WHEN "0011", 
                "0000000000010000" WHEN "0100", 
                "0000000000100000" WHEN "0101", 
                "0000000001000000" WHEN "0110", 
                "0000000010000000" WHEN "0111", 
                "0000000100000000" WHEN "1000", 
                "0000001000000000" WHEN "1001", 
                "0000010000000000" WHEN "1010", 
                "0000100000000000" WHEN "1011", 
                "0001000000000000" WHEN "1100", 
                "0010000000000000" WHEN "1101", 
                "0100000000000000" WHEN "1110", 
                "1000000000000000" WHEN "1111", 
                "0000000000000000" WHEN OTHERS;

END bhv;