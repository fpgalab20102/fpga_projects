library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;
use work.alu_dut_lib.all; 

entity alu_dut is
generic (n : integer := 8);
port  ( alus    : in std_logic_vector(7 downto 1) ;
        dout    : out std_logic_vector(n-1 downto 0) );
end alu_dut ;

architecture arc of alu_dut is

signal ac, db : std_logic_vector(n-1 downto 0) ;
begin

ac  <= "01001001";
db  <= "10011001";

alu_i: alu port map(ac,db,alus,dout);

end arc;
