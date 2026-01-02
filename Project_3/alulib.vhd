LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE alulib IS

  COMPONENT adder1bit
PORT (a, b: IN STD_LOGIC;
cin: IN STD_LOGIC;
s: OUT STD_LOGIC;
cout: OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT adder8bit
GENERIC(NUM_BITS: natural :=8);
PORT (a, b: IN STD_LOGIC_VECTOR(NUM_BITS-1 DOWNTO 0);
      cin: IN STD_LOGIC;
      s: OUT STD_LOGIC_VECTOR(NUM_BITS-1 DOWNTO 0);
      cout: OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT mux2
PORT (input1, input2: IN STD_LOGIC ;
sel: IN STD_LOGIC ;
output: OUT STD_LOGIC ) ;
  END COMPONENT;

  COMPONENT mux4
PORT (input1, input2, input3, input4: IN STD_LOGIC ;
sel: IN STD_LOGIC_VECTOR(1 DOWNTO 0) ;
output: OUT STD_LOGIC ) ;
  END COMPONENT;

END PACKAGE alulib;