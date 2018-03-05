-------------------------------------------------
-- Multiplexor	(char_mux)
--
-- Descripcion:	Multiplexor de digitos
-- Entradas:	Digitos BCD y selectores X e Y
-- Salidas:		Digito BCD
--
-- Autor:		Nahuel Müller
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity char_mux is
	port(
		dig_0, dig_1, dig_2: in std_logic_vector(3 downto 0);
		mux_sel_x: in std_logic_vector(2 downto 0);
		mux_sel_y: in std_logic_vector(1 downto 0);
		mux_out: out std_logic_vector(3 downto 0)
	);
end entity;

architecture char_mux_arq of char_mux is

	constant char_punto: std_logic_vector(3 downto 0) := "1010";
	constant char_V: std_logic_vector(3 downto 0) := "1011";
	constant char_vacio: std_logic_vector(3 downto 0) := "1100";

	component mux_2x1 is
		port(
			mux_x, mux_y, mux_sel: in std_logic;
			mux_out: out std_logic
		);
	end component;

	signal aux_0, aux_1, aux_2, aux_3, aux_4, aux_5: std_logic_vector(3 downto 0);
	signal aux_mux_sel_y: std_logic;

begin

	aux_mux_sel_y <= mux_sel_y(1) or not mux_sel_y(0);

	GEN_mux_2x1:
	for I in 0 to 3 generate

		mux_2x1_0: mux_2x1
			port map (dig_2(I), char_punto(I), mux_sel_x(0), aux_0(I));

		mux_2x1_1: mux_2x1
			port map (dig_1(I), dig_0(I), mux_sel_x(0), aux_1(I));

		mux_2x1_2: mux_2x1
			port map (char_V(I), char_vacio(I), mux_sel_x(0), aux_2(I));

		mux_2x1_3: mux_2x1
			port map (aux_0(I), aux_1(I), mux_sel_x(1), aux_3(I));

		mux_2x1_4: mux_2x1
			port map (aux_2(I), char_vacio(I), mux_sel_x(1), aux_4(I));

		mux_2x1_5: mux_2x1
			port map (aux_3(I), aux_4(I), mux_sel_x(2), aux_5(I));

		mux_2x1_6: mux_2x1
			port map (aux_5(I), char_vacio(I), aux_mux_sel_y, mux_out(I));

	end generate;

end architecture;