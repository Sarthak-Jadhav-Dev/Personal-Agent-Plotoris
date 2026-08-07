import { asyncHandler } from "../Helpers/asyncHandler.helpers.js";
import { getGoogleAccessToken } from "../Helpers/googleAuth.controller.js";
import { classifyEmailForAI } from "../Helpers/emailPrivacy.helpers.js";
import { Features } from "../Models/inAppFeatures.models.js";

const buildAiPrompt = ({ userName, safeEmails, hooks }) => {
    const hookText = hooks.length
        ? hooks.map((hook) => `- ${hook.hook_name}: ${hook.hook_value} (${hook.hook_description})`).join("\n")
        : "No hooks configured.";

    const emailText = safeEmails.length
        ? safeEmails.map((mail) => `- ${mail.id}: ${mail.preview || mail.snippet || "No preview available"}`).join("\n")
        : "No safe emails available to analyze.";

    const responseSchema = `{
  "matchedHooks": [{ "hookName": string, "emailId": string, "reason": string }],
  "emails": [
    {
      "emailId": string,
      "summary": string,
      "priority": number (1=low, 2=normal, 3=medium, 4=high, 5=urgent),
      "category": string (one of: "finance", "work", "education", "social", "promotions", "travel", "health", "government", "subscriptions", "personal", "other"),
      "deadline": string | null (ISO date like "2026-08-09" or null if none),
      "deadlineLabel": string | null (human-readable like "Register before Aug 9" or null),
      "actionRequired": boolean,
      "action": string | null (short action description if actionRequired is true, else null)
    }
  ],
  "overallSummary": string,
  "manualReview": [string]
}`;

    return [
        {
            role: "system",
            content: `You are an intelligent inbox analysis assistant. Analyze emails and return a structured JSON response. Be precise with priority scoring, category assignment, and deadline extraction. Today's date is ${new Date().toISOString().split("T")[0]}. Return valid JSON only matching this exact schema:\n${responseSchema}`
        },
        {
            role: "user",
            content: `User: ${userName}\n\nHooks:\n${hookText}\n\nSafe emails:\n${emailText}\n\nInstructions:\n- Match hooks against email content and explain why.\n- For EACH email, provide: a concise summary, priority score (1-5), category, deadline (extract any dates/deadlines mentioned), and whether action is required with a short action description.\n- Priority guide: 1=newsletter/promo, 2=informational, 3=needs attention soon, 4=important/time-sensitive, 5=urgent/immediate action.\n- Extract deadlines from phrases like "due by", "expires on", "register before", "deadline", "last date", "submit by", etc.\n- Provide an overall summary of the inbox state.\n- Flag emails needing manual review.\n- Return JSON only, no markdown.`
        }
    ];
};

const callOpenRouter = async (messages) => {
    const apiKey = process.env.OPENROUTER_API_KEY;

    if (!apiKey) {
        throw new Error("OPENROUTER_API_KEY is not configured.");
    }

    const response = await fetch("https://openrouter.ai/api/v1/chat/completions", {
        method: "POST",
        headers: {
            Authorization: `Bearer ${apiKey}`,
            "Content-Type": "application/json",
            "HTTP-Referer": process.env.OPENROUTER_REFERER || "http://localhost:8000",
            "X-Title": process.env.OPENROUTER_TITLE || "Scheduler Backend"
        },
        body: JSON.stringify({
            model: process.env.OPENROUTER_MODEL || "openrouter/free",
            messages,
            temperature: 0.2,
            max_tokens: 1200
        })
    });

    if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`OpenRouter request failed: ${response.status} ${errorText}`);
    }

    const data = await response.json();
    return data?.choices?.[0]?.message?.content || "{}";
};

export const analyseEmails = asyncHandler(async (req, res) => {
    const user = req.user;
    const userEmail = user.email;
    const maxEmails = Number(req.query.maxEmails || 10);
    const safeMaxEmails = Math.max(1, Math.min(maxEmails, 500));

    const accessToken = await getGoogleAccessToken(user.googleRefreshToken);

    const response = await fetch(
        `https://gmail.googleapis.com/gmail/v1/users/${userEmail}/messages?maxResults=${safeMaxEmails}`,
        {
            headers: {
                Authorization: `Bearer ${accessToken}`
            }
        }
    );

    const emails = await response.json();

    if (!response.ok) {
        return res.status(response.status).json({
            messege: "Failed to fetch mails",
            error: emails.error || emails
        });
    }

    const mailDetails = [];
    const safeEmails = [];
    const flaggedEmails = [];

    for (const message of emails.messages || []) {
        const detailResponse = await fetch(
            `https://gmail.googleapis.com/gmail/v1/users/${userEmail}/messages/${message.id}`,
            {
                headers: {
                    Authorization: `Bearer ${accessToken}`
                }
            }
        );

        const detail = await detailResponse.json();

        if (!detailResponse.ok) {
            continue;
        }

        const classification = classifyEmailForAI(detail);
        const normalizedMail = {
            id: message.id,
            threadId: detail.threadId,
            snippet: detail.snippet,
            safeToSend: classification.safeToSend,
            reason: classification.reason,
            preview: classification.preview
        };

        mailDetails.push(normalizedMail);

        if (classification.safeToSend) {
            safeEmails.push(normalizedMail);
        } else {
            flaggedEmails.push(normalizedMail);
        }
    }

    const hooksDoc = await Features.findOne({ user: user._id });
    const hooks = hooksDoc?.hooks || [];

    let aiAnalysis = null;

    if (safeEmails.length > 0) {
        try {
            const prompt = buildAiPrompt({
                userName: user.username || user.email,
                safeEmails,
                hooks
            });

            const aiResponseText = await callOpenRouter(prompt);
            aiAnalysis = JSON.parse(aiResponseText);
        } catch (error) {
            aiAnalysis = {
                error: error.message,
                raw: null
            };
        }
    }

    return res.status(200).json({
        messege: "Mails fetched successfully",
        emails: mailDetails,
        safeEmails,
        flaggedEmails,
        hooks,
        aiAnalysis
    });
});