LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY adder1bit IS
PORT (a, b: IN STD_LOGIC;
cin: IN STD_LOGIC;
s: OUT STD_LOGIC;
cout: OUT STD_LOGIC);
END adder1bit;
------------------------------------------------
ARCHITECTURE adder_rtl OF adder1bit IS
SIGNAL xor_out, and1_out, and2_out : STD_LOGIC; -- δήλωση των εσωτερικών σημάτων
BEGIN
xor_out <= a XOR b; -- Περιγραφή του εσωτερικού σήματος xor_out
and1_out <= a AND b; -- Περιγραφή του εσωτερικού σήματος and1_out
and2_out <= cin AND xor_out; -- Περιγραφή του εσωτερικού σήματος and2_out
s <= xor_out XOR cin; -- Περιγραφή της εξόδου του αθροίσματος S
cout <= and1_out OR and2_out; -- Περιγραφή του κρατούμενου εξόδου Co
END adder_rtl;