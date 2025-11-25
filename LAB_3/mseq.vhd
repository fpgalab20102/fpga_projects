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
        mOPs    : out std_logic_vector(26 downto 0)
    );
end mseq;

architecture arc of mseq is

    signal micro_addr : std_logic_vector(5 downto 0);   -- διεύθυνση microinstruction
    signal rom_out    : std_logic_vector(35 downto 0);  -- microinstruction (36 bits)
    signal next_addr  : std_logic_vector(5 downto 0);   -- επόμενη διεύθυνση
    signal inc_addr   : std_logic_vector(5 downto 0);   -- έξοδος incrementer
    signal cond_out   : std_logic;                      -- έξοδος από COND logic
    signal sel        : std_logic_vector(2 downto 0);   -- πεδίο SEL (3 bits)
    signal addr_field : std_logic_vector(5 downto 0);   -- πεδίο ADDR (6 bits)

begin

    rom_seg : mseq_rom
        port map(
            address => micro_addr,
            clock   => clock,
            q       => rom_out
        );

    code <= rom_out;                 -- ολόκληρη μικροεντολή
    mOPs <= rom_out(26 downto 0);    -- 27-bit πεδίο μικροδιεργασιών

    
    addr_field <= rom_out(35 downto 30);  -- πάνω 6 bits
    sel        <= rom_out(29 downto 27);  -- τα 3 bits SEL

    cond_seg : mux4
        port map(
            input1 => '0',
            input2 => '1',
            input3 => z,
            input4 => not z,
            sel    => ir(1 downto 0),
            output => cond_out
        );

    inc_seg : adder8bit
        generic map(NUM_BITS => 6)
        port map(
            a    => micro_addr,
            b    => "000001",
            cin  => '0',
            s    => inc_addr,
            cout => open
        );

    process(sel, cond_out, addr_field, inc_addr)
    begin
        case sel is

            when "000" =>    -- +1
                next_addr <= inc_addr;

            when "001" =>    -- άμεσο jump
                next_addr <= addr_field;

            when "010" =>    -- conditional jump
                if cond_out = '1' then
                    next_addr <= addr_field;
                else
                    next_addr <= inc_addr;
                end if;

            when "011" =>    -- reset/ή ειδικό
                next_addr <= (others => '0');

            when others =>   -- reserved
                next_addr <= (others => '0');

        end case;
    end process;

    regn_seg : regnbit
        generic map(n => 6)
        port map(
            din  => next_addr,
            clk  => clock,
            rst  => reset,
            ld   => '1',      -- μικροδιεύθυνση φορτώνεται κάθε κύκλο
            inc  => '0',      -- δεν χρησιμοποιούμε inc εδώ
            dout => micro_addr
        );

end arc;