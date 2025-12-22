library ieee ;
use ieee.std_logic_1164.all ;

entity alus IS
port(rbus,acload,zload,andop        : in std_logic;
          orop,notop,xorop,aczero        : in std_logic;
          acinc,plus,minus,drbus           : in std_logic;
          alus                                                : out std_logic_vector(6 downto 0));
end alus ;

architecture arc of alus is
signal control : std_logic_vector(11 downto 0);
begin
    control <= rbus & drbus & acload & zload & andop & orop
                    & notop & xorop & aczero & acinc & plus & minus ;
    process(control)
    begin
        case control is
            WHEN "101110000000" => alus <= "1000000" ; -- AND
            WHEN "101101000000" => alus <= "1100000" ; -- OR
            WHEN "001100100000" => alus <= "1110000" ; -- NOT
            WHEN "101100010000" => alus <= "1010000" ; -- XOR
            WHEN "001100001000" => alus <= "0000000" ; -- CLAC
            WHEN "001100000100" => alus <= "0001001" ; -- INAC
            WHEN "101100000010" => alus <= "0000101" ; -- ADD
            WHEN "101100000001" => alus <= "0001011" ; -- SUB
            WHEN "101100000000" => alus <= "0000100" ; -- MOVR
            WHEN "011100000000" => alus <= "0000100" ; -- LDAC5
            WHEN others => alus <= "1111111" ; -- NO OPERATION
        end case;
    end process;
end arc ;