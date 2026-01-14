I need write permission to save the README. Here's the content — please grant write access or copy it directly:

```markdown
# Competitor Analysis Agent

Your competitors changed their pricing last week. A new player entered your market. Someone's hero headline now sounds a lot like yours. You found out three months later.

This agent monitors your competitive landscape and tells you what changed — with specific quotes, sources, and recommendations you can act on.

## Example Output

```markdown
# Competitor Intelligence Briefing — 2025-01-14

## Quick Take
Competitor A shifted messaging from "developer tools" to "enterprise platform" —
direct collision with your positioning. Their new pricing page shows 40% enterprise
discount, suggesting aggressive land-and-expand. Recommend updating comparison page
and monitoring their enterprise customer announcements.

## Recommendations

### ⚠️ Act Now
1. **Update comparison page** — Competitor A's new "enterprise-ready" claim
   overlaps your hero. *Next step: Add feature matrix showing your advantages.*

### 👀 Watch
2. **Competitor B pricing experiment** — Removed free tier from homepage
   (still accessible via direct link). May signal pivot to paid-only.

### 💡 Opportunity
3. **Gap in AI narrative** — No competitor mentions on-premise deployment.
   You offer it. *Next step: Add to homepage.*

## What Changed
| Company | Change | Significance | Action |
|---------|--------|--------------|--------|
| Competitor A | Hero: "For developers" → "Enterprise platform" | Direct positioning overlap | ⚠️ |
| Competitor A | +3 enterprise logos (Airbus, Bosch, MasterCard) | Validating enterprise push | 👀 |
| Competitor B | Free tier hidden from navigation | Possible monetization shift | 👀 |
| Your Company | No changes detected | — | — |

## Threat Landscape
| Competitor | Threat | Trend | Key Gap You Exploit |
|------------|--------|-------|---------------------|
| Competitor A | HIGH | ↑ | No on-premise option |
| Competitor B | MEDIUM | → | Weaker enterprise story |
| Competitor C | LOW | ↓ | Limited integrations |
```

## Quick Start

1. **Edit `competitors.md`** — Add your website URL and competitors
2. **Run `./run.sh`** — Agent analyzes all competitors
3. **Read `output/briefings/`** — Get your briefing with recommendations

## What It Does

- **Discovers** which pages matter (pricing, about, customers, careers, blog)
- **Extracts** positioning, pricing, customers, GTM signals, hiring, recent moves
- **Compares** everything relative to your company
- **Tracks changes** from previous runs
- **Recommends** specific actions based on competitive shifts
- **Reports gaps** — what it couldn't find and where it looked

## Configuration

### competitors.md

Your company first, then competitors:

```markdown
# Competitor Analysis

## Your Company
acme.com

## Competitors
competitor-a.com
competitor-b.com
competitor-c.com
```

### context.md

Tell the agent what you care about:

```markdown
## Your Company
- **Positioning:** AI-powered analytics for growth teams
- **ICP:** Series A-C startups, 50-500 employees
- **Key differentiators:** Real-time insights, no-code setup

## Priorities
- **Focus areas:**
  - Watch for pricing changes
  - Track enterprise positioning
- **Ignore:**
  - Don't care about hiring signals right now
```

The agent weights analysis based on your priorities and updates coverage notes after each run.

### delivery.md

Auto-deliver briefings via email or Slack:

```markdown
## Email Delivery (Resend)
email: you@example.com
resend_api_key: re_your_api_key_here

## Slack Delivery
slack_bot_token: xoxb-your_token_here
slack_channel_id: C01234567
```

## File Structure

```
competitor-analysis-agent/
├── competitors.md          # URLs to analyze
├── context.md              # Your priorities and tracking
├── delivery.md             # Email/Slack settings
├── run.sh                  # Main entry point
├── status.sh               # Check agent status
├── .claude/
│   └── agents/
│       └── competitor_intel.md   # Agent definition
├── output/
│   ├── briefings/          # Generated briefings (markdown + PDF)
│   └── snapshots/          # Competitor data for change tracking
└── scripts/
    ├── deliver.sh          # Email/Slack delivery
    └── generate_pdf.py     # PDF generation
```

## Automation

Run every Sunday at 8pm:

```bash
(crontab -l 2>/dev/null; echo "0 20 * * 0 cd $(pwd) && ./run.sh >> output/logs/cron.log 2>&1") | crontab -
```

Check status anytime:

```bash
./status.sh
```

```
═══════════════════════════════════════════
COMPETITOR INTELLIGENCE AGENT STATUS
═══════════════════════════════════════════
Last briefing: 2025-01-14
Competitors tracked: 3
Agent status: Idle
═══════════════════════════════════════════
```

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- Internet access for web fetching
- Python 3.x (for PDF generation)

## Follow-Up

After a briefing, ask the agent to dig deeper:

- "What are competitors saying about AI?"
- "Deep dive on Competitor B's pricing strategy"
- "Investigate the open questions from the last briefing"

It can handle these because it understands the goal, not just the steps.

## License

MIT
```