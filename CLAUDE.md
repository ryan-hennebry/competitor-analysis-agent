# Competitor Intelligence Agent (V4.2)

An agent-native approach to competitive analysis — with required extraction, coverage transparency, and summary-first presentation.

## What Makes This Different

This agent doesn't follow a rigid workflow. It understands a goal and figures out how to achieve it. But it's also accountable for specific extraction dimensions — and presents them in a scannable format.

**V1 (Workflow):** "Probe these 6 page types, extract these 9 dimensions, follow these 8 phases." Best coverage, but rigid.

**V2 (Agent-Native):** "Understand the competitive landscape. Compare everything to me. Tell me what changed." Flexible, but missed signals.

**V3 (Agent-Native + Coverage):** V2's flexibility + coverage transparency. The agent reports what it found and missed. But extraction remained optional.

**V4:** Required extraction + flexible discovery + full transparency. Great extraction, but poor presentation — recommendations buried at line 103, 40% redundant content.

**V4.2 (This Version):** V4's extraction with summary-first presentation. Single file, recommendations in top third, details below the fold.

### The V4.2 Formula

```
V4.2 = V4's extraction + summary-first presentation
```

- **From V4:** Required extraction dimensions, gap accountability, coverage transparency
- **New:** Summary-first output — Quick Take, Recommendations, and What Changed scannable in 3-5 min
- **New:** Single file with clear divider — summary above, details below

### Why This Matters

V4 had the right extraction but the wrong presentation. Recommendations were buried at line 103. The briefing was 449 lines (15-18 min read) with ~40% redundant content. Internal QA was mixed with executive insights.

V4.2 fixes presentation without sacrificing coverage:
- Summary section (<100 lines) scannable in 3-5 minutes
- Recommendations appear by line 20-25
- Full extraction details below the fold for reference
- Coverage notes moved to end (internal QA, not exec-facing)

### Key V4.2 Additions

1. **Summary-First Structure** — Quick Take, Recommendations, What Changed, and Threat Landscape all appear before the divider.

2. **Clear Fold** — A `---` divider separates the executive summary from detailed reference material.

3. **Consolidated Details** — All per-competitor breakdowns consolidated into one "Details by Competitor" section below the fold.

4. **Presentation Principles** — Six rules the agent follows for output structure (lead with "so what", action before analysis, etc.)

5. **No Redundancy** — Executive Summary and Competitive Implications sections removed (redundant with Quick Take and Recommendations).

## Quick Start

1. Edit `competitors.md` — add your website and competitor URLs
2. Run: `./run.sh`
3. Find briefing in `output/briefings/`

## Configuration

### competitors.md

```markdown
# Competitor Analysis

## Your Company
mycompany.com

## Competitors
competitor-a.com
competitor-b.com
```

### context.md

Tell the agent what you care about and see the required dimensions:

```markdown
## Priorities
- Focus areas: Pricing changes, enterprise positioning
- Ignore: (nothing — all dimensions are required)

## Required Dimensions
### Positioning (Required)
- Hero headline and tagline
- Core value proposition
- Narrative bet

### Pricing (Required)
- Pricing model
- Specific tiers/costs
- Enterprise licensing signals
...
```

The agent reads this and adapts its analysis. After each run, it updates the **Coverage Notes** and **Open Questions** sections.

### delivery.md

Configure email and Slack delivery for automatic briefing distribution.

## What It Does

1. **Discovers** which pages matter for each competitor
2. **Extracts** all required dimensions (positioning, pricing, customers, GTM, hiring, recent moves)
3. **Reports** what it found, what it couldn't find, and which pages it checked
4. **Compares** everything relative to you
5. **Tracks changes** from previous runs
6. **Generates briefing** with pricing tables, GTM analysis, narrative bets, and recommendations
7. **Surfaces questions** — what you might want to investigate next
8. **Asks for follow-up** so you can dig deeper

## The Agent-Native Difference

From Dan Shipper's [agent-native architecture guide](https://every.to/guides/agent-native):

> "The ultimate test: Describe an outcome within your domain that you didn't explicitly build. Can the agent figure out how to accomplish it?"

Try asking this agent:
- "What are competitors saying about AI?"
- "Who's moving into our market segment?"
- "Deep dive on Competitor B's pricing strategy"
- "Investigate the open questions from the last briefing"

It can handle these even though they weren't pre-programmed — because it understands the goal, not just the steps.

## Files

- `competitors.md` — URLs to analyze
- `context.md` — Priorities, required dimensions, coverage notes, open questions
- `delivery.md` — Email/Slack settings
- `.claude/agents/competitor_intel.md` — Agent definition
- `output/snapshots/` — Competitor data
- `output/briefings/` — Generated briefings

## Scheduling

To run automatically every Sunday at 8pm:

```bash
(crontab -l 2>/dev/null; echo "0 20 * * 0 cd $(pwd) && ./run.sh >> output/logs/cron.log 2>&1") | crontab -
```

## Status Check

Run `./status.sh` to see:
- Last briefing date
- Number of competitors tracked
- Agent status (running/idle)

## Evolution

This is the fifth iteration of the competitive intelligence agent:

| Version | Approach | Strength | Weakness |
|---------|----------|----------|----------|
| V1 | Workflow-based | Reliable coverage, caught all signals | Rigid, can't adapt to follow-ups |
| V2 | Agent-native | Flexible, emergent capability | Missed some signals (pricing, GTM) |
| V3 | Agent-native + coverage | Flexible AND transparent | Extraction still optional |
| V4 | Agent-native + required extraction | V1 coverage + V3 flexibility + full transparency | Poor presentation (449 lines, recs at line 103) |
| V4.2 | V4 + summary-first | Same extraction, scannable in 3-5 min | You're using it now |

The key insight: Extraction and presentation are separate problems. V4 solved extraction with required dimensions. V4.2 solves presentation with summary-first structure.
