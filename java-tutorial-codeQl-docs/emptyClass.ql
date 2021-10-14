import java

from IfStmt ifstmt, BlockStmt block
where
  ifstmt.getThen() = block and
  block.getNumStmt() = 0 and
  not exists(ifstmt.getElse())
select ifstmt, "This 'if' statement is redundant."
