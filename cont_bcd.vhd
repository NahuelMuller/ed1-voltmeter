-------------------------------------------------
-- Contador BCD	(cont_bcd)
--
-- Descripcion:	Contador codificado en BCD
-- Entradas:	Clock, reset y enable
-- Salidas:		Digito BCD (4 bits)
--
-- Autor:		Nahuel Müller
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity cont_bcd is
	port(
		clk, rst, ena: in std_logic;
		bcd_out: out std_logic_vector(3 downto 0)
	);
end entity;

architecture cont_bcd_arq of cont_bcd is

	signal ffd_in, ffd_out: std_logic_vector(3 downto 0);

	component ffd is
		port(
			D, clk, rst, ena: in std_logic;
			Q: out std_logic
		);
	end component;

begin

	GEN_ffd:
	for I in 0 to 3 generate
		ffdx: ffd
			port map (ffd_in(I), clk, rst, ena, ffd_out(I));
	end generate;

	ffd_in(0) <= not ffd_out(0);
	ffd_in(1) <= (not ffd_out(3) and not ffd_out(1) and ffd_out(0)) or (ffd_out(1) and not ffd_out(0));
	ffd_in(2) <= ffd_out(2) xor (ffd_out(1) and ffd_out(0));
	ffd_in(3) <= (ffd_out(2) and ffd_out(1) and ffd_out(0)) or (ffd_out(3) and not ffd_out(0));

	bcd_out <= ffd_out;

end architecture;