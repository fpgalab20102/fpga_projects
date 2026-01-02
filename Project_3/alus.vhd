library ieee ;
use ieee.std_logic_1164.all ;

-- Λαμβάνει τα σήματα ελέγχου υψηλού επιπέδου από την FSM (π.χ. "κάνε πρόσθεση", "φόρτωσε AC")
-- και παράγει τον κωδικό επιλογής 7-bit (alus) που ελέγχει τους πολυπλέκτες μέσα στην ALU.
entity alus IS
port(
    --Σήματα ελέγχου κατευθείαν από mOPs
    rbus, acload, zload, andop, orop, notop, xorop, aczero, acinc, plus, minus, drbus : in std_logic;
    
    -- Έξοδος: Ο κωδικός λειτουργίας που πάει κατευθείαν στην ALU (alu.vhd)
    alus : out std_logic_vector(6 downto 0)
);
end alus ;

architecture arc of alus is
    -- Εσωτερικό σήμα για τη συνένωση όλων των εισόδων ελέγχου
    signal control : std_logic_vector(11 downto 0);
begin
    -- Concatenation των σημάτων ελέγχου σε ένα διάνυσμα 12-bit.
    -- Αυτό μας επιτρέπει να ελέγξουμε όλες τις συνθήκες ταυτόχρονα με ένα CASE statement.
    -- Η σειρά των bits είναι: 
    -- 11:rbus, 10:drbus, 9:acload, 8:zload, 7:andop, 6:orop, 5:notop, 4:xorop, ...
    control <= rbus & drbus & acload & zload & andop & orop & notop & xorop & aczero & acinc & plus & minus ;

    process(control)
    begin
        case control is
            
            -- AND: rbus=1, acload=1, zload=1, andop=1 -> Output: Select AND Mux
            WHEN "101110000000" => alus <= "1000000" ; 
            
            -- OR: rbus=1, acload=1, zload=1, orop=1 -> Output: Select OR Mux
            WHEN "101101000000" => alus <= "1100000" ; 
            
            WHEN "001100100000" => alus <= "1110000" ; -- NOT (Μονόμπαιτη, δεν θέλει R)
            WHEN "101100010000" => alus <= "1010000" ; -- XOR (με R)
            WHEN "001100001000" => alus <= "0000000" ; -- CLAC (Clear AC)
            WHEN "001100000100" => alus <= "0001001" ; -- INAC (Increment AC)
            WHEN "101100000010" => alus <= "0000101" ; -- ADD (με R)
            WHEN "101100000001" => alus <= "0001011" ; -- SUB (με R)
            WHEN "101100000000" => alus <= "0000100" ; -- MOVR
            WHEN "011100000000" => alus <= "0000100" ; -- LDAC5
           
            -- Στις εντολές ORB/XORB, το 'rbus' είναι '0' (Bit 11 = 0), διότι 
            -- χρησιμοποιούμε τον 'bbus' (που δεν ελέγχεται εδώ αλλά στο data_bus).
            -- Ωστόσο, πρέπει να δώσουμε στην ALU τον ίδιο κωδικό πράξης.

            -- ORB: rbus=0, orop=1 (Bit 6).
            -- Η έξοδος "1100000" είναι η ίδια με το απλό OR, γιατί η ALU 
            -- δεν ενδιαφέρεται από πού ήρθαν τα δεδομένα, αλλά τι πράξη να κάνει.
            WHEN "001101000000" => alus <= "1100000" ; 
            
            -- XORB: rbus=0, xorop=1 (Bit 4).
            -- Ομοίως, στέλνουμε τον κωδικό XOR στην ALU.
            WHEN "001100010000" => alus <= "1010000" ; 

            -- Default περίπτωση: NOP (No Operation)
            WHEN others => alus <= "1111111" ;
        end case;
    end process;
end arc ;