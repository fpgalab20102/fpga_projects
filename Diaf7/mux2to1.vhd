LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
ENTITY mux2to1 IS
 GENERIC ( k : INTEGER := 8 ) ;
 PORT ( V, W : IN STD_LOGIC_VECTOR(k-1 DOWNTO 0) ;
 Selm : IN STD_LOGIC ;
 F : OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0) ) ;
END mux2to1 ;
ARCHITECTURE Behavior OF mux2to1 IS
BEGIN
 PROCESS ( V, W, Selm )
 BEGIN
 IF Selm = '0' THEN
 F <= V ;
 ELSE
 F <= W ;
 END IF ;
 END PROCESS ;
END Behavior ;