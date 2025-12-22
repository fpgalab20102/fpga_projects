library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all ; 

entity regnbit is
generic (n: integer :=8);
port( din				: in std_logic_vector(n-1 downto 0);
	  clk,rst,ld		: in std_logic;
	  inc			    : in std_logic;
	  dout				: out std_logic_vector(n-1 downto 0));
end regnbit;

architecture  arc  of regnbit is
signal temp : std_logic_vector(n-1 downto 0);		
begin
	process(clk,rst)
	begin
		if  rst='1' then -- changed to use push button
temp<=(others=>'0');
		elsIf rising_edge(clk) then
   			if ld='1' then
				temp<=din;
			elsif inc='1' then 
				temp<=temp+1;	
end if;
 		end if;
	end process;
dout<=temp;
end ;
