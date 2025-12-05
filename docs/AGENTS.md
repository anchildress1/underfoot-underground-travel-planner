# Documentation Instructions for AI Agents

## Purpose

This directory contains project documentation organized by type:

- `architecture/` — ADRs and architectural diagrams
- `planning/` — Project plans, migration summaries, and roadmaps
- `tech_guides/` — Technical guides for deployment, testing, and integration
- `user_guides/` — User-facing documentation and tutorials
- `assets/` — Images, logos, and visual resources

## Documentation Standards

### Mermaid Diagrams

- Use Mermaid for all diagrams
- Include accessibility labels on all diagram elements
- Store in `architecture/MERMAID_DIAGRAMS.md` or inline in relevant docs

### ADRs (Architecture Decision Records)

- Store in `architecture/` directory
- Follow ADR template format
- Maintain historical versions - never delete or overwrite
- Include context, decision, consequences, and alternatives

### Versioning

- Update existing documentation when information changes
- **Exception**: ADRs maintain historical versions
- Add date stamps to major updates in planning docs

### File Naming

- Use `SCREAMING_SNAKE_CASE.md` for documentation files
- Be descriptive and specific
- Group related docs in appropriate subdirectories

## Writing Guidelines

- Write for yourself in 6 months
- Include concrete examples and code snippets
- Link to related docs using relative paths
- Keep technical accuracy over brevity
- Assume reader has context from AGENTS.md files
