theory HyperArith = HyperBin
files "hypreal_arith.ML":

setup hypreal_arith_setup

text{*Used once in NSA*}
lemma hypreal_add_minus_eq_minus: "x + y = (0::hypreal) ==> x = -y"
apply arith
done

ML
{*
val hypreal_add_minus_eq_minus = thm "hypreal_add_minus_eq_minus";
*}

subsubsection{*Division By @{term 1} and @{term "-1"}*}

lemma hypreal_divide_minus1 [simp]: "x/-1 = -(x::hypreal)"
by simp

lemma hypreal_minus1_divide [simp]: "-1/(x::hypreal) = - (1/x)"
by (simp add: hypreal_divide_def hypreal_minus_inverse)


(*
FIXME: we should have this, as for type int, but many proofs would break.
It replaces x+-y by x-y.
Addsimps [symmetric hypreal_diff_def]
*)

end
