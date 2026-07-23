import { google } from "googleapis";
import { User } from "../Models/user.models.js";
import { asyncHandler } from "../Helpers/asyncHandler.helpers.js";
import { getOAuth2Client } from "../Helpers/googleAuth.controller.js";

const scopes = [
    "https://www.googleapis.com/auth/gmail.readonly",
    "https://www.googleapis.com/auth/userinfo.profile",
    "https://www.googleapis.com/auth/userinfo.email"
];

export const getAuthUrl = asyncHandler(async (req, res) => {
    const oauth2Client = getOAuth2Client();
    const url = oauth2Client.generateAuthUrl({
        access_type: "offline",
        prompt: "consent",
        scope: scopes
    });

    return res.status(200).json({ url });
});

export const googleCallback = asyncHandler(async (req, res) => {
    const { code } = req.query;
    if (!code) {
        return res.status(400).json({ error: "Authorization code not provided" });
    }

    const oauth2Client = getOAuth2Client();
    const { tokens } = await oauth2Client.getToken(code);
    oauth2Client.setCredentials(tokens);

    const oauth2 = google.oauth2({
        auth: oauth2Client,
        version: "v2"
    });

    const { data: userInfo } = await oauth2.userinfo.get();

    let user = await User.findOne({
        $or: [{ email: userInfo.email }, { googleId: userInfo.id }]
    });

    if (!user) {
        user = new User({
            username: userInfo.email.split("@")[0],
            fullname: userInfo.name,
            email: userInfo.email,
            authType: "Google",
            googleId: userInfo.id,
            googleRefreshToken: tokens.refresh_token || null
        });
    } else {
        user.googleId = userInfo.id;
        user.email = userInfo.email;
        user.fullname = userInfo.name;
        user.authType = "Google";

        if (tokens.refresh_token) {
            user.googleRefreshToken = tokens.refresh_token;
        }
    }

    const accessToken = user.generateAccessToken();
    const refreshToken = user.generateRefreshToken();

    user.refreshToken = refreshToken;
    await user.save({ validateBeforeSave: false });

    return res
        .status(200)
        .cookie("accessToken", accessToken, { httpOnly: true, secure: true })
        .cookie("refreshToken", refreshToken, { httpOnly: true, secure: true })
        .json({
            message: "User authenticated successfully",
            accessToken,
            refreshToken
        });
});