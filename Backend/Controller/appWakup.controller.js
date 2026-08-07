import { CronJob } from "cron";

export const Job = new CronJob(
    "0 */14 * * * *",
    async function(){
        const req = await fetch("https://www.google.com/");
    },
    null,
    true,
    'Asia/Kolkata'
);