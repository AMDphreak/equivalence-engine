# Evolution Engine Expansion: Filesystem Equivalence Mapping

The goal is to extend the `evolution-engine` to model "filesystem-level path equivalencies" for Linux distros. This allows installer scripts to query an *Intent* (e.g., `lib_dir`) for a specific *Context* (e.g., `Ubuntu 22.04`) and receive the actual path.

## Generic Naming Proposal

If we want to make this even more generic (not just code evolution, but cross-context identity), we could call it:

1. **The Equivalence Engine** (Clean, direct, matches user terminology)
2. **The Convergence Engine** (Converges multiple literal realities into one intent)
3. **Continuum Engine** (Suggests both versioning and contextual spanning)
4. **Prism Engine** (One intent refracted into many contextual instances)

> [!TIP]
> **Continuum** or **Prism** feel very "on brand" for AMDphreak's ecosystem, suggesting a multi-dimensional mapping of reality (versions + distros).

## Proposed Architecture

We will implement a **Directed Acyclic Graph (DAG)** of **Identities** where:
- **Nodes** represent either **Contexts** (Distros/Versions) or **Intents** (Purposes).
- **Edges** represent **Evolution** (Version A -> Version B) or **Implementation** (Intent X -> Literal Path Y).

### 1. Context Hierarchy (In SDL)
We can define a hierarchy so that specific distros can inherit mappings from their parents.

```sdl
context "debian" "Debian Base"
context "ubuntu" "Ubuntu Base" {
    inherits "debian"
}
context "ubuntu-22.04" "Jammy" {
    inherits "ubuntu"
}
```

### 2. Intent-Based Mappings
A "Purpose" (Intent) node defines how it maps to literal paths across different contexts.

```sdl
intent "system-service-dir" {
    mapping "debian" "/lib/systemd/system"
    mapping "fedora" "/usr/lib/systemd/system"
    mapping "alpine" "/etc/init.d" // (OpenRC fallback)
}
```

### 3. Query Logic
The engine will support queries like:
`resolve "system-service-dir" --context "ubuntu-22.04"`

1. Search for a direct mapping in `ubuntu-22.04`.
2. If not found, traverse the inheritance tree (`ubuntu` -> `debian`).
3. Return the first matching literal path.

### 4. Evolution Path for Intents
If an intent's location changes *within* a distro's history:
```sdl
intent "pkg-config-dir" {
    mapping "ubuntu-20.04" "/etc/default"
    mapping "ubuntu-22.04" "/etc/sysconfig" // example change
}
```

## Verification Plan

### Automated Tests
- [ ] Define a mock context tree (Debian -> Ubuntu -> 22.04).
- [ ] Resolve an intent that exists only in the parent (Debian).
- [ ] Resolve an intent that is overridden in the leaf (22.04).
- [ ] Verify that non-existent intents return an error or fallback.

### Manual Verification
- [ ] Use the CLI to query a real-world mapping (e.g., `systemd_service_dir`) across Ubuntu and Alpine snippets.
