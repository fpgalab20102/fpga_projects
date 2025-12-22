LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE mseqlib IS

  COMPONENT regnbit
generic (n: integer :=8);
port( din				: in std_logic_vector(n-1 downto 0);
	  clk,rst,ld		: in std_logic;
	  inc			    : in std_logic;
	  dout				: out std_logic_vector(n-1 downto 0));
END COMPONENT;

  COMPONENT adder8bit
GENERIC(NUM_BITS: natural :=8);
PORT (a, b: IN STD_LOGIC_VECTOR(NUM_BITS-1 DOWNTO 0);
      cin: IN STD_LOGIC;
      s: OUT STD_LOGIC_VECTOR(NUM_BITS-1 DOWNTO 0);
      cout: OUT STD_LOGIC);
  END COMPONENT;

 COMPONENT adder1bit 
PORT (a, b: IN STD_LOGIC;
     cin: IN STD_LOGIC;
     s: OUT STD_LOGIC;
     cout: OUT STD_LOGIC);
  END COMPONENT;

  COMPONENT mux4
PORT (input1, input2, input3, input4: IN STD_LOGIC ;
sel: IN STD_LOGIC_VECTOR(1 DOWNTO 0) ;
output: OUT STD_LOGIC ) ;
  END COMPONENT;
  
  COMPONENT mseq_rom
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (35 DOWNTO 0)
	);
END COMPONENT;

END PACKAGE mseqlib;