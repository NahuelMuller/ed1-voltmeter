-------------------------------------------------
-- Multiplexor 2x1	(mux_2x1)
--
-- Descripcion:	Multiplexor generico
-- Entradas:	2 bit
-- Salidas:		1 bit
--
-- Autor:		Nahuel Müller
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux_2x1 is
	port(
		mux_x, mux_y, mux_sel: in std_logic;
		mux_out: out std_logic
	);
end entity;

architecture mux_2x1_arq of mux_2x1 is

begin

	mux_out <= (mux_x and not mux_sel) or (mux_y and mux_sel);

end architecture;