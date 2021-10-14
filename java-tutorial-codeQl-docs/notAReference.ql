import java

from Callable c
where not exists(c.getAReference())
select c
