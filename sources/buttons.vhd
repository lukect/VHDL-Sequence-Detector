package button_state is
    type button_state is (button_init, button_1, button_2, button_3, button_4, none);
end package;
use work.button_state.all;

library IEEE;
use IEEE.NUMERIC_STD.ALL;

entity buttons is
    Port (
        clk     : in  bit          := '1';
        init    : in  bit          := '0';
        b1      : in  bit          := '0';
        b2      : in  bit          := '0';
        b3      : in  bit          := '0';
        b4      : in  bit          := '0';
        btn_out : out button_state := none
    );
end buttons;

architecture arch_buttons of buttons is
    constant u_size                 : natural                     := 3; -- Enough to fit clk_passes
    constant clk_passes             : unsigned(u_size-1 downto 0) := to_unsigned(5, u_size); -- 250_000
begin
    debounce: process(clk)
        variable   previous         : button_state                := none;
        variable   checking         : button_state                := none;
        variable   debounce_counter : unsigned(u_size-1 downto 0) := to_unsigned(0, u_size);
    begin
        if clk'event and clk = '1' then -- same as rising_edge
            previous := checking;
                        
            if    ((init) and (not b1) and (not b2) and (not b3) and (not b4)) = '1' then
                checking := button_init;
            elsif ((not init) and (b1) and (not b2) and (not b3) and (not b4)) = '1' then
                checking := button_1;
            elsif ((not init) and (not b1) and (b2) and (not b3) and (not b4)) = '1' then
                checking := button_2;
            elsif ((not init) and (not b1) and (not b2) and (b3) and (not b4)) = '1' then
                checking := button_3;
            elsif ((not init) and (not b1) and (not b2) and (not b3) and (b4)) = '1' then
                checking := button_4;
            else
                checking := none;
            end if;
            
            if previous = checking then
                if checking /= btn_out then
                    debounce_counter := debounce_counter + to_unsigned(1, u_size);
                    if debounce_counter >= clk_passes then
                        btn_out <= checking;
                        debounce_counter := to_unsigned(0, u_size);
                    end if;
                end if;
            else
                debounce_counter := to_unsigned(0, u_size);
                btn_out <= none;
            end if;
         end if;
    end process debounce;

end architecture arch_buttons;