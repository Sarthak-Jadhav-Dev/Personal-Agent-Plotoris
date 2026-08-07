import { OAuth2Client } from "google-auth-library";
import { User } from "../Models/user.models.js";
import { asyncHandler } from "../Helpers/asyncHandler.helpers.js";

/**
 * POST /api/auth/google/mobile
 * Receives a Google ID token from the Flutter app (obtained via google_sign_in plugin),
 * verifies it server-side, creates or updates the user, and returns JWT tokens.
 */
export const googleMobileAuth = asyncHandler(async (req, res) => {
    const { idToken } = req.body;

    if (!idToken) {
        return res.status(400).json({ error: "Google ID token is required" });
    }

    // Verify the ID token with Google
    const client = new OAuth2Client(process.env.CLIENT_ID);
    const ticket = await client.verifyIdToken({
        idToken,
        audience: process.env.CLIENT_ID,
    });

    const payload = ticket.getPayload();
    if (!payload) {
        return res.status(401).json({ error: "Invalid Google ID token" });
    }

    const { sub: googleId, email, name } = payload;

    // Find existing user or create a new one
    let user = await User.findOne({
        $or: [{ email }, { googleId }],
    });

    if (!user) {
        user = new User({
            username: email.split("@")[0],
            fullname: name || email.split("@")[0],
            email,
            authType: "Google",
            googleId,
        });
    } else {
        user.googleId = googleId;
        user.email = email;
        user.fullname = name || user.fullname;
        user.authType = "Google";
    }

    const accessToken = user.generateAccessToken();
    const refreshToken = user.generateRefreshToken();

    user.refreshToken = refreshToken;
    await user.save({ validateBeforeSave: false });

    return res.status(200).json({
        message: "User authenticated successfully",
        accessToken,
        refreshToken,
        user: {
            id: user._id,
            username: user.username,
            fullname: user.fullname,
            email: user.email,
        },
    });
});
