-------------------------------------------------
-- Registros BCD	(reg_bcd_4)
--
-- Descripcion:	3 Registros BCD (4 bits)
-- Entradas:	Regs, clock, reset y write enable
-- Salidas:		Regs
--
-- Autor:		Nahuel Müller
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity reg_bcd_4 is
	port(
		reg_in_0, reg_in_1, reg_in_2: in std_logic_vector(3 downto 0);
		clk, rst, write_ena: in std_logic;
		reg_out_0, reg_out_1, reg_out_2: out std_logic_vector(3 downto 0)
	);
end entity;

architecture reg_bcd_4_arq of reg_bcd_4 is

	component ffd is
		port(
			D, clk, rst, ena: in std_logic;
			Q: out std_logic
		);
	end component;

begin

	GEN_ffd_2:
	for I in 0 to 3 generate
		ffdx_2: ffd
			port map (reg_in_2(I), clk, rst, write_ena, reg_out_2(I));
	end generate;

	GEN_ffd_1:
	for I in 0 to 3 generate
		ffdx_1: ffd
			port map (reg_in_1(I), clk, rst, write_ena, reg_out_1(I));
	end generate;

	GEN_ffd_0:
	for I in 0 to 3 generate
		ffdx_0: ffd
			port map (reg_in_0(I), clk, rst, write_ena, reg_out_0(I));
	end generate;

end architecture;