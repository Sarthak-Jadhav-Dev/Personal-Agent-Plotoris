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

    return [
        {
            role: "system",
            content: "You are an inbox analysis assistant. Review the given emails and user hooks. Return valid JSON only with the fields matchedHooks, summary, actions, and manualReview."
        },
        {
            role: "user",
            content: `User: ${userName}\n\nHooks:\n${hookText}\n\nSafe emails:\n${emailText}\n\nInstructions:\n- Find which hooks match the email content.\n- Summarize the important events in the emails.\n- Suggest short action items if something requires attention.\n- Return JSON only.`
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
            max_tokens: 500
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