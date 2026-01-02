LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE work.cpulib.all;

ENTITY rs_cpu IS
PORT(

    ARdata, PCdata : buffer std_logic_vector(15 downto 0); 
    DRdata, ACdata : buffer std_logic_vector(7 downto 0);  
    IRdata, TRdata : buffer std_logic_vector(7 downto 0);
    RRdata         : buffer std_logic_vector(7 downto 0);  
    Bdata          : buffer std_logic_vector(7 downto 0);
    ZRdata         : buffer std_logic;                     
    clock, reset   : in std_logic;
    mOP            : buffer std_logic_vector(28 downto 0); 
    addressBus     : buffer std_logic_vector(15 downto 0); 
    dataBus        : buffer std_logic_vector(7 downto 0)   
);
END rs_cpu;

ARCHITECTURE arc OF rs_cpu IS

    signal internal_bus    : std_logic_vector(15 downto 0); -- Ο Κεντρικός Δίαυλος 16-bit
    signal ram_q_out       : std_logic_vector(7 downto 0);  -- Έξοδος δεδομένων από RAM
    signal mem_data_to_ram : std_logic_vector(7 downto 0);  -- Είσοδος δεδομένων προς RAM
    signal alu_result      : std_logic_vector(7 downto 0);  -- Αποτέλεσμα πράξης ALU
    signal alu_z_flag      : std_logic;                     -- Zero Flag από την ALU
    signal alus_ctrl       : std_logic_vector(6 downto 0);  -- Κωδικός ελέγχου ALU
    signal mem_clock       : std_logic;

BEGIN

mem_clock <= NOT clock;

    -- Αντικατάσταση του παλιού Sequencer με την Hardwired FSM.
    -- Συνδέουμε το IR για να διαβάζει τα Opcodes και παράγει τα 29 bits ελέγχου (mOPs).
    CONTROL_UNIT: hardwired 
PORT MAP ( 
            ir => IRdata, 
            clock => clock, 
            reset => reset, 
            z => ZRdata, 
            mOPs => mOP
          );

    -- Μεταφράζει τα σήματα της FSM (π.χ. mOP(20)=OROP) σε εντολές για την ALU.
    -- Συνδέουμε και το mOP(15) (RBUS) και το mOP(13) (DRBUS) για σωστή επιλογή εισόδων.
    ALU_CONTROLLER: alus 
PORT MAP (
            andop => mOP(19), 
            orop => mOP(20), 
            xorop => mOP(21), 
            notop => mOP(22),
            acinc => mOP(23), 
            aczero => mOP(24), 
            plus => mOP(25), 
            minus => mOP(26),
            rbus => mOP(15), 
            acload => mOP(6), 
            zload => mOP(7), 
            drbus => mOP(13),
            alus => alus_ctrl
          );

    -- Ο Πολυπλέκτης που αποφασίζει ποιος γράφει στον δίαυλο.
    -- Προστέθηκε η σύνδεση του B_out και του σήματος ελέγχου BBUS (mOP(27)).
    BUS_SYSTEM: data_bus 
PORT MAP (
            pc_out => PCdata, 
            dr_out => DRdata, 
            tr_out => TRdata, 
            r_out => RRdata, 
            ac_out => ACdata, 
            mem_out => ram_q_out,
            b_out => Bdata,  -- Σύνδεση του νέου καταχωρητή στο Bus System
            
            -- Mapping των σημάτων ελέγχου (Enable signals)
            pcbus => mOP(12), 
            drbus => mOP(13), 
            trbus => mOP(14), 
            rbus => mOP(15), 
            acbus => mOP(16), 
            membus => mOP(17), 
            busmem => mOP(18), 
            bbus => mOP(27), -- Το νέο σήμα ελέγχου για τον B
            dbus => internal_bus, 
            mem_data_in => mem_data_to_ram
         );

    -- Instantiation των καταχωρητών και σύνδεση με τα σήματα φόρτωσης (Load) και αύξησης (Inc).
    REG_PC: regnbit GENERIC MAP (n => 16) PORT MAP (internal_bus, clock, reset, mOP(1), mOP(9), PCdata);
    REG_AR: regnbit GENERIC MAP (n => 16) PORT MAP (internal_bus, clock, reset, mOP(0), mOP(8), ARdata);
    REG_DR: regnbit GENERIC MAP (n => 8)  PORT MAP (internal_bus(7 downto 0), clock, reset, mOP(2), '0', DRdata);
    REG_IR: regnbit GENERIC MAP (n => 8)  PORT MAP (internal_bus(7 downto 0), clock, reset, mOP(3), '0', IRdata);
    REG_TR: regnbit GENERIC MAP (n => 8)  PORT MAP (internal_bus(7 downto 0), clock, reset, mOP(4), '0', TRdata);
    REG_R:  regnbit GENERIC MAP (n => 8)  PORT MAP (internal_bus(7 downto 0), clock, reset, mOP(5), '0', RRdata);
    REG_AC: regnbit GENERIC MAP (n => 8)  PORT MAP (alu_result, clock, reset, mOP(6), '0', ACdata);
    
    -- Register Z (Zero Flag)
    -- Επειδή το regnbit είναι φτιαγμένο για vectors, και το Z είναι 1-bit signal,
    -- κάνουμε map το bit(0) του din/dout για να αποφύγουμε Type Mismatch Error.
    REG_Z:  regnbit GENERIC MAP (n => 1)  
            PORT MAP (
                clk => clock, 
                rst => reset, 
                ld => mOP(7), 
                inc => '0',
                din(0) => alu_z_flag,  -- Είσοδος: Το αποτέλεσμα από την ALU
                dout(0) => ZRdata      -- Έξοδος: Προς την FSM
            );
    
    -- Υλοποίηση του καταχωρητή B (8-bit).
    -- Συνδέουμε το σήμα φόρτωσης στο bit 28 (mOP(28)) για μελλοντική χρήση (Load B).
    REG_B:  regnbit GENERIC MAP (n => 8)  
             PORT MAP (internal_bus(7 downto 0), clock, reset, mOP(28), '0', Bdata);


    -- Χρησιμοποιούμε "NOT clock" (Ανεστραμμένο Ρολόι).
    -- Η IP Catalog RAM είναι σύγχρονη και διαβάζει στην ακμή. Αν χρησιμοποιούσαμε το ίδιο ρολόι
    -- με τον CPU, ο DR θα προσπαθούσε να διαβάσει δεδομένα πριν αυτά είναι έτοιμα (Race Condition).
    -- Με το NOT clock, η μνήμη βγάζει δεδομένα στη μέση του κύκλου, ώστε να είναι σταθερά
    -- όταν ο DR κάνει latch στην επόμενη άνοδο.
    MEMORY_UNIT: RAM 
PORT MAP (
            clock   => mem_clock, 
            address => ARdata(7 downto 0),   
            data    => mem_data_to_ram,      
            wren    => mOP(11), 
            q       => ram_q_out             
        );
        
    --Δέχεται ως είσοδο τον AC και τα 8-bit του Internal Bus.
    --Αν είναι ενεργό το BBUS, το Internal Bus έχει την τιμή του B.
    ALU_UNIT: alu GENERIC MAP (n => 8) PORT MAP (ACdata, internal_bus(7 downto 0), alus_ctrl, alu_result, alu_z_flag);

    --έξοδοι για παρατήρηση sim
    addressBus <= ARdata;
    dataBus    <= internal_bus(7 downto 0);
end arc;