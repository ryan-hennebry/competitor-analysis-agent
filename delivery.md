# Delivery Setup

Briefings are always saved to `output/briefings/`. Configure email and/or Slack below to receive them automatically.

## Email Delivery (Resend)

Sends PDF attachment with HTML summary.

```
email: you@example.com
resend_api_key: re_your_api_key_here
```

## Slack Delivery

Uploads PDF with summary message to a channel.

```
slack_bot_token: xoxb-your_token_here
slack_channel_id: your_channel_id
```

---

## Setup Instructions

### Email (Resend)
1. Create account at [resend.com](https://resend.com)
2. Create API key in dashboard
3. Add `email:` and `resend_api_key:` above

### Slack
1. Go to [api.slack.com/apps](https://api.slack.com/apps)
2. Create or select your app
3. Add Bot Token Scopes: `files:write`, `chat:write`
4. Install to workspace
5. Copy Bot User OAuth Token (`xoxb-...`)
6. Get channel ID (right-click channel → View details → scroll to bottom)
7. Invite bot to channel: `/invite @YourBotName`
8. Add `slack_bot_token:` and `slack_channel_id:` above
