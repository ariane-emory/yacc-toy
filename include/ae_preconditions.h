#pragma once

#if ! (defined(NIL_IS_IMPLICIT) || defined(NIL_IS_AN_INTERNED_SYMBOL) || defined(NIL_IS_AN_UNINTERNED_SYMBOL))
#  error "Define either NIL_IS_IMPLICIT, NIL_IS_AN_INTERNED_SYMBOL, or NIL_IS_AN_UNINTERNED_SYMBOL."
#endif

#ifdef   NIL_IS_IMPLICIT
#  define NIL_DESCRIPTION "NIL_IS_IMPLICIT"
#endif

#ifdef NIL_IS_AN_INTERNED_SYMBOL
#  define NIL_DESCRIPTION "NIL_IS_AN_INTERNED_SYMBOL"
#endif

#ifdef NIL_IS_AN_UNINTERNED_SYMBOL
#  define NIL_DESCRIPTION "NIL_IS_AN_UNINTERNED_SYMBOL"
#endif

// Bookkeeping defines follow.

#if defined(NIL_IS_AN_INTERNED_SYMBOL) || defined(NIL_IS_AN_INTERNED_SYMBOL)
#  define NIL_EXISTS (1)
#else
#  define NIL_EXISTS (0)
#endif
