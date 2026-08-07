const decodeBase64Data = (data) => {
    if (!data) return "";

    const normalized = data.replace(/-/g, "+").replace(/_/g, "/");
    const padding = normalized.length % 4;
    const padded = padding ? normalized + "=".repeat(4 - padding) : normalized;

    return Buffer.from(padded, "base64").toString("utf8");
};

const extractEmailText = (payload = {}) => {
    const texts = [];

    if (payload?.headers?.length) {
        const subjectHeader = payload.headers.find((header) => header.name?.toLowerCase() === "subject");
        if (subjectHeader?.value) {
            texts.push(`Subject: ${subjectHeader.value}`);
        }
    }

    const visitNode = (node) => {
        if (!node) return;

        if (node.body?.data) {
            texts.push(decodeBase64Data(node.body.data));
        }

        if (Array.isArray(node.parts)) {
            node.parts.forEach(visitNode);
        }
    };

    visitNode(payload);

    return texts.filter(Boolean).join("\n\n");
};

export const classifyEmailForAI = (message) => {
    const text = extractEmailText(message?.payload);

    if (!text.trim()) {
        return {
            safeToSend: true,
            reason: null,
            preview: ""
        };
    }

    const sensitivePatterns = [
        /\bpassword\b\s*[:=]/i,
        /\bpwd\b\s*[:=]/i,
        /\bpasscode\b/i,
        /\bsecret\b/i,
        /\bapi[_ -]?key\b/i,
        /\baccess[_ -]?token\b/i,
        /\brefresh[_ -]?token\b/i,
        /\bauthorization\b/i,
        /\bbearer\b/i,
        /\bjwt\b/i,
        /\botp\b/i,
        /\bverification code\b/i,
        /\bone[- ]time password\b/i,
        /\bsecurity code\b/i,
        /\bpin\b/i,
        /\bssn\b/i,
        /\bsocial security\b/i,
        /\bcredit card\b/i,
        /\bcard number\b/i,
        /\baccount number\b/i,
        /\biban\b/i,
        /\bbank account\b/i,
        /\brouting number\b/i,
        /\bpassport\b/i,
        /\bdriver's? license\b/i,
        /\bphone number\b/i,
        /\bemail address\b/i,
        /\bhome address\b/i,
        /\bstreet\b/i,
        /\bapt\b/i,
        /\bsuite\b/i,
        /\bzip code\b/i,
        /your\s+password\s+is/i,
        /new\s+password/i,
        /(?:https?:\/\/[^\s]+(?:token|key|secret|password)[^\s]*)/i,
        /(?:eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+)/
    ];

    const strictNumberPatterns = [
        /\+?\d{1,3}[-.\s]?\(?\d{2,4}\)?[-.\s]?\d{3,4}[-.\s]?\d{3,4}/,
        /\b(?:\d{4}[-\s]?){3}\d{4}\b/
    ];

    const isSensitive = sensitivePatterns.some((pattern) => pattern.test(text)) ||
        (strictNumberPatterns.some((pattern) => pattern.test(text)) && /\b(card|account|phone|mobile|otp|code|token|secret|password|number)\b/i.test(text));

    const previewText = text.replace(/\s+/g, " ").trim();

    return {
        safeToSend: !isSensitive,
        reason: isSensitive ? "Possible sensitive personal or credential content" : null,
        preview: isSensitive ? "[sensitive content omitted]" : previewText.slice(0, 300)
    };
};
