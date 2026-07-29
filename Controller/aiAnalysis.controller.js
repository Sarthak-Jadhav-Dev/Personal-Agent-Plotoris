import { asyncHandler } from "../Helpers/asyncHandler.helpers.js";
import { getGoogleAccessToken } from "../Helpers/googleAuth.controller.js";
import { classifyEmailForAI } from "../Helpers/emailPrivacy.helpers.js";
import { viewHooks } from "./hooks.controller.js"
import { Features } from "../Models/inAppFeatures.models.js";


export const analyseEmails = asyncHandler(async (req,res)=>{
    let aiPrompt = "";
    let aiFinalPrompt = "";
    //get user
    const user = req.user;
    //get his mails 
    const userEmail = user.email;
    const maxEmails = Number(req.query.maxEmails || 10);
    const safeMaxEmails = Math.max(1, Math.min(maxEmails, 500));

    const accessToken = await getGoogleAccessToken(user.googleRefreshToken);

    const response = await fetch(
        `https://gmail.googleapis.com/gmail/v1/users/${userEmail}/messages?maxResults=${safeMaxEmails}`,
        {
            headers:{
                Authorization:`Bearer ${accessToken}`
            }
        }
    );

    const emails = await response.json();

    if(!response.ok){
        return res.status(response.status).json({
            messege: "Failed to fetch mails",
            error: emails.error || emails
        });
    }

    const mailDetails = [];

    for (const message of emails.messages || []) {
        const detailResponse = await fetch(
            `https://gmail.googleapis.com/gmail/v1/users/${userEmail}/messages/${message.id}`,
            {
                headers:{
                    Authorization:`Bearer ${accessToken}`
                }
            }
        );

        const detail = await detailResponse.json();

        if(!detailResponse.ok){
            continue;
        }
        // the mails with passwords or data should be not send as an input and can be flagged to manual checking 

        const classification = classifyEmailForAI(detail);

        mailDetails.push({
            id: message.id,
            threadId: detail.threadId,
            snippet: detail.snippet,
            safeToSend: classification.safeToSend,
            reason: classification.reason,
            preview: classification.preview
        });
    }

    return res.status(200).json({
        messege: "Mails fetched successfully",
        emails: mailDetails
    });
    //get his hooks 
    const hooksDoc = await Features.findOne({ user: user._id });
    //load the hooks
    if (hooksDoc.hooks != []){
        aiFinalPrompt = aiPrompt + aiFinalPrompt + hooksDoc.hooks;        
    }
    //then analyse mail 
    //  -Check if hooks are matched if yes then return them in hooks secttion 
    //  -Check if an event is their or if their is an immeditate action to be taken
})