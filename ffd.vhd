-------------------------------------------------
-- Flip-flop D	(ffd)
--
-- Descripcion:	Flip-flop D de flanco ascendente
-- Entradas:	Data, clock, reset y enable
-- Salidas:		Normal y negada
--
-- Autor:		Nahuel Müller
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ffd is
	port(
		D, clk, rst, ena: in std_logic;
		Q: out std_logic
	);
end entity;

architecture ffd_arq of ffd is

begin

	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				Q <= '0';
			elsif ena = '1' then
				Q <= D;
			end if;
		end if;
	end process;

end architecture;