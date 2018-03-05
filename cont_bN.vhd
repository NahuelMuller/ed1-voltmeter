-------------------------------------------------
-- Contador binario	(cont_bN)
--
-- Descripcion:	Contador binario de N bits
-- Entradas:	Clock, reset y enable
-- Salidas:		N bits y carry
--
-- Autor:		Nahuel Müller
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity cont_bN is
	generic (N : natural);
	port(
		clk, rst, ena: in std_logic;
		cont_out: out std_logic_vector(N-1 downto 0);
		carry: out std_logic
	);
end entity;

architecture cont_bN_arq of cont_bN is

	signal aux_ena: std_logic_vector(0 to N);

	component cont_b1 is
		port(
			clk, rst, ena: in std_logic;
			cont_out, carry: out std_logic
		);
	end component;

begin

	GEN_cont_b1:
	for I in 0 to N-1 generate
		cont_b1x: cont_b1
			port map (clk, rst, aux_ena(I), cont_out(I), aux_ena(I+1));
	end generate;

	aux_ena(0) <= ena;
	carry <= aux_ena(N);

end architecture;