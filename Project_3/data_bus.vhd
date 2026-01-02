LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY data_bus IS
PORT (
    
    pc_out : IN  STD_LOGIC_VECTOR(15 DOWNTO 0); -- PC (16-bit)
    dr_out, tr_out, r_out, ac_out, mem_out : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- 8-bit καταχωρητές
    b_out : IN STD_LOGIC_VECTOR(7 DOWNTO 0);    -- Η έξοδος του Καταχωρητή B (8-bit)
    
    -- Κάθε σήμα (π.χ. drbus) λειτουργεί ως Enable για τον Tri-state buffer του αντίστοιχου καταχωρητή.
    pcbus, drbus, trbus, rbus, acbus, membus, busmem : IN STD_LOGIC;
    
    bbus : IN STD_LOGIC; -- Enable για να βγει ο B στον δίαυλο

    -- Έξοδοι συστήματος
    dbus        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- Ο κεντρικός δίαυλος 16-bit
    mem_data_in : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)   -- Δεδομένα προς εγγραφή στη Μνήμη
);
END data_bus;

ARCHITECTURE bhv OF data_bus IS

    -- Εσωτερικό σήμα για την προσομοίωση της συμπεριφοράς του διαύλου
    SIGNAL internal_bus : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

    --Combinational Logic
    -- όλα τα σήματα εισόδου στην process, καθώς η έξοδος αλλάζει άμεσα.
    PROCESS (pc_out, dr_out, tr_out, r_out, ac_out, mem_out, b_out, 
             pcbus, drbus, trbus, rbus, acbus, membus, bbus)
    BEGIN
        -- Default State: High Impedance (Υψηλή Σύνθετη Αντίσταση - 'Z')
        -- Αυτό είναι κρίσιμο: Αν κανένα σήμα ελέγχου δεν είναι '1', ο δίαυλος είναι floating.
        -- Έτσι προσομοιώνουμε σωστά τα ηλεκτρονικά Tri-state buffers και αποφεύγουμε συγκρούσεις.
        internal_bus <= (others => 'Z'); 

        -- Priority Encoder Logic
        -- Ελέγχουμε ποιο σήμα ελέγχου είναι ενεργό και οδηγούμε τα αντίστοιχα δεδομένα στον δίαυλο.
        
        IF (pcbus = '1') THEN 
            internal_bus <= pc_out; -- Ο PC είναι 16-bit, περνάει ως έχει.
            
        ELSIF (drbus = '1') THEN 
            -- Padding: Ο DR είναι 8-bit. Γεμίζουμε τα 8 MSB με μηδενικά (x"00").
            internal_bus <= x"00" & dr_out;
            
        ELSIF (trbus = '1') THEN  
            internal_bus <= x"00" & tr_out;
            
        ELSIF (rbus = '1') THEN 
            internal_bus <= x"00" & r_out;
            
        ELSIF (acbus = '1') THEN 
            internal_bus <= x"00" & ac_out;
            
        ELSIF (membus = '1') THEN 
            internal_bus <= x"00" & mem_out;
            
        -- Όταν η FSM ενεργοποιήσει το σήμα 'bbus' (π.χ. στην εντολή ORB),
        -- τα περιεχόμενα του B οδηγούνται στον δίαυλο.
        ELSIF (bbus = '1') THEN 
            internal_bus <= x"00" & b_out; 
            
        END IF;
    END PROCESS;

    dbus <= internal_bus;
    
    -- Στέλνουμε δεδομένα στη RAM μόνο όταν το σήμα εγγραφής (busmem) είναι ενεργό.
    -- Αλλιώς στέλνουμε '0' για ασφάλεια.
    mem_data_in <= internal_bus(7 DOWNTO 0) WHEN busmem = '1' ELSE (others => '0');

END bhv;