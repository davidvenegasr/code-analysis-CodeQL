// /**
//  * @kind path-problem
//  */
import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.FlowSteps
import semmle.code.java.dataflow.TaintTracking

class PrintlCall extends Call {
  PrintlCall() { this.getCallee().getName().matches("println") }
}

class CommandCall extends Call {
  CommandCall() { this.getCallee().getName().matches("command") }
}

class ExternalCallArgumentStep extends TaintTracking::AdditionalTaintStep {
  override predicate step(DataFlow::Node a, DataFlow::Node b) {
    exists(Call c |
      a.asExpr() = c.getAnArgument() and
      b.asExpr() = c and
      not exists(c.getCallee().getBody())
    )
  }
}

// This finds calls with no body (presumably external)
// from Call c
// where not exists(c.getCallee().getBody()) and c.getCaller().getLocation().getFile().getBaseName() = "BenchmarkTest00001.java"
// select c
class JsConfig extends TaintTracking::Configuration {
  JsConfig() { this = "JsConfig" }

  override predicate isSource(DataFlow::Node source) {
    source instanceof RemoteFlowSource and
    source.getLocation().getFile().getBaseName() = "BenchmarkTest00001.java"
  }

  override predicate isSink(DataFlow::Node sink) {
    sink.getLocation().getFile().getBaseName() = "BenchmarkTest00001.java" and
    sink.asExpr() = any(PrintlCall api).getAnArgument() and
    sink.getType() instanceof TypeString
  }
}

from DataFlow::Node source, DataFlow::Node sink
where any(JsConfig conf).hasFlow(source, sink)
select source, sink
