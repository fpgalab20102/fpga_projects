LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_signed.all ;
ENTITY adderk IS
 GENERIC ( k : INTEGER := 8 ) ;
 PORT ( carryin : IN STD_LOGIC ;
 X, Y : IN STD_LOGIC_VECTOR(k-1 DOWNTO 0) ;
 S : OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0) ;
 carryout : OUT STD_LOGIC ) ;
END adderk ;
ARCHITECTURE Behavior OF adderk IS
 SIGNAL Sum : STD_LOGIC_VECTOR(k DOWNTO 0) ;
BEGIN
 Sum <= ('0'& X) + ('0'& Y) + carryin ;
 S <= Sum(k-1 DOWNTO 0) ;
 carryout <= Sum(k) ;
END Behavior ;