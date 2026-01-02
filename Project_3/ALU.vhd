library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
-- use work.alulib.all; -- Αν δεν έχεις αρχείο alulib, μπορείς να το σχολιάσεις αυτό

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
    
    -- === ΝΕΑ ΕΝΔΙΑΜΕΣΑ ΣΗΜΑΤΑ ΓΙΑ ΤΗ ΔΙΟΡΘΩΣΗ ===
    signal not_db     : std_logic_vector(n-1 downto 0); -- Για το not db
    signal sel_mux3   : std_logic_vector(1 downto 0);   -- Για το alus(2) & alus(3)
    signal sel_logic  : std_logic_vector(1 downto 0);   -- Για το alus(5) & alus(6)
    signal final_dout : std_logic_vector(n-1 downto 0); -- Για υπολογισμό Z flag

begin

    -- 1. ΑΝΑΘΕΣΗ ΤΙΜΩΝ ΣΤΑ ΕΝΔΙΑΜΕΣΑ ΣΗΜΑΤΑ (Εκτός Port Map)
    not_db    <= not db;
    sel_mux3  <= alus(2) & alus(3);
    sel_logic <= alus(5) & alus(6);

    -- 2. ΛΟΓΙΚΕΣ ΠΡΑΞΕΙΣ
    logic_and:  and_out  <= ac and db;
    logic_or:   or_out   <= ac or  db;
    logic_xor:  xor_out  <= ac xor db;
    logic_not:  not_out  <= not ac;

    -- 3. ARITHMETIC UNIT
    -- mux2: επιλέγει 0 ή ac με βάση alus1
    mux2_gen : for i in 0 to n-1 generate
        m2: entity work.mux2
        port map(
            input1 => '0',          
            input2 => ac(i),        
            sel    => alus(1),      
            output => mux2_out(i)
        );
    end generate;
    
    -- mux3 (με mux4): επιλέγει 0, db, db'
    mux3_gen : for i in 0 to n-1 generate
        m3 : entity work.mux4
        port map(
            input1 => '0',          -- 00 -> 0
            input2 => db(i),        -- 01 -> db
            input3 => not_db(i),    -- 10 -> db' (ΧΡΗΣΗ ΤΟΥ ΕΝΔΙΑΜΕΣΟΥ ΣΗΜΑΤΟΣ)
            input4 => '0',          -- 11
            sel    => sel_mux3,     -- s1 & s0   (ΧΡΗΣΗ ΤΟΥ ΕΝΔΙΑΜΕΣΟΥ ΣΗΜΑΤΟΣ)
            output => mux3_out(i)
        );
    end generate;

    -- adder8bit
    arith: entity work.adder8bit
    generic map(NUM_BITS => n)
    port map(
        a    => mux2_out,
        b    => mux3_out,
        cin  => alus(4),        
        s    => arith_out,
        cout => carry
    );

    -- MUX4 για επιλογή πράξης logic
    logic_gen: for i in 0 to n-1 generate
        m4 : entity work.mux4
        port map(
            input1 => and_out(i),
            input2 => or_out(i),
            input3 => xor_out(i),
            input4 => not_out(i),
            sel    => sel_logic,    -- (ΧΡΗΣΗ ΤΟΥ ΕΝΔΙΑΜΕΣΟΥ ΣΗΜΑΤΟΣ)
            output => logic_out(i)
        );
    end generate;

    -- Τελικός mux2: επιλέγει arithmetic ή logic result
    final_gen: for i in 0 to n-1 generate
        fm : entity work.mux2
        port map(
            input1 => arith_out(i),   -- 0 -> arithmetic
            input2 => logic_out(i),   -- 1 -> logic
            sel    => alus(7),
            output => final_dout(i)   -- Αποθήκευση σε ενδιάμεσο σήμα πρώτα
        );
    end generate;
    
    -- Ανάθεση στην έξοδο
    dout <= final_dout;

    -- Υπολογισμός Zero Flag (z_out)
    -- Αν το αποτέλεσμα είναι 0, το Z γίνεται 1
    z_out <= '1' when final_dout = (final_dout'range => '0') else '0';

end arch;