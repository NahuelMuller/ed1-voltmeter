-------------------------------------------------
-- Decodificador	(rom_deco)
--
-- Descripcion:	Decodificador de direcciones
-- Entradas:	Digito y selectores X e Y
-- Salidas:		Selectores fila y columna
--
-- Autor:		Nahuel Müller
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rom_deco is
	port(
		digito: in std_logic_vector(3 downto 0);
		sel_x, sel_y: in std_logic_vector(2 downto 0);
		fila: out integer range 0 to 103;
		columna: out integer range 0 to 7
	);
end entity;

architecture rom_deco_arq of rom_deco is

	signal aux_fila: std_logic_vector(6 downto 0);

begin

	aux_fila <= digito & sel_y;
	fila <= to_integer(unsigned(aux_fila));
	columna <= to_integer(unsigned(sel_x));

end architecture;