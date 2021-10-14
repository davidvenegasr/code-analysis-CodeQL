// /**
//  * @kind path-problem
//  */
import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.FlowSteps
import semmle.code.java.dataflow.TaintTracking
import semmle.code.java.security.PathCreation

class TestConfig extends TaintTracking::Configuration {
  TestConfig() { this = " TestConfig" }

  override predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  override predicate isSink(DataFlow::Node sink) {
    exists(Expr e | e = sink.asExpr() |
      e = any(PathCreation p).getAnInput() and
      sink.getLocation().getFile().getBaseName() = "BenchmarkTest00001.java"
    )
  }
}

from DataFlow::Node source, DataFlow::Node sink, TestConfig conf
where conf.hasFlow(source, sink)
select source, sink
