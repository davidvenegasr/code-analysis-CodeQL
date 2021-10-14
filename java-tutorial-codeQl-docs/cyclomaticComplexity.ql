import java

from Method m, MetricCallable mc
where
  mc = m.getMetrics() and
  mc.getCyclomaticComplexity() > 40
select m
