import java

from TypeVariable tv, TypeBound tb
where
  tb = tv.getATypeBound() and
  tb.getType().hasQualifiedName("java.lang", "Number")
select tv
