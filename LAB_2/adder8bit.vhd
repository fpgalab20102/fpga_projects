LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY adder8bit IS
GENERIC(NUM_BITS: natural :=8);
PORT (a, b: IN STD_LOGIC_VECTOR(NUM_BITS-1 DOWNTO 0);
      cin: IN STD_LOGIC;
      s: OUT STD_LOGIC_VECTOR(NUM_BITS-1 DOWNTO 0);
      cout: OUT STD_LOGIC);
END adder8bit;
------------------------------------------------
ARCHITECTURE strl OF adder8bit IS
SIGNAL carry: STD_LOGIC_VECTOR(0 TO NUM_BITS);
BEGIN
carry(0)<=cin;
gen_adder: FOR i IN 0 TO NUM_BITS-1 GENERATE
adder: ENTITY work.adder1bit
PORT MAP (a(i),b(i),carry(i),s(i),carry(i+1));
END GENERATE;
cout<=carry(NUM_BITS);
END strl;