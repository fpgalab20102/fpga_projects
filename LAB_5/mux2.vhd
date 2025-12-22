LIBRARY ieee ;
USE ieee.std_logic_1164.all ;

ENTITY mux2 IS
PORT (input1, input2: IN STD_LOGIC ;
sel: IN STD_LOGIC ;
output: OUT STD_LOGIC ) ;
END mux2 ;

ARCHITECTURE structural OF mux2 IS
BEGIN
output <= input1 WHEN sel = '0' ELSE
input2 WHEN sel = '1';
END structural ;