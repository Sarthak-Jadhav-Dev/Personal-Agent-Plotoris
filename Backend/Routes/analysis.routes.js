import { analyseEmails } from "../Controller/aiAnalysis.controller.js";
import {Router} from 'express'
import {verifyJWT} from "../Middlewares/auth.middleware.js";
const router = Router();

router.use(verifyJWT)

router.route("/email").get(analyseEmails)

export default router