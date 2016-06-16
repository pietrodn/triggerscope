## The paper

![](images/title.pdf)\  

# Introduction

## Logic bombs

*Malicious application logic*: the app violates user's reasonable expectations.

**Logic bomb**: malicious application logic that is triggered only under certain (narrow) conditions.

* Malware is designed to target *specific victims, under certain circumstances*.

* Example: a navigation application, supposed to help a soldier in a war zone finding the shortest route to a location, on a given (hardcoded) date gives to him a long route.
    * It does not do anything unusual (other permissions or API call): the navigation application continues to behave like normal.

## Problems with traditional defenses

App Stores employ some defenses, but they are not sufficient.

* **Static analysis**: logic bombs are undetectable because malicious application logic doesn't require additional privileges or make "strange" API calls.
* **Dynamic analysis**: likely won't execute code triggered only on a future date or in a certain location.
    * Even if covered, how to discern malicious behavior from benign?
* **Manual audit** (current solution): if source code is not available, no guarantees.

# TriggerScope

## Fundamental principle

TriggerScope detects logic bombs by analyzing and characterizing the **checks** that guard a given behavior, and not the behavior itself.

## Trigger analysis

* **Predicate**: logic formula used in conditional statement.
    * `(A or B) and C`
    * **Suspicious predicate**: a predicate satisfied only under very specific, narrow conditions.
* **Functionality**: a set of basic blocks in a program.
    * **Sensitive functionality**: a functionality performing, directly or indirectly a sensitive operation.
    * All calls to Android APIs protected by permissions, and operations involving the filesystem.
* **Trigger**: suspicious predicate controlling the execution of a sensitive functionality.

## Analysis overview (1)

1. **Static analysis** of bytecode; Control Flow Graph.
2. **Symbolic Values Modeling** for integer, string, time, location and SMS-based objects.
3. **Expression Trees** are appended to each symbolic object referenced in a check.
    * Reconstruction of the *semantics* of the check, often lost in bytecode.

![Example of expression tree.](images/expression-tree.pdf)

## Analysis overview (2)

4. **Block Predicate Extraction**: edges of Control Flow Graph are annotated with simple predicates.
    * Simple predicate: P in `if P then X else Y`
5. **Path Predicate Recovery and Minimization**
    * Simple predicates are combined to get the *full path predicate* that reaches each basic block.
    * Minimization: elimination of redundant terms in predicates
        * important to reduce false dependencies

## Path Predicate Recovery and Minimization

![Path Predicate Reconstruction](images/path-predicate-reconstruction-exp.pdf){height=75%}

## Analysis overview (3)

6. **Predicate Classification**: a check is **suspicious** if it's equivalent to:
    * Comparison between current *time* value and constant
    * Bounds check on *location*
    * Hard-coded patterns on body or sender of *SMS*
7. **Control-Dependency Analysis**: control dependency between *suspicious predicates* and *sensitive functionalities*.
    * sensitive = privileged Android APIs + fileystem op.
    * **Suspiciousness propagates** with data flows and callbacks
    * Problem: data flows through files
        * When in doubt: suspicious!

# Evaluation

## Data sets

* **Benign applications**: 9582 apps from Google Play Store
    * They all use time-, location- or SMS-related APIs
* **Malign applications**: 14 apps from several sources
    * Stealthy malware developed for previous researches
    * Real-world malware samples
    * HackingTeam RCSAndroid

## Results (1)

\begin{table}[h]
\begin{center}
\begin{tabular}{| l | c | c | c | c | c | c |}
\hline
\textbf{Analysis step} & \textbf{TP} & \textbf{FP} & \textbf{TN} & \textbf{FN} & \textbf{FPR} & \textbf{FNR} \\
\hline
Predicate detection & 14 & 1386 & 7927 & 0 & 14.88\% & 0\% \\
\hline
Suspicious Predicate A. & 14 & 462 & 8851 & 0 & 4.96\% & 0\% \\
\hline
Control-Dependency A. & 14 & 117 & 9196 & 0 & 1.26\% & 0\% \\
\hline
TriggerScope (all) & 14 & 35 & 9278 & 0 & 0.38\% & 0\% \\
\hline
\end{tabular}
\caption{Results of analysis after each step. Note how each step is useful to refine the analysis. \newline $FPR = \frac{FP}{FP+TN}$, $FNR = \frac{FN}{FN+TP}$}
\end{center}
\end{table}

## Results (2)

![Each step of analysis is useful, because it reduces the false positive rate (FPR).](images/fp-chart.pdf)

# Critique

# Related and future work

## Related work


## Future evolutions


## References
