import { Router } from "express";
import { getMails } from "../Controller/mails.controller.js";
import {verifyJWT} from "../Middlewares/auth.middlewares.js"

const mailRouter = Router();

mailRouter.route("/getMails").get(verifyJWT,getMails)

export default mailRouter;