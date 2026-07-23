import { Router } from "express";
import {setHooks,viewHooks,deleteHooks} from "../Controller/hooks.controller.js"
import {verifyJWT} from "../Middlewares/auth.middlewares.js"

const hooksRouter = Router();

hooksRouter.route("/setHook").put(verifyJWT,setHooks);
hooksRouter.route("/getHooks").get(verifyJWT,viewHooks);
hooksRouter.route("/deleteHook").delete(verifyJWT,deleteHooks)

export default hooksRouter;