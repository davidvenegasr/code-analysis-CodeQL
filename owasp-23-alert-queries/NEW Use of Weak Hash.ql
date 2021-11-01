/**
 * @name Use of a broken or risky cryptographic hash
 * @description Using weak hash algorithm can allow an attacker to compromise security.
 * @kind path-problem
 * @problem.severity warning
 * @security-severity 7.5
 * @precision high
 * @id java/weak-hash-algorithm
 * @tags security
 *       external/cwe/cwe-328
 */

import java
import semmle.code.java.security.Encryption
import semmle.code.java.dataflow.TaintTracking
import DataFlow
import PathGraph

private class ShortStringLiteral extends StringLiteral {
  ShortStringLiteral() { getRepresentedString().length() < 100 }
}

class BrokenAlgoLiteral extends ShortStringLiteral {
  BrokenAlgoLiteral() {
    getRepresentedString().regexpMatch(getInsecureHashRegex()) and
    // Exclude German and French sentences.
    not getRepresentedString().regexpMatch(".*\\p{IsLowercase} des \\p{IsLetter}.*")
  }
}

class InsecureHashConfiguration extends TaintTracking::Configuration {
  InsecureHashConfiguration() { this = "BrokenCryptoAlgortihm::InsecureHashConfiguration" }

  override predicate isSource(Node n) { n.asExpr() instanceof BrokenAlgoLiteral }

  override predicate isSink(Node n) { exists(CryptoAlgoSpec c | n.asExpr() = c.getAlgoSpec()) }

  override predicate isSanitizer(DataFlow::Node node) {
    node.getType() instanceof PrimitiveType or node.getType() instanceof BoxedType
  }
}

from
  PathNode source, PathNode sink, CryptoAlgoSpec c, BrokenAlgoLiteral s,
  InsecureHashConfiguration conf
where
  sink.getNode().asExpr() = c.getAlgoSpec() and
  source.getNode().asExpr() = s and
  conf.hasFlowPath(source, sink)
select c, source, sink, "Hash algorithm $@ is weak and should not be used.", s,
  s.getRepresentedString()



  bindingset[algorithmString]
  private string hashRegex(string algorithmString) {
    // Algorithms usually appear in names surrounded by characters that are not
    // alphabetical characters in the same case. This handles the upper and lower
    // case cases.
    result =
      "((^|.*[^A-Z])(" + algorithmString + ")([^A-Z].*|$))" +
        // or...
        "|" +
        // For lowercase, we want to be careful to avoid being confused by camelCase
        // hence we require two preceding uppercase letters to be sure of a case switch,
        // or a preceding non-alphabetic character
        "((^|.*[A-Z]{2}|.*[^a-zA-Z])(" + algorithmString.toLowerCase() + ")([^a-z].*|$))"
  }
  
  /**
   * Gets the name of an algorithm that is known to be insecure.
   */
  string getAnInsecureHashName() {
    result =
      [
        "SHA512"
        // ARCFOUR is a variant of RC4
        //"ARCFOUR",
        // Encryption mode ECB like AES/ECB/NoPadding is vulnerable to replay and other attacks
        //"ECB",
        // CBC mode of operation with PKCS#5 or PKCS#7 padding is vulnerable to padding oracle attacks
        //"AES/CBC/PKCS[57]Padding"
      ]
  }
  
  /**
   * Gets the name of a hash algorithm that is insecure if it is being used for
   * encryption.
   */
  
  private string rankedInsecureHash(int i) {
    // In this case we know these are being used for encryption, so we want to match
    // weak hash algorithms too.
    result =
      rank[i](string s | s = getAnInsecureHashName() or s = getAnInsecureHashAlgorithmName())
  }
  
  private string insecureHashString(int i) {
    i = 1 and result = rankedInsecureHash(i)
    or
    result = rankedInsecureHash(i) + "|" + insecureHashString(i - 1)
  }
  
  /**
   * Gets the regular expression used for matching strings that look like they
   * contain an Hash that is known to be insecure.
   */
  string getInsecureHashRegex() {
    result = hashRegex(insecureHashString(max(int i | exists(rankedInsecureHash(i)))))
}