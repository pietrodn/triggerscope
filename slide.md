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

## Strengths

1. TriggerScope provides **rich semantics** that help manual analysis, by reconstructing full predicate conditions.
1. Novel approach: **focus on checks**, not malicious behaviors.
1. **Fewer FPs, FNs** than other tools.

## Issues: limits of analysis

* Definition of **suspicious predicate** is too narrow
    * Only checks against hardcoded values
    * Several implementations could be proposed
* Authors claim **0\% FNs**, but the evaluation isn't conclusive
    * *we manually inspected a random subset of 20 applications for which our analysis did not identify any suspicious check. We spent about 10 minutes per application, and we did not find any false negatives.*
    * Difficult to assess FNs if no tool finds anything and source code is unavailable

## Issues: evasion techniques

* *Reflection*, *dynamic code loading*, *polymorphism* and *conditional code obfuscation* \cite{Sharif08} can defeat static analysis.
    * Authors say that these techniques are themselves suspicious, but they also have legitimate uses
* Predicate minimization is **NP-complete**
    * Is it possible to design "pathological" code to slow down and defeat analysis?
    * Or result in very complex, meaningless predicates?
* **Exceptions** were not cited as control flow subversion method
    * *Statically reasoning in the presence of exceptions and about the effects of exceptions is challenging* \cite{Liang14}
    * Unclear how the static analysis engine handles exceptions
    * Unchecked exceptions (e.g. division by zero) could be exploited as stealthy triggers

# Related and future work

## Related work: static analysis

**AppContext** \cite{Yang15}: supervised machine learning method to classify malicious behavior statically.

1. Starts identifying suspicious actions
1. Context: which category of input controls the execution of those actions?

Similar idea: just looking at the action isn't enough. Differences:

* AppContext only does **classification** of checks as suspicious or not
* TriggerScope also provides **semantics* about the predicates, helping manual inspection
* AppContext considers *any* check that uses certain inputs
* AppContext's set of suspicious behaviors is narrower than TriggerScope's
* Expanding the set of AppContext's suspicious behaviors would result in a higher FP rate

## Related work: dynamic analysis

Several **dynamic analyzers** are currently employed to detect malware in Android apps (e.g. Google's Bouncer).

* Logic bombs are known to be resistant to dynamic analysis
* Dynamic analysis can be detected (artifacts!) and **evaded**
* Even if a logic bomb is triggered, how to classify it as malicious?
    * **No semantics** about the checks!
* Code coverage should be very high
    * Static analyzers are not affected by this issue

## Future evolutions

* **Extend trigger analysis** not only to time, location, SMSs
    * The trigger could come e.g. from the network
    * The framework is easily extensible to other types of triggers with more work
    * Is there a **general approach**?

## References
