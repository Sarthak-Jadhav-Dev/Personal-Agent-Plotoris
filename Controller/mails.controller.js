import { asyncHandler } from "../Helpers/asyncHandler.helpers.js"
import { getGoogleAccessToken } from "../Helpers/googleAuth.controller.js";

export const getMails = asyncHandler(async (req,res)=>{
    const user = req.user;
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

    return res.status(200).json({
        messege: "Mails fetched successfully",
        emails: emails.messages || []
    });
})

// sample output from documentsations
// {
//   "messages": [
//     {
//       object (Message)
//     }
//   ],
//   "nextPageToken": string,
//   "resultSizeEstimate": integer
// }