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

    -- Σήματα Δεδομένων
    signal register_out : std_logic_vector(5 downto 0); 
    signal rom_out      : std_logic_vector(35 downto 0);
    signal mux3to1_out  : std_logic_vector(5 downto 0); 
    
    -- Inputs του Κεντρικού MUX
    signal incrm_out    : std_logic_vector(5 downto 0); 
    signal branch_addr  : std_logic_vector(5 downto 0);
    signal map_addr     : std_logic_vector(5 downto 0);
    
    -- Σήματα Ελέγχου
    -- ΑΛΛΑΓΗ 1: Δηλώνουμε το sel ως 3 bits (όχι main_mux_sel)
    signal sel          : std_logic_vector(2 downto 0); 
    signal cond_select  : std_logic_vector(1 downto 0); 
    
    -- Σήμα αποτελέσματος συνθήκης
    signal mux4_out     : std_logic;                    

begin

    -- 1. Αναθέσεις Εξόδων & ROM
    code <= rom_out;
    mOPs <= rom_out(32 downto 6);
    branch_addr <= rom_out(5 downto 0);
	 debug_reg <= register_out;

    -- ΑΛΛΑΓΗ 2: Συνδέουμε το sel κατευθείαν με τη ROM
    sel <= rom_out(35 downto 33);
    
    -- Τα 2 πρώτα bits του SEL πάνε και στον MUX4 (όπως στο διάγραμμα)
    cond_select <= rom_out(35 downto 34);

    -- 3. Υπολογισμός Inputs
    incrm_out <= register_out + 1; -- Input 0
    map_addr  <= ir & "00";        -- Input 2

    -- 4. Μνήμη ROM
    ROM : mseq_rom
        port map(
            address => register_out,
            clock   => clock,
            q       => rom_out
        );

    -- 5. MUX Συνθήκης (MUX4TO1)
    MUX4TO1 : mux4
        port map(
            input1 => '1',
            input2 => z,
            input3 => not z,
            input4 => '0',
            sel    => cond_select, 
            output => mux4_out
        );

    -- ΑΛΛΑΓΗ 3: Αφαιρέσαμε το main_mux_sel <= bt_bit & mux4_out; 
    -- Δεν χρειάζεται γιατί ελέγχουμε απευθείας το 'sel' των 3 bits.

    -- 7. Κύριος MUX (Process)
    -- ΑΛΛΑΓΗ 4: Στο process βάζουμε το 'sel' (3 bits)
    process(sel, mux4_out, branch_addr, incrm_out, map_addr)
    begin
        -- ΑΛΛΑΓΗ 5: Το case κοιτάει το 'sel'
        case sel is
            
            -- "000": Increment 
            -- (FETCH1, FETCH2)
            when "000" =>                 
                mux3to1_out <= incrm_out;

            -- "001": MAP (Βάσει του .mif αρχείου σου)
            -- (FETCH3 -> Πάει στην αρχή της εντολής)
            when "001" =>                 
                mux3to1_out <= map_addr;

            -- "110": Unconditional Jump (Βάσει του .mif αρχείου σου)
            -- (NOP -> Πάει στο 1)
            when "110" =>                 
                mux3to1_out <= branch_addr;

            -- "010": Conditional Branch (π.χ. JMPZ - Αν Z=1 Jump)
            when "010" =>
                if mux4_out = '1' then
                    mux3to1_out <= branch_addr;
                else
                    mux3to1_out <= incrm_out;
                end if;
            
            -- "100": Conditional Branch (π.χ. JPNZ - Αν Z=0 Jump)
            when "100" =>
                if mux4_out = '1' then
                    mux3to1_out <= branch_addr;
                else
                    mux3to1_out <= incrm_out;
                end if;

            -- Default για ασφάλεια
            when others =>
                mux3to1_out <= (others => '0');

        end case;
    end process;

    -- 8. Καταχωρητής
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