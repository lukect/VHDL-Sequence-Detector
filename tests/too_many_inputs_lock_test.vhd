-- Test to prove locking after 12 incorrect inputs

library IEEE;
use IEEE.NUMERIC_STD.ALL;

use work.lock_state.all;   -- lock.vhd
use work.button_state.all; -- buttons.vhd

entity simulation is end simulation;

architecture arch_simulation of simulation is
    constant clk_half_period : time                    := 5ns;
    constant bounce_wait     : time                    := 8ns;
    constant normal_wait     : time                    := 100ns;
    
    signal clk               : bit                     := '1' ;
    signal init              : bit                     := '0' ;
    signal b1                : bit                     := '0' ;
    signal b2                : bit                     := '0' ;
    signal b3                : bit                     := '0' ;
    signal b4                : bit                     := '0' ;
    
    signal lock              : lock_state                     ;
    signal led_out           : bit_vector(7 downto 0)         ;
    signal button            : button_state            := none;
begin

    main_entity : entity work.main(arch_main) port map(
        clk     => clk,
        init    => init,
        b1      => b1,
        b2      => b2,
        b3      => b3,
        b4      => b4,
        led_out => led_out,
        lock    => lock,
        button  => button
    );
    
    clk <= not clk after clk_half_period; -- invert clock every half period

    testbench: process -- unlock=1-4-2-3-3
        procedure press(signal btn : out bit) is -- adds bounce and delays to presses
        begin
            wait for normal_wait;
            btn <= '1';
            wait for bounce_wait;
            btn <= '0';
            wait for bounce_wait;
            btn <= '1';
            wait for bounce_wait;
            btn <= '0';
            wait for bounce_wait;
            btn <= '1';
            wait for normal_wait;
            btn <= '0';
        end procedure;
    begin
        press(init);

        -- Press 7 random buttons to prove counter allows ONLY 12 inputs.
        press(b1);
        press(b4);
        press(b3);
        press(b2);
        press(b2);
        press(b1);
        press(b4);
        press(b2);
        
        -- Unlock Sequence 1 4 2 3 3
        press(b1);
        press(b4);
        press(b2);
        press(b3);
        press(b3);

        -- Then really unlock again
        wait for 100ns;
        press(init);
        -- Unlock Sequence 1 4 2 3 3
        press(b1);
        press(b4);
        press(b2);
        press(b3);
        press(b3);

        wait;
    end process testbench;

end arch_simulation;