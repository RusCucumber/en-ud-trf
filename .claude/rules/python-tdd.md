---
paths:
  - "src/**/*.py"
  - "tests/**/*.py"
  - "scripts/**/*.py"
---

# Python Test-Driven Development (TDD) Rule

Python scripts and modules in this project must be implemented using **Test-Driven Development (TDD)**.

## Core Cycle: Red → Green → Refactor

1. **Red** — Write failing tests first (no implementation yet)
2. **Green** — Write minimal implementation to pass the tests
3. **Refactor** — Improve code clarity and structure (tests remain green)

TDD only begins when tests are written before implementation code.

## Test Organization

- Tests are mirrored under `tests/` with the same structure as `src/`
- File naming: `test_<module_name>.py`
- Function naming: `test_<what_to_test>_<conditions>_<expected_result>()`

## Test Perspective Design (QA Techniques)

Before AI implements code, **humans must define test perspectives**. Enumerate test cases from these viewpoints before coding:

| Technique | Purpose | When to Apply |
|-----------|---------|---------------|
| **Equivalence Partitioning** | Group similar inputs; reduce redundant test cases | When input ranges or types exist |
| **Boundary Value Analysis** | Target edge cases like off-by-one or threshold violations | Numeric ranges, list/string lengths |
| **Decision Table** | Prevent missing combinations of multiple conditions | When if/elif branches intersect |
| **State Transition Testing** | Comprehensively cover status changes | State management, workflows |
| **Error Guessing** | Use domain knowledge to identify realistic failure patterns | Past bugs, external input, type coercion |
| **Checklist-Based Testing** | Ensure quality consistency across repeated execution | Data pipelines, transformations |

## Implementation Workflow

1. When receiving a task, first enumerate test perspectives and present them to the user
2. Obtain user confirmation/feedback, then write test code (no implementation yet)
3. Run `uv run pytest -q` to confirm tests are **Red**
4. Write minimal implementation to pass tests
5. Run `uv run pytest -q` to confirm tests are **Green**
6. Refactor as needed while keeping tests **Green**

For other pytest commands (single file, keyword matching, test deps), see the `pytest-in-uv` skill.

## Important Notes

- Writing tests after implementation is **not** TDD. Tests must come first
- Always cover error cases, boundary values, and exception paths—not just the happy path
- AI tends to focus on safe cases without explicit guidance, so humans must lead test perspective definition
- When tests break due to code changes, verify that the test assumptions have changed before modifying the implementation
