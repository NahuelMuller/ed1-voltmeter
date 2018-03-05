-------------------------------------------------
-- Contador BCD x 4	(cont_bcd_4)
--
-- Descripcion:	Contador BCD de 4 digitos
-- Entradas:	Clock, reset y enable
-- Salidas:		3 digitos BCD (descarto el LS)
--
-- Autor:		Nahuel Müller
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity cont_bcd_4 is
	port(
		clk, rst, ena: in std_logic;
		bcd_out_0, bcd_out_1, bcd_out_2: out std_logic_vector(3 downto 0)
	);
end entity;

architecture cont_bcd_4_arq of cont_bcd_4 is

	signal ena_0, ena_1, ena_2: std_logic;
	signal aux_bcd_out_LS, aux_bcd_out_0, aux_bcd_out_1, aux_bcd_out_2: std_logic_vector(3 downto 0);

	component cont_bcd is
		port(
			clk, rst, ena: in std_logic;
			bcd_out: out std_logic_vector(3 downto 0)
		);
	end component;

begin

	cont_bcd_LS: cont_bcd
		port map (clk, rst, ena, aux_bcd_out_LS);
	cont_bcd_0: cont_bcd
		port map (clk, rst, ena_0, aux_bcd_out_0);
	cont_bcd_1: cont_bcd
		port map (clk, rst, ena_1, aux_bcd_out_1);
	cont_bcd_2: cont_bcd
		port map (clk, rst, ena_2, aux_bcd_out_2);

	-- Enable cont_bcd_0 cuando la salida de cont_bcd_LS es 9 (1001)
	ena_0 <= ena and aux_bcd_out_LS(3) and not aux_bcd_out_LS(2) and not aux_bcd_out_LS(1) and aux_bcd_out_LS(0);

	-- Enable cont_bcd_1 cuando las salidas de cont_bcd_0 y cont_bcd_LS son 9 (1001)
	ena_1 <= ena_0 and aux_bcd_out_0(3) and not aux_bcd_out_0(2) and not aux_bcd_out_0(1) and aux_bcd_out_0(0);

	-- Enable cont_bcd_2 cuando las salidas de cont_bcd_1, cont_bcd_0 y cont_bcd_LS son 9 (1001)
	ena_2 <= ena_1 and aux_bcd_out_1(3) and not aux_bcd_out_1(2) and not aux_bcd_out_1(1) and aux_bcd_out_1(0);

	bcd_out_0 <= aux_bcd_out_0;
	bcd_out_1 <= aux_bcd_out_1;
	bcd_out_2 <= aux_bcd_out_2;

end architecture;