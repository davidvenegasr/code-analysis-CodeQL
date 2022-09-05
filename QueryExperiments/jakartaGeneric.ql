/**
 * @name Jakarta Expression Language injection
 * @description Evaluation of a user-controlled expression
 *              may lead to arbitrary code execution.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @id java/javaee-expression-injection
 * @tags security
 *       external/cwe/cwe-094
 */

import java

import java
import semmle.code.java.dataflow.FlowSources
import semmle.code.java.dataflow.TaintTracking

/**
 * A taint-tracking configuration for unsafe user input
 * that is used to construct and evaluate an expression.
 */
class JakartaExpressionInjectionConfig extends TaintTracking::Configuration {
  JakartaExpressionInjectionConfig() { this = "JakartaExpressionInjectionConfig" }

  override predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  override predicate isSink(DataFlow::Node sink) { sink instanceof ExpressionEvaluationSink }

  override predicate isAdditionalTaintStep(DataFlow::Node fromNode, DataFlow::Node toNode) {
   exists(Call c |
      fromNode.asExpr() = c.getAnArgument() and
      toNode.asExpr() = c and
      not exists(c.getCallee().getBody())
    )
  }
}

/**
 * A sink for Expresssion Language injection vulnerabilities,
 * i.e. method calls that run evaluation of an expression.
 */
private class ExpressionEvaluationSink extends DataFlow::ExprNode {
  ExpressionEvaluationSink() {
    exists(MethodAccess ma, Method m, Expr taintFrom |
      ma.getMethod() = m and taintFrom = this.asExpr()
    |
      m.getDeclaringType() instanceof ValueExpression and
      m.hasName(["getValue", "setValue"]) and
      ma.getQualifier() = taintFrom
      or
      m.getDeclaringType() instanceof MethodExpression and
      m.hasName("invoke") and
      ma.getQualifier() = taintFrom
      or
      m.getDeclaringType() instanceof LambdaExpression and
      m.hasName("invoke") and
      ma.getQualifier() = taintFrom
      or
      m.getDeclaringType() instanceof ELProcessor and
      m.hasName(["eval", "getValue", "setValue"]) and
      ma.getArgument(0) = taintFrom
      or
      m.getDeclaringType() instanceof ELProcessor and
      m.hasName("setVariable") and
      ma.getArgument(1) = taintFrom
    )
  }
}

/**
 * Defines method calls that propagate tainted expressions.
 */
private class TaintPropagatingCall extends Call {
  Expr taintFromExpr;

  TaintPropagatingCall() {
    taintFromExpr = this.getArgument(1) and
    (
      exists(Method m | this.(MethodAccess).getMethod() = m |
        m.getDeclaringType() instanceof ExpressionFactory and
        m.hasName(["createValueExpression", "createMethodExpression"]) and
        taintFromExpr.getType() instanceof TypeString
      )
      or
      exists(Constructor c | this.(ConstructorCall).getConstructor() = c |
        c.getDeclaringType() instanceof LambdaExpression and
        taintFromExpr.getType() instanceof ValueExpression
      )
    )
  }

  /**
   * Holds if `fromNode` to `toNode` is a dataflow step that propagates
   * tainted data.
   */
  predicate taintFlow(DataFlow::Node fromNode, DataFlow::Node toNode) {
    fromNode.asExpr() = taintFromExpr and toNode.asExpr() = this
  }
}

private class JakartaType extends RefType {
  JakartaType() { getPackage().hasName(["javax.el", "jakarta.el"]) }
}

private class ELProcessor extends JakartaType {
  ELProcessor() { hasName("ELProcessor") }
}

private class ExpressionFactory extends JakartaType {
  ExpressionFactory() { hasName("ExpressionFactory") }
}

private class ValueExpression extends JakartaType {
  ValueExpression() { hasName("ValueExpression") }
}

private class MethodExpression extends JakartaType {
  MethodExpression() { hasName("MethodExpression") }
}

private class LambdaExpression extends JakartaType {
  LambdaExpression() { hasName("LambdaExpression") }
}


import DataFlow::PathGraph

from DataFlow::PathNode source, DataFlow::PathNode sink, JakartaExpressionInjectionConfig conf
where conf.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Jakarta Expression Language injection from $@.",
  source.getNode(), "this user input"  
