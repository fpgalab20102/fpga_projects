LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY counter_3bit IS   --κλασικός up counter με διαφορά το inc για buffering, δηλαδή έχουμε 3 FF
    PORT ( 
        clk     : IN STD_LOGIC; 
        reset   : IN STD_LOGIC; 
        inc     : IN STD_LOGIC;                    
        counter : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) 
     );
END counter_3bit;

ARCHITECTURE bhv OF counter_3bit IS
    SIGNAL counter_up: STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN

    PROCESS(clk) -- με συγχρονο reset, με ασυγχρονο δημιουργει προβληματα στις μεταβασεις των bit του mOPs των εντολων
    BEGIN               
        IF rising_edge(clk) THEN
            IF (reset = '1') THEN
                 counter_up <= "000";
            ELSIF (inc = '1') THEN
                counter_up <= counter_up + 1;
            END IF;
        END IF;
    END PROCESS;
    
counter <= counter_up;

END bhv;