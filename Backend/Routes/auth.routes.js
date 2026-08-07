import { Router } from "express";
import { getAuthUrl, googleCallback } from "../Controller/authenticate.controller.js";

const authRouter = Router();

authRouter.route("/google/url").get(getAuthUrl)
authRouter.route("/google/callback").get(googleCallback)

export default authRouter;
