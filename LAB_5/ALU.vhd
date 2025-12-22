library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.alulib.all;

entity alu is
	generic (n : integer := 8);
	port  (
		ac      : in std_logic_vector(n-1 downto 0);
		db      : in std_logic_vector(n-1 downto 0);
		alus    : in std_logic_vector(7 downto 1);
		dout    : out std_logic_vector(n-1 downto 0);
                z_out   : out std_logic
	);
end alu;

architecture arch of alu is

    signal mux2_out   : std_logic_vector(n-1 downto 0);
    signal mux3_out   : std_logic_vector(n-1 downto 0);
    signal arith_out  : std_logic_vector(n-1 downto 0);
    signal and_out    : std_logic_vector(n-1 downto 0);
    signal or_out     : std_logic_vector(n-1 downto 0);
    signal xor_out    : std_logic_vector(n-1 downto 0);
    signal not_out    : std_logic_vector(n-1 downto 0);
    signal logic_out  : std_logic_vector(n-1 downto 0);
    signal carry      : std_logic;

begin

    --ARITHMETIC UNIT
    -- mux2: επιλέγει 0 ή ac με βάση alus1
    
    mux2_gen : for i in 0 to n-1 generate
        m2: entity work.mux2
        port map(
            input1 => '0',          -- 0
            input2 => ac(i),        -- AC
            sel    => alus(1),      -- alus1
            output => mux2_out(i)
        );
    end generate;


    
    --mux3 (με mux4): επιλέγει 0, db, db', με alus2=s1, alus3=s0
    
    mux3_gen : for i in 0 to n-1 generate
        m3 : entity work.mux4
        port map(
            input1 => '0',          -- 00 -> 0
            input2 => db(i),        -- 01 -> db
            input3 => not db(i),    -- 10 -> db'
            input4 => '0',          -- 11 -> δεν χρησιμοποιείται
            sel    => alus(2) & alus(3), -- s1=alus2, s0=alus3
            output => mux3_out(i)
        );
    end generate;


    
    --adder8bit
    
    arith: entity work.adder8bit
    generic map(NUM_BITS => n)
    port map(
        a    => mux2_out,
        b    => mux3_out,
        cin  => alus(4),           -- alus4 = carry in
        s    => arith_out,
        cout => carry
    );

	 --LOGIC UNIT
    logic_and:  and_out  <= ac and db;
    logic_or:   or_out   <= ac or  db;
    logic_xor:  xor_out  <= ac xor db;
    logic_not:  not_out  <= not ac;

    --MUX4 για επιλογή πράξης logic: alus5=s1, alus6=s0
    logic_gen: for i in 0 to n-1 generate
        m4 : entity work.mux4
        port map(
            input1 => and_out(i),
            input2 => or_out(i),
            input3 => xor_out(i),
            input4 => not_out(i),
            sel    => alus(5) & alus(6),
            output => logic_out(i)
        );
    end generate;


    
    --Τελικός mux2: επιλέγει arithmetic ή logic result,alus7 = select
    --------------------------------------------------------------------
    final_gen: for i in 0 to n-1 generate
        fm : entity work.mux2
        port map(
            input1 => arith_out(i),   -- 0 -> arithmetic
            input2 => logic_out(i),   -- 1 -> logic
            sel    => alus(7),
            output => dout(i)
        );
    end generate;

end arch;