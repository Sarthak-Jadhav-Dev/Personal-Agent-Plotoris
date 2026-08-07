import { CronJob } from "cron";
import { User } from "../Models/user.models.js";

const BASE_URL = process.env.BASE_URL || `http://localhost:${process.env.PORT || 8000}`;

/**
 * Cron job that runs every 14 minutes to:
 * 1. Keep the server alive (prevents free-tier hosting from sleeping)
 * 2. Trigger email analysis for all active users with Google tokens
 */
export const Job = new CronJob(
    "*/14 * * * *",
    async function () {
        const timestamp = new Date().toISOString();
        console.log(`[CRON ${timestamp}] Wakeup & scan cycle started`);

        // ── 1. Self-ping to keep alive ──────────────────────────────
        try {
            await fetch(`${BASE_URL}/api/auth/google/url`);
            console.log(`[CRON] Self-ping successful`);
        } catch (err) {
            console.log(`[CRON] Self-ping failed: ${err.message}`);
        }

        // ── 2. Scan emails for all active users ─────────────────────
        try {
            const users = await User.find({
                googleRefreshToken: { $exists: true, $ne: null }
            });

            console.log(`[CRON] Found ${users.length} user(s) with Google tokens`);

            for (const user of users) {
                try {
                    // Generate a short-lived access token for this user
                    const accessToken = user.generateAccessToken();

                    // Call our own analysis endpoint with the user's token
                    const response = await fetch(`${BASE_URL}/api/analysis/email?maxEmails=10`, {
                        method: "GET",
                        headers: {
                            Authorization: `Bearer ${accessToken}`,
                            "Content-Type": "application/json"
                        }
                    });

                    if (response.ok) {
                        console.log(`[CRON] ✓ Scanned emails for ${user.email}`);
                    } else {
                        const errBody = await response.text();
                        console.log(`[CRON] ✗ Scan failed for ${user.email}: ${response.status} ${errBody.slice(0, 200)}`);
                    }
                } catch (userErr) {
                    console.log(`[CRON] ✗ Error scanning ${user.email}: ${userErr.message}`);
                }
            }
        } catch (dbErr) {
            console.log(`[CRON] DB query failed: ${dbErr.message}`);
        }

        console.log(`[CRON ${timestamp}] Cycle complete`);
    },
    null,
    true,
    "Asia/Kolkata"
);