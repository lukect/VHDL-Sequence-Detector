-- Simulation for only the button state processing

use work.button_state.all; -- buttons.vhd

entity simulation is end simulation;

architecture arch_simulation of simulation is
    constant clk_half_period : time                    := 5ns;
    constant bounce_wait     : time                    := 12ns;
    constant normal_wait     : time                    := 70ns;
    
    signal clk               : bit                     :=  '1';
    signal init              : bit                     :=  '0';
    signal b1                : bit                     :=  '0';
    signal b2                : bit                     :=  '0';
    signal b3                : bit                     :=  '0';
    signal b4                : bit                     :=  '0';
    
    signal button            : button_state            := none;
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
    
    clk <= not clk after clk_half_period; -- invert clock every half period

    testbench: process
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
        press(b1);
        press(b4);
        press(b3);
        press(b2);
        press(b1);
        press(b4);
        wait;
    end process testbench;

end arch_simulation;