(*  Title:      HOL/Modelcheck/MuckeSyn.thy
    ID:         $Id$
    Author:     Tobias Hamberger
    Copyright   1999  TU Muenchen
*)

theory MuckeSyn
imports MuCalculus
uses "mucke_oracle.ML"
begin

(* extended with some operators and case treatment (which requires postprocessing with
transform_case (from MuCalculus) (TH) *)

nonterminals
  mutype
  decl decls
  cases_syn case_syn

syntax (Mucke output)
  True          :: bool                                 ("true")
  False         :: bool                                 ("false")
  Not           :: "bool => bool"                       ("! _" [40] 40)
  If            :: "[bool, 'a, 'a] => 'a"       ("('(if'((_)')/ '((_)')/ else/ '((_)'))')" 10)

  "op &"        :: "[bool, bool] => bool"               (infixr "&" 35)
  "op |"        :: "[bool, bool] => bool"               (infixr "|" 30)
  "op -->"      :: "[bool, bool] => bool"               (infixr "->" 25)
  "op ="        :: "['a, 'a] => bool"                   ("(_ =/ _)" [51, 51] 50)
  "_not_equal"  :: "['a, 'a] => bool"                   ("(_ !=/ _)" [51, 51] 50)

  All_binder    :: "[idts, bool] => bool"               ("'((3forall _./ _)')" [0, 10] 10)
  Ex_binder     :: "[idts, bool] => bool"               ("'((3exists _./ _)')" [0, 10] 10)

  "_lambda"     :: "[idts, 'a] => 'b"                   ("(3L _./ _)" 10)
  "_applC"      :: "[('b => 'a), cargs] => aprop"       ("(1_/ '(_'))" [1000,1000] 999)
  "_cargs"      :: "['a, cargs] => cargs"               ("_,/ _" [1000,1000] 1000)

  "_idts"       :: "[idt, idts] => idts"                ("_,/ _" [1, 0] 0)

  "_tuple"      :: "'a => tuple_args => 'a * 'b"        ("(1_,/ _)")
(* "@pttrn"     :: "[pttrn, pttrns] => pttrn"           ("_,/ _" [1, 0] 0)
  "_pattern"    :: "[pttrn, patterns] => pttrn"         ("_,/ _" [1, 0] 0) *)

  "_decl"       :: "[mutype,pttrn] => decl"             ("_ _")
  "_decls"      :: "[decl,decls] => decls"              ("_,/ _")
  ""            :: "decl => decls"                      ("_")
  "_mu"         :: "[decl,decls,'a pred] => 'a pred"    ("mu _ '(_') _ ;")
  "_mudec"      :: "[decl,decls] => 'a pred"            ("mu _ '(_') ;")
  "_nu"         :: "[decl,decls,'a pred] => 'a pred"    ("nu _ '(_') _ ;")
  "_nudec"      :: "[decl,decls] => 'a pred"            ("nu _ '(_') ;")
  "_fun"        :: "[decl,decls,'a pred] => 'a pred"    ("_ '(_') _ ;")
  "_dec"        :: "[decl,decls] => 'a pred"            ("_ '(_') ;")

  "_Ex"         :: "[decl,idts,'a pred] => 'a pred"     ("'((3exists _ _./ _)')")
  "_All"        :: "[decl,idts,'a pred] => 'a pred"     ("'((3forall _ _./ _)')")

  "Mu "         :: "[idts, 'a pred] => 'a pred"         ("(3mu _./ _)" 1000)
  "Nu "         :: "[idts, 'a pred] => 'a pred"         ("(3nu _./ _)" 1000)

  "_case_syntax":: "['a, cases_syn] => 'b"              ("(case*_* / _ / esac*)" 10)
  "_case1"      :: "['a, 'b] => case_syn"               ("(2*= _ :/ _;)" 10)
  ""            :: "case_syn => cases_syn"              ("_")
  "_case2"      :: "[case_syn, cases_syn] => cases_syn" ("_/ _")

(*Terms containing a case statement must be post-processed with the
  ML function transform_case. There, all asterikses before the "="
  will be replaced by the expression between the two asterisks
  following "case" and the asterisk after esac will be deleted *)

oracle mc_mucke_oracle ("term") =
  mk_mc_mucke_oracle

end


