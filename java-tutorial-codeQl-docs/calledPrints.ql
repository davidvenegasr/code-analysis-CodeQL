import java

from Call c, Method m
where
  m = c.getCallee() and
  m.hasName("println")
select c
