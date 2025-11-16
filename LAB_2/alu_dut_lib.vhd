library ieee ;
use ieee.std_logic_1164.all ;

package alu_dut_lib is 

component alu is
generic (n : integer := 8);
port  ( ac      : in std_logic_vector(n-1 downto 0) ;
        db      : in std_logic_vector(n-1 downto 0) ;
        alus    : in std_logic_vector(7 downto 1) ;
        dout    : out std_logic_vector(n-1 downto 0) );
end component ;

end package alu_dut_lib;

