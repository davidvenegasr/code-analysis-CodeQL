import java

predicate isXMLDeserialized(Expr arg) {
  exists(MethodAccess fromXML |
    fromXML.getMethod().getName() = "fromXML" and
    arg = fromXML.getArgument(0)
  )
}

from Expr arg
where isXMLDeserialized(arg)
select arg
