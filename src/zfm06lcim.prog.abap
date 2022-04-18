***INCLUDE FM06LCIM .

DATA:    BEGIN OF COMMON PART FM06LCIM.

* internal table with real estate objects corresponding to the
* selection criteria
DATA:    T_IMKEYS LIKE VIREKEY OCCURS 0 WITH HEADER LINE.
* flag: real estate selections used
DATA:    X_RESEL LIKE SY-CALLD. "#EC *

DATA:    END OF COMMON PART.
