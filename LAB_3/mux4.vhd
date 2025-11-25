LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY mux4 IS
PORT (input1, input2, input3, input4: IN STD_LOGIC ;
sel: IN STD_LOGIC_VECTOR(1 DOWNTO 0) ;
output: OUT STD_LOGIC ) ;
END mux4 ;

ARCHITECTURE structural OF mux4 IS
BEGIN
PROCESS(input1, input2, input3, input4, sel)
BEGIN
CASE sel IS
WHEN "00" => output <= input1;
WHEN "01" => output <= input2;
WHEN "10" => output <= input3;
WHEN "11" => output <= input4;
WHEN others => output <='0';
END CASE;
END PROCESS;
END structural;
