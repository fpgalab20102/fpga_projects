LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY data_bus IS
PORT (
   --bus to register (Inputs from Registers outputs)
   pc_out : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);  --PC=16-bit
   dr_out : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);   --DR=8-bit
   tr_out : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);   --TR=8-bit
   r_out  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);   --R=8-bit
   ac_out : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);   --AC=8-bit
   mem_out: IN  STD_LOGIC_VECTOR(7 DOWNTO 0);   --MEMory data=8-bit
   
   --buffers (Control Signals)
   pcbus   : IN  STD_LOGIC;--PC=1-bit
   drbus   : IN  STD_LOGIC;--DR=1-bit
   trbus   : IN  STD_LOGIC;--TR=1-bit
   rbus    : IN  STD_LOGIC;--R=1-bit
   acbus   : IN  STD_LOGIC;--AC=1-bit
   membus  : IN  STD_LOGIC;--MEMory buffer=1-bit      
   busmem  : IN  STD_LOGIC; --control signal for memory write(Buffer BUS->MEM)

   --outputs
   dbus        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); --common buffer(bus)=16-bit
   mem_data_in : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)   --data to mem in
);
END data_bus;

ARCHITECTURE bhv OF data_bus IS
    SIGNAL internal_bus : STD_LOGIC_VECTOR(15 DOWNTO 0); --for bus reading
BEGIN

    PROCESS (pc_out, dr_out, tr_out, r_out, ac_out, mem_out, 
             pcbus, drbus, trbus, rbus, acbus, membus)
    BEGIN
        
        internal_bus <= "ZZZZZZZZZZZZZZZZ"; --for no action(no btn press)--> high impedance(Z)->16-bit

        --always assign the bottom 8-bits, otherwise the value changes
        
        IF (pcbus = '1') THEN --if pc-->needs all 16-bit bus
            internal_bus <= pc_out;

        
        ELSIF (drbus = '1') THEN --if dr--->since its 8-bit it needs only the bottom 8-bits
            internal_bus(15 DOWNTO 8) <= "00000000";--make the top 8-bits zero(0)
            internal_bus(7 DOWNTO 0)  <= dr_out;--bottoms take dr value

        
        ELSIF (trbus = '1') THEN  --same for tr
            internal_bus(15 DOWNTO 8) <= "00000000";
            internal_bus(7 DOWNTO 0)  <= tr_out;

        
        ELSIF (rbus = '1') THEN --same for r
            internal_bus(15 DOWNTO 8) <= "00000000";
            internal_bus(7 DOWNTO 0)  <= r_out;

        ELSIF (acbus = '1') THEN --same for ac
            internal_bus(15 DOWNTO 8) <= "00000000";
            internal_bus(7 DOWNTO 0)  <= ac_out;

        ELSIF (membus = '1') THEN --same for mem
            internal_bus(15 DOWNTO 8) <= "00000000";
            internal_bus(7 DOWNTO 0)  <= mem_out;
            
        END IF;

    END PROCESS;

    
    dbus <= internal_bus;
    mem_data_in <= internal_bus(7 DOWNTO 0) WHEN busmem = '1' ELSE (others => '0');

END bhv;