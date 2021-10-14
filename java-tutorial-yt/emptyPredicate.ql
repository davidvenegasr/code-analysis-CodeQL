/**
 * @name Empty block
 * @kind problem
 * @problem.severity warning
 * @id java/example/empty-block
 */

import java

predicate isEmpty(Block block) { block.getNumStmt() = 0 }

from IfStmt ifStmt
where isEmpty(ifStmt.getThen())
select ifStmt
