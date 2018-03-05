-------------------------------------------------
-- Contador binario	(cont_b1)
--
-- Descripcion:	Contador binario de 1 bit
-- Entradas:	Clock, reset y enable
-- Salidas:		Bit y carry
--
-- Autor:		Nahuel Müller
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity cont_b1 is
	port(
		clk, rst, ena: in std_logic;
		cont_out, carry: out std_logic
	);
end entity;

architecture cont_b1_arq of cont_b1 is

	signal aux_D, aux_Q: std_logic;

	component ffd is
		port(
			D, clk, rst, ena: in std_logic;
			Q: out std_logic
		);
	end component;

begin

	ffdx: ffd
		port map (aux_D, clk, rst, '1', aux_Q);

	cont_out <= aux_Q;
	aux_D <= ena xor aux_Q;
	carry <= ena and aux_Q;

end architecture;