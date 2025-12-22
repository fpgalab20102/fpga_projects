library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.cpulib.all; 

entity rs_cpu is
port(
    ARdata, PCdata : buffer std_logic_vector(15 downto 0); 
    DRdata, ACdata : buffer std_logic_vector(7 downto 0);  
    IRdata, TRdata : buffer std_logic_vector(7 downto 0);
    RRdata         : buffer std_logic_vector(7 downto 0);  
    ZRdata         : buffer std_logic;                     
    
    clock, reset   : in std_logic;
    
    mOP            : buffer std_logic_vector(26 downto 0); 
    addressBus     : buffer std_logic_vector(15 downto 0); 
    dataBus        : buffer std_logic_vector(7 downto 0)   
);
end rs_cpu;

architecture arc of rs_cpu is

    signal internal_bus : std_logic_vector(15 downto 0); 
    signal ram_q_out       : std_logic_vector(7 downto 0); 
    signal mem_data_to_ram : std_logic_vector(7 downto 0); 
    signal alu_result : std_logic_vector(7 downto 0); 
    signal alu_z_flag : std_logic;                    
    signal alus_ctrl  : std_logic_vector(6 downto 0); 

begin

    -- 1. CONTROL UNIT
    CONTROL_UNIT: mseq
        PORT MAP (
            ir        => IRdata(3 downto 0), 
            clock     => clock,
            reset     => reset,
            z         => ZRdata,
            code      => open, 
            debug_reg => open,
            mOPs      => mOP 
        );

    -- 2. ALU CONTROL
    --με βάση τον πίνακα στην εργασία 3
    ALU_CONTROLLER: alus
        PORT MAP (
            andop  => mOP(7), 
            orop   => mOP(6),
            xorop  => mOP(5),
            notop  => mOP(4),
            acinc  => mOP(3),
            aczero => mOP(2), 
            plus   => mOP(1), 
            minus  => mOP(0),
            
            -- Βοηθητικά σήματα ALU (LOADS/BUSES που επηρεάζουν την ALU)
            rbus   => mOP(9),  -- RBUS (Bit 9)
            acload => mOP(18), -- ACLOAD (Bit 18)
            zload  => mOP(17), -- ZLOAD (Bit 17)
            drbus  => mOP(11), -- DRBUS (Bit 11)
            
            alus   => alus_ctrl 
        );

    -- 3. BUS SYSTEM
    -- Αντιστοίχιση βάσει εικόνας:
    -- PCBUS(12), DRBUS(11), TRBUS(10), RBUS(9), ACBUS(8)
    -- MEMBUS(14 - Read Buffer), BUSMEM(13 - Write Buffer)
    BUS_SYSTEM: data_bus
        PORT MAP (
            pc_out  => PCdata, dr_out  => DRdata,
            tr_out  => TRdata, r_out   => RRdata,
            ac_out  => ACdata, mem_out => ram_q_out,
            
            pcbus   => mOP(12), 
            drbus   => mOP(11),
            trbus   => mOP(10), 
            rbus    => mOP(9),
            acbus   => mOP(8), 
            membus  => mOP(14), 
            busmem  => mOP(13), 
            
            dbus        => internal_bus,   
            mem_data_in => mem_data_to_ram 
        );

    -- 4. REGISTERS
    
    -- PC: PCLOAD(24), PCINC(23)
    REG_PC: regnbit GENERIC MAP (n => 16)
        PORT MAP (clk => clock, rst => reset, ld => mOP(24), inc => mOP(23), 
                  din => internal_bus, dout => PCdata);

    -- AR: ARLOAD(26), ARINC(25)
    REG_AR: regnbit GENERIC MAP (n => 16)
        PORT MAP (clk => clock, rst => reset, ld => mOP(26), inc => mOP(25), 
                  din => internal_bus, dout => ARdata);

    -- DR: DRLOAD(22)
    REG_DR: regnbit GENERIC MAP (n => 8)
        PORT MAP (clk => clock, rst => reset, ld => mOP(22), inc => '0', 
                  din => internal_bus(7 downto 0), dout => DRdata);

    -- IR: IRLOAD(20)
    REG_IR: regnbit GENERIC MAP (n => 8)
        PORT MAP (clk => clock, rst => reset, ld => mOP(20), inc => '0', 
                  din => internal_bus(7 downto 0), dout => IRdata);

    -- TR: TRLOAD(21)
    REG_TR: regnbit GENERIC MAP (n => 8)
        PORT MAP (clk => clock, rst => reset, ld => mOP(21), inc => '0', 
                  din => internal_bus(7 downto 0), dout => TRdata);

    -- R: RLOAD(19)
    REG_R: regnbit GENERIC MAP (n => 8)
        PORT MAP (clk => clock, rst => reset, ld => mOP(19), inc => '0', 
                  din => internal_bus(7 downto 0), dout => RRdata);

    -- AC: ACLOAD(18)
    REG_AC: regnbit GENERIC MAP (n => 8)
        PORT MAP (clk => clock, rst => reset, ld => mOP(18), inc => '0', 
                  din => alu_result, dout => ACdata);

    -- Z: ZLOAD(17)
    REG_Z: regnbit GENERIC MAP (n => 1)
        PORT MAP (clk => clock, rst => reset, ld => mOP(17), inc => '0', 
                  din(0) => alu_z_flag, dout(0) => ZRdata);

    -- 5. MEMORY
    -- WRITE signal is mOP(15)
    MEMORY_UNIT: RAM 
        PORT MAP (
            clock   => clock,
            address => ARdata(7 downto 0),   
            data    => mem_data_to_ram,      
            wren    => mOP(15), -- WRITE SIGNAL
            q       => ram_q_out             
        );
        
    ALU_UNIT: alu GENERIC MAP (n => 8)
        PORT MAP (
            ac    => ACdata,                 
            db    => internal_bus(7 downto 0), 
            alus  => alus_ctrl,              
            dout  => alu_result,             
            z_out => alu_z_flag              
        );

    -- 6. OUTPUTS
    addressBus <= ARdata;
    dataBus    <= internal_bus(7 downto 0);

end arc;