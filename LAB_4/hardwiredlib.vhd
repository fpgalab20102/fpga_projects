LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE hardwiredlib IS

    COMPONENT decdr4to16
        PORT ( 
            Din  : IN  STD_LOGIC_VECTOR (3 DOWNTO 0); 
            Dout : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) 
        );
    END COMPONENT;

    COMPONENT decdr3to8
        PORT ( 
            Din  : IN  STD_LOGIC_VECTOR (2 DOWNTO 0); 
            Dout : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) 
        );
    END COMPONENT;

    
    COMPONENT counter_3bit IS   
    PORT ( 
        clk     : IN STD_LOGIC; 
        reset   : IN STD_LOGIC; 
        inc     : IN STD_LOGIC;                    
        counter : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) 
     );
END COMPONENT;

END hardwiredlib;