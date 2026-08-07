import { Router } from "express";
import { getAuthUrl, googleCallback } from "../Controller/authenticate.controller.js";
import { googleMobileAuth } from "../Controller/localAuth.controller.js";

const authRouter = Router();

authRouter.route("/google/url").get(getAuthUrl)
authRouter.route("/google/callback").get(googleCallback)
authRouter.route("/google/mobile").post(googleMobileAuth)

export default authRouter;
