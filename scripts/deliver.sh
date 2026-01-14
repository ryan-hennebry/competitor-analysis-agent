#!/bin/bash
# Deliver the latest briefing via email and Slack with comprehensive summary

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SCRIPT_DIR"

# Find the latest briefing
LATEST_MD=$(ls -t output/briefings/*.md 2>/dev/null | head -1)
LATEST_PDF=$(ls -t output/briefings/*.pdf 2>/dev/null | head -1)

if [ -z "$LATEST_MD" ]; then
    echo "No briefing found in output/briefings/"
    exit 1
fi

DATE=$(basename "$LATEST_MD" .md)
echo "Delivering briefing: $DATE"

# Parse delivery.md for credentials
parse_config() {
    grep "^$1:" delivery.md 2>/dev/null | sed 's/^[^:]*: *//' | tr -d ' '
}

EMAIL=$(parse_config "email")
RESEND_API_KEY=$(parse_config "resend_api_key")
SLACK_BOT_TOKEN=$(parse_config "slack_bot_token")
SLACK_CHANNEL_ID=$(parse_config "slack_channel_id")

# Extract Quick Take (full paragraph)
QUICK_TAKE=$(sed -n '/^## Quick Take$/,/^---$/p' "$LATEST_MD" | sed '1d;$d' | sed '/^$/d' | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')

# Helper to strip citations [n] from text
strip_citations() {
    echo "$1" | sed 's/\[[0-9]*\]//g' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//'
}

# Extract Changes table rows (skip header)
CHANGES_RAW=$(sed -n '/^## Changes Since Last Run$/,/^---$/p' "$LATEST_MD" | grep "^|" | tail -n +3)

# Extract all recommendations by section
extract_recommendations() {
    local section="$1"
    sed -n "/^### $section$/,/^###/p" "$LATEST_MD" | grep -E "^\d+\." | head -3
}

ACT_NOW=$(extract_recommendations "Act Now")
WATCH=$(extract_recommendations "Watch")
OPPORTUNITY=$(extract_recommendations "Opportunity")

# Fallback: if no grouped format, try old format
if [ -z "$ACT_NOW" ]; then
    ACT_NOW=$(sed -n '/^## Recommendations$/,/^---$/p' "$LATEST_MD" | grep -E "^\d+\. \*\*.*Act Now" | head -3)
    WATCH=$(sed -n '/^## Recommendations$/,/^---$/p' "$LATEST_MD" | grep -E "^\d+\. \*\*.*Watch" | head -2)
    OPPORTUNITY=$(sed -n '/^## Recommendations$/,/^---$/p' "$LATEST_MD" | grep -E "^\d+\. \*\*.*Opportunity" | head -2)
fi

# Helper to format recommendation for HTML - strip emoji, urgency prefixes, and citations
format_rec_html() {
    local line="$1"
    # Extract title (between **) and description (after —), strip emoji and urgency prefixes
    local title=$(echo "$line" | sed 's/^[0-9]*\. \*\*\([^*]*\)\*\*.*/\1/' | sed 's/^[^A-Za-z]*//' | sed 's/^Act Now: //' | sed 's/^Watch: //' | sed 's/^Opportunity: //')
    local desc=$(echo "$line" | sed 's/^[0-9]*\. \*\*[^*]*\*\* — //' | sed 's/\*Next step:/\<em\>Next step:/' | sed 's/\*$/\<\/em\>/' | sed 's/\[[0-9]*\]//g')
    echo "<li><strong>$title</strong> — $desc</li>"
}

# Helper to format recommendation for Slack - strip emoji, urgency prefixes, and citations
format_rec_slack() {
    local line="$1"
    local title=$(echo "$line" | sed 's/^[0-9]*\. \*\*\([^*]*\)\*\*.*/\1/' | sed 's/^[^A-Za-z]*//' | sed 's/^Act Now: //' | sed 's/^Watch: //' | sed 's/^Opportunity: //')
    local desc=$(echo "$line" | sed 's/^[0-9]*\. \*\*[^*]*\*\* — //' | sed 's/\*Next step:/_Next step:/' | sed 's/\*$/_/' | sed 's/\[[0-9]*\]//g')
    echo "• *$title* — $desc"
}

# Build HTML for email - clean, no emojis or colors
build_email_html() {
    cat <<EOF
<div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; color: #333;">
  <h2 style="border-bottom: 1px solid #ddd; padding-bottom: 10px;">Competitor Analysis Briefing — $DATE</h2>

  <h3>Summary</h3>
  <p style="line-height: 1.6;">$(strip_citations "$QUICK_TAKE")</p>

  <h3>Changes Since Last Run</h3>
  <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
    <tr style="background: #f5f5f5;">
      <th style="text-align: left; padding: 8px; border-bottom: 1px solid #ddd;">Competitor</th>
      <th style="text-align: left; padding: 8px; border-bottom: 1px solid #ddd;">What Changed</th>
      <th style="text-align: left; padding: 8px; border-bottom: 1px solid #ddd;">Significance</th>
    </tr>
EOF

    echo "$CHANGES_RAW" | while IFS='|' read -r _ competitor change significance _; do
        competitor=$(echo "$competitor" | sed 's/^ *//;s/ *$//')
        change=$(strip_citations "$(echo "$change" | sed 's/^ *//;s/ *$//')")
        significance=$(echo "$significance" | sed 's/^ *//;s/ *$//')
        if [ -n "$competitor" ]; then
            echo "    <tr><td style=\"padding: 8px; border-bottom: 1px solid #eee;\">$competitor</td><td style=\"padding: 8px; border-bottom: 1px solid #eee;\">$change</td><td style=\"padding: 8px; border-bottom: 1px solid #eee;\">$significance</td></tr>"
        fi
    done

    cat <<EOF
  </table>

  <h3>Recommendations</h3>

  <h4>Act Now</h4>
  <ul style="line-height: 1.8;">
EOF

    echo "$ACT_NOW" | while read -r line; do
        if [ -n "$line" ]; then
            format_rec_html "$line"
        fi
    done

    echo "  </ul>"

    if [ -n "$WATCH" ]; then
        cat <<EOF
  <h4>Watch</h4>
  <ul style="line-height: 1.8;">
EOF
        echo "$WATCH" | while read -r line; do
            if [ -n "$line" ]; then
                format_rec_html "$line"
            fi
        done
        echo "  </ul>"
    fi

    if [ -n "$OPPORTUNITY" ]; then
        cat <<EOF
  <h4>Opportunity</h4>
  <ul style="line-height: 1.8;">
EOF
        echo "$OPPORTUNITY" | while read -r line; do
            if [ -n "$line" ]; then
                format_rec_html "$line"
            fi
        done
        echo "  </ul>"
    fi

    cat <<EOF

  <p style="margin-top: 24px; padding-top: 16px; border-top: 1px solid #ddd; color: #666; font-size: 13px;">
    Full briefing attached as PDF with references included.
  </p>
</div>
EOF
}

# Build Slack message - clean, no emojis or citations
build_slack_message() {
    echo "*Competitor Analysis Briefing — $DATE*"
    echo ""
    echo "*Summary*"
    echo "$(strip_citations "$QUICK_TAKE")"
    echo ""
    echo "*Changes*"

    echo "$CHANGES_RAW" | while IFS='|' read -r _ competitor change significance _; do
        competitor=$(echo "$competitor" | sed 's/^ *//;s/ *$//')
        change=$(strip_citations "$(echo "$change" | sed 's/^ *//;s/ *$//')")
        significance=$(echo "$significance" | sed 's/^ *//;s/ *$//')
        if [ -n "$competitor" ]; then
            echo "• *$competitor:* $change — _$significance_"
        fi
    done

    echo ""
    echo "*Recommendations*"
    echo ""
    echo "_Act Now_"
    echo "$ACT_NOW" | while read -r line; do
        if [ -n "$line" ]; then
            format_rec_slack "$line"
        fi
    done

    if [ -n "$WATCH" ]; then
        echo ""
        echo "_Watch_"
        echo "$WATCH" | while read -r line; do
            if [ -n "$line" ]; then
                format_rec_slack "$line"
            fi
        done
    fi

    if [ -n "$OPPORTUNITY" ]; then
        echo ""
        echo "_Opportunity_"
        echo "$OPPORTUNITY" | while read -r line; do
            if [ -n "$line" ]; then
                format_rec_slack "$line"
            fi
        done
    fi

    echo ""
    echo "Full briefing attached as PDF with references included."
}

# Email delivery
if [ -n "$EMAIL" ] && [ -n "$RESEND_API_KEY" ] && [ "$EMAIL" != "you@example.com" ]; then
    echo "Sending email to $EMAIL..."

    if [ -n "$LATEST_PDF" ]; then
        PDF_BASE64=$(base64 -i "$LATEST_PDF")
        EMAIL_HTML=$(build_email_html)

        RESPONSE=$(curl -s -X POST https://api.resend.com/emails \
            -H "Authorization: Bearer $RESEND_API_KEY" \
            -H "Content-Type: application/json" \
            -d "$(jq -n \
                --arg to "$EMAIL" \
                --arg subject "Competitor Analysis Briefing — $DATE" \
                --arg html "$EMAIL_HTML" \
                --arg pdf "$PDF_BASE64" \
                --arg filename "competitor-analysis-$DATE.pdf" \
                '{
                    "from": "briefings@resend.dev",
                    "to": $to,
                    "subject": $subject,
                    "html": $html,
                    "attachments": [{"filename": $filename, "content": $pdf}]
                }')")

        if echo "$RESPONSE" | grep -q '"id"'; then
            echo "✓ Email delivered"
        else
            echo "✗ Email failed: $RESPONSE"
        fi
    else
        echo "✗ No PDF found for email attachment"
    fi
else
    echo "⚠ Email not configured (update delivery.md)"
fi

# Slack delivery
if [ -n "$SLACK_BOT_TOKEN" ] && [ -n "$SLACK_CHANNEL_ID" ] && [ "$SLACK_BOT_TOKEN" != "xoxb-your_token_here" ]; then
    echo "Sending to Slack..."

    if [ -n "$LATEST_PDF" ]; then
        SLACK_MSG=$(build_slack_message)

        # Get upload URL
        UPLOAD_URL_RESPONSE=$(curl -s -X POST "https://slack.com/api/files.getUploadURLExternal" \
            -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
            -H "Content-Type: application/x-www-form-urlencoded" \
            -d "filename=competitor-analysis-$DATE.pdf&length=$(wc -c < "$LATEST_PDF" | tr -d ' ')")

        UPLOAD_URL=$(echo "$UPLOAD_URL_RESPONSE" | jq -r '.upload_url // empty')
        FILE_ID=$(echo "$UPLOAD_URL_RESPONSE" | jq -r '.file_id // empty')

        if [ -n "$UPLOAD_URL" ] && [ -n "$FILE_ID" ]; then
            # Upload the file
            curl -s -X POST "$UPLOAD_URL" \
                -F "file=@$LATEST_PDF"

            # Complete upload with message
            COMPLETE_RESPONSE=$(curl -s -X POST "https://slack.com/api/files.completeUploadExternal" \
                -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
                -H "Content-Type: application/json" \
                -d "$(jq -n \
                    --arg channel "$SLACK_CHANNEL_ID" \
                    --arg file_id "$FILE_ID" \
                    --arg message "$SLACK_MSG" \
                    '{
                        "files": [{"id": $file_id}],
                        "channel_id": $channel,
                        "initial_comment": $message
                    }')")

            if echo "$COMPLETE_RESPONSE" | grep -q '"ok":true'; then
                echo "✓ Slack delivered"
            else
                echo "✗ Slack failed: $COMPLETE_RESPONSE"
            fi
        else
            echo "✗ Slack upload URL failed: $UPLOAD_URL_RESPONSE"
        fi
    else
        echo "✗ No PDF found for Slack upload"
    fi
else
    echo "⚠ Slack not configured (update delivery.md)"
fi

echo ""
echo "Done."
