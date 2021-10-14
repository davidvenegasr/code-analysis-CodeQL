/**
 * @name Empty block
 * @kind problem
 * @problem.severity warning
 * @id java/example/empty-block
 */

import java

class EmptyBlock extends BlockStmt {
  EmptyBlock() { this.getNumStmt() = 0 }
}

from IfStmt ifStmt
where ifStmt.getThen() instanceof EmptyBlock
select ifStmt
