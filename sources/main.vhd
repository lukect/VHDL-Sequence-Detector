library IEEE;
use IEEE.NUMERIC_STD.ALL;

use work.lock_state.all;   -- lock.vhd
use work.button_state.all; -- buttons.vhd

entity main is
    Port (
        clk     : in  bit                    := '1' ;
        init    : in  bit                    := '0' ;
        b1      : in  bit                    := '0' ;
        b2      : in  bit                    := '0' ;
        b3      : in  bit                    := '0' ;
        b4      : in  bit                    := '0' ;
        
        led_out : out bit_vector(7 downto 0)        ;
        lock    : out lock_state                    ;
        button  : out button_state           := none
    );
end main;

architecture arch_main of main is

begin

    buttons_entity : entity work.buttons(arch_buttons) port map(
        clk     => clk,
        init    => init,
        b1      => b1,
        b2      => b2,
        b3      => b3,
        b4      => b4,
        btn_out => button
    );

    lock_entity : entity work.lock(arch_lock) port map(
        clk     => clk,
        lock    => lock,
        led_out => led_out
    );

    seq_det_entity : entity work.sequence_detector(arch_register_based) port map(
        lock    => lock,
        button  => button
    );
    
end arch_main;