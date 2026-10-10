# Coding standards

## Readability first

Prefer readable, explicit code to compact or clever code. Use focused modules with one job each, and choose descriptive names such as completedObjectives and totalObjectives. Keep nesting shallow with early returns.

## Style

- Four spaces per indent; LF line endings; UTF-8 text; final newline.
- PascalCase for named module functions (CalculatePercentage), camelCase for local variables, and UPPER_SNAKE_CASE for true constants.
- Do not create globals except the WoW-required slash-command registrations and explicitly declared saved variables.
- Avoid magic numbers: explain their meaning or use a named constant.
- Include a purpose comment at the top of each Lua module.
- Document public functions with @param and @return, plus non-obvious constraints.
- Comments should explain *why*, not restate *what* the code already says.

## Architecture

- Bootstrapping, events, UI, domain logic, and persistence belong in separate modules when each actually exists.
- Source order is declared in the TOC. Do not assume ordinary Lua require is available in WoW.
- Communicate through the addon namespace supplied as the second value of ....
- Pure calculations must not call WoW APIs, which makes them testable outside the game.
- Avoid adding abstractions or folders for functionality that does not exist yet.

## Robustness

- Validate inputs at public module boundaries.
- Handle zero totals and unavailable API data without crashing.
- Be careful with secret values in modern WoW APIs; do not compare, format, or branch on potentially secret data without verification.
- Do not silently swallow errors without a user-visible or documented reason.
- Never bypass secure execution restrictions or implement combat/gameplay automation.

## Change hygiene

- Keep commits focused.
- Accompany behavior changes with appropriate tests, game-test steps, and documentation.
- Do not merge copied third-party code without checking licenses.
- Preserve backwards compatibility of user settings unless migration is deliberate and documented.

## Example

~~~lua
--- Returns a completion percentage rounded to two decimal places.
--- Returns zero when the total is zero or the inputs are invalid.
---
--- @param completed number Count of completed objectives.
--- @param total number Count of all available objectives.
--- @return number percentage Completion percentage in [0, 100].
function Progress.CalculatePercentage(completed, total)
    if type(completed) ~= "number" or type(total) ~= "number" or total <= 0 then
        return 0
    end

    local bounded = math.max(0, math.min(completed, total))
    return math.floor((bounded / total) * 10000 + 0.5) / 100
end
~~~
