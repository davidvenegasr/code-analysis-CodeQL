https://codeql.github.com/docs/codeql-overview/about-codeql/

### About variant analysis  

Variant analysis is the process of using a known security vulnerability as a seed to find similar problems in your code. It’s a technique that security engineers use to identify potential vulnerabilities, and ensure these threats are properly fixed across multiple codebases.  

Querying code using CodeQL is the most efficient way to perform variant analysis. You can use the standard CodeQL queries to identify seed vulnerabilities, or find new vulnerabilities by writing your own custom CodeQL queries. Then, develop or iterate over the query to automatically find logical variants of the same bug that could be missed using traditional manual techniques.  


### CodeQL analysis  
CodeQL analysis consists of three steps:  
 
- Preparing the code, by creating a CodeQL database  
- Running CodeQL queries against the database  
- Interpreting the query results    

### Types of queries 

- Alert queries: queries that highlight issues in specific locations in your code.
- Path queries: queries that describe the flow of information between a source and a sink in your code.

https://codeql.github.com/docs/writing-codeql-queries/about-codeql-queries/

### Structure
```
/**
 *
 * Query metadata
 *
 */

import /* ... CodeQL libraries or modules ... */

/* ... Optional, define CodeQL classes and predicates ... */

from /* ... variable declarations ... */
where /* ... logical formula ... */
select /* ... expressions ... */
```