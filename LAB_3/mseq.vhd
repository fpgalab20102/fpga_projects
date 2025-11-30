library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.mseqlib.all;

entity mseq is
    port(
        ir      : in  std_logic_vector(3 downto 0);
        clock   : in  std_logic;
        reset   : in  std_logic;
        z       : in  std_logic;
        code    : out std_logic_vector(35 downto 0);
		  debug_reg : out std_logic_vector(5 downto 0);
        mOPs    : out std_logic_vector(26 downto 0)
		  
    );
end mseq;

architecture arc of mseq is

    signal register_out : std_logic_vector(5 downto 0); 
    signal rom_out      : std_logic_vector(35 downto 0);
    signal mux3to1_out  : std_logic_vector(5 downto 0); 
    signal incrm_out    : std_logic_vector(5 downto 0); 
    signal branch_addr  : std_logic_vector(5 downto 0);
    signal map_addr     : std_logic_vector(5 downto 0);
    signal sel          : std_logic_vector(2 downto 0); 
    signal cond_select  : std_logic_vector(1 downto 0); 
    signal mux4_out     : std_logic;                    

begin

    code <= rom_out;
    mOPs <= rom_out(32 downto 6);
    branch_addr <= rom_out(5 downto 0);
	 debug_reg <= register_out;
    sel <= rom_out(35 downto 33);
    cond_select <= rom_out(35 downto 34);
    incrm_out <= register_out + 1; -- Input 0
    map_addr  <= ir & "00";        -- Input 2

    ROM : mseq_rom
        port map(
            address => register_out,
            clock   => clock,
            q       => rom_out
        );

    MUX4TO1 : mux4
        port map(
            input1 => '1',
            input2 => z,
            input3 => not z,
            input4 => '0',
            sel    => cond_select, 
            output => mux4_out
        );

   
    process(sel, mux4_out, branch_addr, incrm_out, map_addr)
    begin
        
        case sel is
            
            when "000" =>                 
                mux3to1_out <= incrm_out;

            when "001" =>                 
                mux3to1_out <= map_addr;

            when "110" =>                 
                mux3to1_out <= branch_addr;

            when "010" =>
                if mux4_out = '1' then
                    mux3to1_out <= branch_addr;
                else
                    mux3to1_out <= incrm_out;
                end if;
            
            
            when "100" =>
                if mux4_out = '1' then
                    mux3to1_out <= branch_addr;
                else
                    mux3to1_out <= incrm_out;
                end if;

            when others =>
                mux3to1_out <= (others => '0');

        end case;
    end process;

    
    REGISTER_PART : regnbit
        generic map(n => 6)
        port map(
            din  => mux3to1_out,
            clk  => clock,
            rst  => reset,
            ld   => '1',
            inc  => '0',
            dout => register_out
        );

end arc;
