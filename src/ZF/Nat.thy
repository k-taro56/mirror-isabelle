(*  Title: 	ZF/nat.thy
    ID:         $Id$
    Author: 	Lawrence C Paulson, Cambridge University Computer Laboratory
    Copyright   1992  University of Cambridge

Natural numbers in Zermelo-Fraenkel Set Theory 
*)

Nat = Ord + Bool + 
consts
    nat 	::      "i"
    nat_case    ::      "[i, i, i=>i]=>i"
    nat_rec     ::      "[i, i, [i,i]=>i]=>i"

rules

    nat_def     "nat == lfp(Inf, %X. {0} Un {succ(i). i:X})"

    nat_case_def
	"nat_case(k,a,b) == THE y. k=0 & y=a | (EX x. k=succ(x) & y=b(x))"

    nat_rec_def
	"nat_rec(k,a,b) ==   \
\   	  wfrec(Memrel(nat), k, %n f. nat_case(n, a, %m. b(m, f`m)))"

end
