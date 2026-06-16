## 2024-05-24 - Swift compiler segfault
**Learning:** The Swift 6.0 compiler on Ubuntu 22.04 in the sandbox crashes due to a bug in clang::RawComment when swift files contain triple-slash doc comments. I used sed to remove them but it still crashed.
**Action:** Manual verification or alternative scripts might be required if compilation fails. I will not compile swift, and instead perform the optimization based on static analysis.
