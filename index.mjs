import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from "./build/index.main.mjs";
const stdlib = loadStdlib();

const startingBalance = stdlib.parseCurrency(100);
const accChinwe = await stdlib.newTestAccount(startingBalance);
const accEmeka = await stdlib.newTestAccount(startingBalance);

const ctcChinwe = accChinwe.contract(backend);
const ctcEmeka = accEmeka.contract(backend, ctcChinwe.getInfo());

await Promise.all([
    ctcChinwe.p.Chinwe({
        // implement Chinwe's interact object here
    }),
    ctcEmeka.p.Emeka({
        // implement Emeka's interact object here
    }),
]);
