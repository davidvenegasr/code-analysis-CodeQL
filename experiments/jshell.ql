


/**
 * @name JShell injection
 * @description Evaluation of a user-controlled JShell expression
 *              may lead to arbitrary code execution.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @id java/jshell-injection
 * @tags security
 *       external/cwe-094
 */

import java
import semmle.code.java.dataflow.FlowSources

/** A sink for JShell expression injection vulnerabilities. */
class JShellInjectionSink extends DataFlow::Node {
  JShellInjectionSink() {
    this.asExpr() = any(JShellEvalCall jsec).getArgument(0)
    or
    this.asExpr() = any(SourceCodeAnalysisWrappersCall scawc).getArgument(0)
  }
}


/** A call to `JShell.eval`. */
private class JShellEvalCall extends MethodAccess {
  JShellEvalCall() {
    this.getMethod().hasName("eval") and
    this.getMethod().getDeclaringType().hasQualifiedName("jdk.jshell", "JShell") and
    this.getMethod().getNumberOfParameters() = 1
  }
}

/** A call to `SourceCodeAnalysis.wrappers`. */
private class SourceCodeAnalysisWrappersCall extends MethodAccess {
  SourceCodeAnalysisWrappersCall() {
    this.getMethod().hasName("wrappers") and
    this.getMethod().getDeclaringType().hasQualifiedName("jdk.jshell", "SourceCodeAnalysis") and
    this.getMethod().getNumberOfParameters() = 1
  }
}

/** A call to `SourceCodeAnalysis.analyzeCompletion`. */
class SourceCodeAnalysisAnalyzeCompletionCall extends MethodAccess {
  SourceCodeAnalysisAnalyzeCompletionCall() {
    this.getMethod().hasName("analyzeCompletion") and
    this.getMethod()
        .getDeclaringType()
        .getASupertype*()
        .hasQualifiedName("jdk.jshell", "SourceCodeAnalysis") and
    this.getMethod().getNumberOfParameters() = 1
  }
}

/** A call to `CompletionInfo.source` or `CompletionInfo.remaining`. */
class CompletionInfoSourceOrRemainingCall extends MethodAccess {
  CompletionInfoSourceOrRemainingCall() {
    this.getMethod().getName() in ["source", "remaining"] and
    this.getMethod()
        .getDeclaringType()
        .getASupertype*()
        .hasQualifiedName("jdk.jshell", "SourceCodeAnalysis$CompletionInfo") and
    this.getMethod().getNumberOfParameters() = 0
  }
}

import semmle.code.java.dataflow.FlowSources
import DataFlow::PathGraph

class JShellInjectionConfiguration extends TaintTracking::Configuration {
  JShellInjectionConfiguration() { this = "JShellInjectionConfiguration" }

  override predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  override predicate isSink(DataFlow::Node sink) { sink instanceof JShellInjectionSink }

  override predicate isAdditionalTaintStep(DataFlow::Node prod, DataFlow::Node succ) {
    exists(MethodAccess ma |
      ma.getMethod().hasName("analyzeCompletion") and
      ma.getMethod().getNumberOfParameters() = 1 and
      ma.getMethod()
          .getDeclaringType()
          .getASupertype*()
          .hasQualifiedName("jdk.jshell", "SourceCodeAnalysis") and
      ma.getArgument(0) = prod.asExpr() and
      ma = succ.asExpr()
    )
  }
}

from DataFlow::PathNode source, DataFlow::PathNode sink, JShellInjectionConfiguration conf
where conf.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "JShell injection from $@.", source.getNode(),
  "this user input"