(*  Title:	HOL/Integ/Bin.thy
    Authors:	Lawrence C Paulson, Cambridge University Computer Laboratory
		David Spelt, University of Twente 
    Copyright	1994  University of Cambridge
    Copyright   1996 University of Twente

Arithmetic on binary integers.

   The sign Pls stands for an infinite string of leading F's.
   The sign Min stands for an infinite string of leading T's.

A number can have multiple representations, namely leading F's with sign
Pls and leading T's with sign Min.  See ZF/ex/twos-compl.ML/int_of_binary
for the numerical interpretation.

The representation expects that (m mod 2) is 0 or 1, even if m is negative;
For instance, ~5 div 2 = ~3 and ~5 mod 2 = 1; thus ~5 = (~3)*2 + 1

Division is not defined yet!  To do it efficiently requires computing the
quotient and remainder using ML and checking the answer using multiplication
by proof.  Then uniqueness of the quotient and remainder yields theorems
quoting the previously computed values.  (Or code an oracle...)
*)

Bin = Integ + Datatype +

syntax
  "_Int"           :: xnum => int        ("_")

datatype
    bin = Pls
        | Min
        | BIT bin bool	(infixl 90)

consts
  integ_of         :: bin=>int
  NCons            :: [bin,bool]=>bin
  bin_succ         :: bin=>bin
  bin_pred         :: bin=>bin
  bin_minus        :: bin=>bin
  bin_add,bin_mult :: [bin,bin]=>bin
  h_bin            :: [bin,bool,bin]=>bin

(*NCons inserts a bit, suppressing leading 0s and 1s*)
primrec
  norm_Pls "NCons Pls b = (if b then (Pls BIT b) else Pls)"
  norm_Min "NCons Min b = (if b then Min else (Min BIT b))"
  NCons    "NCons (w' BIT x') b = (w' BIT x') BIT b"
 
primrec
  integ_of_Pls  "integ_of Pls = $# 0"
  integ_of_Min  "integ_of Min = - ($# 1)"
  integ_of_BIT  "integ_of(w BIT x) = (if x then $# 1 else $# 0) +
	                             (integ_of w) + (integ_of w)" 

primrec
  succ_Pls  "bin_succ Pls = Pls BIT True" 
  succ_Min  "bin_succ Min = Pls"
  succ_BIT  "bin_succ(w BIT x) =
  	        (if x then bin_succ w BIT False
	              else NCons w True)"

primrec
  pred_Pls  "bin_pred Pls = Min"
  pred_Min  "bin_pred Min = Min BIT False"
  pred_BIT  "bin_pred(w BIT x) =
	        (if x then NCons w False
		      else (bin_pred w) BIT True)"
 
primrec
  minus_Pls  "bin_minus Pls = Pls"
  minus_Min  "bin_minus Min = Pls BIT True"
  minus_BIT  "bin_minus(w BIT x) =
	         (if x then bin_pred (NCons (bin_minus w) False)
		       else bin_minus w BIT False)"

primrec
  add_Pls  "bin_add Pls w = w"
  add_Min  "bin_add Min w = bin_pred w"
  add_BIT  "bin_add (v BIT x) w = h_bin v x w"

primrec
  "h_bin v x Pls = v BIT x"
  "h_bin v x Min = bin_pred (v BIT x)"
  "h_bin v x (w BIT y) =
	     NCons (bin_add v (if (x & y) then bin_succ w else w))
	           (x~=y)" 

primrec
  mult_Pls  "bin_mult Pls w = Pls"
  mult_Min  "bin_mult Min w = bin_minus w"
  mult_BIT "bin_mult (v BIT x) w =
	        (if x then (bin_add (NCons (bin_mult v w) False) w)
	              else (NCons (bin_mult v w) False))"


end

ML

(** Concrete syntax for integers **)

local
  open Syntax;

  (* Bits *)

  fun mk_bit 0 = const "False"
    | mk_bit 1 = const "True"
    | mk_bit _ = sys_error "mk_bit";

  fun dest_bit (Const ("False", _)) = 0
    | dest_bit (Const ("True", _)) = 1
    | dest_bit _ = raise Match;


  (* Bit strings *)   (*we try to handle superfluous leading digits nicely*)

  fun prefix_len _ [] = 0
    | prefix_len pred (x :: xs) =
        if pred x then 1 + prefix_len pred xs else 0;

  fun mk_bin str =
    let
      val (sign, digs) =
        (case Symbol.explode str of
          "#" :: "-" :: cs => (~1, cs)
        | "#" :: cs => (1, cs)
        | _ => raise ERROR);

      fun bin_of 0  = []
        | bin_of ~1 = [~1]
        | bin_of n  = (n mod 2) :: bin_of (n div 2);

      fun term_of []   = const "Bin.bin.Pls"
        | term_of [~1] = const "Bin.bin.Min"
        | term_of (b :: bs) = const "Bin.bin.op BIT" $ term_of bs $ mk_bit b;
    in
      term_of (bin_of (sign * (#1 (read_int digs))))
    end;

  fun dest_bin tm =
    let
      fun bin_of (Const ("Pls", _)) = []
        | bin_of (Const ("Min", _)) = [~1]
        | bin_of (Const ("op BIT", _) $ bs $ b) = dest_bit b :: bin_of bs
        | bin_of _ = raise Match;

      fun int_of [] = 0
        | int_of (b :: bs) = b + 2 * int_of bs;

      val rev_digs = bin_of tm;
      val (sign, zs) =
        (case rev rev_digs of
          ~1 :: bs => ("-", prefix_len (equal 1) bs)
        | bs => ("", prefix_len (equal 0) bs));
      val num = string_of_int (abs (int_of rev_digs));
    in
      "#" ^ sign ^ implode (replicate zs "0") ^ num
    end;


  (* translation of integer constant tokens to and from binary *)

  fun int_tr (*"_Int"*) [t as Free (str, _)] =
        (const "integ_of" $
          (mk_bin str handle ERROR => raise TERM ("int_tr", [t])))
    | int_tr (*"_Int"*) ts = raise TERM ("int_tr", ts);

  fun int_tr' (*"integ_of"*) [t] = const "_Int" $ free (dest_bin t)
    | int_tr' (*"integ_of"*) _ = raise Match;
in
  val parse_translation = [("_Int", int_tr)];
  val print_translation = [("integ_of", int_tr')]; 
end;
