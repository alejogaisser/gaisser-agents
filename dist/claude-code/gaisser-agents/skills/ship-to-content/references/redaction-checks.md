# Redaction checks

Shipped work comes from a repository, and a repository holds more than the user wants to publish. Apply these checks when you extract what shipped, when you write `ship.md`, when QA runs check 4, and in the leak scan. Each category says what to do: remove it, ask the user, or allow it only with approval.

## Rules

- Raw material stays out of the run folder: the diff, the code, command output, and the original text of the PR or the changelog are read in the conversation and never saved. Only `ship.md` is written, after the checks.
- The redaction log in `ship.md` records the category, the count, and the location of each removal or question, never the value.
- Unknown repository visibility is treated as private.
- When unsure whether something is safe to publish, ask.

## Categories

### R1. Secrets and credentials
API keys, tokens, passwords, private key blocks, connection strings with passwords, and values from `.env` files. Always remove them. If one appears in the shipped history, never quote it; tell the user in the final report to rotate it.

### R2. Internal infrastructure
Hostnames, IP addresses, internal URLs, bucket names, ports, cluster and account identifiers. Remove them, or replace them with a generic word such as "the database".

### R3. Personal data
Emails, and names or handles of people other than the user, including co-authors and reviewers. Ask the user, and keep the name out until they answer.

### R4. Customers, partners, and unreleased names
Names of customers, partners, vendors under contract, and unreleased products or features. Ask the user.

### R5. Private code
Never publish code from a private repository. From a public repository, include only a snippet the user approved at the Ship gate.

### R6. Paths and internal identifiers
Absolute file paths and machine or user names are always removed. Repository-relative paths and ticket identifiers are allowed only for a public repository.

### R7. Security fixes
No exploit detail, no affected versions, and no wording that shows how to attack before the fix is disclosed. Ask the user.

### R8. Confidential numbers
Revenue, user counts, costs, and other business figures. Ask the user. Numbers that came from the shipped work itself, such as test counts or file counts, are evidence and stay.

## Leak scan

Run it after QA and before the review gate. With the shell, search every text file in the run folder, the alt text in `copy.md`, the sources in `code/`, and the file names in `out/`, for:

- every value you removed or the user declined to publish, which you keep only in your working memory and never write down;
- the R1 patterns: key-like prefixes, long random strings, `BEGIN` lines of private key blocks, `password=`, and `token=`.

Report each hit by file and category, never the value. A hit fails the run, goes to the role that owns the file, and counts as a fix cycle.
